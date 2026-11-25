import 'dart:io';
import 'package:path/path.dart' as p;
import '../config/constants.dart';
import '../models/models.dart';
import '../generated/l10n.dart';
import 'process_runner.dart';
import 'safety_service.dart';

typedef LogCallback = void Function(String line);

class DeviceService {
  final ProcessRunner _processRunner;
  final bool _skipBinaryExistsCheck;

  DeviceService({
    ProcessRunner? processRunner,
    bool skipBinaryExistsCheck = false,
  })  : _processRunner = processRunner ?? const DefaultProcessRunner(),
        _skipBinaryExistsCheck = skipBinaryExistsCheck;

  Future<List<DeviceInfo>> getAdbDevices({LogCallback? onLog}) async {
    try {
      if (!_skipBinaryExistsCheck && !await File(Constants.adbPath).exists()) {
        onLog?.call(S.current.errAdbNotExist(Constants.adbPath));
        return [];
      }
      final result = await _runAdb(['devices'], onLog: onLog);
      if (result.exitCode != 0) return [];
      final lines = result.stdout.toString().split('\n');
      final devices = <DeviceInfo>[];

      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty ||
            line.startsWith('List of devices') ||
            line.startsWith('* daemon')) {
          continue;
        }
        if (line.contains('\t') || RegExp(r'\s+').hasMatch(line)) {
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
      if (!_skipBinaryExistsCheck &&
          !await File(Constants.fastbootPath).exists()) {
        onLog?.call(S.current.errFastbootNotExist(Constants.fastbootPath));
        return [];
      }
      final result = await _runFastboot(['devices'], onLog: onLog);
      if (result.exitCode != 0) return [];
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

  /// Queries model, Android version, kernel version, and battery for an authorized ADB device.
  Future<DeviceInfo> queryAdbDeviceDetails(
    DeviceInfo base, {
    LogCallback? onLog,
  }) async {
    if (!base.isAuthorizedAdb) return base;
    String? model = base.model;
    String? androidVer = base.androidVersion;
    String? kernelVer = base.kernelVersion;
    int? battery = base.batteryLevel;

    try {
      final mRes = await _runAdb(
        ['-s', base.serial, 'shell', 'getprop', 'ro.product.model'],
        onLog: onLog,
      );
      if (mRes.exitCode == 0 && mRes.stdout.toString().trim().isNotEmpty) {
        model = mRes.stdout.toString().trim();
      }
    } catch (_) {}

    try {
      final aRes = await _runAdb(
        ['-s', base.serial, 'shell', 'getprop', 'ro.build.version.release'],
        onLog: onLog,
      );
      if (aRes.exitCode == 0 && aRes.stdout.toString().trim().isNotEmpty) {
        androidVer = aRes.stdout.toString().trim();
      }
    } catch (_) {}

    try {
      final kRes = await _runAdb(
        ['-s', base.serial, 'shell', 'uname', '-r'],
        onLog: onLog,
      );
      if (kRes.exitCode == 0 && kRes.stdout.toString().trim().isNotEmpty) {
        kernelVer = kRes.stdout.toString().trim();
      }
    } catch (_) {}

    battery = await getBatteryLevel(serial: base.serial, onLog: onLog);

    return base.copyWith(
      model: model,
      androidVersion: androidVer,
      kernelVersion: kernelVer,
      batteryLevel: battery,
    );
  }

  /// Queries whether bootloader is unlocked in Fastboot mode (`yes` -> true, `no` -> false).
  Future<bool?> queryBootloaderUnlocked({
    String? serial,
    LogCallback? onLog,
  }) async {
    final val = await getFastbootVar('unlocked', serial: serial, onLog: onLog);
    if (val == null) return null;
    final lower = val.toLowerCase();
    if (lower == 'yes' || lower == 'true' || lower == '1') return true;
    if (lower == 'no' || lower == 'false' || lower == '0') return false;
    return null;
  }

  Future<bool> checkAdbConnection({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final devices = await getAdbDevices().timeout(timeout);
      return devices.any((d) => d.state == DeviceState.adb);
    } catch (_) {
      return false;
    }
  }

  Future<bool> checkFastbootConnection({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final devices = await getFastbootDevices().timeout(timeout);
      return devices.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> rebootToFastboot({String? serial, LogCallback? onLog}) async {
    try {
      onLog?.call(S.current.logRebootingToFastboot);
      final args = <String>[
        if (serial != null) ...['-s', serial],
        'reboot',
        'bootloader',
      ];
      final result = await _runAdb(args, onLog: onLog);

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
    String? expectedSerial,
    LogCallback? onLog,
  }) async {
    final endTime = DateTime.now().add(timeout);

    onLog?.call(S.current.logWaitFastboot(timeout.inSeconds));

    while (DateTime.now().isBefore(endTime)) {
      final devices = await getFastbootDevices();
      if (devices.isNotEmpty) {
        final match = expectedSerial != null
            ? devices.where((d) => d.serial == expectedSerial).firstOrNull ??
                devices.first
            : devices.first;
        onLog?.call(S.current.logFastbootDetected(match.serial));
        return match;
      }
      await Future.delayed(const Duration(seconds: 2));
    }

    onLog?.call(S.current.logWaitFastbootTimeout);
    return null;
  }

  Future<bool> flashBoot(
    String imagePath, {
    String? serial,
    LogCallback? onLog,
  }) async {
    try {
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        onLog?.call('Boot image file not found: $imagePath');
        return false;
      }

      if (serial == null) {
        final devices = await getFastbootDevices(onLog: onLog);
        if (devices.length != 1) {
          onLog?.call(
            'Refusing to flash: expected 1 fastboot device, found ${devices.length}.',
          );
          return false;
        }
      }

      final absolutePath = imageFile.absolute.path;
      onLog?.call(S.current.logFlashingBootPath(absolutePath));

      final args = <String>[
        if (serial != null) ...['-s', serial],
        'flash',
        'boot',
        absolutePath,
      ];
      final result = await _runFastboot(args, onLog: onLog);

      if (result.exitCode == 0) {
        onLog?.call(S.current.logFlashBootSuccess);
        return true;
      } else {
        final errText = '${result.stderr}\n${result.stdout}'.trim();
        onLog?.call(S.current.errFlashFailed(errText));
        return false;
      }
    } catch (e) {
      onLog?.call(S.current.errFlashException(e));
      return false;
    }
  }

  Future<bool> backupBoot(
    String outputPath, {
    String? serial,
    LogCallback? onLog,
  }) async {
    try {
      onLog?.call(S.current.logBackingUpPartition);

      final args = <String>[
        if (serial != null) ...['-s', serial],
        'fetch',
        'boot',
        outputPath,
      ];
      final result = await _runFastboot(args, onLog: onLog);

      if (result.exitCode == 0 && await File(outputPath).exists()) {
        onLog?.call(S.current.logBackupSuccess(outputPath));
        return true;
      } else {
        onLog?.call(S.current.logBackupFailedTryAlt);
        return await _backupBootAlternative(
          outputPath,
          serial: serial,
          onLog: onLog,
        );
      }
    } catch (e) {
      onLog?.call(S.current.errBackupException(e));
      return false;
    }
  }

  Future<bool> _backupBootAlternative(
    String outputPath, {
    String? serial,
    LogCallback? onLog,
  }) async {
    try {
      final tempDir = p.dirname(outputPath);
      final tempFile = p.join(tempDir, 'boot_backup.img');

      final args = <String>[
        if (serial != null) ...['-s', serial],
        'oem',
        'save',
        'boot',
        tempFile,
      ];
      final result = await _runFastboot(args, onLog: onLog);

      if (result.exitCode == 0 && await File(tempFile).exists()) {
        await File(tempFile).rename(outputPath);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> rebootDevice({String? serial, LogCallback? onLog}) async {
    try {
      onLog?.call(S.current.logRebootingDevice);
      final args = <String>[
        if (serial != null) ...['-s', serial],
        'reboot',
      ];
      final result = await _runFastboot(args, onLog: onLog);

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

  Future<String?> getFastbootVar(
    String varName, {
    String? serial,
    LogCallback? onLog,
  }) async {
    try {
      final args = <String>[
        if (serial != null) ...['-s', serial],
        'getvar',
        varName,
      ];
      final result = await _runFastboot(args, onLog: onLog);
      // Fastboot prints getvar output to stderr on most devices.
      final combined = '${result.stdout}\n${result.stderr}';
      final match = RegExp('$varName:\\s*(\\S+)').firstMatch(combined);
      return match?.group(1);
    } catch (_) {
      return null;
    }
  }

  Future<bool> checkAdbExists() async => File(Constants.adbPath).exists();

  Future<bool> checkFastbootExists() async =>
      File(Constants.fastbootPath).exists();

  Future<bool> checkDriverInstalled({LogCallback? onLog}) async {
    try {
      onLog?.call(S.current.logCheckAdb);

      if (!await File(Constants.adbPath).exists()) {
        onLog?.call(S.current.errAdbNotExist(Constants.adbPath));
        return false;
      }

      final adbResult = await _runAdb(['version'], onLog: onLog);

      if (adbResult.exitCode != 0) {
        onLog?.call(S.current.errAdbNotAvailable);
        return false;
      }

      onLog?.call(S.current.logCheckFastboot);

      if (!await File(Constants.fastbootPath).exists()) {
        onLog?.call(S.current.errFastbootNotExist(Constants.fastbootPath));
        return false;
      }

      final fastbootResult = await _runFastboot(['--version'], onLog: onLog);

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

    final result = await _processRunner.run(executable, args);

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

    final result = await _processRunner.run(executable, args);

    if (result.stdout.toString().isNotEmpty) {
      onLog?.call(result.stdout.toString().trim());
    }
    if (result.stderr.toString().isNotEmpty && result.exitCode != 0) {
      onLog?.call('[STDERR] ${result.stderr}'.trim());
    }

    return result;
  }

  /// Classifies raw ADB output/exceptions into an actionable [AppError].
  static AppError classifyAdbError(String rawError, {String? stage}) {
    final lower = rawError.toLowerCase();
    if (lower.contains('unauthorized')) {
      return AppError(
        category: AppErrorCategory.adb,
        title: 'USB Debugging Not Authorized',
        message: 'The device is connected, but USB debugging RSA authorization has not been granted.',
        reason: 'The RSA authorization prompt on the phone was dismissed or not yet accepted.',
        affectedStage: stage,
        deviceSafe: true,
        nextSteps: 'Unlock your phone screen, accept the "Allow USB debugging" prompt (check "Always allow"), and click Refresh.',
        canSafelyRetry: true,
        technicalDetails: rawError,
      );
    }
    if (lower.contains('offline')) {
      return AppError(
        category: AppErrorCategory.deviceConnection,
        title: 'ADB Device Offline',
        message: 'The device appears in ADB as offline and cannot receive commands.',
        reason: 'Unstable USB connection, outdated ADB driver, or USB debugging handshake stalled.',
        affectedStage: stage,
        deviceSafe: true,
        nextSteps: 'Reconnect the USB cable (prefer a direct motherboard USB port) or toggle USB debugging off and back on.',
        canSafelyRetry: true,
        technicalDetails: rawError,
      );
    }
    if (lower.contains('more than one device')) {
      return AppError(
        category: AppErrorCategory.deviceConnection,
        title: 'Multiple Devices Connected',
        message: 'More than one Android device or emulator is connected.',
        reason: 'ADB cannot target a single device when multiple devices are attached.',
        affectedStage: stage,
        deviceSafe: true,
        nextSteps: 'Disconnect extra devices/emulators or select the exact target device in Device Status.',
        canSafelyRetry: true,
        technicalDetails: rawError,
      );
    }
    if (lower.contains('address already in use') ||
        lower.contains('cannot bind') ||
        lower.contains('daemon')) {
      return AppError(
        category: AppErrorCategory.adb,
        title: 'ADB Server Port Conflict',
        message: 'The ADB daemon could not start or bind to port 5037.',
        reason: 'Another phone suite or Android tool is occupying the ADB port.',
        affectedStage: stage,
        deviceSafe: true,
        nextSteps: 'Close conflicting Android tools (e.g., phone managers, emulators) and retry.',
        canSafelyRetry: true,
        technicalDetails: rawError,
      );
    }
    if (lower.contains('timeout')) {
      return AppError(
        category: AppErrorCategory.process,
        title: 'ADB Command Timed Out',
        message: 'The device did not respond to the ADB command within the expected time.',
        affectedStage: stage,
        deviceSafe: true,
        nextSteps: 'Check the USB cable and phone screen, then retry.',
        canSafelyRetry: true,
        technicalDetails: rawError,
      );
    }
    return AppError(
      category: AppErrorCategory.adb,
      title: 'ADB Command Failed',
      message: 'An ADB command failed to complete.',
      affectedStage: stage,
      deviceSafe: true,
      nextSteps: 'Verify USB connection, USB debugging, and drivers, then check Logs for details.',
      canSafelyRetry: true,
      technicalDetails: rawError,
    );
  }

  /// Classifies raw Fastboot output/exceptions into an actionable [AppError].
  static AppError classifyFastbootError(
    String rawError, {
    String? stage,
    bool duringFlash = false,
  }) {
    final lower = rawError.toLowerCase();
    if (lower.contains('locked') ||
        lower.contains('unlock') ||
        lower.contains('lock state')) {
      return AppError(
        category: AppErrorCategory.fastboot,
        title: 'Bootloader Is Locked',
        message: 'The device rejected flashing because the bootloader is locked.',
        reason: 'OEM/Bootloader unlock is required before flashing custom boot images.',
        affectedStage: stage,
        deviceSafe: true,
        nextSteps: 'Unlock the bootloader according to your device manufacturer instructions (note: unlocking usually wipes user data).',
        canSafelyRetry: false,
        technicalDetails: rawError,
      );
    }
    if (lower.contains('partition') &&
        (lower.contains('not found') || lower.contains('doesn\'t exist'))) {
      return AppError(
        category: AppErrorCategory.fastboot,
        title: 'Target Partition Not Found',
        message: 'The device reported that the target boot partition does not exist.',
        affectedStage: stage,
        deviceSafe: !duringFlash,
        nextSteps: 'Check whether your device uses A/B slots (`boot_a`/`boot_b`) or `init_boot`, and verify compatibility before retrying.',
        canSafelyRetry: false,
        technicalDetails: rawError,
      );
    }
    if (lower.contains('permission') || lower.contains('access is denied')) {
      return AppError(
        category: AppErrorCategory.permission,
        title: 'Insufficient Permissions / Driver Access',
        message: 'Windows denied access to the Fastboot USB interface.',
        affectedStage: stage,
        deviceSafe: !duringFlash,
        nextSteps: 'Reinstall the Fastboot/USB driver from Driver Install and ensure no other flashing tool is holding the device.',
        canSafelyRetry: !duringFlash,
        technicalDetails: rawError,
      );
    }
    if (lower.contains('timeout')) {
      return AppError(
        category: AppErrorCategory.fastboot,
        title: 'Fastboot Command Timed Out',
        message: 'Fastboot did not respond in time.',
        affectedStage: stage,
        deviceSafe: !duringFlash,
        nextSteps: duringFlash
            ? 'Do NOT disconnect abruptly if the device is still writing. Check the phone screen before attempting recovery.'
            : 'Check the USB cable/Fastboot driver and verify the device appears in Device Status.',
        canSafelyRetry: !duringFlash,
        technicalDetails: rawError,
      );
    }
    return AppError(
      category: duringFlash ? AppErrorCategory.flashing : AppErrorCategory.fastboot,
      title: duringFlash ? 'Boot Flashing Failed' : 'Fastboot Command Failed',
      message: duringFlash
          ? 'Flashing the patched boot image did not complete cleanly.'
          : 'A Fastboot operation failed.',
      affectedStage: stage,
      deviceSafe: !duringFlash,
      nextSteps: duringFlash
          ? 'Inspect Logs and check your device state. If the device fails to boot, use Restore Stock Boot in Fastboot mode.'
          : 'Check Fastboot connection and USB drivers, then try again.',
      canSafelyRetry: !duringFlash,
      technicalDetails: rawError,
    );
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

  Future<bool> checkAPatchInstalled({LogCallback? onLog}) async =>
      checkAppInstalled(Constants.apatchPackageName, onLog: onLog);

  Future<bool> checkFolkPatchInstalled({LogCallback? onLog}) async =>
      checkAppInstalled(Constants.folkpatchPackageName, onLog: onLog);

  Future<bool> installApk(
    String apkPath, {
    String? serial,
    LogCallback? onLog,
  }) async {
    try {
      if (!await File(apkPath).exists()) {
        onLog?.call('APK 文件不存在: $apkPath');
        return false;
      }

      onLog?.call('正在安装: $apkPath');
      final args = <String>[
        if (serial != null) ...['-s', serial],
        'install',
        '-r',
        apkPath,
      ];
      final result = await _runAdb(args, onLog: onLog);

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

  Future<bool> installAPatch({String? serial, LogCallback? onLog}) async =>
      installApk(Constants.apatchApkPath, serial: serial, onLog: onLog);

  /// 查询设备当前电量百分比（ADB 模式下可用）
  Future<int?> getBatteryLevel({String? serial, LogCallback? onLog}) async {
    try {
      final args = <String>[
        if (serial != null) ...['-s', serial],
        'shell',
        'dumpsys',
        'battery',
      ];
      final result = await _runAdb(args, onLog: onLog);
      if (result.exitCode != 0) return null;
      return SafetyService.parseBatteryLevel(result.stdout.toString());
    } catch (_) {
      return null;
    }
  }

  Future<bool> installFolkPatch({String? serial, LogCallback? onLog}) async =>
      installApk(Constants.folkpatchApkPath, serial: serial, onLog: onLog);
}