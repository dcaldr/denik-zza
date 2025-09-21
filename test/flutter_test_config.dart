// Ensures global test configuration is applied before any tests run.
// We suppress Drift's noisy multiple-database warnings in tests.
// See docs/testing-database-setup.md for rationale.

import 'dart:async';
import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import 'package:denik_zza/utils/app_logger.dart';

FutureOr<void> testExecutable(FutureOr<void> Function() testMain) {
  // Suppress Drift multiple-database warnings globally for tests.
  // Individual helpers also set this defensively, but doing it here guarantees
  // it runs before any database is constructed (including through wrappers).
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  // Silence non-error logs to keep CI output readable.
  AppLogger.configureForTests(level: Level.error);

  return testMain();
}
