import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'Weather App';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String apiBaseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String apiIconUrl = 'https://openweathermap.org/img/wn/';
  
  // Cache Duration
  static const int cacheValidityMinutes = 30;
  static const int maxRecentSearches = 10;
  static const int maxFavoriteCities = 5;
  
  // Network Timeout
  static const Duration networkTimeout = Duration(seconds: 10);
  static const Duration locationTimeout = Duration(seconds: 10);
  
  // Weather Condition Colors
  static const Map<String, List<Color>> weatherGradients = {
    'clear_day': [Color(0xFF4A90E2), Color(0xFF87CEEB)],
    'clear_night': [Color(0xFF2D3748), Color(0xFF1A202C)],
    'rain': [Color(0xFF4A5568), Color(0xFF718096)],
    'clouds': [Color(0xFFA0AEC0), Color(0xFFCBD5E0)],
    'snow': [Color(0xFFE2E8F0), Color(0xFFFFFFFF)],
    'thunderstorm': [Color(0xFF2D3748), Color(0xFF4A5568)],
    'default': [Color(0xFF667EEA), Color(0xFF764BA2)],
  };
  
  // UI Constants
  static const double cardBorderRadius = 20.0;
  static const double cardElevation = 4.0;
  static const double screenPadding = 20.0;
  static const double defaultSpacing = 16.0;
  
  // Temperature Units
  static const String celsiusUnit = 'celsius';
  static const String fahrenheitUnit = 'fahrenheit';
  
  // Wind Speed Units
  static const String meterPerSecond = 'm/s';
  static const String kilometerPerHour = 'km/h';
  static const String milesPerHour = 'mph';
  
  // Error Messages
  static const String networkError = 'Network error. Please check your internet connection.';
  static const String locationError = 'Failed to get location. Please enable location services.';
  static const String cityNotFound = 'City not found. Please check the city name.';
  static const String apiKeyError = 'Invalid API key. Please check your configuration.';
  static const String genericError = 'Something went wrong. Please try again.';
  
  // Success Messages
  static const String cityAdded = 'City added to favorites';
  static const String cityRemoved = 'City removed from favorites';
  static const String dataRefreshed = 'Weather data refreshed';
  
  // Popular Cities (for quick search)
  static const List<String> popularCities = [
    'Ho Chi Minh City',
    'Hanoi',
    'Da Nang',
    'Can Tho',
    'Hai Phong',
    'London',
    'New York',
    'Tokyo',
    'Paris',
    'Singapore',
    'Bangkok',
    'Seoul',
    'Sydney',
    'Dubai',
    'Mumbai',
  ];
  
  // Weather Conditions
  static const List<String> weatherConditions = [
    'Clear',
    'Clouds',
    'Rain',
    'Drizzle',
    'Thunderstorm',
    'Snow',
    'Mist',
    'Smoke',
    'Haze',
    'Dust',
    'Fog',
    'Sand',
    'Ash',
    'Squall',
    'Tornado',
  ];
  
  // Storage Keys
  static const String cachedWeatherKey = 'cached_weather';
  static const String lastUpdateKey = 'last_update';
  static const String favoriteCitiesKey = 'favorite_cities';
  static const String recentSearchesKey = 'recent_searches';
  static const String temperatureUnitKey = 'temperature_unit';
  static const String windSpeedUnitKey = 'wind_speed_unit';
  static const String lastCityKey = 'last_city';
  static const String useLocationKey = 'use_location';
  static const String notificationsEnabledKey = 'notifications_enabled';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Forecast Constants
  static const int hourlyForecastHours = 24;
  static const int dailyForecastDays = 5;
}

class WeatherIcons {
  // Map weather condition codes to custom descriptions
  static const Map<String, String> conditionDescriptions = {
    '01d': 'Clear Sky',
    '01n': 'Clear Sky',
    '02d': 'Few Clouds',
    '02n': 'Few Clouds',
    '03d': 'Scattered Clouds',
    '03n': 'Scattered Clouds',
    '04d': 'Broken Clouds',
    '04n': 'Broken Clouds',
    '09d': 'Shower Rain',
    '09n': 'Shower Rain',
    '10d': 'Rain',
    '10n': 'Rain',
    '11d': 'Thunderstorm',
    '11n': 'Thunderstorm',
    '13d': 'Snow',
    '13n': 'Snow',
    '50d': 'Mist',
    '50n': 'Mist',
  };
  
  // Map conditions to Material icons
  static IconData getIconForCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
      case 'drizzle':
        return Icons.umbrella;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snow':
        return Icons.ac_unit;
      case 'mist':
      case 'fog':
      case 'haze':
        return Icons.cloud_queue;
      default:
        return Icons.wb_cloudy;
    }
  }
}