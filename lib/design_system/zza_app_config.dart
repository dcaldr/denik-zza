import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/zza_theme.dart';

/// Centralized configuration for the Zza App.
///
/// This class holds configuration that is SHARED between:
/// 1. The real app (`main.dart`)
/// 2. Widget tests (`BaseTestWidget`)
/// 3. Integration tests
///
/// It does NOT contain backend initialization (DB, Files) to keep tests modular.
class ZzaAppConfig {
  ZzaAppConfig._();

  static const String appTitle = 'Event Registration';

  static ThemeData get theme => ZzaTheme.lightTheme;

  static const List<Locale> supportedLocales = [
    Locale('cs', 'CZ'),
  ];

  static const List<LocalizationsDelegate<dynamic>> delegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  /// Initialize low-level formatting libraries (intl).
  /// Safe to call multiple times (idempotent).
  /// Call this in `main()` and `setUpAll()`.
  static Future<void> initialize() async {
    await initializeDateFormatting('cs_CZ', null);
  }
}
