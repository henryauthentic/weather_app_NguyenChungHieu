import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/forecast_model.dart';
import '../config/api_config.dart';
import '../services/settings_service.dart';

class DailyForecastCard extends StatelessWidget {
  final List<ForecastModel> forecasts;

  const DailyForecastCard({
    super.key,
    required this.forecasts,
  });

  Future<String> _formattedTemp(double temp) async {
    final settings = SettingsService();
    final unit = await settings.getTemperatureUnit();
    final converted = settings.convertTemperature(temp, unit);
    final symbol = settings.getTemperatureSymbol(unit);
    return "${converted.round()}$symbol";
  }

  Future<String> _formattedDay(DateTime date) async {
    final settings = SettingsService();
    final lang = await settings.getLanguage();

    if (lang == "vi") {
      return DateFormat('EEEE', 'vi_VN').format(date);
    }
    return DateFormat('EEEE').format(date);
  }

  Future<String> _formattedDate(DateTime date) async {
    final settings = SettingsService();
    final lang = await settings.getLanguage();

    if (lang == "vi") {
      return DateFormat('d MMM', 'vi_VN').format(date);
    }
    return DateFormat('MMM d').format(date);
  }

  Future<String> _translateDescription(String desc) async {
    final lang = await SettingsService().getLanguage();

    if (lang == "vi") {
      switch (desc.toLowerCase()) {
        case "clear sky":
          return "Trời quang";
        case "few clouds":
          return "Ít mây";
        case "scattered clouds":
          return "Mây rải rác";
        case "broken clouds":
          return "Nhiều mây";
        case "shower rain":
          return "Mưa rào";
        case "rain":
          return "Mưa";
        case "thunderstorm":
          return "Dông bão";
        case "snow":
          return "Tuyết";
        case "mist":
          return "Sương mù";
      }
    }

    return desc;
  }

  @override
  Widget build(BuildContext context) {
    if (forecasts.isEmpty) return const SizedBox.shrink();

    final mainForecast = forecasts.length > 4 ? forecasts[4] : forecasts[0];

    final temperatures = forecasts.map((f) => f.temperature).toList();
    final minTemp = temperatures.reduce((a, b) => a < b ? a : b);
    final maxTemp = temperatures.reduce((a, b) => a > b ? a : b);

    // 🔥 Calculate average precipitation probability
    final precipValues = forecasts
        .where((f) => f.pop != null)
        .map((f) => f.pop!)
        .toList();
    final avgPrecip = precipValues.isNotEmpty
        ? (precipValues.reduce((a, b) => a + b) / precipValues.length).round()
        : 0;

    return FutureBuilder(
      future: Future.wait([
        _formattedDay(mainForecast.dateTime),
        _formattedDate(mainForecast.dateTime),
        _formattedTemp(maxTemp),
        _formattedTemp(minTemp),
        _translateDescription(mainForecast.description),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            child: SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final dayName = snapshot.data![0];
        final date = snapshot.data![1];
        final max = snapshot.data![2];
        final min = snapshot.data![3];
        final description = snapshot.data![4];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Day + Date
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Weather Icon
                CachedNetworkImage(
                  imageUrl: ApiConfig.getIconUrl(mainForecast.icon),
                  height: 50,
                  width: 50,
                  placeholder: (context, url) => const SizedBox(
                    height: 50,
                    width: 50,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.cloud, size: 50),
                ),

                const SizedBox(width: 12),

                // Description + Precipitation
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // 🔥 Precipitation probability
                      if (avgPrecip > 0)
                        Row(
                          children: [
                            Icon(Icons.water_drop, size: 14, color: Colors.blue[600]),
                            const SizedBox(width: 4),
                            Text(
                              '$avgPrecip%',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Temperature Max / Min
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      max,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      min,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}