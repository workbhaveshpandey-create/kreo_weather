import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Kreo Weather - Premium Theme System
/// Supports both Light and Dark modes
class AppColors {
  AppColors._();

  // Core Palette - Dark
  static const Color minimalBlack = Color(0xFF000000);
  static const Color minimalSurface = Color(0xFF0A0A0A);
  static const Color minimalWhite = Color(0xFFFFFFFF);
  static const Color minimalGrey = Color(0xFF888888);
  static const Color minimalError = Color(0xFFFF3B30);

  // Core Palette - Light
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFE8E8E8);
  static const Color lightOnBackground = Color(0xFF000000);
  static const Color lightOnSurface = Color(0xFF1A1A1A);
  static const Color lightOnSurfaceVariant = Color(0xFF666666);
  static const Color lightDivider = Color(0xFFE0E0E0);

  // Dark Theme
  static const Color background = minimalBlack;
  static const Color surface = minimalSurface;
  static const Color surfaceVariant = Color(0xFF1A1A1A);
  static const Color onBackground = minimalWhite;
  static const Color onSurface = minimalWhite;
  static const Color primary = minimalWhite;
  static const Color onSurfaceVariant = minimalGrey;
  static const Color divider = Color(0xFF2A2A2A);
  static const Color error = minimalError;

  // Accent (cyan for AI)
  static const Color accent = Color(0xFF00D9FF);

  // Glass effect colors for glassmorphism
  static const Color glassDark = Color(0x22000000); // 13% black
  static const Color glassLight = Color(0x33FFFFFF); // 20% white
  static const Color glassBorder = Color(0x1AFFFFFF); // 10% white border

  // Card colors for grid
  static const Color cardUV = Color(0xFF1E1E2E);
  static const Color cardWind = Color(0xFF1E2E1E);
  static const Color cardHumidity = Color(0xFF1E2E2E);
}

/// Typography - Using Outfit (Cinematic Standard)
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _outfit({
    required double size,
    FontWeight weight = FontWeight.normal,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.outfit(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Temperature Display
  static TextStyle temperature({Color? color}) => _outfit(
    size: 100,
    weight: FontWeight.w100, // Thin
    color: color,
    letterSpacing: -6,
  );

  // Headlines
  static TextStyle headline({Color? color}) => _outfit(
    size: 24,
    weight: FontWeight.w600,
    color: color,
    letterSpacing: -0.5,
  );

  static TextStyle title({Color? color}) =>
      _outfit(size: 18, weight: FontWeight.w500, color: color);

  static TextStyle titleSmall({Color? color}) =>
      _outfit(size: 14, weight: FontWeight.w500, color: color);

  // Body
  static TextStyle body({Color? color}) =>
      _outfit(size: 14, weight: FontWeight.w400, color: color, height: 1.5);

  static TextStyle bodySmall({Color? color}) =>
      _outfit(size: 12, weight: FontWeight.w400, color: color);

  static TextStyle bodyLarge({Color? color}) =>
      _outfit(size: 16, weight: FontWeight.w400, color: color, height: 1.6);

  // Labels
  static TextStyle label({Color? color}) => _outfit(
    size: 11,
    weight: FontWeight.w600,
    color: color,
    letterSpacing: 2,
  );

  static TextStyle labelSmall({Color? color}) => _outfit(
    size: 10,
    weight: FontWeight.w600,
    color: color,
    letterSpacing: 1.5,
  );

  // Card Title
  static TextStyle cardTitle({Color? color}) =>
      _outfit(size: 13, weight: FontWeight.w500, color: color);

  static TextStyle cardValue({Color? color}) =>
      _outfit(size: 22, weight: FontWeight.w600, color: color);
}
