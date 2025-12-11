import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:home_widget/home_widget.dart';
import 'package:weather_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../providers/weather_provider.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/hourly_forecast_list.dart';
import '../widgets/daily_forecast_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/error_widget.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import '../services/settings_service.dart';
import '../widgets/weather_detail_item.dart';

import 'air_quality_screen.dart';
import 'alerts_screen.dart';
import 'compare_cities_screen.dart';
import 'weather_maps_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  Future<void> _reloadAfterSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );

    if (result == true && mounted) {
      context.read<WeatherProvider>().refreshWeather();
      setState(() {});
    }
  }

@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<WeatherProvider>().initialize();
  });

  HomeWidget.setAppGroupId('weather_widget_group');
  HomeWidget.widgetClicked.listen((data) {
    if (mounted) {
      context.read<WeatherProvider>().refreshWeather();
    }
  });
}


  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: _buildDrawer(context, t),
      
      body: RefreshIndicator(
        onRefresh: () => context.read<WeatherProvider>().refreshWeather(),
        child: Consumer<WeatherProvider>(
          builder: (context, provider, child) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
            if (provider.state == WeatherState.loaded) {
              _updateHomeWidget(provider);
            }
          });

            if (provider.state == WeatherState.loading &&
                provider.currentWeather == null) {
              return const LoadingShimmer();
            }

            if (provider.state == WeatherState.error &&
                provider.currentWeather == null) {
              return ErrorWidgetCustom(
                message: provider.errorMessage,
                onRetry: () => provider.fetchWeatherByLocation(),
              );
            }

            if (provider.currentWeather == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      t.noWeatherData,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => provider.fetchWeatherByLocation(),
                      icon: const Icon(Icons.refresh),
                      label: Text(t.getWeather),
                    ),
                  ],
                ),
              );
            }

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 400,
                  pinned: true,
                  stretch: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: CurrentWeatherCard(
                      weather: provider.currentWeather!,
                      isOffline: provider.isOffline,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.location_on),
                      tooltip: t.useCurrentLocation,
                      onPressed: () => provider.fetchWeatherByLocation(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: t.searchCity,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SearchScreen(),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      tooltip: t.settings,
                      onPressed: _reloadAfterSettings,
                    ),
                  ],
                ),

                // 🔥 NEW: Quick Action Buttons
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildQuickActions(context, provider),
                  ),
                ),

                // HOURLY FORECAST
                if (provider.hourlyForecast.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            t.hourlyForecast,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        HourlyForecastList(forecasts: provider.hourlyForecast),
                      ],
                    ),
                  ),

                // DAILY FORECAST
                if (provider.dailyForecast.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.dailyForecast,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          ...provider.dailyForecast.take(5).map(
                                (forecast) => DailyForecastCard(
                                  forecasts: forecast,
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),

                // WEATHER DETAILS
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.weatherDetails,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        WeatherDetailsSection(
                          weather: provider.currentWeather!,
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            );
          },
        ),
      ),
    );
  }
  
  Future<void> _updateHomeWidget(WeatherProvider provider) async {
    if (provider.currentWeather == null) return;

    final w = provider.currentWeather!;

    await HomeWidget.saveWidgetData("city", w.cityName);
    await HomeWidget.saveWidgetData("temp", w.temperature.round().toString());
    await HomeWidget.saveWidgetData("condition", w.description);

    await HomeWidget.saveWidgetData("humidity", "${w.humidity}%");
    await HomeWidget.saveWidgetData("wind", "${w.windSpeed.toStringAsFixed(1)} m/s");
    await HomeWidget.saveWidgetData("pressure", "${w.pressure} hPa");
    await HomeWidget.saveWidgetData(
        "visibility",
        w.visibility != null
            ? "${(w.visibility! / 1000).toStringAsFixed(1)} km"
            : "N/A");

    await HomeWidget.saveWidgetData(
        "updated_at",
        "Updated ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}");

    await HomeWidget.updateWidget(
      androidName: "com.example.weather_app.WeatherWidgetProvider",
    );
  }

  Widget _buildQuickActions(BuildContext context, WeatherProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickActionButton(
              icon: Icons.air,
              label: 'Air Quality',
              onTap: () {
                if (provider.currentLatitude != null && 
                    provider.currentLongitude != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AirQualityScreen(
                        latitude: provider.currentLatitude!,
                        longitude: provider.currentLongitude!,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Loading location data...'),
                    ),
                  );
                }
              },
            ),
            _buildQuickActionButton(
              icon: Icons.warning_amber,
              label: 'Alerts',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AlertsScreen(),
                  ),
                );
              },
            ),
            _buildQuickActionButton(
              icon: Icons.compare_arrows,
              label: 'Compare',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CompareCitiesScreen(),
                  ),
                );
              },
            ),
            _buildQuickActionButton(
              icon: Icons.map,
              label: 'Maps',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WeatherMapsScreen(
                      latitude: provider.currentLatitude,
                      longitude: provider.currentLongitude,
                      cityName: provider.currentWeather?.cityName,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AppLocalizations t) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.cloud, size: 48, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'Weather App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Your weather companion',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(t.home),
            onTap: () => Navigator.pop(context),
          ),
          
          ListTile(
            leading: const Icon(Icons.search),
            title: Text(t.searchCity),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.air),
            title: const Text('Air Quality Index'),
            onTap: () {
              Navigator.pop(context);
              final provider = context.read<WeatherProvider>();
              if (provider.currentLatitude != null && 
                  provider.currentLongitude != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AirQualityScreen(
                      latitude: provider.currentLatitude!,
                      longitude: provider.currentLongitude!,
                    ),
                  ),
                );
              }
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.warning_amber),
            title: const Text('Weather Alerts'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlertsScreen()),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.compare_arrows),
            title: const Text('Compare Cities'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CompareCitiesScreen()),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Weather Maps'),
            onTap: () {
              Navigator.pop(context);
              final provider = context.read<WeatherProvider>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WeatherMapsScreen(
                    latitude: provider.currentLatitude,
                    longitude: provider.currentLongitude,
                    cityName: provider.currentWeather?.cityName,
                  ),
                ),
              );
            },
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(t.settings),
            onTap: () {
              Navigator.pop(context);
              _reloadAfterSettings();
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'Weather App',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.cloud, size: 48),
                children: const [
                  Text(
                    'A comprehensive weather application with advanced features:\n\n'
                    '• Real-time weather data\n'
                    '• Air quality index\n'
                    '• Weather alerts\n'
                    '• Compare multiple cities\n'
                    '• 5-day detailed forecast\n'
                    '• Offline support\n\n'
                    'Developed for Thu Dau Mot University',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}


// ========================= WEATHER DETAILS =============================
// 🔥 FIXED: Sunrise/Sunset moved ABOVE other details
class WeatherDetailsSection extends StatelessWidget {
  final dynamic weather;

  const WeatherDetailsSection({super.key, required this.weather});

  String _getWindDirection(int? degree) {
    if (degree == null) return 'N/A';
    final directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degree + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  String _formatTime(int? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Column(
      children: [
        // 🔥 Row 1: Sunrise + Sunset (MOVED TO TOP!)
        if (weather.sunrise != null && weather.sunset != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: WeatherDetailItem(
                      icon: Icons.wb_sunny,
                      label: 'Sunrise',
                      value: _formatTime(weather.sunrise),
                      iconColor: Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: WeatherDetailItem(
                      icon: Icons.nights_stay,
                      label: 'Sunset',
                      value: _formatTime(weather.sunset),
                      iconColor: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 12),

        // 🔥 Row 2: Humidity + Wind Speed + Wind Direction
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: WeatherDetailItem(
                    icon: Icons.water_drop,
                    label: t.humidity,
                    value: '${weather.humidity}%',
                  ),
                ),

                Expanded(
                  child: FutureBuilder<String>(
                    future: SettingsService().getWindUnit(),
                    builder: (context, snapshot) {
                      final unit = snapshot.data ?? "m/s";
                      double speed = weather.windSpeed.toDouble();

                      if (unit == "km/h") {
                        speed = speed * 3.6;
                      } else if (unit == "mph") {
                        speed = speed * 2.237;
                      }

                      return WeatherDetailItem(
                        icon: Icons.air,
                        label: t.windSpeed,
                        value: '${speed.toStringAsFixed(1)} $unit',
                      );
                    },
                  ),
                ),

                Expanded(
                  child: Column(
                    children: [
                      Transform.rotate(
                        angle: (weather.windDegree ?? 0) * 3.14159 / 180,
                        child: Icon(
                          Icons.navigation,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Direction',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getWindDirection(weather.windDegree),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 🔥 Row 3: Pressure + Visibility + Cloudiness
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: WeatherDetailItem(
                    icon: Icons.compress,
                    label: t.pressure,
                    value: '${weather.pressure} hPa',
                  ),
                ),
                Expanded(
                  child: WeatherDetailItem(
                    icon: Icons.visibility,
                    label: t.visibility,
                    value: weather.visibility != null
                        ? '${(weather.visibility! / 1000).toStringAsFixed(1)} km'
                        : 'N/A',
                  ),
                ),
                Expanded(
                  child: WeatherDetailItem(
                    icon: Icons.cloud,
                    label: 'Cloudiness',
                    value: weather.cloudiness != null 
                        ? '${weather.cloudiness}%' 
                        : 'N/A',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}