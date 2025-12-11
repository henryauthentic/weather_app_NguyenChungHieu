import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';

class StorageService {
  static const String _weatherKey = 'cached_weather';
  static const String _lastUpdateKey = 'last_update';
  static const String _favoriteCitiesKey = 'favorite_cities';
  static const String _recentSearchesKey = 'recent_searches';
  static const String _temperatureUnitKey = 'temperature_unit';
  static const String _lastCityKey = 'last_city';

  // Save weather data
  Future<void> saveWeatherData(WeatherModel weather) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weatherKey, json.encode(weather.toJson()));
    await prefs.setInt(
      _lastUpdateKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  // Get cached weather data
  Future<WeatherModel?> getCachedWeather() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final weatherJson = prefs.getString(_weatherKey);
      
      if (weatherJson != null) {
        return WeatherModel.fromJson(json.decode(weatherJson));
      }
    } catch (e) {
      // If there's an error parsing, return null
      return null;
    }
    return null;
  }

  // Check if cache is valid (less than 30 minutes old)
  Future<bool> isCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getInt(_lastUpdateKey);
    
    if (lastUpdate == null) return false;
    
    final difference = DateTime.now().millisecondsSinceEpoch - lastUpdate;
    return difference < 30 * 60 * 1000; // 30 minutes
  }

  // Get cache age in minutes
  Future<int?> getCacheAgeMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getInt(_lastUpdateKey);
    
    if (lastUpdate == null) return null;
    
    final difference = DateTime.now().millisecondsSinceEpoch - lastUpdate;
    return difference ~/ (60 * 1000);
  }

  // Save favorite cities
  Future<void> saveFavoriteCities(List<String> cities) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoriteCitiesKey, cities);
  }

  // Get favorite cities
  Future<List<String>> getFavoriteCities() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoriteCitiesKey) ?? [];
  }

  // Add to recent searches
  Future<void> addRecentSearch(String city) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recent = prefs.getStringList(_recentSearchesKey) ?? [];
    
    // Remove if already exists
    recent.remove(city);
    
    // Add to beginning
    recent.insert(0, city);
    
    // Keep only last 10 searches
    if (recent.length > 10) {
      recent = recent.sublist(0, 10);
    }
    
    await prefs.setStringList(_recentSearchesKey, recent);
  }

  // Get recent searches
  Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentSearchesKey) ?? [];
  }

  // Clear recent searches
  Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchesKey);
  }

  // Save temperature unit preference
  Future<void> saveTemperatureUnit(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_temperatureUnitKey, unit);
  }

  // Get temperature unit preference
  Future<String> getTemperatureUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_temperatureUnitKey) ?? 'celsius';
  }

  // Save last searched city
  Future<void> saveLastCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCityKey, city);
  }

  // Get last searched city
  Future<String?> getLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastCityKey);
  }

  // Clear all cached data
  Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_weatherKey);
    await prefs.remove(_lastUpdateKey);
  }
}