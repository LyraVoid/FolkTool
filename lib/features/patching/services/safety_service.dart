import 'dart:io';
import '../../../core/config/app_config.dart';
import '../../../core/errors/app_error.dart';
import '../../device/models/device_info.dart';

/// Result of pre-flight safety checks executed before patching/flashing.
class PreflightResult {
  final bool passed;
  final List<String> warnings;
  final List<String> errors;
  final AppError? primaryError;

  const PreflightResult({
    required this.passed,
    this.warnings = const [],
    this.errors = const [],
    this.primaryError,
  });
}

/// Validates environment, binary presence, image magic, device readiness,
/// kernel compatibility range, and battery level.
class SafetyService {
  static const int minRecommendedBatteryPercent = 20;
  static const List<int> _androidBootMagic = [
    0x41, 0x4E, 0x44, 0x52, 0x4F, 0x49, 0x44, 0x21, // "ANDROID!"
  ];

  /// Checks whether the Linux kernel version falls within 3.18 – 6.15.
  static bool isKernelCompatible(String? kernelVersion) {
    if (kernelVersion == null || kernelVersion.trim().isEmpty) {
      return false;
    }
    final match = RegExp(r'^(\d+)\.(\d+)').firstMatch(kernelVersion.trim());
    if (match == null) {
      return false;
    }
    final major = int.tryParse(match.group(1) ?? '');
    final minor = int.tryParse(match.group(2) ?? '');
    if (major == null || minor == null) {
      return false;
    }

    if (major < 3 || major > 6) return false;
    if (major == 3 && minor < 18) return false;
    if (major == 6 && minor > 15) return false;
    return true;
  }

  /// Checks whether [path] starts with the standard `ANDROID!` boot image magic.
  static Future<bool> hasAndroidBootMagic(String path) async {
    try {
      final raf = await File(path).open(mode: FileMode.read);
      try {
        final header = await raf.read(8);
        if (header.length < 8) return false;
        for (var i = 0; i < 8; i++) {
          if (header[i] != _androidBootMagic[i]) return false;
        }
        return true;
      } finally {
        await raf.close();
      }
    } catch (_) {
      return false;
    }
  }

