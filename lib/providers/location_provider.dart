import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/l10n/app_localizations.dart';  // ✔ ĐÚNG

import '../models/location_model.dart';
import '../services/location_service.dart';

enum LocationState { initial, loading, loaded, error, permissionDenied }

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService;

  LocationModel? _currentLocation;
  LocationState _state = LocationState.initial;
  String _errorMessage = '';

  bool _isLocationServiceEnabled = false;
  bool _hasPermission = false;

  LocationProvider(this._locationService);

  // ================================
  // GETTERS
  // ================================
  LocationModel? get currentLocation => _currentLocation;
  LocationState get state => _state;
  String get errorMessage => _errorMessage;
  bool get isLocationServiceEnabled => _isLocationServiceEnabled;
  bool get hasPermission => _hasPermission;

  // ==========================================
  // INTERNAL: lấy text theo locale
  // ==========================================
  String _translate(BuildContext context, String key) {
    final t = AppLocalizations.of(context)!;

    switch (key) {
      case 'serviceDisabled':
        return t.locationServiceDisabled;
      case 'permissionDenied':
        return t.locationPermissionDenied;
      case 'permissionRequired':
        return t.locationPermissionRequired;
      default:
        return key;
    }
  }

  // ================================
  // CHECK LOCATION SERVICE
  // ================================
  Future<bool> checkLocationService(BuildContext context) async {
    try {
      _isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!_isLocationServiceEnabled) {
        _state = LocationState.error;
        _errorMessage = _translate(context, 'serviceDisabled');
      }

      notifyListeners();
      return _isLocationServiceEnabled;
    } catch (e) {
      _isLocationServiceEnabled = false;
      _state = LocationState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ================================
  // CHECK PERMISSION
  // ================================
  Future<bool> checkLocationPermission(BuildContext context) async {
    try {
      _hasPermission = await _locationService.checkPermission();

      if (!_hasPermission) {
        _state = LocationState.permissionDenied;
        _errorMessage = _translate(context, 'permissionRequired');
      }

      notifyListeners();
      return _hasPermission;
    } catch (e) {
      _hasPermission = false;
      _state = LocationState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ================================
  // GET CURRENT LOCATION
  // ================================
  Future<LocationModel?> getCurrentLocation(BuildContext context) async {
    _state = LocationState.loading;
    notifyListeners();

    try {
      // Check service enabled
      final serviceEnabled = await checkLocationService(context);
      if (!serviceEnabled) return null;

      // Check permission
      final allowed = await checkLocationPermission(context);
      if (!allowed) return null;

      // Actual position
      final position = await _locationService.getCurrentLocation();

      // Get city name
      final cityName = await _locationService.getCityName(
        position.latitude,
        position.longitude,
      );

      _currentLocation = LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: cityName,
      );

      _state = LocationState.loaded;
      _errorMessage = "";
      notifyListeners();
      return _currentLocation;
    } catch (e) {
      _state = LocationState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // ================================
  // GET LOCATION WITH ADDRESS
  // ================================
  Future<LocationModel?> getCurrentLocationWithAddress(BuildContext context) async {
    _state = LocationState.loading;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentLocation();
      final address = await _locationService.getFullAddress(
        position.latitude,
        position.longitude,
      );

      final parsed = address.split(', ');

      _currentLocation = LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: parsed.isNotEmpty ? parsed[0] : "Unknown",
        country: parsed.length > 1 ? parsed[1] : null,
      );

      _state = LocationState.loaded;
      notifyListeners();
      return _currentLocation;
    } catch (e) {
      _state = LocationState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // ================================
  // REQUEST PERMISSION
  // ================================
  Future<bool> requestLocationPermission(BuildContext context) async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();

      _hasPermission = permission == LocationPermission.always ||
                       permission == LocationPermission.whileInUse;

      if (!_hasPermission) {
        _state = LocationState.permissionDenied;
        _errorMessage = _translate(context, 'permissionDenied');
      } else {
        _state = LocationState.initial;
        _errorMessage = "";
      }

      notifyListeners();
      return _hasPermission;
    } catch (e) {
      _state = LocationState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ================================
  // OPEN LOCATION SETTINGS
  // ================================
  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  // ================================
  // CLEAR LOCATION INFO
  // ================================
  void clearLocation() {
    _currentLocation = null;
    _state = LocationState.initial;
    _errorMessage = "";
    notifyListeners();
  }

  void resetState() {
    _state = LocationState.initial;
    _errorMessage = "";
    notifyListeners();
  }

  // ================================
  // UTILS: DISTANCE
  // ================================
  double getDistance(LocationModel a, LocationModel b) {
    return Geolocator.distanceBetween(
          a.latitude,
          a.longitude,
          b.latitude,
          b.longitude,
        ) /
        1000;
  }

  String formatDistance(double km) {
    if (km < 1) return "${(km * 1000).round()} m";
    if (km < 10) return "${km.toStringAsFixed(1)} km";
    return "${km.round()} km";
  }
}
