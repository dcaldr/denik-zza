import 'package:flutter/material.dart';

/// App-wide color constants extracted from CSV import flow and NewRecord page.
///
/// These colors create the "open, clean, minimalistic, professional but not clinical"
/// feel that the user loves from the CSV import and NewRecord screens.
///
/// Reference: SCREEN_ANALYSIS.md, APP_DESIGN_FEEL.md
/// Date: 2025-11-16
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // ==========================================
  // BLUE SHADES (Primary color family)
  // Extracted from NewRecord and CSV screens
  // ==========================================

  /// Light blue background for participant info boxes
  /// Used in: NewRecord participant box, CSV summary cards
  static final Color blueBackground = Colors.blue.shade50;

  /// Very light blue for gradients (30% opacity)
  /// Used in: NewRecord participant box gradient
  static final Color blueBackgroundLight = Colors.blue.shade50.withOpacity(0.3);

  /// Blue for icon button backgrounds
  /// Used in: NewRecord icon panel
  static final Color blueIconBackground = Colors.blue.shade100;

  /// Border color for form fields and containers
  /// Used in: NewRecord TextFormField borders, CSV container borders
  static final Color blueBorder = Colors.blue.shade200;

  /// Light border variant (50% opacity)
  /// Used in: Subtle separators
  static final Color blueBorderLight = Colors.blue.shade200.withOpacity(0.5);

  /// Primary blue for buttons and interactive text
  /// Used in: NewRecord "Uložit" button, CSV "Vybrat soubor" button
  static final Color blueText = Colors.blue.shade600;

  /// Dark blue for icons and emphasis text
  /// Used in: NewRecord icons, dark text on light backgrounds
  static final Color blueDark = Colors.blue.shade700;

  // ==========================================
  // GREY SHADES (Neutral color family)
  // Used for secondary UI elements
  // ==========================================

  /// Very light grey for secondary backgrounds
  /// Used in: Alternative card backgrounds
  static final Color greyBackground = Colors.grey.shade50;

  /// Medium grey for subtle backgrounds
  /// Used in: Disabled states, subtle containers
  static final Color greyBackgroundMedium = Colors.grey.shade100;

  /// Light grey for borders
  /// Used in: Subtle separators, light borders
  static final Color greyBorder = Colors.grey.shade200;

  /// Darker grey for outline borders
  /// Used in: NewRecord "Zavřít" button border
  static final Color greyBorderDark = Colors.grey.shade300;

  /// Grey for secondary text
  /// Used in: Labels, less important text
  static final Color greyText = Colors.grey.shade600;

  /// Light grey for disabled text
  /// Used in: Disabled form fields, inactive elements
  static final Color greyTextLight = Colors.grey.shade400;

  /// Dark grey for icons
  /// Used in: NewRecord "Zavřít" button icon, secondary icons
  static final Color greyIcon = Colors.grey.shade700;

  // ==========================================
  // ACCENT COLORS
  // Used for specific UI contexts
  // ==========================================

  /// Green background for health status (zpusobilost)
  /// Used in: NewRecord health status chips
  static final Color greenBackground = Colors.green.shade50;

  /// Green text for health status
  /// Used in: NewRecord health status text
  static final Color greenText = Colors.green.shade700;

  /// Green for medical action buttons (context-sensitive - Option C)
  /// Used in: IntakeForm "uložit a přišel" button
  /// Note: Applied manually with .styleFrom(), not in theme
  static final Color greenAction = Colors.green;

  /// Yellow background for poznámka (notes) boxes
  /// Used in: NewRecord poznámka section
  static final Color yellowBackground = Colors.yellow.shade50;

  /// Yellow/amber border for poznámka boxes
  /// Used in: NewRecord poznámka border
  static final Color yellowBorder = Colors.amber.shade300;

  /// Yellow/amber text for poznámka
  /// Used in: NewRecord poznámka text
  static final Color yellowText = Colors.amber.shade700;

  /// Orange background for AppDrawer highlights
  /// Used in: AppDrawer "HLAVNÍ: BĚHEM AKCE" section
  static final Color orangeBackground = Colors.orange.shade100;

  /// Orange border for highlights
  /// Used in: AppDrawer highlight borders
  static final Color orangeBorder = Colors.orange.shade300;

  /// Orange text for highlights
  /// Used in: AppDrawer highlight text
  static final Color orangeText = Colors.orange.shade600;

  /// Red for destructive actions (context-sensitive - Option C)
  /// Used in: IntakeForm "neukládat" button
  /// Note: Applied manually with .styleFrom(), not in theme
  static final Color redAction = Colors.red;

  // ==========================================
  // MATERIAL DESIGN 3 COLOR SCHEME
  // Used by ThemeData
  // ==========================================

  /// Light color scheme for Material 3 theme
  /// Based on extracted colors (not generic Material 3 defaults)
  static final ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,

    // Primary colors (Blue family)
    primary: blueText, // blue.shade600
    onPrimary: Colors.white,
    primaryContainer: blueBackground, // blue.shade50
    onPrimaryContainer: blueDark, // blue.shade700

    // Secondary colors (Grey family)
    secondary: greyIcon, // grey.shade700
    onSecondary: Colors.white,
    secondaryContainer: greyBackgroundMedium, // grey.shade100
    onSecondaryContainer: greyIcon, // grey.shade700

    // Tertiary colors (Orange accent)
    tertiary: orangeText, // orange.shade600
    onTertiary: Colors.white,
    tertiaryContainer: orangeBackground, // orange.shade100
    onTertiaryContainer: orangeText, // orange.shade600

    // Error colors
    error: Colors.red.shade700,
    onError: Colors.white,
    errorContainer: Colors.red.shade50,
    onErrorContainer: Colors.red.shade900,

    // Background colors
    background: const Color(0xFFFAFAFA), // Slight off-white for "open feel"
    onBackground: Colors.black87,

    // Surface colors
    surface: Colors.white,
    onSurface: Colors.black87,
    surfaceVariant: greyBackground, // grey.shade50
    onSurfaceVariant: greyText, // grey.shade600

    // Outline colors
    outline: blueBorder, // blue.shade200 (form field borders)
    outlineVariant: greyBorder, // grey.shade200

    // Shadow and overlay
    shadow: Colors.black,
    scrim: Colors.black54,

    // Inverse colors (for snackbars, etc.)
    inverseSurface: Colors.grey.shade800,
    onInverseSurface: Colors.white,
    inversePrimary: Colors.blue.shade200,
  );
}
