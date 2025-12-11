// lib/screens/forecast_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:weather_app/l10n/app_localizations.dart';  // ✔ ĐÚNG

import '../providers/weather_provider.dart';
import '../models/forecast_model.dart';
import '../config/api_config.dart';
import '../utils/date_formatter.dart';
import '../services/settings_service.dart';
import 'package:intl/intl.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  // simple translator reused here
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
        case "light rain":
          return "Mưa nhẹ";
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
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.weatherForecast),
        elevation: 0,
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, child) {
          if (provider.forecast.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    t.noForecastData,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: TabBar(
                    tabs: [
                      Tab(text: t.hourly, icon: const Icon(Icons.access_time)),
                      Tab(text: t.daily, icon: const Icon(Icons.calendar_today)),
                    ],
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildHourlyForecast(context, provider.forecast),
                      _buildDailyForecast(context, provider.dailyForecast),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ----------------------------
  // HOURLY FORECAST LIST
  // ----------------------------
  Widget _buildHourlyForecast(
      BuildContext context, List<ForecastModel> forecasts) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: forecasts.length,
      itemBuilder: (context, index) {
        final forecast = forecasts[index];
        return _HourlyForecastCard(forecast: forecast, translate: _translateDescription);
      },
    );
  }

  // ----------------------------
  // DAILY FORECAST LIST
  // ----------------------------
  Widget _buildDailyForecast(
      BuildContext context, List<List<ForecastModel>> dailyForecasts) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dailyForecasts.length,
      itemBuilder: (context, index) {
        final dayForecasts = dailyForecasts[index];
        return _DailyForecastCard(forecasts: dayForecasts, translate: _translateDescription);
      },
    );
  }
}

// ===================================================================
// HOURLY FORECAST CARD
// ===================================================================

typedef DescTranslator = Future<String> Function(String desc);

class _HourlyForecastCard extends StatelessWidget {
  final ForecastModel forecast;
  final DescTranslator translate;

  const _HourlyForecastCard({required this.forecast, required this.translate});

  Future<String> _formatTime(DateTime dt) async {
    final setting = SettingsService();
    final format = await setting.getTimeFormat();
    return DateFormat(format == "24h" ? "HH:mm" : "hh:mm a").format(dt);
  }

  Future<String> _formatTemp(double t) async {
    final s = SettingsService();
    final u = await s.getTemperatureUnit();
    final v = s.convertTemperature(t, u);
    return "${v.round()}${s.getTemperatureSymbol(u)}";
  }

  Future<String> _formatWind(double w) async {
    final s = SettingsService();
    final u = await s.getWindUnit();
    final v = s.convertWindSpeed(w, u);
    return "${v.toStringAsFixed(1)} ${s.getWindSpeedLabel(u)}";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        _formatTime(forecast.dateTime),
        _formatTemp(forecast.temperature),
        _formatWind(forecast.windSpeed),
        translate(forecast.description),
      ]),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final time = snap.data![0];
        final temp = snap.data![1];
        final wind = snap.data![2];
        final desc = snap.data![3];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormatter.formatShortDate(forecast.dateTime),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                CachedNetworkImage(
                  imageUrl: ApiConfig.getIconUrl(forecast.icon),
                  height: 60,
                  width: 60,
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        desc,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.water_drop,
                              size: 16, color: Colors.blue[300]),
                          const SizedBox(width: 4),
                          Text('${forecast.humidity}%'),
                          const SizedBox(width: 16),
                          Icon(Icons.air, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(wind),
                        ],
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      temp,
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      forecast.temperatureRange,
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey[600]),
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

// ===================================================================
// DAILY FORECAST CARD (small adjustment to accept translator)
// ===================================================================

class _DailyForecastCard extends StatelessWidget {
  final List<ForecastModel> forecasts;
  final DescTranslator translate;

  const _DailyForecastCard({required this.forecasts, required this.translate});

  Future<String> _formatDay(DateTime d) async {
    final lang = await SettingsService().getLanguage();
    return lang == "vi"
        ? DateFormat("EEEE", "vi_VN").format(d)
        : DateFormat("EEEE").format(d);
  }

  Future<String> _formatDate(DateTime d) async {
    final lang = await SettingsService().getLanguage();
    return lang == "vi"
        ? DateFormat("d MMM", "vi_VN").format(d)
        : DateFormat("MMM d").format(d);
  }

  Future<String> _formatTemp(double t) async {
    final s = SettingsService();
    final unit = await s.getTemperatureUnit();
    final v = s.convertTemperature(t, unit);
    return "${v.round()}${s.getTemperatureSymbol(unit)}";
  }

  Future<String> _formatWind(double w) async {
    final s = SettingsService();
    final u = await s.getWindUnit();
    final v = s.convertWindSpeed(w, u);
    return "${v.toStringAsFixed(1)} ${s.getWindSpeedLabel(u)}";
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    if (forecasts.isEmpty) return const SizedBox();

    final main = forecasts.length > 4 ? forecasts[4] : forecasts[0];

    final temps = forecasts.map((f) => f.temperature).toList();
    final min = temps.reduce((a, b) => a < b ? a : b);
    final max = temps.reduce((a, b) => a > b ? a : b);

    final avgHumidity =
        forecasts.map((e) => e.humidity).reduce((a, b) => a + b) ~/
            forecasts.length;
    final avgWind =
        forecasts.map((e) => e.windSpeed).reduce((a, b) => a + b) /
            forecasts.length;

    return FutureBuilder(
      future: Future.wait([
        _formatDay(main.dateTime),
        _formatDate(main.dateTime),
        _formatTemp(max),
        _formatTemp(min),
        translate(main.description),
        _formatWind(avgWind),
      ]),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Card(
            child: SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final day = snap.data![0];
        final date = snap.data![1];
        final minT = snap.data![3];
        final maxT = snap.data![2];
        final desc = snap.data![4];
        final wind = snap.data![5];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: CachedNetworkImage(
              imageUrl: ApiConfig.getIconUrl(main.icon),
              height: 50,
              width: 50,
            ),
            title: Text(
              "$day • $date",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(desc),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  maxT,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  minT,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _detail(Icons.water_drop, t.humidity, "$avgHumidity%"),
                        _detail(Icons.air, t.wind, wind),
                        _detail(Icons.compress, t.pressure, "${main.pressure} hPa"),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
