import 'patch_target.dart';

class KpVersion {
  final String version;
  final String kpimgPath;
  final bool isCustom;
  final bool supportsUnpack;
  final PatchTarget source;

  KpVersion({
    required this.version,
    required this.kpimgPath,
    this.isCustom = false,
    bool? supportsUnpack,
    required this.source,
  }) : supportsUnpack = supportsUnpack ?? _checkUnpackSupport(version);

  static bool _checkUnpackSupport(String version) {
    return _compareVersions(version, '0.13.0') >= 0;
  }

  static int _compareVersions(String v1, String v2) {
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

  bool get isNewerThan013 => supportsUnpack;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KpVersion && other.version == version && other.kpimgPath == kpimgPath && other.source == source;
  }

  @override
  int get hashCode => Object.hash(version, kpimgPath, source);

  @override
  String toString() {
    return 'KpVersion(version: $version, kpimgPath: $kpimgPath, isCustom: $isCustom, supportsUnpack: $supportsUnpack, source: $source)';
  }
}
