// lib/services/weather_backup_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherBackupService {
  final String apiKey;

  WeatherBackupService({required this.apiKey});

  /// Fetch current weather from WeatherAPI.com
  Future<Map<String, dynamic>> getWeather(String city) async {
    final url = Uri.parse(
      "https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$city&aqi=no",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Backup API error: ${response.body}");
    }
  }

  /// Fetch forecast from WeatherAPI.com
  Future<Map<String, dynamic>> getForecast(String city) async {
    final url = Uri.parse(
      "https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$city&days=5&aqi=no",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Backup Forecast Error: ${response.body}");
    }
  }
}
