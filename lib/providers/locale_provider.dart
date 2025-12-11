import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = "app_locale";

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  /// Load locale từ SharedPreferences
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);

    _locale = Locale(code ?? 'en');
    notifyListeners();
  }

  /// Đổi ngôn ngữ (chỉ đổi ở đây thôi)
  Future<void> setLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);

    _locale = Locale(languageCode);
    notifyListeners();
  }

  /// Reset về mặc định
  Future<void> clearLocale() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localeKey);

    _locale = const Locale('en');
    notifyListeners();
  }
}
