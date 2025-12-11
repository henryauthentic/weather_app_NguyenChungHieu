import 'package:flutter/material.dart';
import 'package:weather_app/l10n/app_localizations.dart';
import '../models/air_quality_model.dart';
import '../services/air_quality_service.dart';
import '../config/api_config.dart';

class AirQualityScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  
  const AirQualityScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<AirQualityScreen> createState() => _AirQualityScreenState();
}

class _AirQualityScreenState extends State<AirQualityScreen> {
  AirQualityModel? _airQuality;
  List<AirQualityModel>? _forecast;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAirQuality();
  }

  Future<void> _loadAirQuality() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = AirQualityService(apiKey: ApiConfig.apiKey);
      
      final airQuality = await service.getAirQuality(
        widget.latitude,
        widget.longitude,
      );
      final forecast = await service.getAirQualityForecast(
        widget.latitude,
        widget.longitude,
      );

      setState(() {
        _airQuality = airQuality;
        _forecast = forecast;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(t.airQualityIndex),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAirQuality,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
    final t = AppLocalizations.of(context)!;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              t.failedToLoadAirQuality,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? t.unknownError,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadAirQuality,
              child: Text(t.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_airQuality == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: _loadAirQuality,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAQICard(),
          const SizedBox(height: 16),
          _buildHealthRecommendation(),
          const SizedBox(height: 16),
          _buildPollutantsCard(),
          const SizedBox(height: 16),
          if (_forecast != null && _forecast!.isNotEmpty) _buildForecast(),
        ],
      ),
    );
  }

  Widget _buildAQICard() {
    final aqi = _airQuality!;
    final t = AppLocalizations.of(context)!;
    
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(aqi.getColor()).withOpacity(0.7),
              Color(aqi.getColor()).withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              aqi.getIcon(),
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              'AQI: ${aqi.aqi}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              aqi.category,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${t.mainPollutant}: ${aqi.getMainPollutant()}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthRecommendation() {
    final t = AppLocalizations.of(context)!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.health_and_safety, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  t.healthRecommendation,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _airQuality!.healthRecommendation,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPollutantsCard() {
    final t = AppLocalizations.of(context)!;
    final pollutants = _airQuality!.pollutants;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.pollutantLevels,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...pollutants.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPollutantItem(
                  _formatPollutantName(entry.key),
                  entry.value,
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPollutantItem(String name, double value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            name,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: (value / 500).clamp(0.0, 1.0),
                backgroundColor: Colors.grey[300],
                color: _getPollutantColor(value),
              ),
              const SizedBox(height: 4),
              Text(
                value.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getPollutantColor(double value) {
    if (value < 50) return Colors.green;
    if (value < 100) return Colors.yellow;
    if (value < 150) return Colors.orange;
    return Colors.red;
  }

  String _formatPollutantName(String key) {
    switch (key) {
      case 'co':
        return 'CO';
      case 'no':
        return 'NO';
      case 'no2':
        return 'NO₂';
      case 'o3':
        return 'O₃';
      case 'so2':
        return 'SO₂';
      case 'pm2_5':
        return 'PM2.5';
      case 'pm10':
        return 'PM10';
      case 'nh3':
        return 'NH₃';
      default:
        return key.toUpperCase();
    }
  }

  Widget _buildForecast() {
    final t = AppLocalizations.of(context)!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.aqiForecast,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _forecast!.take(24).length,
                itemBuilder: (context, index) {
                  final item = _forecast![index];
                  return _buildForecastItem(item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastItem(AirQualityModel item) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color(item.getColor()).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Color(item.getColor()).withOpacity(0.5),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${item.dateTime.hour}:00',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            item.getIcon(),
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            '${item.aqi}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            item.category,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}