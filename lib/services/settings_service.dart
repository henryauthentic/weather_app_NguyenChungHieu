// lib/services/settings_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  // Keys
  static const String _temperatureUnitKey = 'temperature_unit';
  static const String _windSpeedUnitKey = 'wind_speed_unit';
  static const String _timeFormatKey = 'time_format';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _useLocationKey = 'use_location';
  static const String _themeKey = 'theme';
  static const String _languageKey = 'language';

  // Default values (use consistent, canonical strings)
  static const String defaultTemperatureUnit = 'celsius'; // or 'fahrenheit'
  static const String defaultWindSpeedUnit = 'm/s'; // 'm/s' | 'km/h' | 'mph'
  static const String defaultTimeFormat = '24h'; // '24h' | '12h'
  static const bool defaultNotificationsEnabled = false;
  static const bool defaultUseLocation = true;
  static const String defaultTheme = 'system';
  static const String defaultLanguage = 'en';

  // Temperature Unit
  Future<String> getTemperatureUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_temperatureUnitKey) ?? defaultTemperatureUnit;
  }

  Future<void> setTemperatureUnit(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_temperatureUnitKey, unit);
  }

  // Convert temperature based on unit
  double convertTemperature(double celsius, String unit) {
    if (unit == 'fahrenheit') {
      return (celsius * 9 / 5) + 32;
    }
    return celsius;
  }

  // Get temperature symbol
  String getTemperatureSymbol(String unit) {
    return unit == 'fahrenheit' ? '°F' : '°C';
  }

  // Wind Speed Unit (canonical strings)
  Future<String> getWindUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_windSpeedUnitKey) ?? defaultWindSpeedUnit;
  }

  Future<void> setWindSpeedUnit(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_windSpeedUnitKey, unit);
  }

  // Convert wind speed based on unit (input m/s)
  double convertWindSpeed(double metersPerSecond, String unit) {
    switch (unit) {
      case 'km/h':
        return metersPerSecond * 3.6;
      case 'mph':
        return metersPerSecond * 2.23693629;
      default: // m/s
        return metersPerSecond;
    }
  }

  // Get wind speed unit label
  String getWindSpeedLabel(String unit) {
    switch (unit) {
      case 'km/h':
        return 'km/h';
      case 'mph':
        return 'mph';
      default:
        return 'm/s';
    }
  }

  // Time Format (12h or 24h)
  Future<String> getTimeFormat() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_timeFormatKey) ?? defaultTimeFormat;
  }

  Future<void> setTimeFormat(String format) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_timeFormatKey, format);
  }

  // Notifications
  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? defaultNotificationsEnabled;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  // Location
  Future<bool> getUseLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_useLocationKey) ?? defaultUseLocation;
  }

  Future<void> setUseLocation(bool use) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useLocationKey, use);
  }

  // Theme
  Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? defaultTheme;
  }

  Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  // Language
  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? defaultLanguage;
  }

  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  // Reset all settings to default
  Future<void> resetAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_temperatureUnitKey);
    await prefs.remove(_windSpeedUnitKey);
    await prefs.remove(_timeFormatKey);
    await prefs.remove(_notificationsEnabledKey);
    await prefs.remove(_useLocationKey);
    await prefs.remove(_themeKey);
    await prefs.remove(_languageKey);
  }

  // Get all settings as Map
  Future<Map<String, dynamic>> getAllSettings() async {
    return {
      'temperatureUnit': await getTemperatureUnit(),
      'windSpeedUnit': await getWindUnit(),
      'timeFormat': await getTimeFormat(),
      'notificationsEnabled': await getNotificationsEnabled(),
      'useLocation': await getUseLocation(),
      'theme': await getTheme(),
      'language': await getLanguage(),
    };
  }
}
