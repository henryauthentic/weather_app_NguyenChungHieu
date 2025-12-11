import 'package:flutter/material.dart';
import 'package:weather_app/l10n/app_localizations.dart';
import '../models/weather_alert_model.dart';
import '../utils/date_formatter.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<WeatherAlertModel> _alerts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() => _isLoading = true);
    
    // TODO: Load real alerts from API
    // For demo, we'll create sample alerts
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _alerts = _getSampleAlerts();
      _isLoading = false;
    });
  }

  List<WeatherAlertModel> _getSampleAlerts() {
    // Sample alerts for demonstration
    return [
      WeatherAlertModel(
        senderName: 'National Weather Service',
        event: 'Thunderstorm Warning',
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(hours: 3)),
        description: 'Severe thunderstorms are expected in the area. Heavy rain, lightning, and strong winds are possible.',
        tags: ['Thunderstorm', 'Warning'],
      ),
      WeatherAlertModel(
        senderName: 'Weather Alert System',
        event: 'Heat Advisory',
        start: DateTime.now().add(const Duration(hours: 2)),
        end: DateTime.now().add(const Duration(hours: 24)),
        description: 'Temperatures are expected to reach 38°C. Stay hydrated and avoid prolonged outdoor activities.',
        tags: ['Heat', 'Advisory'],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(t.weatherAlerts),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAlerts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _alerts.isEmpty
              ? _buildNoAlerts()
              : _buildAlertsList(),
    );
  }

  Widget _buildNoAlerts() {
    final t = AppLocalizations.of(context)!;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.green[300],
          ),
          const SizedBox(height: 16),
          Text(
            t.noActiveAlerts,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.allClearNoWarnings,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList() {
    final t = AppLocalizations.of(context)!;
    
    // Separate active and expired alerts
    final activeAlerts = _alerts.where((a) => a.isActive()).toList();
    final upcomingAlerts = _alerts.where((a) => !a.isActive() && a.start.isAfter(DateTime.now())).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (activeAlerts.isNotEmpty) ...[
          Text(
            t.activeAlerts,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...activeAlerts.map((alert) => _buildAlertCard(alert, true)),
          const SizedBox(height: 24),
        ],
        if (upcomingAlerts.isNotEmpty) ...[
          Text(
            t.upcomingAlerts,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...upcomingAlerts.map((alert) => _buildAlertCard(alert, false)),
        ],
      ],
    );
  }

  Widget _buildAlertCard(WeatherAlertModel alert, bool isActive) {
    final t = AppLocalizations.of(context)!;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isActive ? 8 : 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color(alert.getColor()),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(alert.getColor()).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    alert.getIcon(),
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.event,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          alert.getSeverity(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(alert.getColor()),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        t.active,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time info
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${t.from} ${DateFormatter.formatTime24(alert.start)} ${t.to} ${DateFormatter.formatTime24(alert.end)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Sender
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        alert.senderName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 24),
                  
                  // Description
                  Text(
                    alert.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  
                  if (isActive) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${t.timeRemaining}: ${_formatDuration(alert.getTimeRemaining())}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final t = AppLocalizations.of(context)!;
    
    if (duration.isNegative) return t.expired;
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 24) {
      final days = hours ~/ 24;
      return '$days day${days > 1 ? 's' : ''}';
    } else if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''} $minutes min';
    } else {
      return '$minutes minute${minutes > 1 ? 's' : ''}';
    }
  }
}