import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../core/process/process_runner.dart';

class DriverInfo {
  final String name;
  final String description;
  final String executableName;
  final String icon;
  final String publisher;
  final String supportedModes;
  final String? officialUrl;
  final bool isExternalOfficialDownload;

  const DriverInfo({
    required this.name,
    required this.description,
    required this.executableName,
    required this.icon,
    required this.publisher,
    required this.supportedModes,
    this.officialUrl,
    this.isExternalOfficialDownload = false,
  });
}

class DriverSignatureResult {
  final bool checked;
  final bool isValid;
  final String status;
  final String? signer;

  const DriverSignatureResult({
    required this.checked,
    required this.isValid,
    required this.status,
    this.signer,
  });
}

class DriverInstallResult {
  final bool launched;
  final String? errorMessage;
  final DriverSignatureResult? signature;

  const DriverInstallResult({
    required this.launched,
    this.errorMessage,
    this.signature,
  });
}

class DriverService {
  final ProcessRunner _processRunner;

  DriverService({ProcessRunner? processRunner})
      : _processRunner = processRunner ?? const DefaultProcessRunner();

  static const DriverInfo samsungDriver = DriverInfo(
    name: 'Samsung USB Driver for Mobile Phones',
    description:
        'Official Samsung Electronics USB driver for Galaxy devices (ADB & Download/Odin mode). Opens the official Samsung Developers download page.',
    executableName: '',
    icon: 'smartphone',
    publisher: 'Samsung Electronics Co., Ltd.',
    supportedModes: 'ADB / MTP / Download Mode',
    officialUrl: 'https://developer.samsung.com/android-usb-driver',
    isExternalOfficialDownload: true,
  );

  static const List<DriverInfo> drivers = [
    DriverInfo(
      name: 'qualcommDriver64',
      description: 'qualcommDriver64Desc',
      executableName: 'fastboot_driver_64.exe',
      icon: 'memory',
      publisher: 'Qualcomm / Google WinUSB (Bundled)',
      supportedModes: 'Fastboot (64-bit)',
    ),
    DriverInfo(
      name: 'qualcommDriver32',
      description: 'qualcommDriver32Desc',
      executableName: 'fastboot_driver_32.exe',
      icon: 'memory',
      publisher: 'Qualcomm / Google WinUSB (Bundled)',
      supportedModes: 'Fastboot (32-bit)',
    ),
    DriverInfo(
      name: 'mediatekDriver',
      description: 'mediatekDriverDesc',
      executableName: 'MTK_USB_All_v1.0.8.exe',
      icon: 'developer_board',
      publisher: 'MediaTek Inc. (Bundled)',
      supportedModes: 'ADB / Fastboot / VCOM',
    ),
    DriverInfo(
      name: 'oneplusAdbDriver',
      description: 'oneplusAdbDriverDesc',
      executableName: 'adb_driver.exe',
      icon: 'phone_android',
      publisher: 'OnePlus Technology (Bundled)',
      supportedModes: 'ADB / Fastboot',
    ),
    DriverInfo(
      name: 'oppoAdbDriver',
      description: 'oppoAdbDriverDesc',
      executableName: 'Oppo+USB+Driver+Setup+V4.0.1.6.exe',
      icon: 'smartphone',
      publisher: 'OPPO Electronics (Bundled)',
      supportedModes: 'ADB / Fastboot',
    ),
  ];

  Future<String> _getDriverPath(String executableName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final driverDir = p.join(appDir.path, 'FolkTool', 'drivers');
    final driverPath = p.join(driverDir, executableName);

    final file = File(driverPath);
    if (!await file.exists()) {
      await file.parent.create(recursive: true);
      final assetPath = 'drive/$executableName';
      final data = await rootBundle.load(assetPath);
      await file.writeAsBytes(data.buffer.asUint8List());
    }

    return driverPath;
  }

  /// Checks Windows Authenticode signature for an extracted driver installer.
  Future<DriverSignatureResult> verifySignature(String filePath) async {
    if (!Platform.isWindows) {
      return const DriverSignatureResult(
        checked: false,
        isValid: true,
        status: 'Non-Windows host',
      );
    }
    try {
      final result = await _processRunner.run(
        'powershell',
        [
          '-NoProfile',
          '-NonInteractive',
          '-Command',
          r'$sig = Get-AuthenticodeSignature -LiteralPath $args[0]; '
              r'Write-Output "$($sig.Status)|$($sig.SignerCertificate.Subject)"',
          filePath,
        ],
        timeout: const Duration(seconds: 15),
      );
      if (result.exitCode != 0) {
        return const DriverSignatureResult(
          checked: true,
          isValid: false,
          status: 'VerificationError',
        );
      }
      final out = result.stdout.toString().trim();
      final parts = out.split('|');
      final status = parts.isNotEmpty ? parts[0].trim() : 'Unknown';
      final signer = parts.length > 1 ? parts[1].trim() : null;
      return DriverSignatureResult(
        checked: true,
        isValid: status == 'Valid',
        status: status,
        signer: (signer != null && signer.isNotEmpty) ? signer : null,
      );
    } catch (e) {
      return DriverSignatureResult(
        checked: true,
        isValid: false,
        status: 'Error: $e',
      );
    }
  }

  /// Verifies and launches a bundled driver installer with explicit details.
  Future<DriverInstallResult> installDriverDetailed(
    String executableName, {
    bool allowUnsigned = false,
  }) async {
    try {
      final driverPath = await _getDriverPath(executableName);
      final file = File(driverPath);

      if (!await file.exists()) {
        return const DriverInstallResult(
          launched: false,
          errorMessage: 'Driver executable not found after extraction.',
        );
      }

      final sig = await verifySignature(driverPath);
      if (sig.checked && !sig.isValid && !allowUnsigned) {
        return DriverInstallResult(
          launched: false,
          signature: sig,
          errorMessage:
              'Authenticode signature status is "${sig.status}". Refusing to run unverified installer automatically.',
        );
      }

      await _processRunner.run(
        driverPath,
        const [],
        timeout: const Duration(minutes: 10),
      );
      return DriverInstallResult(launched: true, signature: sig);
    } catch (e) {
      return DriverInstallResult(
        launched: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> installDriver(String executableName) async {
    final res = await installDriverDetailed(executableName, allowUnsigned: true);
    return res.launched;
  }
}
