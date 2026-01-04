class WeatherModel {
  final double temperature;
  final double apparentTemperature;
  final int weatherCode;
  final int humidity;
  final double windSpeed;
  final int isDay;
  final DateTime time;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  WeatherModel({
    required this.temperature,
    required this.apparentTemperature,
    required this.weatherCode,
    required this.humidity,
    required this.windSpeed,
    required this.isDay,
    required this.time,
    required this.hourly,
    required this.daily,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    final hourlyJson = json['hourly'];
    final dailyJson = json['daily'];

    return WeatherModel(
      temperature: (current['temperature_2m'] as num).toDouble(),
      apparentTemperature: (current['apparent_temperature'] as num).toDouble(),
      weatherCode: current['weather_code'] as int,
      humidity: current['relative_humidity_2m'] as int,
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      isDay: current['is_day'] as int,
      time: DateTime.parse(current['time']),
      hourly: _parseHourly(hourlyJson),
      daily: _parseDaily(dailyJson),
    );
  }

  static List<HourlyForecast> _parseHourly(Map<String, dynamic> json) {
    final times = json['time'] as List;
    final temps = json['temperature_2m'] as List;
    final codes = json['weather_code'] as List;

    // Take next 24 hours
    List<HourlyForecast> list = [];
    for (int i = 0; i < 24 && i < times.length; i++) {
      list.add(
        HourlyForecast(
          time: DateTime.parse(times[i]),
          temperature: (temps[i] as num).toDouble(),
          weatherCode: codes[i] as int,
        ),
      );
    }
    return list;
  }

  static List<DailyForecast> _parseDaily(Map<String, dynamic> json) {
    final times = json['time'] as List;
    final maxTemps = json['temperature_2m_max'] as List;
    final minTemps = json['temperature_2m_min'] as List;
    final codes = json['weather_code'] as List;

    List<DailyForecast> list = [];
    for (int i = 0; i < 7 && i < times.length; i++) {
      list.add(
        DailyForecast(
          date: DateTime.parse(times[i]),
          maxTemp: (maxTemps[i] as num).toDouble(),
          minTemp: (minTemps[i] as num).toDouble(),
          weatherCode: codes[i] as int,
        ),
      );
    }
    return list;
  }
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final int weatherCode;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
  });
}

class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
  });
}
