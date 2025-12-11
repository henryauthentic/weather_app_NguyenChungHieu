import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  // Stream controller for connectivity changes
  final _connectivityController = StreamController<bool>.broadcast();
  
  // Get connectivity stream
  Stream<bool> get connectivityStream => _connectivityController.stream;
  
  // Current connectivity status
  bool _isConnected = true;
  bool get isConnected => _isConnected;
  
  // Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    await checkConnectivity();
    
    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {
        _updateConnectionStatus(result);
      },
    );
  }
  
  // Check current connectivity status
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
      return _isConnected;
    } catch (e) {
      _isConnected = false;
      _connectivityController.add(false);
      return false;
    }
  }
  
  // Update connection status
  void _updateConnectionStatus(ConnectivityResult result) {
    final wasConnected = _isConnected;
    _isConnected = result != ConnectivityResult.none;
    
    // Only emit if status changed
    if (wasConnected != _isConnected) {
      _connectivityController.add(_isConnected);
    }
  }
  
  // Get connectivity type
  Future<String> getConnectivityType() async {
    final result = await _connectivity.checkConnectivity();
    
    switch (result) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.none:
        return 'No Connection';
      default:
        return 'Unknown';
    }
  }
  
  // Show connectivity snackbar
  static void showConnectivitySnackbar(
    BuildContext context,
    bool isConnected,
  ) {
    final message = isConnected
        ? 'Back online'
        : 'No internet connection';
    
    final backgroundColor = isConnected ? Colors.green : Colors.red;
    final icon = isConnected ? Icons.wifi : Icons.wifi_off;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: isConnected ? 2 : 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
  }
}

// Connectivity status widget
class ConnectivityStatusBar extends StatefulWidget {
  final Widget child;
  
  const ConnectivityStatusBar({
    super.key,
    required this.child,
  });
  
  @override
  State<ConnectivityStatusBar> createState() => _ConnectivityStatusBarState();
}

class _ConnectivityStatusBarState extends State<ConnectivityStatusBar> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isConnected = true;
  bool _showBanner = false;
  
  @override
  void initState() {
    super.initState();
    _initConnectivity();
  }
  
  Future<void> _initConnectivity() async {
    await _connectivityService.initialize();
    
    _connectivityService.connectivityStream.listen((isConnected) {
      setState(() {
        _isConnected = isConnected;
        _showBanner = !isConnected;
      });
      
      // Auto-hide banner after 3 seconds if connected
      if (isConnected && _showBanner) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() => _showBanner = false);
          }
        });
      }
    });
  }
  
  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_showBanner)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: _isConnected ? Colors.green : Colors.red,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isConnected ? Icons.wifi : Icons.wifi_off,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _isConnected
                      ? 'Back online'
                      : 'No internet connection',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}