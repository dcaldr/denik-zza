// Ensures global test configuration is applied before any tests run.
// We suppress Drift's noisy multiple-database warnings in tests.
// See docs/testing-database-setup.md for rationale.

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import 'package:denik_zza/utils/app_logger.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/utils/mode_coordinator.dart';

FutureOr<void> testExecutable(FutureOr<void> Function() testMain) {
  // Ensure binding is initialized for plugins
  TestWidgetsFlutterBinding.ensureInitialized();

  // GLOBAL SETUP:
  // Ensure every test starts in a clean "Testing Mode" (in-memory DB, no direct file access).
  // This bypasses the need for mocking path_provider in most unit/widget tests.
  setUp(() {
    ModeCoordinator.setTestingMode();
  });

  // Suppress Drift multiple-database warnings globally for tests.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  // Silence non-error logs to keep CI output readable.
  AppLogger.configureForTests(level: Level.error);

  // UNIVERSAL TEARDOWN:
  // Automatically dispose of any database resources after EVERY test.
  // This ensures no "zombie" databases leak between tests, even if the test
  // itself forgets to clean up.
  //
  // DatabaseWrapper.dispose() is safe to call even if no DB was used.
  tearDown(() async {
    await DatabaseWrapper.dispose();
  });

  return testMain();
}
