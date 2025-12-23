import 'package:flutter/material.dart';

/// Typography tokens extracted from your actual screens.
///
/// Font sizes found in code:
/// - NewRecord body text: isCompact ? 13 : 14
/// - NewRecord labels: isCompact ? 12 : 13
/// - NewRecord title fields: isCompact ? 14 : 15
/// - Small text: 11, 10, 9 (various places)
///
/// These are SMALLER than Material 3 defaults (which use 14-16px body text).
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Roboto'; // Supports Czech diacritics

  /// Text theme matching your actual font sizes
  static const TextTheme textTheme = TextTheme(
    // Display styles (large headings) - rarely used in your app
    displayLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 26, // Reduced from 28
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
      height: 1.2,
      locale: Locale('cs', 'CZ'),
    ),
    displayMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 22, // Reduced from 24
      fontWeight: FontWeight.bold,
      height: 1.2,
      locale: Locale('cs', 'CZ'),
    ),
    displaySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 18, // Reduced from 20
      fontWeight: FontWeight.bold,
      height: 1.3,
      locale: Locale('cs', 'CZ'),
    ),

    // Headline styles (section headers)
    headlineLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16, // Reduced from 18
      fontWeight: FontWeight.w600,
      height: 1.3,
      locale: Locale('cs', 'CZ'),
    ),
    headlineMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 15, // Reduced from 16
      fontWeight: FontWeight.w600,
      height: 1.3,
      locale: Locale('cs', 'CZ'),
    ),
    headlineSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14, // Reduced from 15
      fontWeight: FontWeight.w600,
      height: 1.3,
      locale: Locale('cs', 'CZ'),
    ),

    // Title styles (CSV uses theme.textTheme.titleMedium for labels)
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 15, // Reduced from 16
      fontWeight: FontWeight.w600,
      height: 1.4,
      locale: Locale('cs', 'CZ'),
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14, // Reduced from 15
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.4,
      locale: Locale('cs', 'CZ'),
    ),
    titleSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12, // Reduced from 13
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.4,
      locale: Locale('cs', 'CZ'),
    ),

    // Body styles (main content)
    // CRITICAL: These match your actual code!
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14, // Reduced from 15
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5,
      height: 1.5,
      locale: Locale('cs', 'CZ'),
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 13, // Reduced from 14
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25,
      height: 1.5,
      locale: Locale('cs', 'CZ'),
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 11, // Reduced from 12
      fontWeight: FontWeight.normal,
      letterSpacing: 0.4,
      height: 1.5,
      locale: Locale('cs', 'CZ'),
    ),

    // Label styles (buttons, small UI elements)
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 13, // Reduced from 14
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.4,
      locale: Locale('cs', 'CZ'),
    ),
    labelMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 11, // Reduced from 12
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.4,
      locale: Locale('cs', 'CZ'),
    ),
    labelSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 10, // Reduced from 11
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.4,
      locale: Locale('cs', 'CZ'),
    ),
  );
}
