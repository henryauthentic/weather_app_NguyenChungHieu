import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../config/api_config.dart';

class CompareCitiesScreen extends StatefulWidget {
  const CompareCitiesScreen({super.key});

  @override
  State<CompareCitiesScreen> createState() => _CompareCitiesScreenState();
}

class _CompareCitiesScreenState extends State<CompareCitiesScreen> {
  final List<String> _selectedCities = [];
  final Map<String, WeatherModel?> _weatherData = {};
  final Map<String, bool> _loadingStates = {};
  bool _isComparing = false;

  final List<String> _popularCities = [
    'Ho Chi Minh City',
    'Hanoi',
    'Da Nang',
    'London',
    'New York',
    'Tokyo',
    'Paris',
    'Singapore',
    'Bangkok',
    'Seoul',
    'Dubai',
    'Sydney',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Compare Cities"),

        /// Nút Compare – chỉ hiện khi chọn ≥ 2 cities
        actions: [
          if (!_isComparing && _selectedCities.length >= 2)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton(
                onPressed: _compareWeather,
                child: const Text(
                  "Compare",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

          /// Khi đang trong chế độ So sánh → có nút Quay lại
          if (_isComparing)
            TextButton(
              onPressed: () {
                setState(() => _isComparing = false);
              },
              child: const Text("Back", style: TextStyle(color: Colors.white)),
            ),
        ],
      ),

      body: Column(
        children: [
          _buildSelectedCitiesBar(),
          Expanded(
            child: _isComparing
                ? _buildComparisonView()
                : _buildCitySelectionList(),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SELECTED CITIES PANEL
  // ===========================================================================

  Widget _buildSelectedCitiesBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Selected Cities (${_selectedCities.length}/4)",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          if (_selectedCities.isEmpty)
            const Text(
              "Select at least 2 cities to compare",
              style: TextStyle(fontSize: 14),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedCities.map((city) {
                return Chip(
                  deleteIcon: const Icon(Icons.close),
                  label: Text(city),
                  onDeleted: () {
                    setState(() {
                      _selectedCities.remove(city);
                      _weatherData.remove(city);
                      if (_selectedCities.length < 2) {
                        _isComparing = false;
                      }
                    });
                  },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // CITY LIST SELECTOR
  // ===========================================================================

  Widget _buildCitySelectionList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _popularCities.length,
      itemBuilder: (context, index) {
        final city = _popularCities[index];
        final isSelected = _selectedCities.contains(city);

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Icon(
              isSelected ? Icons.check_circle : Icons.location_city,
              color: isSelected ? Colors.green : null,
            ),
            title: Text(city),
            trailing: isSelected
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedCities.remove(city);
                } else if (_selectedCities.length < 4) {
                  _selectedCities.add(city);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Maximum 4 cities allowed"),
                    ),
                  );
                }
              });
            },
          ),
        );
      },
    );
  }

  // ===========================================================================
  // FETCH WEATHER + SWITCH TO COMPARE MODE
  // ===========================================================================

  Future<void> _compareWeather() async {
    setState(() => _isComparing = true);

    final service = WeatherService(apiKey: ApiConfig.apiKey);

    for (final city in _selectedCities) {
      if (!_weatherData.containsKey(city)) {
        setState(() => _loadingStates[city] = true);

        try {
          final weather = await service.getCurrentWeatherByCity(city);
          setState(() {
            _weatherData[city] = weather;
            _loadingStates[city] = false;
          });
        } catch (e) {
          setState(() {
            _weatherData[city] = null;
            _loadingStates[city] = false;
          });
        }
      }
    }
  }

  // ===========================================================================
  // MAIN COMPARISON VIEW
  // ===========================================================================

  Widget _buildComparisonView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildQuickOverviewCards(),
        const SizedBox(height: 24),
        _buildDetailedComparison(),
      ],
    );
  }

  // ===========================================================================
  // QUICK OVERVIEW CARDS
  // ===========================================================================

  Widget _buildQuickOverviewCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Overview",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _selectedCities.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
          itemBuilder: (context, index) {
            final city = _selectedCities[index];
            final weather = _weatherData[city];
            final isLoading = _loadingStates[city] ?? false;

            return _buildCityWeatherCard(city, weather, isLoading);
          },
        ),
      ],
    );
  }

  Widget _buildCityWeatherCard(
      String city, WeatherModel? weather, bool isLoading) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : weather == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      Text("Failed\n$city",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        city,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      CachedNetworkImage(
                        imageUrl: ApiConfig.getLargeIconUrl(weather.icon),
                        height: 55,
                        width: 55,
                      ),

                      Text(
                        weather.temperatureString,
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),

                      Text(
                        weather.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
    );
  }

  // ===========================================================================
  // DETAILED TABLE
  // ===========================================================================

  Widget _buildDetailedComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Detailed Comparison",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        _buildComparisonRow("Temperature", (w) => "${w.temperature}°C"),
        _buildComparisonRow("Feels Like", (w) => "${w.feelsLike}°C"),
        _buildComparisonRow("Humidity", (w) => "${w.humidity}%"),
        _buildComparisonRow("Wind Speed", (w) => "${w.windSpeed} m/s"),
        _buildComparisonRow("Wind Direction", (w) => "${w.windDegree}°"),
        _buildComparisonRow("Pressure", (w) => "${w.pressure} hPa"),
        _buildComparisonRow("Visibility",
            (w) => w.visibility != null ? "${w.visibility! / 1000} km" : "N/A"),
      ],
    );
  }

  Widget _buildComparisonRow(
      String label, String Function(WeatherModel) getValue) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            ..._selectedCities.map((city) {
              final w = _weatherData[city];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(city,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    Text(
                      w != null ? getValue(w) : "N/A",
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
