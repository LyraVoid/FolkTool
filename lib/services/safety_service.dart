import 'dart:io';
import '../config/constants.dart';
import '../models/device_info.dart';

/// Result of pre-flight safety checks executed before patching/flashing.
class PreflightResult {
  final bool passed;
  final List<String> warnings;
  final List<String> errors;

  const PreflightResult({
    required this.passed,
    this.warnings = const [],
    this.errors = const [],
  });
}

/// Validates environment, binary presence, kernel range, and battery level.
class SafetyService {
  static const int minRecommendedBatteryPercent = 20;

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

  /// Parses battery percentage from `adb shell dumpsys battery` output.
  static int? parseBatteryLevel(String dumpsysOutput) {
    final match = RegExp(r'level:\s*(\d+)').firstMatch(dumpsysOutput);
    if (match == null) return null;
    return int.tryParse(match.group(1) ?? '');
  }

  /// Runs pre-flight checks on required files and optional device metadata.
  Future<PreflightResult> runPreflightChecks({
    required String bootImagePath,
    DeviceInfo? deviceInfo,
    int? batteryLevel,
    bool checkBinaries = true,
  }) async {
    final errors = <String>[];
    final warnings = <String>[];

    if (!await File(bootImagePath).exists()) {
      errors.add('Boot image not found: $bootImagePath');
    } else {
      final length = await File(bootImagePath).length();
      if (length == 0) {
        errors.add('Boot image file is empty: $bootImagePath');
      }
    }

    if (checkBinaries) {
      final requiredBins = <String, String>{
        'kptools': Constants.kptoolsPath,
        'adb': Constants.adbPath,
        'fastboot': Constants.fastbootPath,
      };
      for (final entry in requiredBins.entries) {
        if (!await File(entry.value).exists()) {
          errors.add('Missing required binary (${entry.key}): ${entry.value}');
        }
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

    if (batteryLevel != null && batteryLevel < minRecommendedBatteryPercent) {
      warnings.add(
        'Device battery is low ($batteryLevel%). Charge above $minRecommendedBatteryPercent% before flashing.',
      );
    }

    return PreflightResult(
      passed: errors.isEmpty,
      warnings: warnings,
      errors: errors,
    );
  }
}
