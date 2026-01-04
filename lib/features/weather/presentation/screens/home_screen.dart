import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:kreo_weather/app/theme/app_colors.dart';
import 'package:kreo_weather/core/widgets/bouncing_glass_card.dart';
import 'package:kreo_weather/core/widgets/weather_background_wrapper.dart';
import 'package:kreo_weather/core/widgets/lottie_weather_display.dart';
import 'package:kreo_weather/features/settings/settings_screen.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_event.dart';
import '../bloc/weather_state.dart';
import '../widgets/location_search_sheet.dart';

class WeatherHomeScreen extends StatelessWidget {
  const WeatherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          // Calculate background state
          int bgCode = 0;
          final now = DateTime.now();
          bool bgNight = now.hour >= 19 || now.hour < 6;

          if (state is WeatherLoaded) {
            bgCode = state.weather.weatherCode;
          } else if (state is WeatherRefreshing) {
            bgCode = state.weather.weatherCode;
          }

          return WeatherBackgroundWrapper(
            weatherCode: bgCode,
            isNight: bgNight,
            child: SafeArea(
              child: Builder(
                builder: (context) {
                  if (state is WeatherLoading) {
                    return _buildLoading(theme);
                  }
                  if (state is WeatherError) {
                    return _buildError(context, theme, state.message);
                  }
                  if (state is WeatherLoaded || state is WeatherRefreshing) {
                    final weather = state is WeatherLoaded
                        ? state.weather
                        : (state as WeatherRefreshing).weather;
                    final city = state is WeatherLoaded
                        ? state.city
                        : (state as WeatherRefreshing).city;
                    final insight = state is WeatherLoaded
                        ? state.aiInsight
                        : (state as WeatherRefreshing).aiInsight;
                    final isRefreshing = state is WeatherRefreshing;

                    return _buildContent(
                      context,
                      theme,
                      isDark,
                      weather,
                      city,
                      insight,
                      state is WeatherLoaded ? state.aiCards : [],
                      isRefreshing,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoading(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'LOADING',
            style: AppTextStyles.label(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, ThemeData theme, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.body(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => context.read<WeatherBloc>().add(RefreshWeather()),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.onSurface),
                ),
                child: Text(
                  'RETRY',
                  style: AppTextStyles.label(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    dynamic weather,
    String city,
    String insight,
    List<AiInsightCard> aiCards,
    bool isRefreshing,
  ) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return Stack(
      children: [
        RefreshIndicator(
          color: theme.colorScheme.onSurface,
          backgroundColor: theme.scaffoldBackgroundColor,
          onRefresh: () async {
            context.read<WeatherBloc>().add(RefreshWeather());
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Clean Header - Location + Settings only
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Location Tap
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showLocationSearch(context),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                greeting.toUpperCase(),
                                style: AppTextStyles.labelSmall(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      city,
                                      style: AppTextStyles.title(
                                        color: theme.colorScheme.onSurface,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: theme.colorScheme.onSurfaceVariant,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Settings Only
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceVariant
                                : AppColors.lightSurfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            color: theme.colorScheme.onSurface,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 32),

                  // Hero Section - Temperature + Animation Side by Side
                  // Clean Minimal Lottie Layout
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Lottie Weather Animation
                        SizedBox(
                              height: 220,
                              child: LottieWeatherDisplay(
                                weatherCode: weather.weatherCode,
                                isNight: now.hour >= 19 || now.hour < 6,
                                size: 200,
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .scale(
                              begin: const Offset(0.8, 0.8),
                              curve: Curves.easeOutBack,
                            ),

                        const SizedBox(height: 12),

                        // Temperature
                        Text(
                          '${weather.temperature.round()}°',
                          style: TextStyle(
                            fontSize: 96,
                            fontWeight: FontWeight.w200,
                            color: theme.colorScheme.onSurface,
                            height: 1,
                            letterSpacing: -4,
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                        const SizedBox(height: 8),

                        // Condition
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceVariant.withOpacity(0.5)
                                : AppColors.lightSurfaceVariant.withOpacity(
                                    0.5,
                                  ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            _getConditionText(weather.weatherCode),
                            style: AppTextStyles.body(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ).animate().fadeIn(delay: 300.ms),

                        const SizedBox(height: 16),

                        // High/Low
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'H: ${weather.daily.isNotEmpty ? weather.daily[0].maxTemp.round() : '--'}°',
                              style: AppTextStyles.body(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'L: ${weather.daily.isNotEmpty ? weather.daily[0].minTemp.round() : '--'}°',
                              style: AppTextStyles.body(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 400.ms),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🦉 Weather Owl Mascot
                  const SizedBox(height: 24),

                  // Quick Stats Row
                  BouncingGlassCard(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceVariant.withOpacity(0.4)
                            : AppColors.lightSurface,
                        border: Border.all(
                          color: isDark
                              ? AppColors.divider
                              : AppColors.lightDivider,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildQuickStat(
                            theme,
                            Icons.thermostat_outlined,
                            'Feels',
                            '${weather.apparentTemperature.round()}°',
                          ),
                          _buildDivider(isDark),
                          _buildQuickStat(
                            theme,
                            Icons.water_drop_outlined,
                            'Humidity',
                            '${weather.humidity}%',
                          ),
                          _buildDivider(isDark),
                          _buildQuickStat(
                            theme,
                            Icons.air_rounded,
                            'Wind',
                            '${weather.windSpeed.round()} km/h',
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  // AI Insight - Minimal Style
                  BouncingGlassCard(
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceVariant.withOpacity(0.3)
                            : AppColors.lightSurface,
                        border: Border.all(
                          color: AppColors.accent.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'AI INSIGHT',
                                style: AppTextStyles.labelSmall(
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            insight,
                            style: AppTextStyles.body(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 28),

                  // Hourly Section
                  Text(
                    'TODAY',
                    style: AppTextStyles.label(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: weather.hourly.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      // Cache extent for smoother scrolling
                      cacheExtent: 500,
                      padding: const EdgeInsets.only(right: 20),
                      itemBuilder: (context, index) {
                        final item = weather.hourly[index];
                        final isNow = index == 0;

                        // Calculate colors based on background
                        final textColor = isNow
                            ? theme.scaffoldBackgroundColor
                            : theme.colorScheme.onSurface;

                        // Glass container
                        return BouncingGlassCard(
                          child: Container(
                            width: 64,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isNow
                                  ? theme.colorScheme.onSurface
                                  : (isDark
                                        ? AppColors.glassDark
                                        : AppColors
                                              .glassLight), // Use new glass colors
                              border: isNow
                                  ? null
                                  : Border.all(
                                      color: AppColors
                                          .glassBorder, // Use new glass border
                                    ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isNow
                                      ? 'Now'
                                      : DateFormat('h a').format(item.time),
                                  style: AppTextStyles.labelSmall(
                                    color: isNow
                                        ? textColor
                                        : textColor.withOpacity(0.7),
                                  ),
                                ),
                                Icon(
                                  _getWeatherIcon(item.weatherCode),
                                  size: 22,
                                  color: textColor,
                                ),
                                Text(
                                  '${item.temperature.round()}°',
                                  style: AppTextStyles.titleSmall(
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 300.ms),

                  const SizedBox(height: 28),

                  // 7-Day Section
                  Text(
                    '7-DAY FORECAST',
                    style: AppTextStyles.label(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),

                  BouncingGlassCard(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.glassDark
                            : AppColors.glassLight,
                        border: Border.all(color: AppColors.glassBorder),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: weather.daily
                            .map<Widget>(
                              (day) => _buildDailyRow(theme, isDark, day),
                            )
                            .toList(),
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),

        // Refreshing Indicator
        if (isRefreshing)
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.scaffoldBackgroundColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'UPDATING',
                      style: AppTextStyles.labelSmall(
                        color: theme.scaffoldBackgroundColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickStat(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.titleSmall(color: theme.colorScheme.onSurface),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.labelSmall(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: 40,
      color: isDark ? AppColors.divider : AppColors.lightDivider,
    );
  }

  Widget _buildDailyRow(ThemeData theme, bool isDark, dynamic day) {
    final isToday = DateUtils.isSameDay(day.date, DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              isToday ? 'Today' : DateFormat('EEE').format(day.date),
              style:
                  AppTextStyles.body(
                    color: isToday
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                  ).copyWith(
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
          ),
          Icon(
            _getWeatherIcon(day.weatherCode),
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 36,
            child: Text(
              '${day.maxTemp.round()}°',
              style: AppTextStyles.titleSmall(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              '${day.minTemp.round()}°',
              style: AppTextStyles.bodySmall(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<WeatherBloc>(),
        child: const LocationSearchSheet(),
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  IconData _getWeatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny_rounded;
    if (code < 4) return Icons.cloud_rounded;
    if (code < 50) return Icons.foggy;
    if (code < 60) return Icons.grain_rounded;
    if (code < 70) return Icons.water_drop_rounded;
    if (code < 80) return Icons.ac_unit_rounded;
    if (code < 85) return Icons.shower_rounded;
    return Icons.thunderstorm_rounded;
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
