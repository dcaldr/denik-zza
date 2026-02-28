// Global configuration for integration tests.
// Ensures all integration tests start with proper mode setup.

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:integration_test/integration_test.dart';
import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:denik_zza/utils/app_logger.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/utils/mode_coordinator.dart';
import 'package:path/path.dart' as path;

import '../test/utils/capturing_system_interface.dart';

FutureOr<void> testExecutable(FutureOr<void> Function() testMain) async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Generate and set run ID ONCE per test suite execution (format: 241221_211900)
  // This ensures all tests in this suite share the same runId for folder grouping.
  final runId = DateFormat('yyMMdd_HHmmss').format(DateTime.now());
  ModeCoordinator.initializeRunId(runId);

  // Suppress Drift multiple-database warnings globally for tests
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  // Silence non-error logs to keep CI output readable
  AppLogger.configureForTests(level: Level.error);

  // Locale initialization (matches main.dart)
  Intl.defaultLocale = 'cs_CZ';
  await initializeDateFormatting('cs_CZ', null);

  // Cleanup old runs (keep last 5 per category)
  await ModeCoordinator.cleanupOldRuns(keepLast: 5);

  // Clear hardware keyboard state before each test to avoid stray key events
  setUp(() {
    HardwareKeyboard.instance.clearState();
  });

  // Global tearDown - ensures no database leaks between tests
  tearDown(() async {
    await DatabaseWrapper.dispose();
    final testDir = ModeCoordinator.currentTestDirectory;
    if (testDir != null) {
      final artifactsDir = path.join(testDir.path, 'pdf_artifacts');
      await CapturingSystemInterface.cleanupOldFiles(
        baseDir: artifactsDir,
        keepLast: 5,
      );
    }
  });

  return testMain();
}
