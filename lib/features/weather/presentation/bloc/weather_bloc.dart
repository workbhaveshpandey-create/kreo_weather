import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../ai_insights/data/ai_service.dart';
import '../../../weather/data/weather_repository.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/background_service.dart';
import 'weather_event.dart';
import 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository weatherRepository;
  final LocationService locationService;
  final AiService aiService;

  // Cache current location
  double? _currentLat;
  double? _currentLon;
  String? _currentCity;

  WeatherBloc({
    required this.weatherRepository,
    required this.locationService,
    required this.aiService,
  }) : super(WeatherInitial()) {
    on<LoadWeather>(_onLoadWeather);
    on<RefreshWeather>(_onRefreshWeather);
    on<LoadWeatherForLocation>(_onLoadWeatherForLocation);
  }

  Future<void> _onLoadWeather(
    LoadWeather event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());

    try {
      // Get current location
      final position = await locationService.getCurrentPosition();
      final city = await locationService.getCityName(
        position.latitude,
        position.longitude,
      );

      _currentLat = position.latitude;
      _currentLon = position.longitude;
      _currentCity = city;

      // Fetch weather
      final weather = await weatherRepository.getWeather(
        position.latitude,
        position.longitude,
      );

      // Get AI insight
      final insight = await aiService.getWeatherInsight(
        weather.weatherCode,
        weather.temperature,
        humidity: weather.humidity,
        windSpeed: weather.windSpeed,
      );

      // Generate AI insight cards
      final cards = _generateInsightCards(weather);

      emit(
        WeatherLoaded(
          weather: weather,
          city: city,
          aiInsight: insight,
          aiCards: cards,
        ),
      );

      // Show persistent notification with current weather
      BackgroundService.showPersistentWeatherNotification(
        temperature: weather.temperature,
        condition: _getConditionText(weather.weatherCode),
        city: city,
      );
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }

  Future<void> _onRefreshWeather(
    RefreshWeather event,
    Emitter<WeatherState> emit,
  ) async {
    // Keep current data visible while refreshing
    if (state is WeatherLoaded) {
      final current = state as WeatherLoaded;
      emit(
        WeatherRefreshing(
          weather: current.weather,
          city: current.city,
          aiInsight: current.aiInsight,
        ),
      );
    }

    try {
      final lat = _currentLat;
      final lon = _currentLon;
      final city = _currentCity;

      if (lat == null || lon == null || city == null) {
        add(LoadWeather());
        return;
      }

      // Fetch fresh weather
      final weather = await weatherRepository.getWeather(lat, lon);

      // Get fresh AI insight
      final insight = await aiService.getWeatherInsight(
        weather.weatherCode,
        weather.temperature,
        humidity: weather.humidity,
        windSpeed: weather.windSpeed,
      );

      final cards = _generateInsightCards(weather);

      emit(
        WeatherLoaded(
          weather: weather,
          city: city,
          aiInsight: insight,
          aiCards: cards,
        ),
      );
    } catch (e) {
      // If refresh fails, keep old data
      if (state is WeatherRefreshing) {
        final current = state as WeatherRefreshing;
        emit(
          WeatherLoaded(
            weather: current.weather,
            city: current.city,
            aiInsight: current.aiInsight,
          ),
        );
      } else {
        emit(WeatherError(e.toString()));
      }
    }
  }

  Future<void> _onLoadWeatherForLocation(
    LoadWeatherForLocation event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());

    try {
      _currentLat = event.latitude;
      _currentLon = event.longitude;
      _currentCity = event.cityName;

      // Fetch weather for specified location
      final weather = await weatherRepository.getWeather(
        event.latitude,
        event.longitude,
      );

      // Get AI insight
      final insight = await aiService.getWeatherInsight(
        weather.weatherCode,
        weather.temperature,
        humidity: weather.humidity,
        windSpeed: weather.windSpeed,
      );

      final cards = _generateInsightCards(weather);

      emit(
        WeatherLoaded(
          weather: weather,
          city: event.cityName,
          aiInsight: insight,
          aiCards: cards,
        ),
      );
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }

  List<AiInsightCard> _generateInsightCards(dynamic weather) {
    final cards = <AiInsightCard>[];
    final temp = weather.temperature as double;
    final humidity = weather.humidity as int;
    final code = weather.weatherCode as int;

    // Clothing suggestion
    String clothing;
    if (temp < 10) {
      clothing = 'Layer up! Wear a warm jacket, scarf, and gloves.';
    } else if (temp < 20) {
      clothing = 'A light jacket or sweater would be perfect today.';
    } else if (temp < 30) {
      clothing = 'Comfortable t-shirt and pants weather.';
    } else {
      clothing = 'Stay cool with light, breathable fabrics.';
    }
    cards.add(
      AiInsightCard(
        title: 'What to Wear',
        content: clothing,
        icon: IconType.clothing,
      ),
    );

    // Activity suggestion
    String activity;
    if (code == 0 && temp > 15 && temp < 30) {
      activity =
          'Perfect weather for outdoor activities! Go for a walk or bike ride.';
    } else if (code >= 60) {
      activity =
          'Indoor activities recommended today. Great time for movies or reading.';
    } else {
      activity = 'Moderate conditions - plan accordingly for outdoor plans.';
    }
    cards.add(
      AiInsightCard(
        title: 'Activity Tip',
        content: activity,
        icon: IconType.activity,
      ),
    );

    // Health tip
    String health;
    if (humidity > 70) {
      health =
          'High humidity today. Stay hydrated and avoid strenuous outdoor exercise.';
    } else if (humidity < 30) {
      health =
          'Low humidity - keep your skin moisturized and drink plenty of water.';
    } else {
      health = 'Comfortable humidity levels. Great day for your health!';
    }
    cards.add(
      AiInsightCard(
        title: 'Health Advisory',
        content: health,
        icon: IconType.health,
      ),
    );

    return cards;
  }

  String _getConditionText(int code) {
    if (code == 0) return 'Sunny';
    if (code < 4) return 'Cloudy';
    if (code < 50) return 'Foggy';
    if (code < 60) return 'Drizzle';
    if (code < 70) return 'Rainy';
    if (code < 80) return 'Snowy';
    if (code < 85) return 'Showers';
    return 'Stormy';
  }
}
