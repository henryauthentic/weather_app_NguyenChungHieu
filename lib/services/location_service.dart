import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Check and request location permission
  Future<bool> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Get current position
  Future<Position> getCurrentLocation() async {
    bool hasPermission = await checkPermission();
    
    if (!hasPermission) {
      throw Exception(
        'Location permission denied. Please enable location services in settings.'
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      throw Exception('Failed to get location: ${e.toString()}');
    }
  }

  // Get city name from coordinates
  Future<String> getCityName(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        return place.locality ?? place.subAdministrativeArea ?? 'Unknown';
      }
      
      return 'Unknown';
    } catch (e) {
      throw Exception('Failed to get city name: ${e.toString()}');
    }
  }

  // Get full address from coordinates
  Future<String> getFullAddress(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        return '${place.locality}, ${place.country}';
      }
      
      return 'Unknown Location';
    } catch (e) {
      return 'Unknown Location';
    }
  }

  // Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}