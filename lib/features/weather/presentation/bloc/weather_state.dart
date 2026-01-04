import 'package:equatable/equatable.dart';
import '../../data/weather_model.dart';

sealed class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

/// State for refreshing - keeps old data visible while fetching new data
class WeatherRefreshing extends WeatherState {
  final WeatherModel weather;
  final String city;
  final String aiInsight;

  const WeatherRefreshing({
    required this.weather,
    required this.city,
    required this.aiInsight,
  });

  @override
  List<Object?> get props => [weather, city, aiInsight];
}

class WeatherLoaded extends WeatherState {
  final WeatherModel weather;
  final String city;
  final String aiInsight;
  final List<AiInsightCard> aiCards;

  const WeatherLoaded({
    required this.weather,
    required this.city,
    required this.aiInsight,
    this.aiCards = const [],
  });

  @override
  List<Object?> get props => [weather, city, aiInsight, aiCards];
}

class WeatherError extends WeatherState {
  final String message;

  const WeatherError(this.message);

  @override
  List<Object?> get props => [message];
}

/// AI Insight Card Model
class AiInsightCard {
  final String title;
  final String content;
  final IconType icon;

  const AiInsightCard({
    required this.title,
    required this.content,
    required this.icon,
  });
}

enum IconType { clothing, activity, health, travel }
