import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// A widget that displays high-quality Lottie weather animations
/// sourced from open-source repositories (basmilius/weather-icons).
/// Includes fallback mechanism and caching.
class LottieWeatherDisplay extends StatefulWidget {
  final int weatherCode;
  final bool isNight;
  final double size;

  const LottieWeatherDisplay({
    super.key,
    required this.weatherCode,
    this.isNight = false,
    this.size = 200,
  });

  @override
  State<LottieWeatherDisplay> createState() => _LottieWeatherDisplayState();
}

class _LottieWeatherDisplayState extends State<LottieWeatherDisplay> {
  // Primary Source: basmilius/weather-icons (Dev branch for raw access)
  static const String _baseUrl =
      'https://raw.githubusercontent.com/basmilius/weather-icons/dev/production/lottie/all';

  // Secondary Source: duvid/lottie-weather as fallback structure if we need to switch strategies
  // But for now, we map WMO codes to basmilius filenames

  String _getAnimationUrl() {
    final filename = _getFilenameForCode(widget.weatherCode, widget.isNight);
    return '$_baseUrl/$filename.json';
  }

  String _getFilenameForCode(int code, bool isNight) {
    // WMO Weather Code Mapping to basmilius filenames
    // 0: Clear sky
    if (code == 0) return isNight ? 'clear-night' : 'clear-day';

    // 1, 2, 3: Mainly clear, partly cloudy, overcast
    if (code == 1) return isNight ? 'partly-cloudy-night' : 'partly-cloudy-day';
    if (code == 2) return isNight ? 'partly-cloudy-night' : 'partly-cloudy-day';
    if (code == 3) return isNight ? 'overcast-night' : 'overcast-day';

    // 45, 48: Fog
    if (code == 45 || code == 48) return isNight ? 'fog-night' : 'fog-day';

    // 51, 53, 55: Drizzle
    if (code >= 51 && code <= 55)
      return isNight
          ? 'partly-cloudy-night-drizzle'
          : 'partly-cloudy-day-drizzle';

    // 56, 57: Freezing Drizzle
    if (code == 56 || code == 57)
      return isNight ? 'partly-cloudy-night-sleet' : 'partly-cloudy-day-sleet';

    // 61, 63, 65: Rain
    if (code == 61) return 'rain';
    if (code == 63) return 'rain';
    if (code == 65) return 'rain';

    // 66, 67: Freezing Rain
    if (code == 66 || code == 67) return 'sleet';

    // 71, 73, 75: Snow fall
    if (code == 71) return 'snow';
    if (code == 73) return 'snow';
    if (code == 75) return 'snow';

    // 77: Snow grains
    if (code == 77) return 'snow';

    // 80, 81, 82: Rain showers
    if (code >= 80 && code <= 82)
      return isNight ? 'partly-cloudy-night-rain' : 'partly-cloudy-day-rain';

    // 85, 86: Snow showers
    if (code == 85 || code == 86)
      return isNight ? 'partly-cloudy-night-snow' : 'partly-cloudy-day-snow';

    // 95, 96, 99: Thunderstorm
    if (code >= 95) return 'thunderstorms';

    // Default
    return isNight ? 'clear-night' : 'clear-day';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Lottie.network(
        _getAnimationUrl(),
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to local asset if network fails or URL is wrong
          // We can use a simple icon as ultimate fallback
          return Icon(
            _getFallbackIcon(),
            size: widget.size * 0.5,
            color: Theme.of(context).colorScheme.onSurface,
          );
        },
        frameBuilder: (context, child, composition) {
          if (composition == null) {
            return const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          return child;
        },
      ),
    );
  }

  IconData _getFallbackIcon() {
    final code = widget.weatherCode;
    if (code == 0)
      return widget.isNight ? Icons.nightlight_round : Icons.wb_sunny_rounded;
    if (code < 4) return Icons.cloud_rounded;
    if (code < 50) return Icons.foggy;
    if (code < 60) return Icons.grain_rounded;
    if (code < 70) return Icons.water_drop_rounded;
    if (code < 80) return Icons.ac_unit_rounded;
    if (code < 95) return Icons.shower_rounded;
    return Icons.thunderstorm_rounded;
  }
}
