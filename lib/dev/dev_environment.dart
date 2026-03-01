import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/database/drift_database_connector.dart'; // Required for seeded health data
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_omezeni.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_lek.dart';
import 'package:denik_zza/input/file_manager.dart';
import 'package:denik_zza/shared/czech_test_data.dart';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:denik_zza/utils/app_logger.dart';

/// Development environment configuration and test data generator.
class DevEnvironment {
  /// Initializes the development environment with a test database and comprehensive mock data.
  ///
  /// This setup mimics `HardcodedTestSetup.setupTestData()` logic but is maintained
  /// as a separate utility for development app entry points and specific tests.
  ///
  /// [registerGlobally] - If true (default), registers the database with [DatabaseWrapper].
  /// Set to false when running isolated tests (e.g. `mocked_part_test.dart`) to avoid polluting global state.
  static Future<AppDatabase> initialize({bool registerGlobally = true}) async {
    // Initialize Czech locale for date formatting (fixes LocaleDataException)
    Intl.defaultLocale = 'cs_CZ';
    await initializeDateFormatting('cs_CZ', null);

    // Create in-memory test database
    final AppDatabase database = AppDatabase.testInMemory();

    try {
      if (registerGlobally) {
        // Ensure the app uses this database instance (so UI + services see same data)
        DatabaseWrapper.setTestMode();
        DatabaseWrapper.useTestDriftDatabase(database);

        // Configure FileManager for in-memory mode (prevents disk writes during dev)
        FileManager(isTesting: true);
      }

      // 1. Create test event (matches HardcodedTestSetup pattern exactly)
      final now = DateTime.now();
      final eventId = await database.addZzaAction(
        ZzaActionsCompanion(
          actionTitle: const Value('Letní Tábor 2024'),
          actionDescription: const Value('Testovací turnus pro vývoj'),
          dateFrom: Value(now.subtract(const Duration(days: 2))),
          dateTo: Value(now.add(const Duration(days: 12))),
          homeDirectory: const Value('test_camp_2024'),
        ),
      );

      // Set as current event (Critical for UI to load anything)
      await database.updateCache(
        CacheCompanion(
          id: const Value(1),
          currentActionID: Value(eventId),
        ),
      );

      // 2. Create default paramedic (admin user)
      // Matches Schema requirements (FirstName, LastName, Address, BirthDate, PhoneNumber)
      // ID 1 is typically used as default author in seeded records
      final testParamedicId = await database.addParamedic(
        ParamedicsCompanion(
          firstName: Value('Hlavní'),
          lastName: Value('Zdravotník'),
          username: Value('test_admin'),
          address: Value('Test Address 1'),
          birthDate: Value(DateTime(1990, 1, 1)),
          phoneNumber: Value('+420000000000'),
          // Password field does not exist in Paramedics table based on schema analysis
        ),
      );

      // 3. Create participants using shared generators
      final participantIds =
          await CzechTestData.createParticipants(database, eventId);

      // 6. Create medical records using shared generators
      await CzechTestData.createMedicalRecords(
          database, participantIds, testParamedicId);

      // 7. Create health data (alergie, omezení, léky) for UI testing
      // We pass the database instance to use a local connector, avoiding global DatabaseWrapper dependency
      await _createTestHealthData(database, participantIds);

      return database;
    } catch (e) {
      AppLogger.l.e('❌ Error setting up dev environment: $e');
      rethrow;
    }
  }

  // Participant and record creation moved to lib/shared/czech_test_data.dart

  /// Creates test health data (omezení, alergie, léky) for UI testing.
  ///
  /// Uses [DriftDatabaseConnector] wrapping the LOCAL [database] instance.
  /// This avoids using Raw DB calls for complex objects (Lek/Omezeni logic),
  /// while also avoiding dependency on the global [DatabaseWrapper].
  static Future<void> _createTestHealthData(
      AppDatabase database, List<int> participantIds) async {
    // Inject the local database into the connector to ensure isolation
    final dbInterface = DriftDatabaseConnector.withDatabase(database);

    // Target participant: Antonín Dvořák (index 3)
    final antoninId = participantIds[3];

    // 7.1 Create Alergie (Multiple to test overflow)
    // "Alergie na prach" (Standard)
    // "Alergie na pyl a roztoče" (Medium)
    final alergie = [
      MemoryOmezeni.fullNamed(
          id: null, // ID auto-increment
          omezeni: 'Alergie na prach',
          typOmezeni: 2, // 2 = Alergie
          idOsoby: antoninId,
          wasPrinted: false),
      MemoryOmezeni.fullNamed(
          id: null,
          omezeni: 'Alergie na pyl a jarní kvetoucí stromy', // Long string
          typOmezeni: 2,
          idOsoby: antoninId,
          wasPrinted: false),
    ];

    for (var a in alergie) {
      await dbInterface.addOmezeni(a);
    }

    // 7.2 Create Omezení (Long string test)
    final omezeni = MemoryOmezeni.fullNamed(
        id: null,
        omezeni:
            'Nemůže zvedat těžká břemena kvůli operaci páteře v roce 2023', // Very long string > 50 chars
        typOmezeni: 1, // 1 = Omezení
        idOsoby: antoninId,
        wasPrinted: false);
    await dbInterface.addOmezeni(omezeni);

    // 7.3 Create Léky
    final medications = [
      {'nazev': 'Ibalgin 400mg (ráno a večer)', 'popis': '1 tableta po jídle'},
      {'nazev': 'Paralen 500mg', 'popis': 'Při teplotě nad 38°C'},
      {'nazev': 'Aspirin 100mg', 'popis': 'Ráno na lačno'},
      {'nazev': 'Vitamin D3 2000IU', 'popis': 'Jednou denně'},
      {'nazev': 'Omega-3 kapsle', 'popis': 'S jídlem'},
      {'nazev': 'Probiotika', 'popis': 'Před jídlem'},
      {'nazev': 'Antihistaminikum cetirizin', 'popis': 'Večer před spánkem'},
      {'nazev': 'Ventolin inhaler', 'popis': 'Při potřebě'},
    ];

    for (var med in medications) {
      final lek = MemoryLek.fullNamed(
          id: null,
          nazev: med['nazev']!,
          popisDavkovani: med['popis']!,
          idOsoby: antoninId,
          wasPrinted: false
          // note: 'bereSam', 'kdy', 'poznamkaLek' are not available in fullNamed constructor
          );
      await dbInterface.addLek(lek);
    }
  }
}
