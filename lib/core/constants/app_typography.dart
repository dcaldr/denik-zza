import 'package:flutter/material.dart';

/// App-wide typography constants extracted from NewRecord, CSV, and AppDrawer.
///
/// CRITICAL: Body text is 15px default (NOT 14px)
/// - Avoids breaking NewRecord's responsive logic: isCompact ? 14 : 15
/// - Screens override with responsive values when needed
///
/// ALL TextStyles include locale: Locale('cs', 'CZ') for Czech diacritics
/// (ě, š, č, ř, ž, ý, á, í, é, ú, ů, ď, ť, ň)
///
/// User feedback: "Too large, decrease default size" + "CSV/NewRecord well packed"
///
/// Reference: SCREEN_ANALYSIS.md, APP_DESIGN_FEEL.md line 694
/// Date: 2025-11-16
class AppTypography {
  AppTypography._(); // Private constructor to prevent instantiation

  // ==========================================
  // FONT FAMILY
  // ==========================================

  /// Roboto font family (default Flutter font)
  /// Supports Czech diacritics perfectly
  static const String fontFamily = 'Roboto';

  // ==========================================
  // RESPONSIVE FONT SIZE CONSTANTS
  // For screens that need responsive behavior
  // ==========================================

  /// Body medium size for desktop/tablet (15px)
  /// Theme default - most screens use this
  static const double bodyMediumSize = 15.0;

  /// Body medium size for compact vertical layouts (14px)
  /// Used in: NewRecord with isCompact ? 14 : 15
  static const double bodyMediumSizeCompact = 14.0;

  /// Body medium size for phone screens (14px)
  /// User wants smaller text on phones
  static const double bodyMediumSizePhone = 14.0;

  /// Body medium size for very compact vertical (14px)
  /// When maxHeight <= 600
  static const double bodyMediumSizeVerticalCompact = 14.0;

  // ==========================================
  // CZECH LOCALE
  // Must be included in ALL TextStyles
  // ==========================================

  static const Locale czechLocale = Locale('cs', 'CZ');

  // ==========================================
  // TEXT THEME (Material Design 3)
  // Actual sizes from code analysis
  // ==========================================

  static final TextTheme textTheme = TextTheme(
    // ==========================================
    // DISPLAY STYLES (Rarely used - large headings)
    // ==========================================

    displayLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 28.0,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.5,
      locale: czechLocale,
    ),

    displayMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 24.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.0,
      locale: czechLocale,
    ),

    displaySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 20.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.0,
      locale: czechLocale,
    ),

    // ==========================================
    // HEADLINE STYLES (Page titles, section headers)
    // ==========================================

    headlineLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.0,
      locale: czechLocale,
    ),

    headlineMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      locale: czechLocale,
    ),

    headlineSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 15.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      locale: czechLocale,
    ),

    // ==========================================
    // TITLE STYLES (Component titles, form field titles)
    // ==========================================

    /// Card/Container titles
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      locale: czechLocale,
    ),

    /// Form field titles, labels (NewRecord style - 15px)
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 15.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      locale: czechLocale,
    ),

    /// AppDrawer section headers (13px)
    /// Example: "HLAVNÍ: BĚHEM AKCE"
    titleSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 13.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      locale: czechLocale,
    ),

    // ==========================================
    // BODY STYLES (Main content text)
    // ==========================================

    /// Large body text (CSV labels - 15px)
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 15.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      locale: czechLocale,
    ),

    /// CRITICAL: Default body text (15px NOT 14px)
    /// Theme provides 15px to avoid breaking responsive logic
    /// Screens override with: isCompact ? 14 : 15
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: bodyMediumSize, // 15.0
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      locale: czechLocale,
    ),

    /// Small body text (12px)
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      locale: czechLocale,
    ),

    // ==========================================
    // LABEL STYLES (Buttons, chips, small UI elements)
    // ==========================================

    /// Button text (14px)
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      locale: czechLocale,
    ),

    /// Small labels (12px)
    labelMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      locale: czechLocale,
    ),

    /// Health chips (NewRecord - 11px), AppDrawer menu subtitles (11px)
    labelSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 11.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      locale: czechLocale,
    ),
  );

  // ==========================================
  // COMMON TEXT STYLE HELPERS
  // For manual TextStyle creation
  // ==========================================

  /// Base text style with Czech locale
  /// Use as base: AppTypography.baseTextStyle.copyWith(fontSize: 16)
  static const TextStyle baseTextStyle = TextStyle(
    fontFamily: fontFamily,
    locale: czechLocale,
  );

  /// Bold text helper
  static TextStyle bold(double fontSize) => TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        locale: czechLocale,
      );

  /// Regular text helper
  static TextStyle regular(double fontSize) => TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        locale: czechLocale,
      );

  /// Medium weight text helper
  static TextStyle medium(double fontSize) => TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        locale: czechLocale,
      );

  // ==========================================
  // SPECIFIC USE CASE STYLES
  // Common patterns from actual screens
  // ==========================================

  /// Form field label style (from NewRecord)
  static final TextStyle formFieldLabel = textTheme.titleMedium!;

  /// Form field hint style
  static final TextStyle formFieldHint = textTheme.bodyMedium!.copyWith(
    color: Colors.grey.shade600,
  );

  /// Form field error style
  static const TextStyle formFieldError = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w400,
    color: Colors.red,
    height: 0.8,
    locale: czechLocale,
  );

  /// Button text style (14px bold)
  static final TextStyle buttonText = textTheme.labelLarge!;

  /// Health chip style (NewRecord - 11px)
  static final TextStyle healthChip = textTheme.labelSmall!;

  /// AppDrawer section header style (13px bold)
  static final TextStyle drawerSectionHeader = textTheme.titleSmall!;

  /// AppDrawer menu item style (15px regular)
  static final TextStyle drawerMenuItem = textTheme.bodyLarge!;
}
