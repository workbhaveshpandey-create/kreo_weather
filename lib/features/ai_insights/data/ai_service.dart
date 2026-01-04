import 'package:http/http.dart' as http;

class AiService {
  Future<String> getWeatherInsight(
    int weatherCode,
    double temperature, {
    int? humidity,
    double? windSpeed,
  }) async {
    try {
      final condition = _getConditionText(weatherCode);

      // Build a more detailed prompt
      String details =
          'Temperature: ${temperature.round()}°C, Condition: $condition';
      if (humidity != null) details += ', Humidity: $humidity%';
      if (windSpeed != null) details += ', Wind: ${windSpeed.round()} km/h';

      final prompt =
          '''You are a witty weather assistant for a premium app called Kreo Weather. 
Given these conditions: $details

Provide a single creative, helpful, and slightly humorous one-liner insight (max 15 words). 
Be specific to the weather. No emojis. Be clever.''';

      final encodedPrompt = Uri.encodeComponent(prompt);
      final url = 'https://text.pollinations.ai/$encodedPrompt';

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        String result = response.body.trim();
        // Clean up the response
        result = result.replaceAll('"', '');
        if (result.length > 100) {
          result = result.substring(0, 100);
        }
        return result;
      }

      return _getFallbackInsight(weatherCode, temperature);
    } catch (e) {
      return _getFallbackInsight(weatherCode, temperature);
    }
  }

  String _getFallbackInsight(int code, double temp) {
    if (code == 0) {
      if (temp > 25)
        return 'Sunglasses weather. Your future is looking bright.';
      return 'Clear skies ahead. Perfect day to tackle that to-do list.';
    }
    if (code < 4) return 'Clouds are gathering, but so are opportunities.';
    if (code >= 60 && code < 70) return 'Rain is just confetti from the sky.';
    if (code >= 95) return 'Thor is practicing his drum solos today.';
    return 'Weather is doing its thing. You do yours.';
  }

  String _getConditionText(int code) {
    if (code == 0) return 'Clear';
    if (code < 4) return 'Cloudy';
    if (code < 50) return 'Fog';
    if (code < 60) return 'Drizzle';
    if (code < 70) return 'Rain';
    if (code < 80) return 'Snow';
    if (code >= 95) return 'Thunderstorm';
    return 'Variable';
  }
}
