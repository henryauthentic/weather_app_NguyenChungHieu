import 'package:flutter/material.dart';

class WeatherIconsUtil {
  // Map OpenWeatherMap icon codes to Material Icons
  static IconData getIconFromCode(String iconCode) {
    // Remove 'd' or 'n' from the end
    final code = iconCode.substring(0, iconCode.length - 1);
    
    switch (code) {
      case '01': // Clear sky
        return iconCode.endsWith('d') ? Icons.wb_sunny : Icons.nightlight;
      case '02': // Few clouds
        return iconCode.endsWith('d') 
            ? Icons.wb_sunny_outlined 
            : Icons.nightlight_round;
      case '03': // Scattered clouds
        return Icons.cloud_outlined;
      case '04': // Broken clouds
        return Icons.cloud;
      case '09': // Shower rain
        return Icons.grain;
      case '10': // Rain
        return Icons.umbrella;
      case '11': // Thunderstorm
        return Icons.flash_on;
      case '13': // Snow
        return Icons.ac_unit;
      case '50': // Mist
        return Icons.cloud_queue;
      default:
        return Icons.wb_cloudy;
    }
  }

  // Get icon from weather condition name
  static IconData getIconFromCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
      case 'cloudy':
        return Icons.cloud;
      case 'rain':
      case 'rainy':
        return Icons.umbrella;
      case 'drizzle':
        return Icons.grain;
      case 'thunderstorm':
      case 'storm':
        return Icons.flash_on;
      case 'snow':
      case 'snowy':
        return Icons.ac_unit;
      case 'mist':
      case 'fog':
      case 'haze':
      case 'smoke':
        return Icons.cloud_queue;
      case 'tornado':
        return Icons.tornado;
      case 'dust':
      case 'sand':
        return Icons.air;
      default:
        return Icons.wb_cloudy;
    }
  }

  // Get color for weather condition
  static Color getColorFromCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return const Color(0xFFFDB813);
      case 'clouds':
      case 'cloudy':
        return const Color(0xFFA0AEC0);
      case 'rain':
      case 'rainy':
      case 'drizzle':
        return const Color(0xFF4A5568);
      case 'thunderstorm':
      case 'storm':
        return const Color(0xFF2D3748);
      case 'snow':
      case 'snowy':
        return const Color(0xFFE2E8F0);
      case 'mist':
      case 'fog':
      case 'haze':
        return const Color(0xFFCBD5E0);
      default:
        return const Color(0xFF667EEA);
    }
  }

  // Get weather condition description
  static String getConditionDescription(String iconCode) {
    final code = iconCode.substring(0, iconCode.length - 1);
    
    switch (code) {
      case '01':
        return 'Clear Sky';
      case '02':
        return 'Few Clouds';
      case '03':
        return 'Scattered Clouds';
      case '04':
        return 'Broken Clouds';
      case '09':
        return 'Shower Rain';
      case '10':
        return 'Rain';
      case '11':
        return 'Thunderstorm';
      case '13':
        return 'Snow';
      case '50':
        return 'Mist';
      default:
        return 'Cloudy';
    }
  }

  // Check if it's a severe weather condition
  static bool isSevereWeather(String condition) {
    final severe = [
      'thunderstorm',
      'storm',
      'tornado',
      'hurricane',
      'typhoon',
    ];
    
    return severe.any((s) => condition.toLowerCase().contains(s));
  }

  // Get weather emoji
  static String getWeatherEmoji(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
      case 'cloudy':
        return '☁️';
      case 'rain':
      case 'rainy':
        return '🌧️';
      case 'drizzle':
        return '🌦️';
      case 'thunderstorm':
      case 'storm':
        return '⛈️';
      case 'snow':
      case 'snowy':
        return '❄️';
      case 'mist':
      case 'fog':
        return '🌫️';
      case 'tornado':
        return '🌪️';
      default:
        return '🌤️';
    }
  }

  // Get background gradient colors for condition
  static List<Color> getGradientColors(String condition, bool isDay) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return isDay
            ? [const Color(0xFF4A90E2), const Color(0xFF87CEEB)]
            : [const Color(0xFF2D3748), const Color(0xFF1A202C)];
      
      case 'rain':
      case 'drizzle':
        return [const Color(0xFF4A5568), const Color(0xFF718096)];
      
      case 'clouds':
        return [const Color(0xFFA0AEC0), const Color(0xFFCBD5E0)];
      
      case 'snow':
        return [const Color(0xFFE2E8F0), const Color(0xFFFFFFFF)];
      
      case 'thunderstorm':
        return [const Color(0xFF2D3748), const Color(0xFF4A5568)];
      
      case 'mist':
      case 'fog':
      case 'haze':
        return [const Color(0xFF718096), const Color(0xFFA0AEC0)];
      
      default:
        return [const Color(0xFF667EEA), const Color(0xFF764BA2)];
    }
  }

  // Get advice based on weather condition
  static String getWeatherAdvice(String condition, double temperature) {
    switch (condition.toLowerCase()) {
      case 'rain':
      case 'drizzle':
        return "Don't forget your umbrella! ☔";
      
      case 'thunderstorm':
        return 'Stay indoors if possible. Lightning can be dangerous! ⚡';
      
      case 'snow':
        return 'Bundle up! Dress warmly and drive carefully. ❄️';
      
      case 'clear':
        if (temperature > 30) {
          return "It's hot! Stay hydrated and use sunscreen. 🌞";
        } else if (temperature < 10) {
          return "It's cold! Wear warm clothes. 🧥";
        }
        return 'Perfect weather! Enjoy your day! ☀️';
      
      case 'clouds':
        return 'Cloudy skies. A jacket might be a good idea. ☁️';
      
      case 'mist':
      case 'fog':
        return 'Visibility is low. Drive carefully! 🌫️';
      
      default:
        return 'Have a great day! 🌤️';
    }
  }

  // Get activity recommendations
  static List<String> getActivityRecommendations(String condition, double temperature) {
    final activities = <String>[];
    
    switch (condition.toLowerCase()) {
      case 'clear':
        if (temperature > 15 && temperature < 30) {
          activities.addAll([
            'Perfect for outdoor activities',
            'Great for hiking',
            'Ideal for picnics',
            'Good for cycling',
          ]);
        } else if (temperature > 30) {
          activities.addAll([
            'Visit indoor attractions',
            'Swimming recommended',
            'Stay in shade',
          ]);
        }
        break;
      
      case 'rain':
      case 'drizzle':
        activities.addAll([
          'Indoor activities recommended',
          'Visit museums',
          'Watch movies',
          'Read a book',
        ]);
        break;
      
      case 'clouds':
        activities.addAll([
          'Good for photography',
          'Comfortable for walking',
          'Suitable for outdoor sports',
        ]);
        break;
      
      case 'snow':
        activities.addAll([
          'Perfect for skiing',
          'Build a snowman',
          'Enjoy winter sports',
        ]);
        break;
      
      default:
        activities.add('Plan according to conditions');
    }
    
    return activities;
  }

  // Get clothing recommendations
  static List<String> getClothingRecommendations(double temperature, String condition) {
    final clothes = <String>[];
    
    if (temperature > 30) {
      clothes.addAll(['Light clothing', 'Shorts', 'T-shirt', 'Sunglasses', 'Hat']);
    } else if (temperature > 20) {
      clothes.addAll(['Light jacket', 'Comfortable clothes', 'Sunglasses']);
    } else if (temperature > 10) {
      clothes.addAll(['Jacket', 'Long pants', 'Light sweater']);
    } else if (temperature > 0) {
      clothes.addAll(['Warm coat', 'Sweater', 'Scarf', 'Gloves']);
    } else {
      clothes.addAll(['Heavy coat', 'Thermal wear', 'Scarf', 'Gloves', 'Hat']);
    }
    
    if (condition.toLowerCase().contains('rain')) {
      clothes.addAll(['Umbrella', 'Raincoat', 'Waterproof shoes']);
    }
    
    if (condition.toLowerCase().contains('snow')) {
      clothes.addAll(['Winter boots', 'Warm socks', 'Thermal gloves']);
    }
    
    return clothes;
  }
}