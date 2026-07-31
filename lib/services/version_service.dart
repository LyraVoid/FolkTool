import 'dart:io';
import 'package:flutter/foundation.dart';
import '../config/constants.dart';
import '../models/kp_version.dart';
import '../models/patch_target.dart';

class VersionService {
  Future<List<KpVersion>> getAvailableVersions({required PatchTarget source}) async {
    final versions = <KpVersion>[];

    // 不再区分版本号：每个源直接读取单一 kpimg 文件（kp_versions/<源>/kpimg）
    final kpimgPath = Constants.getKpimgFilePath(source);

    debugPrint('[VersionService] kpVersionsBasePath: ${Constants.kpVersionsBasePath}');
    debugPrint('[VersionService] Checking single kpimg for ${source.directoryName}: $kpimgPath');
    debugPrint('[VersionService] kpimg exists: ${await File(kpimgPath).exists()}');

    if (await File(kpimgPath).exists()) {
      versions.add(KpVersion(
        version: Constants.defaultKpVersion,
        kpimgPath: kpimgPath,
        isCustom: false,
        source: source,
      ));
      debugPrint('[VersionService] Added single kpimg for ${source.directoryName}');
    } else {
      debugPrint('[VersionService] kpimg not found for ${source.directoryName}!');
    }

    return versions;
  }
  
  Future<KpVersion?> validateCustomVersion(String filePath, {required PatchTarget source}) async {
    final file = File(filePath);

    if (!await file.exists()) {
      return null;
    }

    // 不再限制文件名，允许任何文件作为自定义版本
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
    
    final maxLen = parts1.length > parts2.length ? parts1.length : parts2.length;
    
    for (var i = 0; i < maxLen; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;
      
      if (p1 != p2) {
        return p1.compareTo(p2);
      }
    }
    
    return 0;
  }
  
  bool isVersionSupportsUnpack(String version) {
    return _compareVersions(version, Constants.minVersionWithUnpack) >= 0;
  }
}
