import 'package:flutter/material.dart';

/// Typography tokens with two variants for responsive design.
///
/// Two variants:
/// - desktopTextTheme: Compact line-heights for desktop (1.25-1.35)
/// - touchTextTheme: Spacious line-heights for touch (1.4-1.5)
///
/// Font sizes are SMALLER than Material 3 defaults (which use 14-16px body text).
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Roboto'; // Supports Czech diacritics

  // ========================================
  // DESKTOP TEXT THEME (Compact)
  // ========================================
  
  /// Compact text theme for desktop (tighter line-heights)
  static const TextTheme desktopTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 26,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
      height: 1.15,
      locale: Locale('cs', 'CZ'),
    ),
    displayMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 22,
      fontWeight: FontWeight.bold,
      height: 1.15,
      locale: Locale('cs', 'CZ'),
    ),
    displaySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      height: 1.2,
      locale: Locale('cs', 'CZ'),
    ),
    headlineLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.25,
      locale: Locale('cs', 'CZ'),
    ),
    headlineMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.25,
      locale: Locale('cs', 'CZ'),
    ),
    headlineSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.25,
      locale: Locale('cs', 'CZ'),
    ),
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.3,
      locale: Locale('cs', 'CZ'),
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.3,
      locale: Locale('cs', 'CZ'),
    ),
    titleSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.3,
      locale: Locale('cs', 'CZ'),
    ),
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5,
      height: 1.35,
      locale: Locale('cs', 'CZ'),
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 13,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25,
      height: 1.35,
      locale: Locale('cs', 'CZ'),
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.4,
      height: 1.4,
      locale: Locale('cs', 'CZ'),
    ),
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.25,
      locale: Locale('cs', 'CZ'),
    ),
    labelMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.25,
      locale: Locale('cs', 'CZ'),
    ),
    labelSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.25,
      locale: Locale('cs', 'CZ'),
    ),
  );

  // ========================================
  // TOUCH TEXT THEME (Spacious)
  // ========================================
  
  /// Spacious text theme for touch devices (original line-heights)
  static const TextTheme touchTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 26,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
      height: 1.2,
      locale: Locale('cs', 'CZ'),
    ),
    displayMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 22,
      fontWeight: FontWeight.bold,
      height: 1.2,
      locale: Locale('cs', 'CZ'),
    ),
    displaySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      height: 1.3,
      locale: Locale('cs', 'CZ'),
    ),
    headlineLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.3,
      locale: Locale('cs', 'CZ'),
    ),
    headlineMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.3,
      locale: Locale('cs', 'CZ'),
    ),
    headlineSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.3,
      locale: Locale('cs', 'CZ'),
    ),
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.4,
      locale: Locale('cs', 'CZ'),
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.4,
      locale: Locale('cs', 'CZ'),
    ),
    titleSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.4,
      locale: Locale('cs', 'CZ'),
    ),
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5,
      height: 1.5,
      locale: Locale('cs', 'CZ'),
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 13,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25,
      height: 1.5,
      locale: Locale('cs', 'CZ'),
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.4,
      height: 1.5,
      locale: Locale('cs', 'CZ'),
    ),
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.4,
      locale: Locale('cs', 'CZ'),
    ),
    labelMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.4,
      locale: Locale('cs', 'CZ'),
    ),
    labelSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.4,
      locale: Locale('cs', 'CZ'),
    ),
  );

  /// @Deprecated: Use desktopTextTheme or touchTextTheme.
  /// Kept for backward compatibility - maps to desktopTextTheme.
  static const TextTheme textTheme = desktopTextTheme;
}
