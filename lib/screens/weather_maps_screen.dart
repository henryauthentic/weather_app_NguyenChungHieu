// lib/screens/weather_maps_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';
import '../models/weather_model.dart';
import '../config/api_config.dart';

class WeatherMapsScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? cityName;

  const WeatherMapsScreen({
    super.key,
    this.latitude,
    this.longitude,
    this.cityName,
  });

  @override
  State<WeatherMapsScreen> createState() => _WeatherMapsScreenState();
}

class _WeatherMapsScreenState extends State<WeatherMapsScreen>
    with TickerProviderStateMixin {
  late final MapController _mapController;
  late final TabController _tabController;
  late final AnimationController _anim;

  bool _panelOpen = true;
  double _overlayOpacity = 0.55;

  bool _showWind = true;
  bool _showTemp = true;
  bool _showRain = true;

  late LatLng _center;

  final List<_WindParticle> _wind = [];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();

    _center = LatLng(widget.latitude ?? 10.8231, widget.longitude ?? 106.6297);

    _mapController = MapController();
    _tabController = TabController(length: 3, vsync: this);

    // unbounded with long period so animation value grows smoothly
    _anim = AnimationController.unbounded(vsync: this)
      ..repeat(min: 0, max: 99999999, period: const Duration(seconds: 90));

    for (int i = 0; i < 140; i++) {
      _wind.add(_WindParticle.random(_rnd));
    }

    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeatherProvider>(context);
    final WeatherModel? w = provider.currentWeather;

    // safe fallbacks
    final windSpeed = w?.windSpeed ?? 0.0;
    final windDeg = w?.windDegree ?? 0;
    final temp = w?.temperature ?? 0.0;
    final cond = (w?.description ?? "").toLowerCase();

    final overlayUrl = _getTileLayerUrl();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cityName ?? "Weather Maps"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Radar", icon: Icon(Icons.cloud)),
            Tab(text: "Temperature", icon: Icon(Icons.thermostat)),
            Tab(text: "Precipitation", icon: Icon(Icons.water_drop)),
          ],
          onTap: (_) => setState(() {}), // redraw legend when tab selected
        ),
      ),
      body: Stack(
        children: [
          // Map
          _buildFlutterMap(overlayUrl, cond, windSpeed, windDeg, temp),

          // Top control panel (collapsible)
          _buildTopPanel(),

          // Left controls (zoom + my location)
          _buildLeftButtons(),

          // Status card bottom-right
          Positioned(
            right: 15,
            bottom: 20,
            child: _buildStatusCard(windSpeed, windDeg, temp, cond),
          ),
        ],
      ),
    );
  }

  // ---------------------------
  // Build map widget (separate so we can pass variables)
  // ---------------------------
  Widget _buildFlutterMap(String overlayUrl, String cond, double windSpeed,
      int windDeg, double temp) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        // initial center & zoom
        center: _center,
        zoom: 9.0,
        minZoom: 3.0,
        maxZoom: 18.0,
        // enable interactions (drag, pinch zoom, double tap etc)
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      // layers / children (TileLayer, MarkerLayer, etc.)
      children: [
        // Base map OSM
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: "com.example.weather_app",
        ),

        // Weather overlay tiles (OpenWeatherMap tile server)
        TileLayer(
          urlTemplate: overlayUrl,
          userAgentPackageName: "com.example.weather_app",
          // for flutter_map 6.x: wrap tileWidget to control opacity
          tileBuilder: (context, tileWidget, tile) {
            return Opacity(opacity: _overlayOpacity, child: tileWidget);
          },
        ),

        // Marker layer for current location / chosen city
        MarkerLayer(
          markers: [
            Marker(
              point: _center,
              width: 48,
              height: 48,
              // using child (works with your flutter_map version)
              child: const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 40,
              ),
            ),
          ],
        ),
      ],
    ).wrapWithOverlay(
        // Put animated overlays as overlay on top of map (not inside children)
        AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => IgnorePointer(
        ignoring: true,
        child: CustomPaint(
          painter: _OverlayPainter(
            anim: _anim.value,
            showWind: _showWind,
            showTemp: _showTemp,
            showRain: _showRain && cond.contains("rain"),
            windSpeed: windSpeed,
            windDeg: windDeg.toDouble(),
            temperature: temp,
            particles: _wind,
            rnd: _rnd,
          ),
        ),
      ),
    ));
  }

  // ---------------------------
  // Top collapsible panel
  // ---------------------------
  Widget _buildTopPanel() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      top: _panelOpen ? 12 : -260,
      right: 12,
      child: GestureDetector(
        onTap: () => setState(() => _panelOpen = !_panelOpen),
        child: _buildControlPanel(),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _legendTitle(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Icon(_panelOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down)
            ],
          ),
          const SizedBox(height: 8),
          _legendItems(),
          const Divider(),
          const Text("Overlay Opacity"),
          Slider(
            value: _overlayOpacity,
            min: 0.0,
            max: 1.0,
            onChanged: (v) => setState(() => _overlayOpacity = v),
          ),
          _checkRow(_showWind, "Wind", (v) => setState(() => _showWind = v)),
          _checkRow(_showTemp, "Temperature Glow", (v) => setState(() => _showTemp = v)),
          _checkRow(_showRain, "Rain Effect", (v) => setState(() => _showRain = v)),
        ],
      ),
    );
  }

  Widget _checkRow(bool value, String label, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: (v) => onChanged(v ?? false)),
        Text(label),
      ],
    );
  }

  // ---------------------------
  // Left vertical buttons (zoom + my location)
  // ---------------------------
  Widget _buildLeftButtons() {
    return Positioned(
      left: 14,
      bottom: 18,
      child: Column(
        children: [
          _roundBtn(Icons.add, () {
            _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
          }),
          const SizedBox(height: 8),
          _roundBtn(Icons.remove, () {
            _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);
          }),
          const SizedBox(height: 8),
          _roundBtn(Icons.my_location, () {
            // move map to current center (instant). animate not necessary for now.
            _mapController.move(_center, 13.0);
          }),
        ],
      ),
    );
  }

  Widget _roundBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, size: 26),
        ),
      ),
    );
  }

  // ---------------------------
  // Status card bottom-right
  // ---------------------------
  Widget _buildStatusCard(double wind, int deg, double temp, String cond) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.98),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _statusRow("Wind", "${wind.toStringAsFixed(1)} m/s"),
          _statusRow("Dir", "$deg°"),
          _statusRow("Temp", "${temp.toStringAsFixed(1)}°C"),
          _statusRow("Cond", cond),
        ],
      ),
    );
  }

  Widget _statusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }

  // ---------------------------
  // Tile URL helper (uses ApiConfig.getMapTileUrl)
  // ---------------------------
  String _getTileLayerUrl() {
    switch (_tabController.index) {
      case 0:
        return ApiConfig.getMapTileUrl(ApiConfig.clouds);
      case 1:
        return ApiConfig.getMapTileUrl(ApiConfig.temp);
      case 2:
      default:
        return ApiConfig.getMapTileUrl(ApiConfig.precip);
    }
  }

  String _legendTitle() {
    switch (_tabController.index) {
      case 0:
        return "Cloud Coverage";
      case 1:
        return "Temperature";
      default:
        return "Precipitation";
    }
  }

  Widget _legendItems() {
    switch (_tabController.index) {
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("> 40°C", style: TextStyle(color: Colors.red)),
            Text("30°C", style: TextStyle(color: Colors.orange)),
            Text("20°C", style: TextStyle(color: Colors.yellow)),
            Text("10°C", style: TextStyle(color: Colors.green)),
            Text("0°C", style: TextStyle(color: Colors.blue)),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Heavy", style: TextStyle(color: Colors.blue)),
            Text("Moderate", style: TextStyle(color: Colors.lightBlue)),
            Text("Light", style: TextStyle(color: Colors.cyan)),
          ],
        );
      default:
        return const Text("Cloud layers");
    }
  }
}

