import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/l10n/app_localizations.dart';
import '../models/weather_model.dart';
import '../config/api_config.dart';
import '../services/settings_service.dart';

class CurrentWeatherCard extends StatelessWidget {
  final WeatherModel weather;
  final bool isOffline;

  const CurrentWeatherCard({
    super.key,
    required this.weather,
    this.isOffline = false,
  });

  Future<String> _formattedTemperature(double celsius) async {
    final settings = SettingsService();
    final unit = await settings.getTemperatureUnit();
    final converted = settings.convertTemperature(celsius, unit);
    final symbol = settings.getTemperatureSymbol(unit);
    return "${converted.round()}$symbol";
  }

  Future<String> _formattedMinMax(double min, double max, BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final settings = SettingsService();
    final unit = await settings.getTemperatureUnit();
    final minConverted = settings.convertTemperature(min, unit).round();
    final maxConverted = settings.convertTemperature(max, unit).round();
    final symbol = settings.getTemperatureSymbol(unit);
    
    // Use "Min" and "Max" from translations
    return "Min $minConverted$symbol • Max $maxConverted$symbol";
  }

  Future<String> _formattedDate(DateTime date) async {
    final settings = SettingsService();
    final lang = await settings.getLanguage();

    return lang == "vi"
        ? DateFormat('EEEE, d MMM yyyy', 'vi_VN').format(date)
        : DateFormat('EEEE, MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    
    return FutureBuilder(
      future: Future.wait([
        _formattedTemperature(weather.temperature),
        weather.tempMin != null && weather.tempMax != null
            ? _formattedMinMax(weather.tempMin!, weather.tempMax!, context)
            : Future.value(""),
        _formattedDate(weather.dateTime),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 400,
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        final tempText = snapshot.data![0];
        final minMaxText = snapshot.data![1];
        final dateText = snapshot.data![2];

        return Container(
          width: double.infinity,
          height: 400,
          decoration: BoxDecoration(
            gradient: _getWeatherGradient(weather.mainCondition, weather.isDay),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🔥 Offline Badge
                    if (isOffline)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cloud_off, size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              t.offlineCachedData,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 12),

                    // 🔥 City Name
                    Text(
                      weather.cityName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // 🔥 Country
                    Text(
                      weather.country,
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),

                    const SizedBox(height: 4),

                    // 🔥 Date
                    Text(
                      dateText,
                      style: const TextStyle(fontSize: 14, color: Colors.white60),
                    ),

                    const SizedBox(height: 16),

                    // 🔥 Weather Icon
                    CachedNetworkImage(
                      imageUrl: ApiConfig.getLargeIconUrl(weather.icon),
                      height: 100,
                      width: 100,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(color: Colors.white),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.cloud, size: 100, color: Colors.white),
                    ),

                    const SizedBox(height: 12),

                    // 🔥 Main Temperature
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tempText.replaceAll(RegExp(r'[^0-9-]'), ''),
                          style: const TextStyle(
                            fontSize: 72,
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                            height: 1.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            tempText.replaceAll(RegExp(r'[0-9-]'), ''),
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // 🔥 Weather Description (CLEAR SKY, SCATTERED CLOUDS...)
                    Text(
                      weather.description.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 🔥 Min/Max Temperature - FIXED: Now clearly visible!
                    if (minMaxText.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          minMaxText,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  LinearGradient _getWeatherGradient(String condition, bool isDay) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return isDay
            ? const LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF87CEEB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF2D3748), Color(0xFF1A202C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );
      case 'rain':
      case 'drizzle':
        return const LinearGradient(
          colors: [Color(0xFF4A5568), Color(0xFF718096)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'clouds':
        return const LinearGradient(
          colors: [Color(0xFFA0AEC0), Color(0xFFCBD5E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'snow':
        return const LinearGradient(
          colors: [Color(0xFFE2E8F0), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'thunderstorm':
        return const LinearGradient(
          colors: [Color(0xFF2D3748), Color(0xFF4A5568)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}