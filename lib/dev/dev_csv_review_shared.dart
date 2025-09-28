import 'dart:io';

import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'package:path/path.dart' as p;

/// Boots an in-memory database so CSV review dev mains never touch
/// production storage. Returns the configured [AppDatabase] so callers can
/// optionally seed data.
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
