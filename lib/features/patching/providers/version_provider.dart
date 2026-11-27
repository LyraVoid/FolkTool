import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/app_config.dart';
import '../models/kp_version.dart';
import '../models/patch_target.dart';
import '../services/version_service.dart';

class VersionProvider extends ChangeNotifier {
  final VersionService _versionService = VersionService();

  List<KpVersion> _availableVersions = [];
  KpVersion? _selectedVersion;
  String? _customVersionPath;
  bool _isLoading = false;

  PatchTarget _currentTarget = PatchTarget.folkpatch;
  PatchTarget get currentTarget => _currentTarget;

  List<KpVersion> get availableVersions =>
      List.unmodifiable(_availableVersions);
  KpVersion? get selectedVersion => _selectedVersion;
  String? get customVersionPath => _customVersionPath;
  bool get isLoading => _isLoading;

  void setTarget(PatchTarget target) {
    if (_currentTarget != target) {
      _currentTarget = target;
      _selectedVersion = null;
      _customVersionPath = null;
      _saveTarget();
      loadVersions();
    }
  }

  Future<void> _saveTarget() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.patchTargetKey, _currentTarget.name);
  }

  Future<void> _loadTarget() async {
    final prefs = await SharedPreferences.getInstance();
    final targetName = prefs.getString(AppConfig.patchTargetKey);
    if (targetName != null) {
      _currentTarget = PatchTarget.values.firstWhere(
        (t) => t.name == targetName,
        orElse: () => PatchTarget.folkpatch,
      );
    }
  }

  Future<void> loadVersions() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadTarget();

      _availableVersions =
          await _versionService.getAvailableVersions(source: _currentTarget);

      if (_availableVersions.isNotEmpty && _selectedVersion == null) {
        final defaultVersion = _availableVersions.firstWhere(
          (v) => v.version == AppConfig.minVersionWithUnpack,
          orElse: () => _availableVersions.first,
        );
        _selectedVersion = defaultVersion;
      }

      await _loadSavedVersion();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadSavedVersion() async {
    final prefs = await SharedPreferences.getInstance();
    final savedVersion = prefs.getString(AppConfig.selectedVersionKey);
    final customPath = prefs.getString(AppConfig.customVersionPathKey);

    if (customPath != null && customPath.isNotEmpty) {
      final customVersion = await _versionService.validateCustomVersion(
        customPath,
        source: _currentTarget,
      );
      if (customVersion != null) {
        _selectedVersion = customVersion;
        _customVersionPath = customPath;
        return;
      }
    }

    if (savedVersion != null && savedVersion.isNotEmpty) {
      final version =
          _availableVersions.where((v) => v.version == savedVersion).firstOrNull;
      if (version != null) {
        _selectedVersion = version;
      }
    }
  }

  void selectVersion(KpVersion version) {
    _selectedVersion = version;
    if (!version.isCustom) {
      _customVersionPath = null;
    }
    _saveSelectedVersion();
    notifyListeners();
  }

  Future<bool> selectCustomVersion(String filePath) async {
    final version = await _versionService.validateCustomVersion(
      filePath,
      source: _currentTarget,
    );
    if (version == null) {
      return false;
    }

    _selectedVersion = version;
    _customVersionPath = filePath;
    _saveSelectedVersion();
    notifyListeners();
    return true;
  }

  Future<void> _saveSelectedVersion() async {
    final prefs = await SharedPreferences.getInstance();

    if (_selectedVersion != null) {
      if (_selectedVersion!.isCustom) {
        await prefs.setString(AppConfig.selectedVersionKey, 'custom');
        if (_customVersionPath != null) {
          await prefs.setString(
            AppConfig.customVersionPathKey,
            _customVersionPath!,
          );
        }
      } else {
        await prefs.setString(
          AppConfig.selectedVersionKey,
          _selectedVersion!.version,
        );
        await prefs.remove(AppConfig.customVersionPathKey);
      }
    }
  }

  KpVersion? getDefaultVersion() {
    if (_availableVersions.isEmpty) return null;

    return _availableVersions.firstWhere(
      (v) => v.version == AppConfig.minVersionWithUnpack,
      orElse: () => _availableVersions.first,
    );
  }
}
