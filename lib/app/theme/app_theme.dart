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
}
