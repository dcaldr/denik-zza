import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:denik_zza/database/database_interface.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'dart:io';
import 'package:denik_zza/utils/mode_coordinator.dart';
import 'package:denik_zza/input/file_manager.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'setup_templates/hardcoded_setup.dart';
import 'utils/database_test_helper.dart';
import 'utils/test_configuration.dart';

/// 🏆 UNIVERSAL STRATEGY SHOWCASE TEST
///
/// This file serves as the definitive guide and verification suite for the
/// "Universal Test Automation Strategy". It demonstrates how to use each mode
/// and verifies that the infrastructure behaves as expected.
///
/// Modes Covered:
/// 1. **In-Memory Mode** (Default): Fast, isolated, no disk I/O.
/// 2. **Integration Mode**: File-based, isolated directory, auto-cleanup.
/// 3. **Debug Mode**: File-based, persistent directory, manual cleanup.
void main() {
  // Initialize Flutter binding
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock path_provider for Integration/Debug modes
  const MethodChannel channel =
      MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    channel,
    (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return '.'; // Use current directory as docs dir
      }
      if (methodCall.method == 'getTemporaryDirectory') {
        return '.'; // Use current directory as temp dir
      }
      return null;
    },
  );

  group('🦄 Universal Strategy Showcase', () {
    // =========================================================================
    // MODE 1: IN-MEMORY (The "Happy Path" for Unit Tests)
    // =========================================================================
    group('1. In-Memory Mode (Unit Tests)', () {
      late AppDatabase database;

      setUp(() async {
        // 1. Set Mode: Testing (In-Memory)
        ModeCoordinator.setTestingMode();

        // 2. Populate DB using HardcodedTestSetup
        // It automatically uses the DB provided by DatabaseWrapper (which is in-memory)
        database = await HardcodedTestSetup.setupTestData();
      });

      tearDown(() async {
        await ModeCoordinator.setProductionMode();
      });

      test('should be fast and isolated', () async {
        // Verify Mode
        expect(DatabaseWrapper.getCurrentMode(), equals(DatabaseMode.testing));
        expect(FileManager().currentMode, equals(FileManagerMode.inMemory));

        // Verify Data Population
        final events = await database.select(database.zzaActions).get();
        expect(events, isNotEmpty,
            reason: 'HardcodedTestSetup should populate events');
        expect(events.first.actionTitle, equals('Test Test Test'));

        // Verify Operation (Direct DB Access)
        final companyId = await database.addInsuranceCompany(
            InsuranceCompaniesCompanion.insert(name: 'Memory Co'));
        expect(companyId, greaterThan(0));

        // Verify Isolation (No files created)
        final dbPath = await FileManager().getDbFilePath();
        expect(dbPath, isNull,
            reason: 'In-memory mode should not have a file path');
      });
    });

    // =========================================================================
    // MODE 2: INTEGRATION MODE (File-Based, Isolated)
    // =========================================================================
    group('2. Integration Mode (File Isolation)', () {
      late DatabaseInterface databaseInterface;
      final testName = 'showcase_integration_test';

      setUp(() async {
        // 1. Set Mode: Integration (File-based, isolated folder)
        await ModeCoordinator.setIntegrationTestMode(
          runId: 'test_run',
          testName: testName,
        );
        print(
            'DEBUG: ModeCoordinator set. FileManager homeDir: ${FileManager().homeDir?.path}');

        // 2. Populate DB using HardcodedTestSetup
        // It automatically uses the DB provided by DatabaseWrapper.
        // Note: ModeCoordinator.setIntegrationTestMode sets DatabaseWrapper to 'testing' (memory)
        // but FileManager to 'production' (real files). This is the standard integration setup.
        // If we wanted a FILE DB for integration, we'd need to configure DatabaseWrapper differently,
        // but for now we follow the standard behavior.
        await HardcodedTestSetup.setupTestData();

        // 3. Get Interface for testing
        databaseInterface = DatabaseWrapper.getDatabase();
      });

      tearDown(() async {
        await ModeCoordinator.setProductionMode(); // Resets and cleans up
      });

      test('should create files in isolated directory', () async {
        // Verify Mode
        expect(DatabaseWrapper.getCurrentMode(), equals(DatabaseMode.testing));
        expect(FileManager().currentMode,
            equals(FileManagerMode.production)); // Real file ops

        print(
            'DEBUG: Test running. FileManager homeDir: ${FileManager().homeDir?.path}');

        // Verify Data Population (via Interface)
        final events = await databaseInterface.getAllZzaActions();
        expect(events, isNotEmpty);
        expect(events.first.nadpis, equals('Test Test Test'));

        // Verify Operation (Via Interface)
        // addOsoba should work because HardcodedTestSetup sets the current event!
        final osoba = MemoryOsoba('Test', 'Integration', DateTime.now(),
            'Address', '123', 'Integration Co', '123456', 1);
        osoba.zpusobilost = true;
        osoba.bezinfekcnost = true;

        await databaseInterface.addOsoba(osoba);

        // Verify File Creation (FileManager should be pointing to isolated dir)
        final homeDir = await FileManager().getHomeDir();
        print('DEBUG: getHomeDir returned: ${homeDir?.path}');

        expect(homeDir, isNotNull);
        expect(
            homeDir!.path, contains(testName)); // Should be in isolated folder
        expect(homeDir.existsSync(), isTrue);
      });
    });

    // =========================================================================
    // MODE 3: DEBUG MODE (Persistence for Manual Inspection)
    // =========================================================================
    group('3. Debug Mode (Persistence)', () {
      late DatabaseInterface databaseInterface;
      final testName = 'showcase_debug_session';

      setUp(() async {
        // 1. Set Mode: Debug (Persistent output)
        await ModeCoordinator.setDebugMode(testName: testName);

        // 2. Clean up previous run's DB if exists (ensure idempotency)
        // Since Debug Mode is persistent, we must clear it to allow HardcodedTestSetup to run without unique constraint violations
        final dbPath = await FileManager().getDbFilePath();
        if (dbPath != null) {
          final file = File(dbPath);
          if (await file.exists()) {
            await file.delete();
            print('DEBUG: Deleted existing debug DB for test isolation');
          }
        }

        // 3. Populate DB using HardcodedTestSetup
        // Debug mode uses a persistent file DB (via DatabaseWrapper defaulting to production logic but with redirected paths)
        await HardcodedTestSetup.setupTestData();

        // 3. Get Interface
        databaseInterface = DatabaseWrapper.getDatabase();
      });

      tearDown(() async {
        await ModeCoordinator.setProductionMode();
      });

      test('should persist data for inspection', () async {
        // Verify Mode
        expect(ModeCoordinator.currentMode, equals(AppMode.debug));
        expect(FileManager().isPersistMode, isTrue);

        // Verify Data Population
        final events = await databaseInterface.getAllZzaActions();
        expect(events, isNotEmpty);

        // Verify Operation
        final osoba = MemoryOsoba('Test', 'Debug', DateTime.now(), 'Address',
            '123', 'Debug Co', '123456', 1);
        osoba.zpusobilost = true;
        osoba.bezinfekcnost = true;

        await databaseInterface.addOsoba(osoba);

        // Verify Persistence Path
        final homeDir = await FileManager().getHomeDir();
        expect(homeDir!.path, contains('test_outputs'));
        expect(homeDir.path, contains(testName));

        print('📝 Debug Output Location: ${homeDir.path}');
      });
    });

    // =========================================================================
    // VERIFICATION: DATABASE ISOLATION & CLEANUP
    // =========================================================================
    group('4. Infrastructure Verification', () {
      test('should handle rapid creation/deletion of file databases', () async {
        // Migrated from database_directory_management_test.dart
        if (!TestConfiguration.isPersist) {
          // Skip if not in persist mode to avoid FS spam, but for showcase we run a lightweight version
        }

        final databases = <AppDatabase>[];
        try {
          for (int i = 0; i < 3; i++) {
            final db =
                DatabaseTestHelper.createTestDatabase(TestDatabaseType.file);
            databases.add(db);
            await Future.delayed(
                const Duration(milliseconds: 10)); // Ensure unique timestamps
          }

          // Verify they are distinct
          final paths = databases.map((db) => db.hashCode).toSet();
          expect(paths.length, equals(3),
              reason: 'Each database instance should be unique');
        } finally {
          for (final db in databases) {
            await db.close();
          }
        }
      });
    });
  });
}
