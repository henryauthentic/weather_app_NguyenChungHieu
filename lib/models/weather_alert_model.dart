class WeatherAlertModel {
  final String senderName;
  final String event;
  final DateTime start;
  final DateTime end;
  final String description;
  final List<String> tags;

  WeatherAlertModel({
    required this.senderName,
    required this.event,
    required this.start,
    required this.end,
    required this.description,
    required this.tags,
  });

  factory WeatherAlertModel.fromJson(Map<String, dynamic> json) {
    return WeatherAlertModel(
      senderName: json['sender_name'] ?? 'Unknown',
      event: json['event'] ?? 'Weather Alert',
      start: DateTime.fromMillisecondsSinceEpoch(json['start'] * 1000),
      end: DateTime.fromMillisecondsSinceEpoch(json['end'] * 1000),
      description: json['description'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  // Get severity level
  String getSeverity() {
    final eventLower = event.toLowerCase();
    
    if (eventLower.contains('extreme') || 
        eventLower.contains('severe') ||
        eventLower.contains('tornado') ||
        eventLower.contains('hurricane')) {
      return 'Extreme';
    } else if (eventLower.contains('warning')) {
      return 'Warning';
    } else if (eventLower.contains('watch')) {
      return 'Watch';
    } else {
      return 'Advisory';
    }
  }

  // Get color based on severity
  int getColor() {
    final severity = getSeverity();
    
    switch (severity) {
      case 'Extreme':
        return 0xFFFF0000; // Red
      case 'Warning':
        return 0xFFFF7E00; // Orange
      case 'Watch':
        return 0xFFFFFF00; // Yellow
      default:
        return 0xFF00E400; // Green
    }
  }

  // Get icon based on event type
  String getIcon() {
    final eventLower = event.toLowerCase();
    
    if (eventLower.contains('thunder') || eventLower.contains('storm')) {
      return '⛈️';
    } else if (eventLower.contains('flood') || eventLower.contains('rain')) {
      return '🌊';
    } else if (eventLower.contains('snow') || eventLower.contains('ice')) {
      return '❄️';
    } else if (eventLower.contains('wind')) {
      return '💨';
    } else if (eventLower.contains('heat')) {
      return '🔥';
    } else if (eventLower.contains('cold')) {
      return '🥶';
    } else if (eventLower.contains('tornado')) {
      return '🌪️';
    } else if (eventLower.contains('hurricane')) {
      return '🌀';
    } else {
      return '⚠️';
    }
  }

  // Check if alert is active
  bool isActive() {
    final now = DateTime.now();
    return now.isAfter(start) && now.isBefore(end);
  }

  // Get time remaining
  Duration getTimeRemaining() {
    return end.difference(DateTime.now());
  }

  Map<String, dynamic> toJson() {
    return {
      'sender_name': senderName,
      'event': event,
      'start': start.millisecondsSinceEpoch ~/ 1000,
      'end': end.millisecondsSinceEpoch ~/ 1000,
      'description': description,
      'tags': tags,
    };
  }
}