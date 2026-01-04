import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BackgroundService {
  static const String taskName = 'fetchWeatherTask';
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize background service and notifications
  static Future<void> initialize() async {
    // Initialize notifications
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Handle notification tap
      },
    );

    // Initialize Workmanager
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

    // Register periodic task - every 3 hours
    await Workmanager().registerPeriodicTask(
      taskName,
      taskName,
      frequency: const Duration(hours: 3),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  /// Show weather notification immediately
  static Future<void> showWeatherNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'weather_channel',
      'Weather Updates',
      channelDescription: 'Weather alerts and updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Show persistent weather notification
  static Future<void> showPersistentWeatherNotification({
    required double temperature,
    required String condition,
    required String city,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'weather_persistent',
      'Current Weather',
      channelDescription: 'Shows current weather conditions',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        '$condition in $city',
        contentTitle: '${temperature.round()}° - $condition',
        summaryText: 'Kreo Weather',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0, // Fixed ID for persistent notification
      '${temperature.round()}° $condition',
      city,
      details,
    );
  }

  /// Cancel persistent notification
  static Future<void> cancelPersistentNotification() async {
    await _notifications.cancel(0);
  }

  /// Fetch weather and show notification (called by workmanager)
  static Future<void> fetchAndNotify() async {
    try {
      // Use a default location (can be enhanced to use last known location)
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=28.6139&longitude=77.2090&current=temperature_2m,weather_code',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];
        final temp = current['temperature_2m'] as double;
        final code = current['weather_code'] as int;
        final condition = _getConditionFromCode(code);

        await showWeatherNotification(
          title: '${temp.round()}° $condition',
          body: 'Current weather in your area',
        );
      }
    } catch (e) {
      // Silently fail on background fetch
    }
  }

  static String _getConditionFromCode(int code) {
    if (code == 0) return 'Clear';
    if (code < 4) return 'Cloudy';
    if (code < 50) return 'Foggy';
    if (code < 60) return 'Drizzle';
    if (code < 70) return 'Rain';
    if (code < 80) return 'Snow';
    if (code >= 95) return 'Storm';
    return 'Showers';
  }
}

/// Top-level callback for workmanager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == BackgroundService.taskName) {
      await BackgroundService.fetchAndNotify();
    }
    return true;
  });
}
