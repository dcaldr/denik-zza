import 'package:flutter/material.dart';

/// Unified theme configuration for development mode
/// 
/// Provides a consistent orange-themed appearance across all dev entry points
/// to make it immediately obvious when running in development mode.
class DevTheme {
  /// Get the standard dev mode theme
  /// 
  /// Features:
  /// - Orange AppBar to indicate dev mode
  /// - Blue primary swatch (standard app color)
  /// - White text on orange AppBar
  static ThemeData get theme {
    return ThemeData(
      primarySwatch: Colors.blue,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Get alternative theme with deepOrange color scheme
  /// Used by some CSV dev entry points
  static ThemeData get deepOrangeTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
    );
  }
}
