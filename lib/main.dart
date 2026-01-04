import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'app/theme/app_colors.dart';
import 'app/theme/app_theme.dart'; // Add this
import 'app/theme/theme_cubit.dart';
import 'core/services/background_service.dart';
import 'core/services/location_service.dart';
import 'features/ai_insights/data/ai_service.dart';
import 'features/weather/data/weather_repository.dart';
import 'features/weather/presentation/bloc/weather_bloc.dart';
import 'features/weather/presentation/bloc/weather_event.dart';
import 'features/weather/presentation/screens/home_screen.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Background Service
  await BackgroundService.initialize();

  // Request Notification Permissions
  await Permission.notification.request();

  runApp(const KreoWeatherApp());
}

class KreoWeatherApp extends StatelessWidget {
  const KreoWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<WeatherBloc>(
          create: (_) => WeatherBloc(
            weatherRepository: WeatherRepository(),
            locationService: LocationService(),
            aiService: AiService(),
          ),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Kreo Weather',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const AppWrapper(),
          );
        },
      ),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _showSplash = true;

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
    // Load weather after splash
    context.read<WeatherBloc>().add(LoadWeather());
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(onComplete: _onSplashComplete);
    }
    return const WeatherHomeScreen();
  }
}
