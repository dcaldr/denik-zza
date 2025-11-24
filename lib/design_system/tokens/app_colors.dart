import 'package:flutter/material.dart';

/// Color tokens extracted from your CSV import and NewRecord pages.
///
/// Based on actual usage:
/// - Blue: shade50 (backgrounds), shade100 (icon buttons),
///         shade200 (borders), shade600 (filled buttons), shade700 (text)
/// - Green: For positive actions (from NewRecord zpusobilost button)
class AppColors {
  AppColors._();

  // Blue shades (EXACTLY as used in your code)
  static final Color blueBackground = Colors.blue.shade50;
  static final Color blueBackgroundLight =
      Colors.blue.shade50.withValues(alpha: 0.3); // NewRecord datetime box
  static final Color blueIconBackground = Colors.blue.shade100;
  static final Color blueBorder = Colors.blue.shade200;
  static final Color blueBorderLight =
      Colors.blue.shade200.withValues(alpha: 0.5);
  static final Color blueText = Colors.blue.shade600;
  static final Color blueDark = Colors.blue.shade700;

  // Green shades (from NewRecord zpusobilost button)
  static final Color greenBackground = Colors.green.shade50;
  static final Color greenText = Colors.green.shade700;
  static final Color greenIcon = Colors.green.shade400;

  // Grey shades (from NewRecord history section)
  static final Color greyBackground = Colors.grey.shade50;
  static final Color greyBackgroundMedium = Colors.grey.shade100;
  static final Color greyBorder = Colors.grey.shade200;
  static final Color greyBorderDark = Colors.grey.shade300;
  static final Color greyText = Colors.grey.shade600;
  static final Color greyTextLight = Colors.grey.shade400;
  static final Color greyIcon = Colors.grey.shade700;

  // Yellow (poznámka sticky note from NewRecord)
  static final Color yellowBackground = Colors.yellow.shade50;
  static final Color yellowBorder = Colors.amber.shade300;
  static final Color yellowText = Colors.amber.shade700;
  static final Color yellowTextDark = Colors.amber.shade800;

  // Orange (unsaved changes badge from NewRecord)
  static final Color orangeBackground = Colors.orange.shade100;
  static final Color orangeBorder = Colors.orange.shade300;
  static final Color orangeText = Colors.orange.shade600;

  /// Light color scheme matching your actual app
  static final ColorScheme lightColorScheme = ColorScheme.light(
    // Primary: Blue (your current color - "okay" per feedback)
    primary: Colors.blue,
    onPrimary: Colors.white,
    primaryContainer: blueBackground,
    onPrimaryContainer: const Color(0xFF001D35),

    // Secondary: Use for vibrant major actions
    // (Will configure FilledButton to use custom vibrant green separately)
    secondary: Colors.blue.shade600,
    onSecondary: Colors.white,
    secondaryContainer: blueIconBackground,
    onSecondaryContainer: const Color(0xFF001D35),

    // Error
    error: Colors.red,
    onError: Colors.white,
    errorContainer: Colors.red.shade50,
    onErrorContainer: Colors.red.shade900,

    // Background (open, clean feel - slight off-white like CSV import)
    surface: const Color(0xFFFAFAFA),
    onSurface: Colors.black87,
    surfaceContainerHighest: greyBackground,
    onSurfaceVariant: greyText,

    // Outline (for minimalistic borders)
    outline: greyBorderDark, // Light grey, subtle
    outlineVariant: greyBorder, // Even lighter

    // Shadows
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF000000),
  );
}
