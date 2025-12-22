import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/input/file_manager.dart';
import 'package:denik_zza/shared/czech_test_data.dart';
import 'package:drift/drift.dart';
import '../utils/database_test_helper.dart';
import 'package:denik_zza/utils/app_logger.dart';

/// Hardcoded setup for testing with predefined test data
///
/// This class prepares the app database with a test event called "Test Test Test"
/// and 10 participants with various test data configurations.
/// Uses the existing DatabaseTestHelper infrastructure.
///
/// 🎯 **Testing Approach**: Uses Drift database directly (like other tests)
/// - ✅ Events: Created using Drift database methods
/// - ✅ Participants: Created using Drift database methods
/// - ✅ Insurance companies: Auto-created by participant addition
/// - ⚠️  Paramedics: Uses hardcoded test ID (no front-facing creation method exists)
/// - ✅ Medical records: Created using Drift database methods
///
/// 📖 Database Access:
/// Uses DatabaseTestHelper.createTestDatabase() for real SQLite databases.
///
/// Usage:
/// ```dart
/// setUp(() async {
///   database = await HardcodedTestSetup.setupTestData();
/// });
/// ```
class HardcodedTestSetup {
  // Static variable to track selected event
  static int? _selectedEventId;

  /// Gets the ID of the currently selected test event
  static int? get selectedEventId => _selectedEventId;

  /// Sets up the database with test data and returns the database instance
  ///
  /// [db] - Optional database instance to populate. If null, it creates one based on the current environment.
  /// This allows it to work with any mode (Memory, File, Debug) set by [ModeCoordinator].
  static Future<AppDatabase> setupTestData({AppDatabase? db}) async {
    AppDatabase database;

    if (db != null) {
      database = db;
    } else {
      // Smart Creation: Create DB based on current environment
      if (DatabaseWrapper.getCurrentMode() == DatabaseMode.testing) {
        // In-Memory Mode (Unit Tests & Integration Tests)
        database = AppDatabase.testInMemory();
      } else {
        // Persistent Mode (Debug / Production)
        // We need to wait for the path from FileManager (which ModeCoordinator configured)
        final path = await FileManager().getDbFilePath();
        if (path == null) {
          // Fallback if no path (shouldn't happen in persistent mode)
          database = AppDatabase.testInMemory();
        } else {
          database = AppDatabase(path);
        }
      }

      // Inject the created DB so the app uses it
      DatabaseWrapper.useTestDriftDatabase(database);
    }

    try {
      // Note: We no longer force setTestMode() here.
      // The caller (test setup) should have already configured the environment via ModeCoordinator.

      // 1. Create the test event using Drift database methods
      final now = DateTime.now();
      final eventCompanion = ZzaActionsCompanion(
        actionTitle: const Value('Test Test Test'),
        actionDescription: const Value(
            'Testovací akce s českými účastníky a historickými osobnostmi'),
        dateFrom: Value(now),
        dateTo: Value(now.add(const Duration(days: 7))),
      );
      final eventId = await database.addZzaAction(eventCompanion);
      _selectedEventId = eventId;

      // Persist selected event into cache so production code paths using
      // getCurrentActionID/watchParticipantsByCurrentEvent work in tests/dev
      await database.updateCache(CacheCompanion(
        id: const Value(1),
        currentActionID: Value(eventId),
        pinnedActionID: const Value(null),
      ));

      // Create a test paramedic row to satisfy foreign key constraints on records
      final testParamedicId = await database.addParamedic(ParamedicsCompanion(
        firstName: const Value('Test'),
        lastName: const Value('Paramedic'),
        address: const Value('Test Address 1'),
        birthDate: Value(DateTime(1990, 1, 1)),
        phoneNumber: const Value('+420000000000'),
        username: const Value('tester1'),
      ));

      // 2. Create 10 Czech participants using shared generators
      final participants =
          await CzechTestData.createParticipants(database, eventId);

      // 3. Create medical records using shared generators
      await CzechTestData.createMedicalRecords(
          database, participants, testParamedicId);

      return database;
    } catch (e) {
      AppLogger.l.e('❌ Error setting up test data: $e');
      rethrow;
    }
  }

  // Participant and record creation moved to lib/shared/czech_test_data.dart

  /// Quick setup method that can be called in test setUp()
  static Future<AppDatabase> quickSetup({AppDatabase? db}) async {
    return await setupTestData(db: db);
  }

  /// Close and clean up the database
  static Future<void> cleanup(AppDatabase database) async {
    await DatabaseTestHelper.closeTestDatabase(database);
  }
}
