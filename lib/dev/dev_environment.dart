import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/input/file_manager.dart';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Unified development environment setup for all dev mains.
///
/// Provides consistent test data initialization across all development entry points.
/// This setup mirrors the structure of `test/setup_templates/hardcoded_setup.dart`
/// but with minimal data for fast dev iterations.
///
/// Creates:
/// - 1 test event ("Test Dev Event")
/// - Sets it as current event (fixes getCurrentActionID() null errors!)
/// - 1 test paramedic (for foreign key constraints on records)
/// - 2 insurance companies (for participant creation)
/// - In-memory database for fast iterations
///
/// **Usage in dev mains:**
/// ```dart
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await DevEnvironment.initialize();
///   runApp(MyDevApp());
/// }
/// ```
///
/// **Benefits:**
/// - ✅ Consistent setup across all dev entry points
/// - ✅ Fixes null errors (current event always exists)
/// - ✅ Fast in-memory database
/// - ✅ One-liner initialization
/// - ✅ Isolated from production data
/// - ✅ Same structure as HardcodedTestSetup (easier to understand)
class DevEnvironment {
  /// Initialize development environment with minimal test data.
  ///
  /// Sets up an in-memory database with test infrastructure matching
  /// the pattern used in `test/setup_templates/hardcoded_setup.dart`.
  ///
  /// This ensures:
  /// - [getCurrentActionID()] never returns null
  /// - Foreign key constraints are satisfied
  /// - Participants can be created with valid insurance
  /// - Records can be created with valid paramedic FK
  ///
  /// Returns the initialized [AppDatabase] instance.
  static Future<AppDatabase> initialize() async {
    // Initialize Czech locale for date formatting (fixes LocaleDataException)
    Intl.defaultLocale = 'cs_CZ';
    await initializeDateFormatting('cs_CZ', null);
    
    // Create in-memory test database (MUST happen before setTestMode/useTestDriftDatabase)
    final AppDatabase database = AppDatabase.testInMemory();
    
    try {
      // Ensure the app uses this database instance (so UI + services see same data)
      DatabaseWrapper.setTestMode();
      DatabaseWrapper.useTestDriftDatabase(database);
      
      // Configure FileManager for in-memory mode (prevents disk writes during dev)
      FileManager(isTesting: true);
      
      // 1. Create test event (matches HardcodedTestSetup pattern)
      final now = DateTime.now();
      final eventCompanion = ZzaActionsCompanion(
        actionTitle: const Value('Test Dev Event'),
        actionDescription: const Value('Development test event with auto-setup'),
        dateFrom: Value(now),
        dateTo: Value(now.add(const Duration(days: 7))),
      );
      final eventId = await database.addZzaAction(eventCompanion);
      
      // 2. CRITICAL: Set as current event in cache (like HardcodedTestSetup)
      // This makes getCurrentActionID() work and fixes null errors!
      await database.updateCache(CacheCompanion(
        id: const Value(1),
        currentActionID: Value(eventId),
        pinnedActionID: const Value(null),
      ));
      
      // 3. Create test paramedic (like HardcodedTestSetup)
      // Required for foreign key constraints on medical records
      await database.addParamedic(ParamedicsCompanion(
        firstName: const Value('Test'),
        lastName: const Value('Paramedic'),
        address: const Value('Test Address 1'),
        birthDate: Value(DateTime(1990, 1, 1)),
        phoneNumber: const Value('+420000000000'),
        username: const Value('tester1'),
      ));
      
      // 4. Create insurance companies (like HardcodedTestSetup)
      // These will be available for participant creation
      await database.addInsuranceCompany(
        const InsuranceCompaniesCompanion(
          name: Value('Všeobecná zdravotní pojišťovna'),
        ),
      );
      await database.addInsuranceCompany(
        const InsuranceCompaniesCompanion(
          name: Value('Oborová zdravotní pojišťovna'),
        ),
      );
      
      return database;
      
    } catch (e) {
      // Match HardcodedTestSetup error handling for consistent debugging
      print('❌ Error setting up dev environment: $e');
      rethrow;
    }
  }
  
  /// Initialize with full rich test data (10 participants + records).
  ///
  /// For complete test data with cultural references, import and use
  /// HardcodedTestSetup directly instead of this method:
  ///
  /// ```dart
  /// // In test files or dev_main.dart for rich testing:
  /// import '../../test/setup_templates/hardcoded_setup.dart';
  /// await HardcodedTestSetup.setupTestData();
  /// ```
  ///
  /// **Note:** This method is kept for backward compatibility but
  /// HardcodedTestSetup is recommended for full app testing.
  @Deprecated('Use HardcodedTestSetup.setupTestData() for rich test data')
  static Future<AppDatabase> initializeWithTestData() async {
    // Just delegate to initialize() - users should use HardcodedTestSetup
    // if they want 10 participants + records
    return await initialize();
  }
}
