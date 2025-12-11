import 'package:intl/intl.dart';

class DateFormatter {
  // Format full date and time
  static String formatFullDateTime(DateTime dateTime) {
    return DateFormat('EEEE, MMMM d, yyyy - HH:mm').format(dateTime);
  }
  
  // Format date only
  static String formatDate(DateTime dateTime) {
    return DateFormat('EEEE, MMM d, yyyy').format(dateTime);
  }
  
  // Format short date
  static String formatShortDate(DateTime dateTime) {
    return DateFormat('MMM d').format(dateTime);
  }
  
  // Format time only (24-hour format)
  static String formatTime24(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
  
  // Format time only (12-hour format)
  static String formatTime12(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }
  
  // Format day name
  static String formatDayName(DateTime dateTime) {
    return DateFormat('EEEE').format(dateTime);
  }
  
  // Format short day name
  static String formatShortDayName(DateTime dateTime) {
    return DateFormat('EEE').format(dateTime);
  }
  
  // Format month and year
  static String formatMonthYear(DateTime dateTime) {
    return DateFormat('MMMM yyyy').format(dateTime);
  }
  
  // Format for forecast display
  static String formatForecastDate(DateTime dateTime) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    
    // Check if it's today
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return 'Today';
    }
    
    // Check if it's tomorrow
    if (dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day) {
      return 'Tomorrow';
    }
    
    // Otherwise return day name
    return formatDayName(dateTime);
  }
  
  // Format relative time (e.g., "2 hours ago")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return formatDate(dateTime);
    }
  }
  
  // Format sunrise/sunset time
  static String formatSunTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('h:mm a').format(dateTime);
  }
  
  // Get time period (Morning, Afternoon, Evening, Night)
  static String getTimePeriod(DateTime dateTime) {
    final hour = dateTime.hour;
    
    if (hour >= 5 && hour < 12) {
      return 'Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Evening';
    } else {
      return 'Night';
    }
  }
  
  // Check if it's daytime
  static bool isDaytime(DateTime dateTime, int? sunrise, int? sunset) {
    if (sunrise == null || sunset == null) {
      // Fallback: consider 6 AM to 6 PM as daytime
      final hour = dateTime.hour;
      return hour >= 6 && hour < 18;
    }
    
    final sunriseTime = DateTime.fromMillisecondsSinceEpoch(sunrise * 1000);
    final sunsetTime = DateTime.fromMillisecondsSinceEpoch(sunset * 1000);
    
    return dateTime.isAfter(sunriseTime) && dateTime.isBefore(sunsetTime);
  }
  
  // Format duration
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''} $minutes min${minutes != 1 ? 's' : ''}';
    } else {
      return '$minutes minute${minutes != 1 ? 's' : ''}';
    }
  }
  
  // Get greeting based on time
  static String getGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }
  
  // Format for hourly forecast
  static String formatHourlyTime(DateTime dateTime) {
    final now = DateTime.now();
    
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day &&
        dateTime.hour == now.hour) {
      return 'Now';
    }
    
    return formatTime24(dateTime);
  }
  
  // Check if date is today
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }
  
  // Check if date is tomorrow
  static bool isTomorrow(DateTime dateTime) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day;
  }
}