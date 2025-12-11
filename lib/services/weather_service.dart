import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../config/api_config.dart';

class WeatherService {
  final String apiKey;

  WeatherService({required this.apiKey});

  // ========================================================
  // CURRENT WEATHER — BY CITY NAME
  // ========================================================
  Future<WeatherModel> getCurrentWeatherByCity(String cityName) async {
    try {
      final url = ApiConfig.buildUrl(
        ApiConfig.currentWeather,
        {'q': cityName},
      );

      final response = await http
          .get(
            Uri.parse(url),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('City not found. Please check the city name.');
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your configuration.');
      } else {
        throw Exception(
            'Failed to load weather data. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('City not found') ||
          e.toString().contains('Invalid API key')) {
        rethrow;
      }
      throw Exception('Network error: Please check your internet connection.');
    }
  }

  // ========================================================
  // CURRENT WEATHER — BY COORDINATES
  // ========================================================
  Future<WeatherModel> getCurrentWeatherByCoordinates(
      double lat, double lon) async {
    try {
      final url = ApiConfig.buildUrl(
        ApiConfig.currentWeather,
        {'lat': lat.toString(), 'lon': lon.toString()},
      );

      final response = await http
          .get(Uri.parse(url), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Network error: Please check your internet connection.');
    }
  }

  // ========================================================
  // 5-DAY / 3-HOUR FORECAST
  // ========================================================
  Future<List<ForecastModel>> getForecast(String cityName) async {
    try {
      final url = ApiConfig.buildUrl(
        ApiConfig.forecast,
        {'q': cityName},
      );

      final response = await http
          .get(Uri.parse(url), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final forecastList = data['list'] as List<dynamic>? ?? [];

        return forecastList
            .map((item) => ForecastModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load forecast data');
      }
    } catch (e) {
      throw Exception('Failed to load forecast: $e');
    }
  }

  // ========================================================
  // NEW: Get GEO coordinates from city name (for widget + AQI + alerts)
  // ========================================================
  Future<Map<String, double>?> getCoordinatesFromCity(String cityName) async {
    final url =
        "https://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=1&appid=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List && data.isNotEmpty) {
          final c = data[0];
          return {
            "lat": (c["lat"] as num).toDouble(),
            "lon": (c["lon"] as num).toDouble(),
          };
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ========================================================
  // ICON URLs
  // ========================================================
  String getIconUrl(String code) => ApiConfig.getIconUrl(code);
  String getLargeIconUrl(String code) => ApiConfig.getLargeIconUrl(code);
}
