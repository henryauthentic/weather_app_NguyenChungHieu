// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/l10n/app_localizations.dart';

import '../providers/locale_provider.dart';
import '../services/settings_service.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storage = StorageService();
  final SettingsService _settings = SettingsService();

  String _tempUnit = SettingsService.defaultTemperatureUnit;
  String _windUnit = SettingsService.defaultWindSpeedUnit;
  String _timeFormat = SettingsService.defaultTimeFormat;
  String _language = SettingsService.defaultLanguage;

  bool _notifications = SettingsService.defaultNotificationsEnabled;
  bool _useLocation = SettingsService.defaultUseLocation;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _tempUnit = await _settings.getTemperatureUnit();
      _windUnit = await _settings.getWindUnit();
      _timeFormat = await _settings.getTimeFormat();
      _language = await _settings.getLanguage();
      _notifications = await _settings.getNotificationsEnabled();
      _useLocation = await _settings.getUseLocation();
    } catch (e) {
      // ignore
    }
    setState(() => _loading = false);
  }

  void _showSnack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 2)),
    );
  }

  // -------- TEMPERATURE --------
  Future<void> _changeTemperatureUnit() async {
    final t = AppLocalizations.of(context)!;
    String tmp = _tempUnit;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.temperatureUnit),
          content: StatefulBuilder(
            builder: (context, setLocal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: Text('${t.temperatureUnit} - Celsius (°C)'),
                    value: 'celsius',
                    groupValue: tmp,
                    onChanged: (v) => setLocal(() => tmp = v!),
                  ),
                  RadioListTile<String>(
                    title: const Text('Fahrenheit (°F)'),
                    value: 'fahrenheit',
                    groupValue: tmp,
                    onChanged: (v) => setLocal(() => tmp = v!),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(t.settings)),
            TextButton(
              onPressed: () async {
                await _settings.setTemperatureUnit(tmp);
                setState(() => _tempUnit = tmp);
                Navigator.pop(context, true);
                _showSnack('Temperature unit changed');
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // -------- WIND --------
  Future<void> _changeWindUnit() async {
    final t = AppLocalizations.of(context)!;
    String tmp = _windUnit;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Wind speed unit'),
        content: StatefulBuilder(
          builder: (context, setLocal) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('m/s'),
                  value: 'm/s',
                  groupValue: tmp,
                  onChanged: (v) => setLocal(() => tmp = v!),
                ),
                RadioListTile<String>(
                  title: const Text('km/h'),
                  value: 'km/h',
                  groupValue: tmp,
                  onChanged: (v) => setLocal(() => tmp = v!),
                ),
                RadioListTile<String>(
                  title: const Text('mph'),
                  value: 'mph',
                  groupValue: tmp,
                  onChanged: (v) => setLocal(() => tmp = v!),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t.settings)),
          TextButton(
            onPressed: () async {
              await _settings.setWindSpeedUnit(tmp);
              setState(() => _windUnit = tmp);
              Navigator.pop(context, true);
              _showSnack('Wind unit changed');
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  // -------- TIME FORMAT --------
  Future<void> _changeTimeFormat() async {
    final t = AppLocalizations.of(context)!;
    String tmp = _timeFormat;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Time format'),
        content: StatefulBuilder(
          builder: (context, setLocal) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('24-hour'),
                  value: '24h',
                  groupValue: tmp,
                  onChanged: (v) => setLocal(() => tmp = v!),
                ),
                RadioListTile<String>(
                  title: const Text('12-hour'),
                  value: '12h',
                  groupValue: tmp,
                  onChanged: (v) => setLocal(() => tmp = v!),
                )
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t.settings)),
          TextButton(
            onPressed: () async {
              await _settings.setTimeFormat(tmp);
              setState(() => _timeFormat = tmp);
              Navigator.pop(context, true);
              _showSnack('Time format changed');
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  // -------- LANGUAGE --------
  Future<void> _changeLanguage() async {
    final t = AppLocalizations.of(context)!;
    String tmp = _language;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Language'),
        content: StatefulBuilder(
          builder: (context, setLocal) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('English'),
                  value: 'en',
                  groupValue: tmp,
                  onChanged: (v) => setLocal(() => tmp = v!),
                ),
                RadioListTile<String>(
                  title: const Text('Tiếng Việt'),
                  value: 'vi',
                  groupValue: tmp,
                  onChanged: (v) => setLocal(() => tmp = v!),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t.settings)),
          TextButton(
            onPressed: () async {
              // Save in SettingsService
              await _settings.setLanguage(tmp);

              // Also update LocaleProvider so MaterialApp rebuilds immediately
              if (mounted) {
                final localeProv = Provider.of<LocaleProvider>(context, listen: false);
                await localeProv.setLocale(tmp);
              }

              setState(() => _language = tmp);
              Navigator.pop(context, true); // return true → caller can refresh
              _showSnack('Language changed');
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  // -------- CLEAR CACHE / SEARCH ----------
  Future<void> _clearCache() async {
    await _storage.clearAllCache();
    _showSnack('Cache cleared');
  }

  Future<void> _clearSearchHistory() async {
    await _storage.clearRecentSearches();
    _showSnack('Search history cleared');
  }

  // UI
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: ListView(
        children: [
          _section(t.temperatureUnit),
          ListTile(
            leading: const Icon(Icons.thermostat),
            title: Text(t.temperatureUnit),
            subtitle: Text(_tempUnit == 'celsius' ? 'Celsius (°C)' : 'Fahrenheit (°F)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _changeTemperatureUnit,
          ),
          ListTile(
            leading: const Icon(Icons.air),
            title: const Text('Wind Speed Unit'),
            subtitle: Text(_windUnit),
            trailing: const Icon(Icons.chevron_right),
            onTap: _changeWindUnit,
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Time Format'),
            subtitle: Text(_timeFormat),
            trailing: const Icon(Icons.chevron_right),
            onTap: _changeTimeFormat,
          ),

          const Divider(),
          _section(t.useLocation),
          SwitchListTile(
            value: _useLocation,
            secondary: const Icon(Icons.location_on),
            title: Text(t.useLocation),
            subtitle: const Text("Automatically detect your location"),
            onChanged: (v) async {
              await _settings.setUseLocation(v);
              setState(() => _useLocation = v);
            },
          ),

          const Divider(),
          _section(t.notifications),
          SwitchListTile(
            value: _notifications,
            secondary: const Icon(Icons.notifications),
            title: Text(t.notifications),
            subtitle: const Text("Receive weather alerts"),
            onChanged: (v) async {
              await _settings.setNotificationsEnabled(v);
              setState(() => _notifications = v);
            },
          ),

          const Divider(),
          _section(t.clearCache),
          ListTile(
            leading: const Icon(Icons.delete_sweep),
            title: Text(t.clearCache),
            subtitle: const Text('Remove cached weather data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _clearCache,
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(t.clearSearchHistory),
            subtitle: const Text('Remove recent searches'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _clearSearchHistory,
          ),

          const Divider(),
          _section(t.language),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text('App language'),
            subtitle: Text(_language == 'en' ? 'English' : 'Tiếng Việt'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _changeLanguage,
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
      );
}
