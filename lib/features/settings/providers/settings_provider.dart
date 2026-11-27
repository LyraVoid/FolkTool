import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists user preferences for monitoring, safety confirmations, and diagnostics.
class SettingsProvider extends ChangeNotifier {
  static const String _autoMonitorKey = 'settings_auto_monitor';
  static const String _confirmFlashKey = 'settings_confirm_flash';
  static const String _redactDiagKey = 'settings_redact_diagnostics';
  static const String _checkUpdatesKey = 'settings_check_updates';

  bool _autoMonitorDevices = true;
  bool _confirmBeforeFlash = true;
  bool _redactDiagnostics = true;
  bool _checkUpdatesOnLaunch = true;

  bool get autoMonitorDevices => _autoMonitorDevices;
  bool get confirmBeforeFlash => _confirmBeforeFlash;
  bool get redactDiagnostics => _redactDiagnostics;
  bool get checkUpdatesOnLaunch => _checkUpdatesOnLaunch;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _autoMonitorDevices = prefs.getBool(_autoMonitorKey) ?? true;
    _confirmBeforeFlash = prefs.getBool(_confirmFlashKey) ?? true;
    _redactDiagnostics = prefs.getBool(_redactDiagKey) ?? true;
    _checkUpdatesOnLaunch = prefs.getBool(_checkUpdatesKey) ?? true;
    notifyListeners();
  }

  Future<void> setAutoMonitorDevices(bool value) async {
    if (_autoMonitorDevices == value) return;
    _autoMonitorDevices = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoMonitorKey, value);
  }

  Future<void> setConfirmBeforeFlash(bool value) async {
    if (_confirmBeforeFlash == value) return;
    _confirmBeforeFlash = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_confirmFlashKey, value);
  }

  Future<void> setRedactDiagnostics(bool value) async {
    if (_redactDiagnostics == value) return;
    _redactDiagnostics = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_redactDiagKey, value);
  }

  Future<void> setCheckUpdatesOnLaunch(bool value) async {
    if (_checkUpdatesOnLaunch == value) return;
    _checkUpdatesOnLaunch = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_checkUpdatesKey, value);
  }

  Future<void> resetToDefaults() async {
    _autoMonitorDevices = true;
    _confirmBeforeFlash = true;
    _redactDiagnostics = true;
    _checkUpdatesOnLaunch = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_autoMonitorKey);
    await prefs.remove(_confirmFlashKey);
    await prefs.remove(_redactDiagKey);
    await prefs.remove(_checkUpdatesKey);
  }
}