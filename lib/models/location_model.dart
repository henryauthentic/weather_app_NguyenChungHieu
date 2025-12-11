class LocationModel {
  final double latitude;
  final double longitude;
  final String? cityName;
  final String? country;
  final String? state;
  final String? postalCode;
  final DateTime timestamp;

  LocationModel({
    required this.latitude,
    required this.longitude,
    this.cityName,
    this.country,
    this.state,
    this.postalCode,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Create from JSON
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      cityName: json['cityName'],
      country: json['country'],
      state: json['state'],
      postalCode: json['postalCode'],
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'])
          : DateTime.now(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'cityName': cityName,
      'country': country,
      'state': state,
      'postalCode': postalCode,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  // Get full address
  String get fullAddress {
    List<String> parts = [];
    
    if (cityName != null && cityName!.isNotEmpty) {
      parts.add(cityName!);
    }
    
    if (state != null && state!.isNotEmpty) {
      parts.add(state!);
    }
    
    if (country != null && country!.isNotEmpty) {
      parts.add(country!);
    }
    
    return parts.isNotEmpty ? parts.join(', ') : 'Unknown Location';
  }

  // Get short address (city, country)
  String get shortAddress {
    List<String> parts = [];
    
    if (cityName != null && cityName!.isNotEmpty) {
      parts.add(cityName!);
    }
    
    if (country != null && country!.isNotEmpty) {
      parts.add(country!);
    }
    
    return parts.isNotEmpty ? parts.join(', ') : 'Unknown';
  }

  // Get coordinates as string
  String get coordinatesString {
    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }

  // Copy with
  LocationModel copyWith({
    double? latitude,
    double? longitude,
    String? cityName,
    String? country,
    String? state,
    String? postalCode,
    DateTime? timestamp,
  }) {
    return LocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cityName: cityName ?? this.cityName,
      country: country ?? this.country,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'LocationModel(lat: $latitude, lon: $longitude, city: $cityName, country: $country)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is LocationModel &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.cityName == cityName &&
      other.country == country;
  }

  @override
  int get hashCode {
    return latitude.hashCode ^
      longitude.hashCode ^
      cityName.hashCode ^
      country.hashCode;
  }
}