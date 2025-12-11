class WeatherModel {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final String description;
  final String icon;
  final String mainCondition;
  final DateTime dateTime;

  final double? tempMin;
  final double? tempMax;
  final int? visibility;
  final int? cloudiness;
  final int? sunrise;
  final int? sunset;

  // 🔥 NEW — cần cho hiệu ứng gió giống Windy
  final int? windDegree;

  WeatherModel({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.description,
    required this.icon,
    required this.mainCondition,
    required this.dateTime,
    this.tempMin,
    this.tempMax,
    this.visibility,
    this.cloudiness,
    this.sunrise,
    this.sunset,
    this.windDegree,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? 'Unknown',
      country: json['sys']['country'] ?? '',
      temperature: (json['main']['temp'] ?? 0).toDouble(),
      feelsLike: (json['main']['feels_like'] ?? 0).toDouble(),
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] ?? 0).toDouble(),
      windDegree: json['wind']['deg'],   //  🔥 IMPORTANT
      pressure: json['main']['pressure'] ?? 0,
      description: json['weather'][0]['description'] ?? 'Unknown',
      icon: json['weather'][0]['icon'] ?? '01d',
      mainCondition: json['weather'][0]['main'] ?? 'Clear',
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] ?? 0) * 1000,
      ),
      tempMin: json['main']['temp_min']?.toDouble(),
      tempMax: json['main']['temp_max']?.toDouble(),
      visibility: json['visibility'],
      cloudiness: json['clouds']?['all'],
      sunrise: json['sys']?['sunrise'],
      sunset: json['sys']?['sunset'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': cityName,
      'sys': {
        'country': country,
        'sunrise': sunrise,
        'sunset': sunset,
      },
      'main': {
        'temp': temperature,
        'feels_like': feelsLike,
        'humidity': humidity,
        'pressure': pressure,
        'temp_min': tempMin,
        'temp_max': tempMax,
      },
      'wind': {
        'speed': windSpeed,
        'deg': windDegree,  // 🔥 add for storing direction
      },
      'weather': [
        {
          'description': description,
          'icon': icon,
          'main': mainCondition,
        }
      ],
      'dt': dateTime.millisecondsSinceEpoch ~/ 1000,
      'visibility': visibility,
      'clouds': {'all': cloudiness},
    };
  }

  String get temperatureString => '${temperature.round()}°';

  bool get isDay => icon.endsWith('d');
}