// ---------------------------
// Wind particle & painter
// ---------------------------
class _WindParticle {
  Offset pos;
  double size;
  double speed;
  Color color;

  _WindParticle({
    required this.pos,
    required this.size,
    required this.speed,
    required this.color,
  });

  factory _WindParticle.random(Random rnd) {
    return _WindParticle(
      pos: Offset(rnd.nextDouble(), rnd.nextDouble()),
      size: 1 + rnd.nextDouble() * 2.5,
      speed: 0.3 + rnd.nextDouble() * 1.3,
      color: Colors.white.withOpacity(0.8),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final double anim;
  final bool showWind, showTemp, showRain;
  final double windSpeed, windDeg, temperature;
  final List<_WindParticle> particles;
  final Random rnd;

  _OverlayPainter({
    required this.anim,
    required this.showWind,
    required this.showTemp,
    required this.showRain,
    required this.windSpeed,
    required this.windDeg,
    required this.temperature,
    required this.particles,
    required this.rnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (showTemp) _paintTempGlow(canvas, size);
    if (showWind) _paintWind(canvas, size);
    if (showRain) _paintRain(canvas, size);
  }

  void _paintTempGlow(Canvas canvas, Size size) {
    final t = temperature.clamp(-30.0, 45.0);
    final n = (t + 30) / 75; // normalize 0..1
    final color = Color.lerp(Colors.blue, Colors.red, n)!;

    final paint = Paint()
      ..color = color.withOpacity(0.14)
      ..blendMode = BlendMode.overlay;

    canvas.drawRect(Offset.zero & size, paint);
  }

  void _paintWind(Canvas canvas, Size size) {
    final rad = (windDeg + 180) * pi / 180;
    final vx = cos(rad);
    final vy = sin(rad);

    final paint = Paint()..strokeCap = StrokeCap.round;

    // scale windSpeed to pixels step
    final speedFactor = (windSpeed.clamp(0.0, 30.0) / 30.0) * 8.0;

    for (final p in particles) {
      final x = p.pos.dx * size.width;
      final y = p.pos.dy * size.height;

      final nx = x + vx * p.speed * speedFactor;
      final ny = y + vy * p.speed * speedFactor;

      paint.color = p.color;
      paint.strokeWidth = p.size;

      canvas.drawLine(Offset(x, y), Offset(nx, ny), paint);

      p.pos = Offset(
        ((nx % size.width) + size.width) / size.width,
        ((ny % size.height) + size.height) / size.height,
      );

      p.color = Colors.white.withOpacity(0.3 + rnd.nextDouble() * 0.6);
    }
  }

  void _paintRain(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.blueAccent.withOpacity(0.22);

    for (int i = 0; i < 80; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = (anim * 0.5 + i * 30) % size.height;
      canvas.drawRect(Rect.fromLTWH(x, y, 2, 10), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) => true;
}

// ---------------------------
// Helper extension to place overlay (keeps FlutterMap children clean)
// ---------------------------
extension _MapOverlayExt on FlutterMap {
  /// Wraps the map with a Stack overlay child placed on top.
  Widget wrapWithOverlay(Widget overlay) {
    return Stack(
      fit: StackFit.expand,
      children: [
        this,
        overlay,
      ],
    );
  }
}
