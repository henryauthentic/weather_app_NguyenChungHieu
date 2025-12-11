import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/forecast_model.dart';
import '../config/api_config.dart';
import '../services/settings_service.dart';

class HourlyForecastList extends StatelessWidget {
  final List<ForecastModel> forecasts;

  const HourlyForecastList({
    super.key,
    required this.forecasts,
  });

  Future<String> _formattedTime(DateTime dt) async {
    final settings = SettingsService();
    final format = await settings.getTimeFormat();
    return DateFormat(format == '24h' ? 'HH:mm' : 'hh:mm a').format(dt);
  }

  Future<String> _formattedTemperature(double tempC) async {
    final settings = SettingsService();
    final unit = await settings.getTemperatureUnit();
    final converted = settings.convertTemperature(tempC, unit);
    final symbol = settings.getTemperatureSymbol(unit);
    return "${converted.round()}$symbol";
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160, // 🔥 Increased height for precipitation
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: forecasts.length,
        itemBuilder: (context, index) {
          final forecast = forecasts[index];

          return FutureBuilder(
            future: Future.wait([
              _formattedTime(forecast.dateTime),
              _formattedTemperature(forecast.temperature),
            ]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(
                  width: 90,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              final time = snapshot.data![0];
              final temp = snapshot.data![1];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  width: 90, // 🔥 Slightly wider
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Time
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      // Weather Icon
                      CachedNetworkImage(
                        imageUrl: ApiConfig.getIconUrl(forecast.icon),
                        height: 40,
                        width: 40,
                        placeholder: (context, url) => const SizedBox(
                          height: 40,
                          width: 40,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.cloud,
                          size: 40,
                        ),
                      ),

                      // Temperature
                      Text(
                        temp,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // 🔥 Precipitation Probability
                      if (forecast.pop != null && forecast.pop! > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.water_drop,
                              size: 14,
                              color: Colors.blue[600],
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${forecast.pop}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[600],
                                fontWeight: FontWeight.w600,
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
        },
      ),
    );
  }
}