// lib/utils/weather_translator.dart
import '../services/settings_service.dart';

class WeatherTranslator {
  /// Dịch mô tả thời tiết dựa vào ngôn ngữ đang chọn
  static Future<String> translate(String description) async {
    final lang = await SettingsService().getLanguage();

    if (lang == "vi") {
      return _toVietnamese(description.toLowerCase());
    }

    /// English → giữ nguyên
    return _capitalize(description);
  }

  /// -----------------------------
  /// 🇻🇳 BẢN DỊCH TIẾNG VIỆT
  /// -----------------------------
  static String _toVietnamese(String input) {
    const map = {
      // CLEAR
      "clear sky": "Trời quang",

      // CLOUDS
      "few clouds": "Ít mây",
      "scattered clouds": "Mây rải rác",
      "broken clouds": "Nhiều mây",
      "overcast clouds": "Mây u ám",

      // RAIN
      "light rain": "Mưa nhẹ",
      "moderate rain": "Mưa vừa",
      "heavy intensity rain": "Mưa to",
      "very heavy rain": "Mưa rất to",
      "extreme rain": "Mưa cực lớn",

      // SHOWER RAIN
      "shower rain": "Mưa rào",
      "light intensity shower rain": "Mưa rào nhẹ",
      "heavy intensity shower rain": "Mưa rào nặng",
      "ragged shower rain": "Mưa rào không đều",

      // DRIZZLE
      "drizzle": "Mưa phùn",
      "light drizzle": "Mưa phùn nhẹ",
      "heavy drizzle": "Mưa phùn nặng",

      // SNOW
      "snow": "Tuyết rơi",
      "light snow": "Tuyết nhẹ",
      "heavy snow": "Tuyết dày",
      "sleet": "Mưa tuyết",
      "light shower sleet": "Mưa tuyết nhẹ",
      "shower sleet": "Mưa tuyết rào",
      "light rain and snow": "Mưa và tuyết nhẹ",
      "rain and snow": "Mưa và tuyết",

      // THUNDERSTORM
      "thunderstorm": "Dông bão",
      "light thunderstorm": "Dông nhẹ",
      "heavy thunderstorm": "Dông mạnh",
      "ragged thunderstorm": "Dông không đều",

      // ATMOSPHERE
      "mist": "Sương mù",
      "smoke": "Khói mù",
      "haze": "Sương mù khô",
      "fog": "Sương dày",
      "sand": "Bụi cát",
      "dust": "Bụi",
      "volcanic ash": "Tro núi lửa",
      "squalls": "Gió giật",
      "tornado": "Lốc xoáy",
    };

    return map[input] ?? _capitalize(input);
  }

  /// Helper: viết hoa chữ cái đầu
  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
