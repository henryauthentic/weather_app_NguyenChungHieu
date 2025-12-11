class ForecastModel {
  final DateTime dateTime;
  final double temperature;
  final String description;
  final String icon;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final int? windDegree; // 🔥 NEW: Wind direction
  final String mainCondition;
  final int pressure;
  final int? pop; // 🔥 NEW: Probability of Precipitation (0-100)

  ForecastModel({
    required this.dateTime,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    this.windDegree,
    required this.mainCondition,
    required this.pressure,
    this.pop,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] ?? 0) * 1000,
      ),
      temperature: (json['main']['temp'] ?? 0).toDouble(),
      description: json['weather'][0]['description'] ?? 'Unknown',
      icon: json['weather'][0]['icon'] ?? '01d',
      tempMin: (json['main']['temp_min'] ?? 0).toDouble(),
      tempMax: (json['main']['temp_max'] ?? 0).toDouble(),
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] ?? 0).toDouble(),
      windDegree: json['wind']['deg'], // 🔥 Parse wind direction
      mainCondition: json['weather'][0]['main'] ?? 'Clear',
      pressure: json['main']['pressure'] ?? 0,
      pop: json['pop'] != null 
          ? (json['pop'] * 100).toInt() // OpenWeather returns 0.0-1.0
          : null,
    );
  }

  String get temperatureString => '${temperature.round()}°';
  String get temperatureRange => '${tempMin.round()}° / ${tempMax.round()}°';
  
  // 🔥 Helper: Get wind direction as text
  String get windDirection {
    if (windDegree == null) return 'N/A';
    final directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((windDegree! + 22.5) / 45).floor() % 8;
    return directions[index];
  }
}