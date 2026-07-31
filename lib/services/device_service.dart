import 'dart:async';
import 'dart:io';
import 'package:process_run/process_run.dart';
import 'package:path/path.dart' as p;
import '../config/constants.dart';
import '../models/device_info.dart';
import '../generated/l10n.dart';

typedef LogCallback = void Function(String line);

class DeviceService {
  Future<List<DeviceInfo>> getAdbDevices({LogCallback? onLog}) async {
    try {
      if (!await File(Constants.adbPath).exists()) {
        onLog?.call(S.current.errAdbNotExist(Constants.adbPath));
        return [];
      }
      final result = await _runAdb(['devices'], onLog: onLog);
      final lines = result.stdout.toString().split('\n');
      final devices = <DeviceInfo>[];
      
      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty || line.contains('List of devices')) continue;
        if (line.contains('\t')) {
          final device = DeviceInfo.fromAdbLine(line);
          if (device.serial.isNotEmpty) {
            devices.add(device);
          }
        }
      }
      
      return devices;
    } catch (e) {
      onLog?.call(S.current.errGetAdbFailed(e));
      return [];
    }
  }

  Future<List<DeviceInfo>> getFastbootDevices({LogCallback? onLog}) async {
    try {
      if (!await File(Constants.fastbootPath).exists()) {
        onLog?.call(S.current.errFastbootNotExist(Constants.fastbootPath));
        return [];
      }
      final result = await _runFastboot(['devices'], onLog: onLog);
      final lines = result.stdout.toString().split('\n');
      final devices = <DeviceInfo>[];
      
      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty) continue;
        if (line.contains('fastboot')) {
          final device = DeviceInfo.fromFastbootLine(line);
          if (device.serial.isNotEmpty) {
            devices.add(device);
          }
        }
      }
      
      return devices;
    } catch (e) {
      onLog?.call(S.current.errGetFastbootFailed(e));
      return [];
    }
  }

  Future<bool> checkAdbConnection({Duration timeout = const Duration(seconds: 5)}) async {
    try {
      final devices = await getAdbDevices().timeout(timeout);
      return devices.any((d) => d.state == DeviceState.adb);
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkFastbootConnection({Duration timeout = const Duration(seconds: 5)}) async {
    try {
      final devices = await getFastbootDevices().timeout(timeout);
      return devices.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rebootToFastboot({LogCallback? onLog}) async {
    try {
      onLog?.call(S.current.logRebootingToFastboot);
      final result = await _runAdb(['reboot', 'bootloader'], onLog: onLog);
      
      if (result.exitCode == 0) {
        onLog?.call(S.current.logRebootCmdSent);
        return true;
      } else {
        onLog?.call(S.current.errRebootFailed(result.stderr));
        return false;
      }
    } catch (e) {
      onLog?.call(S.current.errRebootException(e));
      return false;
    }
  }

  Future<DeviceInfo?> waitForFastbootDevice({
    Duration timeout = const Duration(seconds: 60),
    LogCallback? onLog,
  }) async {
    final endTime = DateTime.now().add(timeout);
    
    onLog?.call(S.current.logWaitFastboot(timeout.inSeconds));
    
    while (DateTime.now().isBefore(endTime)) {
      final devices = await getFastbootDevices();
      if (devices.isNotEmpty) {
        onLog?.call(S.current.logFastbootDetected(devices.first.serial));
        return devices.first;
      }
      await Future.delayed(const Duration(seconds: 2));
    }
    
    onLog?.call(S.current.logWaitFastbootTimeout);
    return null;
  }

  Future<bool> flashBoot(String imagePath, {LogCallback? onLog}) async {
    try {
      final absolutePath = File(imagePath).absolute.path;
      onLog?.call(S.current.logFlashingBootPath(absolutePath));
      
      final result = await _runFastboot(['flash', 'boot', absolutePath], onLog: onLog);
      
      if (result.exitCode == 0) {
        onLog?.call(S.current.logFlashBootSuccess);
        return true;
      } else {
        onLog?.call(S.current.errFlashFailed(result.stderr));
        return false;
      }
    } catch (e) {
      onLog?.call(S.current.errFlashException(e));
      return false;
    }
  }

  Future<bool> backupBoot(String outputPath, {LogCallback? onLog}) async {
    try {
      onLog?.call(S.current.logBackingUpPartition);
      
      final result = await _runFastboot(['fetch', 'boot', outputPath], onLog: onLog);
      
      if (result.exitCode == 0 && await File(outputPath).exists()) {
        onLog?.call(S.current.logBackupSuccess(outputPath));
        return true;
      } else {
        onLog?.call(S.current.logBackupFailedTryAlt);
        return await _backupBootAlternative(outputPath, onLog: onLog);
      }
    } catch (e) {
      onLog?.call(S.current.errBackupException(e));
      return false;
    }
  }

  Future<bool> _backupBootAlternative(String outputPath, {LogCallback? onLog}) async {
    try {
      final tempDir = p.dirname(outputPath);
      final tempFile = p.join(tempDir, 'boot_backup.img');
      
      final result = await _runFastboot([
        'oem', 'save', 'boot', tempFile,
      ], onLog: onLog);
      
      if (result.exitCode == 0) {
        await File(tempFile).rename(outputPath);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rebootDevice({LogCallback? onLog}) async {
    try {
      onLog?.call(S.current.logRebootingDevice);
      final result = await _runFastboot(['reboot'], onLog: onLog);
      
      if (result.exitCode == 0) {
        onLog?.call(S.current.logDeviceRebooting);
        return true;
      } else {
        onLog?.call(S.current.errRebootFailed(result.stderr));
        return false;
      }
    } catch (e) {
      onLog?.call(S.current.errRebootException(e));
      return false;
    }
  }

  Future<String?> getFastbootVar(String varName, {LogCallback? onLog}) async {
    try {
      final result = await _runFastboot(['getvar', varName], onLog: onLog);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final match = RegExp('$varName:\\s*(\\S+)').firstMatch(output);
        return match?.group(1);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> checkAdbExists() async {
    return File(Constants.adbPath).exists();
  }

  Future<bool> checkFastbootExists() async {
    return File(Constants.fastbootPath).exists();
  }

  Future<bool> checkDriverInstalled({LogCallback? onLog}) async {
    try {
      onLog?.call(S.current.logCheckAdb);
      
      if (!await File(Constants.adbPath).exists()) {
        onLog?.call(S.current.errAdbNotExist(Constants.adbPath));
        return false;
      }
      
      final adbResult = await runExecutableArguments(
        Constants.adbPath,
        ['version'],
        verbose: false,
      );
      
      if (adbResult.exitCode != 0) {
        onLog?.call(S.current.errAdbNotAvailable);
        return false;
      }
      
      onLog?.call(S.current.logCheckFastboot);
      
      if (!await File(Constants.fastbootPath).exists()) {
        onLog?.call(S.current.errFastbootNotExist(Constants.fastbootPath));
        return false;
      }
      
      final fastbootResult = await runExecutableArguments(
        Constants.fastbootPath,
        ['--version'],
        verbose: false,
      );
      
      if (fastbootResult.exitCode != 0) {
        onLog?.call(S.current.errFastbootNotAvailable);
        return false;
      }
      
      onLog?.call(S.current.logDriverCheckPassed);
      return true;
    } catch (e) {
      onLog?.call(S.current.errDriverCheckFailed(e));
      return false;
    }
  }

  Future<ProcessResult> _runAdb(
    List<String> args, {
    LogCallback? onLog,
  }) async {
    final executable = Constants.adbPath;
    
    onLog?.call(S.current.logExecuteCmd('adb ${args.join(' ')}'));
    
    final result = await runExecutableArguments(
      executable,
      args,
      verbose: false,
    );
    
    if (result.stdout.toString().isNotEmpty) {
      onLog?.call(result.stdout.toString().trim());
    }
    if (result.stderr.toString().isNotEmpty && result.exitCode != 0) {
      onLog?.call('[STDERR] ${result.stderr}'.trim());
    }
    
    return result;
  }

  Future<ProcessResult> _runFastboot(
    List<String> args, {
    LogCallback? onLog,
  }) async {
    final executable = Constants.fastbootPath;
    
    onLog?.call(S.current.logExecuteCmd('fastboot ${args.join(' ')}'));
    
    final result = await runExecutableArguments(
      executable,
      args,
      verbose: false,
    );
    
    if (result.stdout.toString().isNotEmpty) {
      onLog?.call(result.stdout.toString().trim());
    }
    if (result.stderr.toString().isNotEmpty && result.exitCode != 0) {
      onLog?.call('[STDERR] ${result.stderr}'.trim());
    }
    
    return result;
  }

  /// 检测设备上是否安装了指定的应用
  Future<bool> checkAppInstalled(String packageName, {LogCallback? onLog}) async {
    try {
      final result = await _runAdb(['shell', 'pm', 'list', 'packages'], onLog: onLog);
      final output = result.stdout.toString();
      final lines = output.split('\n');
      
      return lines.any((line) => line.trim() == 'package:$packageName');
    } catch (e) {
      onLog?.call('检查应用安装状态失败: $e');
      return false;
    }
  }

  /// 检测 APatch 是否已安装
  Future<bool> checkAPatchInstalled({LogCallback? onLog}) async {
    return checkAppInstalled(Constants.apatchPackageName, onLog: onLog);
  }

  /// 检测 FolkPatch 是否已安装
  Future<bool> checkFolkPatchInstalled({LogCallback? onLog}) async {
    return checkAppInstalled(Constants.folkpatchPackageName, onLog: onLog);
  }

  /// 通过 ADB 安装 APK
  Future<bool> installApk(String apkPath, {LogCallback? onLog}) async {
    try {
      if (!await File(apkPath).exists()) {
        onLog?.call('APK 文件不存在: $apkPath');
        return false;
      }
      
      onLog?.call('正在安装: $apkPath');
      final result = await _runAdb(['install', '-r', apkPath], onLog: onLog);
      
      if (result.exitCode == 0) {
        final output = result.stdout.toString().toLowerCase();
        if (output.contains('success')) {
          onLog?.call('安装成功');
          return true;
        }
      }
      
      onLog?.call('安装失败: ${result.stderr}');
      return false;
    } catch (e) {
      onLog?.call('安装异常: $e');
      return false;
    }
  }

  /// 安装 APatch
  Future<bool> installAPatch({LogCallback? onLog}) async {
    return installApk(Constants.apatchApkPath, onLog: onLog);
  }

  /// 安装 FolkPatch
  Future<bool> installFolkPatch({LogCallback? onLog}) async {
    return installApk(Constants.folkpatchApkPath, onLog: onLog);
  }
}
