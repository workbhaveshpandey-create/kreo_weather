import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.primary,
      surface: AppColors.surface,
      error: AppColors.error,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
    ),
    textTheme: TextTheme(
      bodyMedium: AppTextStyles.body(color: AppColors.onSurface),
      bodySmall: AppTextStyles.bodySmall(color: AppColors.onSurfaceVariant),
      titleMedium: AppTextStyles.title(color: AppColors.onSurface),
      headlineSmall: AppTextStyles.headline(color: AppColors.onSurface),
    ),
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.lightOnBackground,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightOnBackground,
      secondary: AppColors.lightOnBackground,
      surface: AppColors.lightSurface,
      error: AppColors.error,
      onSurface: AppColors.lightOnSurface,
      onSurfaceVariant: AppColors.lightOnSurfaceVariant,
    ),
    textTheme: TextTheme(
      bodyMedium: AppTextStyles.body(color: AppColors.lightOnSurface),
      bodySmall: AppTextStyles.bodySmall(
        color: AppColors.lightOnSurfaceVariant,
      ),
      titleMedium: AppTextStyles.title(color: AppColors.lightOnSurface),
      headlineSmall: AppTextStyles.headline(color: AppColors.lightOnSurface),
    ),
  );
}
