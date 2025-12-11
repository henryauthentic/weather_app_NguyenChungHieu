import 'package:flutter/material.dart';

class ErrorWidgetCustom extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorWidgetCustom({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getErrorIcon(message),
              size: 80,
              color: Colors.red[300],
            ),
            const SizedBox(height: 24),
            Text(
              _getErrorTitle(message),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getErrorSuggestion(message),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getErrorIcon(String message) {
    if (message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('internet') ||
        message.toLowerCase().contains('connection')) {
      return Icons.wifi_off;
    } else if (message.toLowerCase().contains('location') ||
               message.toLowerCase().contains('permission')) {
      return Icons.location_off;
    } else if (message.toLowerCase().contains('city not found')) {
      return Icons.location_city;
    } else if (message.toLowerCase().contains('api key')) {
      return Icons.key_off;
    }
    return Icons.error_outline;
  }

  String _getErrorTitle(String message) {
    if (message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('internet') ||
        message.toLowerCase().contains('connection')) {
      return 'Connection Error';
    } else if (message.toLowerCase().contains('location') ||
               message.toLowerCase().contains('permission')) {
      return 'Location Access Needed';
    } else if (message.toLowerCase().contains('city not found')) {
      return 'City Not Found';
    } else if (message.toLowerCase().contains('api key')) {
      return 'Configuration Error';
    }
    return 'Oops! Something went wrong';
  }

  String _getErrorSuggestion(String message) {
    if (message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('internet') ||
        message.toLowerCase().contains('connection')) {
      return 'Please check your internet connection and try again';
    } else if (message.toLowerCase().contains('location') ||
               message.toLowerCase().contains('permission')) {
      return 'Please enable location services in your device settings';
    } else if (message.toLowerCase().contains('city not found')) {
      return 'Try searching for a different city name';
    } else if (message.toLowerCase().contains('api key')) {
      return 'Please check your API key configuration';
    }
    return 'Please try again or contact support if the problem persists';
  }
}