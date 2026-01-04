import 'package:equatable/equatable.dart';

sealed class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object?> get props => [];
}

class LoadWeather extends WeatherEvent {}

class RefreshWeather extends WeatherEvent {}

class LoadWeatherForLocation extends WeatherEvent {
  final double latitude;
  final double longitude;
  final String cityName;

  const LoadWeatherForLocation(this.latitude, this.longitude, this.cityName);

  @override
  List<Object?> get props => [latitude, longitude, cityName];
}
