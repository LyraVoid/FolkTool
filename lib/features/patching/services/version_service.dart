import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../core/config/app_config.dart';
import '../models/kp_version.dart';
import '../models/patch_target.dart';

class VersionService {
  Future<List<KpVersion>> getAvailableVersions({
    required PatchTarget source,
  }) async {
    final versions = <KpVersion>[];
    final kpimgPath = AppConfig.kpimgFilePathForSource(source.directoryName);

    debugPrint(
      '[VersionService] kpVersionsBasePath: ${AppConfig.kpVersionsBasePath}',
    );
    debugPrint(
      '[VersionService] Checking kpimg for ${source.directoryName}: $kpimgPath',
    );

    if (await File(kpimgPath).exists()) {
      versions.add(KpVersion(
        version: AppConfig.defaultKpVersion,
        kpimgPath: kpimgPath,
        isCustom: false,
        source: source,
      ));
    }

    return versions;
  }

  Future<KpVersion?> validateCustomVersion(
    String filePath, {
    required PatchTarget source,
  }) async {
    if (!await File(filePath).exists()) {
      return null;
    }

    return KpVersion(
      version: 'custom',
      kpimgPath: filePath,
      isCustom: true,
      source: source,
    );
  }

  int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final parts2 = v2.split('.').map((p) => int.tryParse(p) ?? 0).toList();

    final maxLen =
        parts1.length > parts2.length ? parts1.length : parts2.length;

    for (var i = 0; i < maxLen; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;

      if (p1 != p2) {
        return p1.compareTo(p2);
      }
    }

    return 0;
  }

  bool isVersionSupportsUnpack(String version) =>
      _compareVersions(version, AppConfig.minVersionWithUnpack) >= 0;
}
