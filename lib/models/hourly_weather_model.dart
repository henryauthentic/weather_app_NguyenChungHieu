class HourlyWeatherModel {
  final DateTime dateTime;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final String description;
  final String icon;
  final String mainCondition;
  final int? cloudiness;
  final double? precipitationProbability;
  final double? rain;
  final double? snow;

  HourlyWeatherModel({
    required this.dateTime,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.description,
    required this.icon,
    required this.mainCondition,
    this.cloudiness,
    this.precipitationProbability,
    this.rain,
    this.snow,
  });

  factory HourlyWeatherModel.fromJson(Map<String, dynamic> json) {
    return HourlyWeatherModel(
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] ?? 0) * 1000,
      ),
      temperature: (json['main']['temp'] ?? 0).toDouble(),
      feelsLike: (json['main']['feels_like'] ?? 0).toDouble(),
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] ?? 0).toDouble(),
      pressure: json['main']['pressure'] ?? 0,
      description: json['weather'][0]['description'] ?? 'Unknown',
      icon: json['weather'][0]['icon'] ?? '01d',
      mainCondition: json['weather'][0]['main'] ?? 'Clear',
      cloudiness: json['clouds']?['all'],
      precipitationProbability: json['pop'] != null 
          ? (json['pop'] * 100).toDouble() 
          : null,
      rain: json['rain']?['3h']?.toDouble(),
      snow: json['snow']?['3h']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dt': dateTime.millisecondsSinceEpoch ~/ 1000,
      'main': {
        'temp': temperature,
        'feels_like': feelsLike,
        'humidity': humidity,
        'pressure': pressure,
      },
      'wind': {'speed': windSpeed},
      'weather': [
        {
          'description': description,
          'icon': icon,
          'main': mainCondition,
        }
      ],
      'clouds': {'all': cloudiness},
      'pop': precipitationProbability != null 
          ? precipitationProbability! / 100 
          : null,
      'rain': rain != null ? {'3h': rain} : null,
      'snow': snow != null ? {'3h': snow} : null,
    };
  }

  // Helper method to get formatted temperature
  String get temperatureString => '${temperature.round()}°';
  
  // Helper method to get feels like temperature
  String get feelsLikeString => '${feelsLike.round()}°';
  
  // Helper method to check if it's day or night
  bool get isDay => icon.endsWith('d');
  
  // Helper method to get precipitation info
  String? get precipitationInfo {
    if (rain != null && rain! > 0) {
      return 'Rain: ${rain!.toStringAsFixed(1)}mm';
    } else if (snow != null && snow! > 0) {
      return 'Snow: ${snow!.toStringAsFixed(1)}mm';
    }
    return null;
  }
  
  // Helper method to get precipitation probability
  String? get precipitationProbabilityString {
    if (precipitationProbability != null) {
      return '${precipitationProbability!.round()}%';
    }
    return null;
  }
  
  // Copy with
  HourlyWeatherModel copyWith({
    DateTime? dateTime,
    double? temperature,
    double? feelsLike,
    int? humidity,
    double? windSpeed,
    int? pressure,
    String? description,
    String? icon,
    String? mainCondition,
    int? cloudiness,
    double? precipitationProbability,
    double? rain,
    double? snow,
  }) {
    return HourlyWeatherModel(
      dateTime: dateTime ?? this.dateTime,
      temperature: temperature ?? this.temperature,
      feelsLike: feelsLike ?? this.feelsLike,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      pressure: pressure ?? this.pressure,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      mainCondition: mainCondition ?? this.mainCondition,
      cloudiness: cloudiness ?? this.cloudiness,
      precipitationProbability: precipitationProbability ?? this.precipitationProbability,
      rain: rain ?? this.rain,
      snow: snow ?? this.snow,
    );
  }

  @override
  String toString() {
    return 'HourlyWeatherModel(time: $dateTime, temp: $temperature°C, condition: $mainCondition)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is HourlyWeatherModel &&
      other.dateTime == dateTime &&
      other.temperature == temperature &&
      other.mainCondition == mainCondition;
  }

  @override
  int get hashCode {
    return dateTime.hashCode ^
      temperature.hashCode ^
      mainCondition.hashCode;
  }
}