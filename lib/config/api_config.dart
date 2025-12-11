// lib/config/api_config.dart

class ApiConfig {
  // =============================
  // 🔑 API KEY — Có setter / getter
  // =============================
  static String _apiKey = "";
  static String get apiKey => _apiKey;

  static set apiKey(String value) {
    _apiKey = value.trim();
  }

  // =============================
  // 🌦 WEATHER REST API CONFIG
  // =============================
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';

  static const String currentWeather = '/weather';
  static const String forecast = '/forecast';
  static const String oneCall = '/onecall';

  /// Build URL cho REST API
  static String buildUrl(String endpoint, Map<String, dynamic> params) {
    params['appid'] = _apiKey;
    params['units'] = 'metric';

    final uri = Uri.parse('$baseUrl$endpoint');
    return uri.replace(
      queryParameters: params.map((k, v) => MapEntry(k, v.toString())),
    ).toString();
  }

  // =============================
  // 🌤 ICONS
  // =============================
  static String getIconUrl(String code) =>
      'https://openweathermap.org/img/wn/$code@2x.png';

  static String getLargeIconUrl(String code) =>
      'https://openweathermap.org/img/wn/$code@4x.png';

  // =============================
  // 🗺 MAP TILE CONFIG
  // =============================
  static const String mapTileBaseUrl = "https://tile.openweathermap.org/map";

  /// Trả tile URL đúng chuẩn Flutter Map
  static String getMapTileUrl(String layer) {
    return "$mapTileBaseUrl/$layer/{z}/{x}/{y}.png?appid=$_apiKey";
  }

  // =============================
  // 🧩 MAP LAYERS — tên đúng chuẩn OWM
  // =============================
  static const String clouds = 'clouds_new';
  static const String temp = 'temp_new';
  static const String precip = 'precipitation_new';
  static const String pressure = 'pressure_new';
  static const String wind = 'wind_new';
  
}
