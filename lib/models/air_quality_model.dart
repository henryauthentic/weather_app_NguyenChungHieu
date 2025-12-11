class AirQualityModel {
  final int aqi;
  final String category;
  final String healthRecommendation;
  final Map<String, double> pollutants;
  final DateTime dateTime;

  AirQualityModel({
    required this.aqi,
    required this.category,
    required this.healthRecommendation,
    required this.pollutants,
    required this.dateTime,
  });

  factory AirQualityModel.fromJson(Map<String, dynamic> json) {
    final list = json['list'][0];
    final components = list['components'];
    final aqi = list['main']['aqi'];
    
    return AirQualityModel(
      aqi: aqi,
      category: _getCategory(aqi),
      healthRecommendation: _getHealthRecommendation(aqi),
      pollutants: {
        'co': (components['co'] ?? 0).toDouble(),
        'no': (components['no'] ?? 0).toDouble(),
        'no2': (components['no2'] ?? 0).toDouble(),
        'o3': (components['o3'] ?? 0).toDouble(),
        'so2': (components['so2'] ?? 0).toDouble(),
        'pm2_5': (components['pm2_5'] ?? 0).toDouble(),
        'pm10': (components['pm10'] ?? 0).toDouble(),
        'nh3': (components['nh3'] ?? 0).toDouble(),
      },
      dateTime: DateTime.fromMillisecondsSinceEpoch(list['dt'] * 1000),
    );
  }

  static String _getCategory(int aqi) {
    switch (aqi) {
      case 1:
        return 'Good';
      case 2:
        return 'Fair';
      case 3:
        return 'Moderate';
      case 4:
        return 'Poor';
      case 5:
        return 'Very Poor';
      default:
        return 'Unknown';
    }
  }

  static String _getHealthRecommendation(int aqi) {
    switch (aqi) {
      case 1:
        return 'Air quality is satisfactory, and air pollution poses little or no risk.';
      case 2:
        return 'Air quality is acceptable. However, there may be a risk for some people, particularly those who are unusually sensitive to air pollution.';
      case 3:
        return 'Members of sensitive groups may experience health effects. The general public is less likely to be affected.';
      case 4:
        return 'Some members of the general public may experience health effects; members of sensitive groups may experience more serious health effects.';
      case 5:
        return 'Health alert: The risk of health effects is increased for everyone. Avoid outdoor activities.';
      default:
        return 'No data available';
    }
  }

  // Get color based on AQI
  int getColor() {
    switch (aqi) {
      case 1:
        return 0xFF00E400; // Green
      case 2:
        return 0xFFFFFF00; // Yellow
      case 3:
        return 0xFFFF7E00; // Orange
      case 4:
        return 0xFFFF0000; // Red
      case 5:
        return 0xFF8F3F97; // Purple
      default:
        return 0xFF808080; // Gray
    }
  }

  // Get icon based on AQI
  String getIcon() {
    switch (aqi) {
      case 1:
        return '😊';
      case 2:
        return '🙂';
      case 3:
        return '😐';
      case 4:
        return '☹️';
      case 5:
        return '😷';
      default:
        return '❓';
    }
  }

  // Get main pollutant
  String getMainPollutant() {
    var maxPollutant = pollutants.entries.first;
    for (var entry in pollutants.entries) {
      if (entry.value > maxPollutant.value) {
        maxPollutant = entry;
      }
    }
    return _formatPollutantName(maxPollutant.key);
  }

  static String _formatPollutantName(String key) {
    switch (key) {
      case 'co':
        return 'Carbon Monoxide (CO)';
      case 'no':
        return 'Nitrogen Monoxide (NO)';
      case 'no2':
        return 'Nitrogen Dioxide (NO2)';
      case 'o3':
        return 'Ozone (O3)';
      case 'so2':
        return 'Sulphur Dioxide (SO2)';
      case 'pm2_5':
        return 'PM2.5';
      case 'pm10':
        return 'PM10';
      case 'nh3':
        return 'Ammonia (NH3)';
      default:
        return key.toUpperCase();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'aqi': aqi,
      'category': category,
      'healthRecommendation': healthRecommendation,
      'pollutants': pollutants,
      'dateTime': dateTime.millisecondsSinceEpoch,
    };
  }
}