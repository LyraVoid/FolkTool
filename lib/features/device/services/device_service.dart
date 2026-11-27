import 'dart:io';
import 'package:path/path.dart' as p;
import '../../../core/config/app_config.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/process/process_runner.dart';
import '../../../generated/l10n.dart';
import '../models/device_info.dart';

typedef LogCallback = void Function(String line);

class DeviceService {
  final ProcessRunner _processRunner;
  final bool _skipBinaryExistsCheck;
  String? _lastRawError;

  /// Raw stdout/stderr or exception text from the most recent failed ADB/Fastboot call.
  String? get lastRawError => _lastRawError;

  DeviceService({
    ProcessRunner? processRunner,
    bool skipBinaryExistsCheck = false,
  })  : _processRunner = processRunner ?? const DefaultProcessRunner(),
        _skipBinaryExistsCheck = skipBinaryExistsCheck;

  /// Parses battery percentage from `adb shell dumpsys battery` output.
  static int? parseBatteryLevel(String dumpsysOutput) {
    final match = RegExp(r'level:\s*(\d+)').firstMatch(dumpsysOutput);
    if (match == null) return null;
    return int.tryParse(match.group(1) ?? '');
  }

  Future<List<DeviceInfo>> getAdbDevices({LogCallback? onLog}) async {
    try {
      if (!_skipBinaryExistsCheck && !await File(AppConfig.adbPath).exists()) {
        onLog?.call(S.current.errAdbNotExist(AppConfig.adbPath));
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
          !await File(AppConfig.fastbootPath).exists()) {
        onLog?.call(S.current.errFastbootNotExist(AppConfig.fastbootPath));
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

  Future<String?> _readAdbProp(
    String serial,
    List<String> shellArgs, {
    LogCallback? onLog,
  }) async {
    try {
      final res = await _runAdb(['-s', serial, ...shellArgs], onLog: onLog);
      if (res.exitCode == 0) {
        final value = res.stdout.toString().trim();
        if (value.isNotEmpty) return value;
      }
    } catch (_) {
      // Property probes are optional diagnostics; keep remaining fields available.
    }
    return null;
  }

  /// Queries model, Android version, kernel version, and battery concurrently.
  ///
  /// When [includeStaticProperties] is `false`, only battery level is refreshed.
  Future<DeviceInfo> queryAdbDeviceDetails(
    DeviceInfo base, {
    bool includeStaticProperties = true,
    LogCallback? onLog,
  }) async {
    if (!base.isAuthorizedAdb) return base;

    if (!includeStaticProperties) {
      final battery = await getBatteryLevel(serial: base.serial, onLog: onLog);
      return base.copyWith(batteryLevel: battery);
    }

    final results = await Future.wait([
      _readAdbProp(
        base.serial,
        ['shell', 'getprop', 'ro.product.model'],
        onLog: onLog,
      ),
      _readAdbProp(
        base.serial,
        ['shell', 'getprop', 'ro.build.version.release'],
        onLog: onLog,
      ),
      _readAdbProp(base.serial, ['shell', 'uname', '-r'], onLog: onLog),
      getBatteryLevel(serial: base.serial, onLog: onLog),
    ]);

    return base.copyWith(
      model: (results[0] as String?) ?? base.model,
      androidVersion: (results[1] as String?) ?? base.androidVersion,
      kernelVersion: (results[2] as String?) ?? base.kernelVersion,
      batteryLevel: results[3] as int?,
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
    _lastRawError = null;
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
        final raw = '${result.stderr}\n${result.stdout}'.trim();
        _lastRawError = raw.isNotEmpty ? raw : 'adb exited with code ${result.exitCode}';
        onLog?.call(S.current.errRebootFailed(result.stderr));
        return false;
      }
    } catch (e) {
      _lastRawError = e.toString();
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
    _lastRawError = null;
    try {
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        _lastRawError = 'Boot image file not found: $imagePath';
        onLog?.call(_lastRawError!);
        return false;
      }

      if (serial == null) {
        final devices = await getFastbootDevices(onLog: onLog);
        if (devices.length != 1) {
          _lastRawError =
              'Expected 1 fastboot device, found ${devices.length}.';
          onLog?.call('Refusing to flash: $_lastRawError');
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
      final result = await _runFastboot(
        args,
        timeout: const Duration(seconds: AppConfig.flashTimeoutSeconds),
        onLog: onLog,
      );

      if (result.exitCode == 0) {
        onLog?.call(S.current.logFlashBootSuccess);
        return true;
      } else {
        final errText = '${result.stderr}\n${result.stdout}'.trim();
        _lastRawError =
            errText.isNotEmpty ? errText : 'fastboot exited with code ${result.exitCode}';
        onLog?.call(S.current.errFlashFailed(errText));
        return false;
      }
    } catch (e) {
      _lastRawError = e.toString();
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

  /// Queries the active A/B slot (`a`/`b`) if the device supports slots, otherwise `null`.
  Future<String?> getActiveSlot({String? serial, LogCallback? onLog}) =>
      getFastbootVar('current-slot', serial: serial, onLog: onLog);

  /// Ensures the ADB server daemon can start cleanly.
  Future<bool> ensureAdbServerStarted({LogCallback? onLog}) async {
    _lastRawError = null;
    try {
      if (!_skipBinaryExistsCheck && !await File(AppConfig.adbPath).exists()) {
        _lastRawError = S.current.errAdbNotExist(AppConfig.adbPath);
        onLog?.call(_lastRawError!);
        return false;
      }
      final res = await _runAdb(['start-server'], onLog: onLog);
      if (res.exitCode != 0) {
        final raw = '${res.stderr}\n${res.stdout}'.trim();
        _lastRawError = raw.isNotEmpty ? raw : 'adb start-server exited ${res.exitCode}';
        return false;
      }
      return true;
    } catch (e) {
      _lastRawError = e.toString();
      return false;
    }
  }

  Future<bool> checkAdbExists() async => File(AppConfig.adbPath).exists();

  Future<bool> checkFastbootExists() async =>
      File(AppConfig.fastbootPath).exists();

  Future<bool> checkDriverInstalled({LogCallback? onLog}) async {
    try {
      onLog?.call(S.current.logCheckAdb);

      if (!await File(AppConfig.adbPath).exists()) {
        onLog?.call(S.current.errAdbNotExist(AppConfig.adbPath));
        return false;
      }

      final adbResult = await _runAdb(['version'], onLog: onLog);

      if (adbResult.exitCode != 0) {
        onLog?.call(S.current.errAdbNotAvailable);
        return false;
      }

      onLog?.call(S.current.logCheckFastboot);

      if (!await File(AppConfig.fastbootPath).exists()) {
        onLog?.call(S.current.errFastbootNotExist(AppConfig.fastbootPath));
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
    Duration? timeout,
    LogCallback? onLog,
  }) async {
    final executable = AppConfig.adbPath;
    onLog?.call(S.current.logExecuteCmd('adb ${args.join(' ')}'));

    final result = await _processRunner.run(
      executable,
      args,
      timeout: timeout ?? const Duration(seconds: AppConfig.adbTimeoutSeconds),
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
    Duration? timeout,
    LogCallback? onLog,
  }) async {
    final executable = AppConfig.fastbootPath;
    onLog?.call(S.current.logExecuteCmd('fastboot ${args.join(' ')}'));

    final result = await _processRunner.run(
      executable,
      args,
      timeout:
          timeout ?? const Duration(seconds: AppConfig.fastbootTimeoutSeconds),
    );

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
        message:
            'The device is connected, but USB debugging RSA authorization has not been granted.',
        reason:
            'The RSA authorization prompt on the phone was dismissed or not yet accepted.',
        affectedStage: stage,
        deviceSafe: true,
        nextSteps:
            'Unlock your phone screen, accept the "Allow USB debugging" prompt (check "Always allow"), and click Refresh.',
        canSafelyRetry: true,
        technicalDetails: rawError,
      );
    }
    if (lower.contains('offline')) {
      return AppError(
        category: AppErrorCategory.deviceConnection,
        title: 'ADB Device Offline',
        message:
            'The device appears in ADB as offline and cannot receive commands.',
        reason:
            'Unstable USB connection, outdated ADB driver, or USB debugging handshake stalled.',
        affectedStage: stage,
        deviceSafe: true,
        nextSteps:
            'Reconnect the USB cable (prefer a direct motherboard USB port) or toggle USB debugging off and back on.',
        canSafelyRetry: true,
        technicalDetails: rawError,
      );
    }
    if (lower.contains('more than one device')) {
      return AppError(
        category: AppErrorCategory.deviceConnection,
        title: 'Multiple Devices Connected',
        message: 'More than one Android device or emulator is connected.',
        reason:
            'ADB cannot target a single device when multiple devices are attached.',
        affectedStage: stage,
        deviceSafe: true,
        nextSteps:
            'Disconnect extra devices/emulators or select the exact target device in Device Status.',
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
        nextSteps:
            'Close conflicting Android tools (e.g., phone managers, emulators) and retry.',
        canSafelyRetry: true,
        technicalDetails: rawError,
      );
    }
    if (lower.contains('timeout')) {
      return AppError(
        category: AppErrorCategory.process,
        title: 'ADB Command Timed Out',
        message:
            'The device did not respond to the ADB command within the expected time.',
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
      nextSteps:
          'Verify USB connection, USB debugging, and drivers, then check Logs for details.',
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
        message:
            'The device rejected flashing because the bootloader is locked.',
        reason:
            'OEM/Bootloader unlock is required before flashing custom boot images.',
        affectedStage: stage,
        deviceSafe: true,
        nextSteps:
            'Unlock the bootloader according to your device manufacturer instructions (note: unlocking usually wipes user data).',
        canSafelyRetry: false,
        technicalDetails: rawError,
      );
    }
    if (lower.contains('partition') &&
        (lower.contains('not found') || lower.contains('doesn\'t exist'))) {
      return AppError(
        category: AppErrorCategory.fastboot,
        title: 'Target Partition Not Found',
        message:
            'The device reported that the target boot partition does not exist.',
        affectedStage: stage,
        deviceSafe: !duringFlash,
        nextSteps:
            'Check whether your device uses A/B slots (`boot_a`/`boot_b`) or `init_boot`, and verify compatibility before retrying.',
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
        nextSteps:
            'Reinstall the Fastboot/USB driver from Driver Install and ensure no other flashing tool is holding the device.',
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
      category: duringFlash
          ? AppErrorCategory.flashing
          : AppErrorCategory.fastboot,
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

  /// Checks multiple package IDs in a single `adb shell pm list packages` invocation.
  Future<Set<String>> checkInstalledPackages(
    Set<String> packageNames, {
    String? serial,
    LogCallback? onLog,
  }) async {
    if (packageNames.isEmpty) return const {};
    try {
      final args = <String>[
        if (serial != null) ...['-s', serial],
        'shell',
        'pm',
        'list',
        'packages',
      ];
      final result = await _runAdb(args, onLog: onLog);
      if (result.exitCode != 0) return const {};
      final installed = <String>{};
      for (final rawLine in result.stdout.toString().split('\n')) {
        final line = rawLine.trim();
        if (!line.startsWith('package:')) continue;
        final pkg = line.substring(8);
        if (packageNames.contains(pkg)) {
          installed.add(pkg);
        }
      }
      return installed;
    } catch (e) {
      onLog?.call('检查应用安装状态失败: $e');
      return const {};
    }
  }

  /// Checks whether [packageName] is installed on the target ADB device.
  Future<bool> checkAppInstalled(
    String packageName, {
    String? serial,
    LogCallback? onLog,
  }) async {
    final installed = await checkInstalledPackages(
      {packageName},
      serial: serial,
      onLog: onLog,
    );
    return installed.contains(packageName);
  }

  Future<bool> checkAPatchInstalled({String? serial, LogCallback? onLog}) =>
      checkAppInstalled(
        AppConfig.apatchPackageName,
        serial: serial,
        onLog: onLog,
      );

  Future<bool> checkFolkPatchInstalled({String? serial, LogCallback? onLog}) =>
      checkAppInstalled(
        AppConfig.folkpatchPackageName,
        serial: serial,
        onLog: onLog,
      );

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
      installApk(AppConfig.apatchApkPath, serial: serial, onLog: onLog);

  /// Queries current battery percentage over ADB.
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
      return parseBatteryLevel(result.stdout.toString());
    } catch (_) {
      return null;
    }
  }

  Future<bool> installFolkPatch({String? serial, LogCallback? onLog}) async =>
      installApk(AppConfig.folkpatchApkPath, serial: serial, onLog: onLog);
}
