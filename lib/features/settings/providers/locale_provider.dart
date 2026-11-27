import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'locale';
  
  Locale _locale = const Locale('zh');
  
  Locale get locale => _locale;
  
  bool get isZh => _locale.languageCode == 'zh';
  bool get isEn => _locale.languageCode == 'en';
  
  LocaleProvider() {
    _loadLocale();
  }
  
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);
    
    if (localeCode != null) {
      _locale = Locale(localeCode);
    } else {
      _locale = Locale(PlatformDispatcher.instance.locale.languageCode);
      if (_locale.languageCode != 'zh' && _locale.languageCode != 'en') {
        _locale = const Locale('zh');
      }
    }
    notifyListeners();
  }
  
  Future<void> setLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
    _locale = Locale(languageCode);
    notifyListeners();
  }
  
  Future<void> toggleLanguage() async {
    final newLanguageCode = isZh ? 'en' : 'zh';
    await setLocale(newLanguageCode);
  }
}