  /// Runs pre-flight checks on required files, device state, and environment.
  Future<PreflightResult> runPreflightChecks({
    required String bootImagePath,
    DeviceInfo? deviceInfo,
    int? batteryLevel,
    bool checkBinaries = true,
    bool checkImageMagic = false,
    bool requireConnectedDevice = false,
    int connectedDeviceCount = 1,
  }) async {
    final errors = <String>[];
    final warnings = <String>[];
    AppError? primaryError;

    void addError(String msg, AppError err) {
      errors.add(msg);
      primaryError ??= err;
    }

    final bootFile = File(bootImagePath);
    if (!await bootFile.exists()) {
      addError(
        'Boot image not found: $bootImagePath',
        AppError(
          category: AppErrorCategory.file,
          title: 'Boot Image Not Found',
          message:
              'The selected boot image file no longer exists or was moved.',
          affectedStage: 'Preflight',
          deviceSafe: true,
          nextSteps: 'Select a valid boot.img file before starting.',
          canSafelyRetry: true,
          technicalDetails: bootImagePath,
        ),
      );
    } else {
      final length = await bootFile.length();
      if (length == 0) {
        addError(
          'Boot image file is empty: $bootImagePath',
          AppError(
            category: AppErrorCategory.imageValidation,
            title: 'Empty Boot Image',
            message: 'The selected boot image file is 0 bytes.',
            affectedStage: 'Validation',
            deviceSafe: true,
            nextSteps: 'Provide a valid, non-empty stock boot.img.',
            canSafelyRetry: true,
            technicalDetails: bootImagePath,
          ),
        );
      } else if (checkImageMagic && !await hasAndroidBootMagic(bootImagePath)) {
        warnings.add(
          'File header does not start with standard ANDROID! magic (some vendor/LZ4/vendor_boot images differ—verify before flashing).',
        );
      }
    }

    if (checkBinaries) {
      final requiredBins = <String, String>{
        'kptools': AppConfig.kptoolsPath,
        'adb': AppConfig.adbPath,
        'fastboot': AppConfig.fastbootPath,
      };
      for (final entry in requiredBins.entries) {
        if (!await File(entry.value).exists()) {
          addError(
            'Missing required binary (${entry.key}): ${entry.value}',
            AppError(
              category: AppErrorCategory.file,
              title: 'Missing Required Tool (${entry.key})',
              message:
                  'Bundled tool ${entry.key} was not found at expected path.',
              affectedStage: 'Preflight',
              deviceSafe: true,
              nextSteps: 'Reinstall FolkTool or restore the bin/ directory.',
              canSafelyRetry: false,
              technicalDetails: entry.value,
            ),
          );
        }
      }
    }

    if (requireConnectedDevice) {
      if (connectedDeviceCount > 1) {
        addError(
          'Multiple devices connected ($connectedDeviceCount). Select a single target device.',
          const AppError(
            category: AppErrorCategory.deviceConnection,
            title: 'Multiple Devices Connected',
            message: 'More than one device is connected to this PC.',
            affectedStage: 'Preflight',
            deviceSafe: true,
            nextSteps:
                'Disconnect extra devices or choose one target device in Device Status.',
            canSafelyRetry: true,
          ),
        );
      } else if (deviceInfo == null ||
          deviceInfo.state == DeviceState.disconnected) {
        addError(
          'No authorized device connected.',
          const AppError(
            category: AppErrorCategory.deviceConnection,
            title: 'No Device Connected',
            message: 'No Android device was detected in ADB or Fastboot mode.',
            affectedStage: 'Preflight',
            deviceSafe: true,
            nextSteps:
                'Connect your device via USB, enable USB debugging, or enter Fastboot mode.',
            canSafelyRetry: true,
          ),
        );
      } else if (deviceInfo.state == DeviceState.unauthorized) {
        addError(
          'Device ${deviceInfo.serial} is unauthorized.',
          AppError(
            category: AppErrorCategory.adb,
            title: 'Device Unauthorized',
            message:
                'Device ${deviceInfo.serial} has not authorized USB debugging.',
            affectedStage: 'Preflight',
            deviceSafe: true,
            nextSteps:
                'Unlock the phone screen and accept the "Allow USB debugging" RSA prompt.',
            canSafelyRetry: true,
          ),
        );
      } else if (deviceInfo.state == DeviceState.offline) {
        addError(
          'Device ${deviceInfo.serial} is offline.',
          AppError(
            category: AppErrorCategory.deviceConnection,
            title: 'Device Offline',
            message: 'Device ${deviceInfo.serial} is offline and unresponsive.',
            affectedStage: 'Preflight',
            deviceSafe: true,
            nextSteps: 'Reconnect the USB cable or toggle USB debugging.',
            canSafelyRetry: true,
          ),
        );
      } else if (deviceInfo.bootloaderUnlocked == false) {
        addError(
          'Bootloader is locked on ${deviceInfo.serial}.',
          AppError(
            category: AppErrorCategory.fastboot,
            title: 'Bootloader Locked',
            message:
                'Flashing a patched boot image requires an unlocked bootloader.',
            affectedStage: 'Preflight',
            deviceSafe: true,
            nextSteps:
                'Unlock the bootloader first (note: unlocking wipes user data).',
            canSafelyRetry: false,
          ),
        );
      }
    }

    if (deviceInfo != null &&
        deviceInfo.kernelVersion != null &&
        deviceInfo.kernelVersion!.isNotEmpty &&
        !isKernelCompatible(deviceInfo.kernelVersion)) {
      warnings.add(
        'Kernel version ${deviceInfo.kernelVersion} may be outside the supported 3.18 - 6.15 range.',
      );
    }

    final effectiveBattery = batteryLevel ?? deviceInfo?.batteryLevel;
    if (effectiveBattery != null &&
        effectiveBattery < minRecommendedBatteryPercent) {
      warnings.add(
        'Device battery is low ($effectiveBattery%). Charge above $minRecommendedBatteryPercent% before flashing.',
      );
    }

    return PreflightResult(
      passed: errors.isEmpty,
      warnings: warnings,
      errors: errors,
      primaryError: primaryError,
    );
  }
}
