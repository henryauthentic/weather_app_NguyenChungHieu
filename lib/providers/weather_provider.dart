import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import '../services/weather_backup_service.dart';

enum WeatherState { initial, loading, loaded, error }

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService;
  final LocationService _locationService;
  final StorageService _storageService;

  late final WeatherBackupService _backupService;

  WeatherModel? _currentWeather;
  List<ForecastModel> _forecast = [];
  WeatherState _state = WeatherState.initial;
  String _errorMessage = '';
  bool _isOffline = false;

  double? _currentLatitude;
  double? _currentLongitude;

  WeatherProvider(
    this._weatherService,
    this._locationService,
    this._storageService,
  ) {
    _backupService = WeatherBackupService(
      apiKey: dotenv.env['WEATHER_API_KEY'] ?? '',
    );
  }

  WeatherModel? get currentWeather => _currentWeather;
  List<ForecastModel> get forecast => _forecast;
  WeatherState get state => _state;
  String get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;

  double? get currentLatitude => _currentLatitude;
  double? get currentLongitude => _currentLongitude;

  List<ForecastModel> get hourlyForecast {
    if (_forecast.isEmpty) return [];
    final now = DateTime.now();
    return _forecast.where((f) =>
      f.dateTime.isAfter(now) &&
      f.dateTime.isBefore(now.add(const Duration(hours: 24)))
    ).toList();
  }

  List<List<ForecastModel>> get dailyForecast {
    if (_forecast.isEmpty) return [];
    Map<String, List<ForecastModel>> result = {};
    for (var f in _forecast) {
      final key = "${f.dateTime.year}-${f.dateTime.month}-${f.dateTime.day}";
      result.putIfAbsent(key, () => []);
      result[key]!.add(f);
    }
    return result.values.toList();
  }

  // =============================
  // FETCH BY CITY
  // =============================
  Future<void> fetchWeatherByCity(String cityName) async {
    _state = WeatherState.loading;
    _isOffline = false;
    notifyListeners();

    try {
      _currentWeather = await _weatherService.getCurrentWeatherByCity(cityName);
      _forecast = await _weatherService.getForecast(cityName);

      _currentLatitude = await _getLatitudeFromCity(cityName);
      _currentLongitude = await _getLongitudeFromCity(cityName);

      await _storageService.saveWeatherData(_currentWeather!);
      await _storageService.saveLastCity(cityName);
      await _storageService.addRecentSearch(cityName);

      _state = WeatherState.loaded;
      _errorMessage = '';

      await _updateHomeWidget();
    }

    catch (e) {
      print("⚠ Main API failed → using Backup API");

      try {
        final backup = await _backupService.getWeather(cityName);
        final backupForecast = await _backupService.getForecast(cityName);

        _currentWeather = WeatherModel(
          cityName: backup["location"]["name"],
          country: backup["location"]["country"],
          temperature: backup["current"]["temp_c"].toDouble(),
          feelsLike: backup["current"]["feelslike_c"].toDouble(),
          humidity: backup["current"]["humidity"],
          windSpeed: backup["current"]["wind_kph"] / 3.6,
          windDegree: backup["current"]["wind_degree"],   // ✔ ADDED
          pressure: backup["current"]["pressure_mb"],
          description: backup["current"]["condition"]["text"],
          icon: backup["current"]["condition"]["icon"],
          mainCondition: backup["current"]["condition"]["text"],
          dateTime: DateTime.now(),
        );

        _currentLatitude = backup["location"]["lat"].toDouble();
        _currentLongitude = backup["location"]["lon"].toDouble();

        _forecast = (backupForecast["forecast"]["forecastday"] as List)
            .expand((day) => day["hour"])
            .map((h) => ForecastModel.fromJson({
                "dt": DateTime.parse(h["time"])
                    .millisecondsSinceEpoch ~/ 1000,
                "main": {
                  "temp": h["temp_c"],
                  "temp_min": h["temp_c"],
                  "temp_max": h["temp_c"],
                  "humidity": h["humidity"],
                },
                "weather": [
                  {
                    "description": h["condition"]["text"],
                    "icon": h["condition"]["icon"],
                    "main": h["condition"]["text"],
                  }
                ],
                "wind": {
                  "speed": h["wind_kph"] / 3.6,
                  "deg": h["wind_degree"],        // ✔ ADDED
                }
            }))
            .toList();

        _state = WeatherState.loaded;
        _errorMessage = '';

        await _updateHomeWidget();
      }

      catch (backupError) {
        _state = WeatherState.error;
        _errorMessage = "Both APIs failed: $backupError";
        await loadCachedWeather();
      }
    }

    notifyListeners();
  }

  // =============================
  // FETCH BY GPS
  // =============================
  Future<void> fetchWeatherByLocation() async {
    _state = WeatherState.loading;
    notifyListeners();

    try {
      final pos = await _locationService.getCurrentLocation();

      _currentLatitude = pos.latitude;
      _currentLongitude = pos.longitude;

      _currentWeather = await _weatherService.getCurrentWeatherByCoordinates(
        pos.latitude,
        pos.longitude,
      );

      final cityName =
        await _locationService.getCityName(pos.latitude, pos.longitude);

      _forecast = await _weatherService.getForecast(cityName);

      await _storageService.saveWeatherData(_currentWeather!);
      await _storageService.saveLastCity(cityName);

      _state = WeatherState.loaded;
      _errorMessage = '';

      await _updateHomeWidget();
    }

    catch (e) {
      _state = WeatherState.error;
      _errorMessage = e.toString();

      await loadCachedWeather();
    }

    notifyListeners();
  }

  // =============================
  // SAVE WIDGET
  // =============================
  Future<void> _updateHomeWidget() async {
    if (_currentWeather == null) return;

    await HomeWidget.saveWidgetData("city", _currentWeather!.cityName);
    await HomeWidget.saveWidgetData("temp",
        "${_currentWeather!.temperature.round()}°C");
    await HomeWidget.saveWidgetData("condition",
        _currentWeather!.description);

    await HomeWidget.saveWidgetData("wind",
        "${_currentWeather!.windSpeed.toStringAsFixed(1)} m/s");
    await HomeWidget.saveWidgetData("humidity",
        "${_currentWeather!.humidity}%");
    await HomeWidget.saveWidgetData("pressure",
        "${_currentWeather!.pressure} hPa");
    await HomeWidget.saveWidgetData("visibility",
        (_currentWeather!.visibility ?? 0).toString());

    await HomeWidget.saveWidgetData("updated_at",
        DateFormat('HH:mm').format(DateTime.now()));

    await HomeWidget.updateWidget(androidName: "WeatherWidgetProvider");
  }

  // =============================
  // UTILITIES
  // =============================
  Future<Map<String, double>?> _getCoordinatesFromCity(String name) {
    return _weatherService.getCoordinatesFromCity(name);
  }

  Future<double?> _getLatitudeFromCity(String cityName) async {
    final c = await _getCoordinatesFromCity(cityName);
    return c?["lat"];
  }

  Future<double?> _getLongitudeFromCity(String cityName) async {
    final c = await _getCoordinatesFromCity(cityName);
    return c?["lon"];
  }

  Future<void> loadCachedWeather() async {
    final cached = await _storageService.getCachedWeather();

    if (cached != null) {
      _currentWeather = cached;
      _isOffline = true;

      if (_state == WeatherState.error) {
        _state = WeatherState.loaded;
      }

      await _updateHomeWidget();
      notifyListeners();
    }
  }

  Future<void> refreshWeather() async {
    if (_currentWeather != null) {
      await fetchWeatherByCity(_currentWeather!.cityName);
    } else {
      await fetchWeatherByLocation();
    }
  }

  Future<void> initialize() async {
    await loadCachedWeather();

    final lastCity = await _storageService.getLastCity();
    if (lastCity != null) {
      await fetchWeatherByCity(lastCity);
    } else {
      await fetchWeatherByLocation();
    }
  }

}
