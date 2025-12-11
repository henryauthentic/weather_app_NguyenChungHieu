import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _service = SettingsService();

  String temperatureUnit = 'celsius';
  String windUnit = 'm/s';
  String timeFormat = '24h';
  String language = 'en';

  bool notifications = false;
  bool useLocation = true;

  bool isLoaded = false;

  SettingsProvider() {
    load();
  }

  Future<void> load() async {
    temperatureUnit = await _service.getTemperatureUnit();
    windUnit = await _service.getWindUnit();
    timeFormat = await _service.getTimeFormat();
    language = await _service.getLanguage();
    notifications = await _service.getNotificationsEnabled();
    useLocation = await _service.getUseLocation();

    isLoaded = true;
    notifyListeners();
  }

  Future<void> setTemperatureUnit(String v) async {
    await _service.setTemperatureUnit(v);
    temperatureUnit = v;
    notifyListeners();
  }

  Future<void> setWindUnit(String v) async {
    await _service.setWindSpeedUnit(v);
    windUnit = v;
    notifyListeners();
  }

  Future<void> setTimeFormat(String v) async {
    await _service.setTimeFormat(v);
    timeFormat = v;
    notifyListeners();
  }

  Future<void> setLanguage(String v) async {
    await _service.setLanguage(v);
    language = v;
    notifyListeners();
  }

  Future<void> setNotifications(bool v) async {
    await _service.setNotificationsEnabled(v);
    notifications = v;
    notifyListeners();
  }

  Future<void> setUseLocation(bool v) async {
    await _service.setUseLocation(v);
    useLocation = v;
    notifyListeners();
  }
}
