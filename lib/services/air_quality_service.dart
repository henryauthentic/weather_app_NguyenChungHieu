import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/air_quality_model.dart';
//import '../config/api_config.dart';

class AirQualityService {
  final String apiKey;

  AirQualityService({required this.apiKey});

  // Get air quality by coordinates
  Future<AirQualityModel> getAirQuality(double lat, double lon) async {
    try {
      final url = 'http://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$apiKey';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AirQualityModel.fromJson(data);
      } else {
        throw Exception('Failed to load air quality data');
      }
    } catch (e) {
      throw Exception('Error fetching air quality: ${e.toString()}');
    }
  }

  // Get air quality forecast
  Future<List<AirQualityModel>> getAirQualityForecast(double lat, double lon) async {
    try {
      final url = 'http://api.openweathermap.org/data/2.5/air_pollution/forecast?lat=$lat&lon=$lon&appid=$apiKey';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = data['list'] as List;
        
        return list.map((item) {
          return AirQualityModel.fromJson({'list': [item]});
        }).toList();
      } else {
        throw Exception('Failed to load air quality forecast');
      }
    } catch (e) {
      throw Exception('Error fetching air quality forecast: ${e.toString()}');
    }
  }
}