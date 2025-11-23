import 'dart:io';

import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:denik_zza/dev/ui/dev_theme.dart';
import 'package:path/path.dart' as p;

/// Boots an in-memory database so CSV review dev mains never touch
/// production storage. Returns the configured [AppDatabase] so callers can
/// optionally seed data.
///
/// @deprecated Use [DevEnvironment.initialize()] instead for consistent setup
/// across all dev entry points. This provides rich test data automatically.
@Deprecated('Use DevEnvironment.initialize() instead')
Future<AppDatabase> configureCsvReviewDevDatabase() async {
  DatabaseWrapper.setTestMode();
  final AppDatabase database = AppDatabase.testInMemory();
  DatabaseWrapper.useTestDriftDatabase(database);
  return database;
}

/// Resolves a relative project path to an absolute location and validates that
/// the file exists. Throws [StateError] if the target cannot be found.
String resolveProjectFile(String relativePath) {
  final String absolutePath =
      p.normalize(p.join(Directory.current.path, relativePath));
  if (!File(absolutePath).existsSync()) {
    throw StateError('Fixture not found: $absolutePath');
  }
  return absolutePath;
}

/// Simple MaterialApp builder for dev entry points.
///
/// @deprecated Use the unified dev UI components instead:
/// ```dart
/// import 'package:denik_zza/dev/ui/dev_app_builder.dart';
///
/// // Simple version (no banner):
/// runApp(buildDevApp(title: 'My Dev App', home: MyScreen()));
///
/// // With banner (recommended):
/// runApp(buildDevAppWithBanner(
///   title: 'My Dev App',
///   bannerMessage: 'Testing Feature X',
///   bannerIcon: Icons.science,
///   home: MyScreen(),
/// ));
/// ```
@Deprecated(
    'Use buildDevApp() or buildDevAppWithBanner() from lib/dev/ui/dev_app_builder.dart instead')
MaterialApp buildDevApp({
  required String title,
  required Widget home,
}) {
  return MaterialApp(
    title: title,
    debugShowCheckedModeBanner: true,
    locale: const Locale('cs', 'CZ'),
    supportedLocales: const <Locale>[Locale('cs', 'CZ')],
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: DevTheme.theme,
    home: home,
  );
}
