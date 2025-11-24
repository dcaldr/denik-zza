import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/theme/zza_theme.dart';

/// Unified theme configuration for development mode
///
/// Provides a consistent orange-themed appearance across all dev entry points
/// to make it immediately obvious when running in development mode.
class DevTheme {
  /// Orange warning colors for dev badges and indicators
  static const Color warningBackground =
      Color(0xFFFFECB3); // Light orange background
  static const Color warningBorder = Color(0xFFFFB74D); // Medium orange border
  static const Color warningText = Color(0xFFE65100); // Dark orange text/icon

  /// Get the standard dev mode theme
  ///
  /// Features:
  /// - Inherits EVERYTHING from ZzaTheme (fonts, shapes, colors)
  /// - Overrides AppBar to be Orange (Visual Warning)
  static ThemeData get theme {
    // Start with the real app theme so dev mode looks exactly like production
    final base = ZzaTheme.lightTheme;

    // Override ONLY the AppBar to indicate dev mode
    return base.copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      // We can add other dev-specific overrides here if needed
    );
  }
}
