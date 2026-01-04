import 'package:flutter/material.dart';

class WeatherBackgroundWrapper extends StatelessWidget {
  final Widget child;
  final int weatherCode;
  final bool isNight;

  const WeatherBackgroundWrapper({
    super.key,
    required this.child,
    required this.weatherCode,
    this.isNight = false,
  });

  List<Color> _getGradientColors() {
    // Night overrides
    if (isNight) {
      if (weatherCode >= 95) {
        // Stormy Night
        return const [
          Color(0xFF0F0C29), // Dark Purple/Black
          Color(0xFF302B63), // Deep Purple
          Color(0xFF24243E), // Dark Blue Grey
        ];
      }
      // Standard Night
      return const [
        Color(0xFF000000), // Black
        Color(0xFF1A1A2E), // Dark Navy
        Color(0xFF16213E), // Midnight Blue
      ];
    }

    // Day Conditions
    if (weatherCode == 0) {
      // Sunny / Clear
      return const [
        Color(0xFF4CA1AF), // Muted Teal
        Color(0xFFC4E0E5), // Soft Blue
      ];
    }

    if (weatherCode < 4) {
      // Cloudy
      return const [
        Color(0xFF606C88), // Slate Grey
        Color(0xFF3F4C6B), // Dark Slate
      ];
    }

    if (weatherCode >= 50 && weatherCode < 60) {
      // Drizzle / Fog
      return const [
        Color(0xFF3E5151), // Dark Green Grey
        Color(0xFFDECBA4), // Sand (Foggy)
      ];
    }

    if (weatherCode >= 60 && weatherCode < 70) {
      // Rain
      return const [
        Color(0xFF2C3E50), // Dark Blue Grey
        Color(0xFF4CA1AF), // Teal Grey
      ];
    }

    if (weatherCode >= 70 && weatherCode < 80) {
      // Snow
      return const [
        Color(0xFF83A4D4), // Ice Blue
        Color(0xFFB6FBFF), // Light Cyan
      ];
    }

    if (weatherCode >= 95) {
      // Storm
      return const [
        Color(0xFF232526), // Dark Grey
        Color(0xFF414345), // Lighter Grey
      ];
    }

    // Default
    return const [Color(0xFF1A1A1A), Color(0xFF000000)];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _getGradientColors(),
        ),
      ),
      child: child,
    );
  }
}
