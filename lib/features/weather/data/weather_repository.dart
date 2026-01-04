import 'package:dio/dio.dart';
import 'weather_model.dart';

class WeatherRepository {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<WeatherModel> getWeather(double lat, double lon) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'current':
              'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m',
          'hourly': 'temperature_2m,weather_code',
          'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
          'timezone': 'auto',
        },
      );

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }
}
