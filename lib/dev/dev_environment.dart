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
/// - 1 test event ("Test Test Test")
/// - Sets it as current event (fixes getCurrentActionID() null errors!)
/// - 1 test paramedic (for foreign key constraints on records)
/// - 2 insurance companies (for participant creation)
/// - 10 test participants with Czech cultural references
/// - 10 medical records with cultural easter eggs
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
/// - ✅ Includes 10 participants + 10 records (exact copy of HardcodedTestSetup)
class DevEnvironment {
  /// Initialize development environment with test data including participants.
  ///
  /// Sets up an in-memory database with test infrastructure matching
  /// the pattern used in `test/setup_templates/hardcoded_setup.dart`.
  ///
  /// This ensures:
  /// - [getCurrentActionID()] never returns null
  /// - Foreign key constraints are satisfied
  /// - 10 Czech participants with cultural references (same as HardcodedTestSetup)
  /// - 10 medical records with easter eggs (same as HardcodedTestSetup)
  /// - Participants have valid insurance
  /// - Complete test data for development
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
      
      // 1. Create test event (matches HardcodedTestSetup pattern exactly)
      final now = DateTime.now();
      final eventCompanion = ZzaActionsCompanion(
        actionTitle: const Value('Test Test Test'),
        actionDescription: const Value('Testovací akce s českými účastníky a historickými osobnostmi'),
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
      final testParamedicId = await database.addParamedic(ParamedicsCompanion(
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
      
      // 5. Create 10 Czech participants (like HardcodedTestSetup)
      final participantIds = await _createTestParticipants(database, eventId);
      
      // 6. Create medical records (like HardcodedTestSetup)
      await _createCzechMedicalRecords(database, participantIds, testParamedicId);
      
      return database;
      
    } catch (e) {
      // Match HardcodedTestSetup error handling for consistent debugging
      print('❌ Error setting up dev environment: $e');
      rethrow;
    }
  }
  
  /// Create test participants (exact copy from HardcodedTestSetup)
  static Future<List<int>> _createTestParticipants(AppDatabase database, int eventId) async {
    final participantIds = <int>[];
    // Czech historical and cultural figures with subtle references
    final participants = [
      {
        'firstName': 'Václav',
        'lastName': 'Havlík', // Reference to Václav Havel
        'birthDate': DateTime(2010, 10, 5),
        'address': 'Hradčanské náměstí 1, Praha',
        'note': 'Rád hraje divadlo a píše básně',
        'insurance': 'Všeobecná zdravotní pojišťovna',
      },
      {
        'firstName': 'Karel',
        'lastName': 'Čapková', // Reference to Karel Čapek
        'birthDate': DateTime(2009, 1, 9),
        'address': 'Vinohrady 42, Praha',
        'note': 'Miluje roboty a sci-fi příběhy',
        'insurance': 'Oborová zdravotní pojišťovna',
      },
      {
        'firstName': 'Bedřich',
        'lastName': 'Smetana', // Bedřich Smetana - composer
        'birthDate': DateTime(2008, 3, 2),
        'address': 'Kampa Island 5, Praha',
        'note': 'Hraje na klavír Vltavu',
        'insurance': 'Všeobecná zdravotní pojišťovna',
      },
      {
        'firstName': 'Antonín',
        'lastName': 'Dvořák', // Antonín Dvořák - composer
        'birthDate': DateTime(2007, 9, 8),
        'address': 'Nelahozeves 123',
        'note': 'Komponuje melodie z Nového světa',
        'insurance': 'Všeobecná zdravotní pojišťovna',
      },
      {
        'firstName': 'Milan',
        'lastName': 'Kundera', // Milan Kundera - writer
        'birthDate': DateTime(2006, 4, 1),
        'address': 'Brno, Moravské náměstí 1',
        'note': 'Píše o nesnesitelné lehkosti bytí',
        'insurance': 'Oborová zdravotní pojišťovna',
      },
      {
        'firstName': 'Jaroslav',
        'lastName': 'Hašek', // Jaroslav Hašek - author of Švejk
        'birthDate': DateTime(2011, 4, 30),
        'address': 'U Fleku 11, Praha',
        'note': 'Vyprávě historky o dobrém vojákovi',
        'insurance': 'Všeobecná zdravotní pojišťovna',
      },
      {
        'firstName': 'Tomáš',
        'lastName': 'Baťa', // Tomáš Baťa - shoe entrepreneur  
        'birthDate': DateTime(2005, 4, 3),
        'address': 'Zlín, náměstí Míru 12',
        'note': 'Sbírá staré boty a opravuje je',
        'insurance': 'Oborová zdravotní pojišťovna',
      },
      {
        'firstName': 'Ema',
        'lastName': 'Destinnová', // Ema Destinnová - opera singer
        'birthDate': DateTime(2004, 2, 26),
        'address': 'Vinohrady, Korunní 15, Praha',
        'note': 'Zpívá árie z Prodané nevěsty',
        'insurance': 'Všeobecná zdravotní pojišťovna',
      },
      {
        'firstName': 'Jan',
        'lastName': 'Komenský', // Jan Amos Komenský
        'birthDate': DateTime(2003, 3, 28),
        'address': 'Nivnice 456, Zlínský kraj',
        'note': 'Zajímá se o vzdělávání a učí ostatní',
        'insurance': 'Oborová zdravotní pojišťovna',
      },
      {
        'firstName': 'Franz',
        'lastName': 'Kafka', // Franz Kafka
        'birthDate': DateTime(2002, 7, 3),
        'address': 'Staroměstské náměstí 27, Praha',
        'note': 'Píše podivné příběhy o proměnách',
        'insurance': 'Všeobecná zdravotní pojišťovna',
      },
    ];
    
    for (final participant in participants) {
      // Get insurance company ID
      final insuranceName = participant['insurance'] as String;
      int? insuranceId = await database.getInsuranceCompanyIDbyName(insuranceName);
      if (insuranceId == null) {
        insuranceId = await database.addInsuranceCompany(
          InsuranceCompaniesCompanion(name: Value(insuranceName))
        );
      }
      
      final companion = ParticipantsCompanion(
        firstName: Value(participant['firstName'] as String),
        lastName: Value(participant['lastName'] as String),
        birthDate: Value(participant['birthDate'] as DateTime),
        address: Value(participant['address'] as String),
        note: Value(participant['note'] as String),
        insuranceCompanyFK: Value(insuranceId),
        zzaActionFK: Value(eventId),
        eligibleConfirmation: const Value(true),
        nonInfectiousConfirmation: const Value(true),
        arrivedConfirmation: const Value(true),
        wasPrinted: const Value(false),
      );
      
      final id = await database.addParticipant(companion);
      participantIds.add(id);
    }
    return participantIds;
  }
  
  /// Creates medical records with Czech cultural easter eggs (exact copy from HardcodedTestSetup)
  static Future<void> _createCzechMedicalRecords(AppDatabase database, List<int> participantIds, int paramedicId) async {
    final czechRecords = [
      {
        'title': 'Kontrola zdraví',
        'description': 'má velrybí stoličku a hodně ho bolí', // The requested easter egg
        'participantIndex': 0, // Václav Havlík
      },
      {
        'title': 'Preventivní prohlídka',
        'description': 'stěžuje si na roboty v břiše, možná sci-fi alergie',
        'participantIndex': 1, // Karel Čapková
      },
      {
        'title': 'Hudební terapie',
        'description': 'Vltava mu teče v uších, doporučujeme méně klavíru',
        'participantIndex': 2, // Bedřich Smetana
      },
      {
        'title': 'Bolest hlavy',
        'description': 'hlava bolí z příliš mnoha symfonií, potřebuje klid',
        'participantIndex': 3, // Antonín Dvořák
      },
      {
        'title': 'Existenciální krize',
        'description': 'trpí nesnesitelnou lehkostí bytí, doporučen filozofický klid',
        'participantIndex': 4, // Milan Kundera
      },
      {
        'title': 'Vojenské vyšetření',
        'description': 'simuluje nemoc jako dobrý voják Švejk, ale je zdravý',
        'participantIndex': 5, // Jaroslav Hašek
      },
      {
        'title': 'Pracovní úraz',
        'description': 'poranil si nohu při výrobě bot, rychlé hojení',
        'participantIndex': 6, // Tomáš Baťa
      },
      {
        'title': 'Hlasové problémy',
        'description': 'přepěla se při áriích, doporučen hlasový klid',
        'participantIndex': 7, // Ema Destinnová
      },
      {
        'title': 'Únava z učení',
        'description': 'vyčerpání z příliš mnoho vzdělávání, potřebuje pauzu',
        'participantIndex': 8, // Jan Komenský
      },
      {
        'title': 'Kafka-esque situace',
        'description': 'proměnil se v brouka během spánku, ale ráno byl zase normální',
        'participantIndex': 9, // Franz Kafka
      },
    ];
    
    for (int i = 0; i < czechRecords.length; i++) {
      final record = czechRecords[i];
      final companion = RecordsCompanion(
        title: Value(record['title'] as String),
        description: Value(record['description'] as String),
        note: const Value('Záznam s českým kulturním odkazem'),
        participantFK: Value(participantIds[record['participantIndex'] as int]),
        paramedicFK: Value(paramedicId),
        dateAndTime: Value(DateTime.now().subtract(Duration(hours: i * 2))),
        wasPrinted: const Value(false),
      );
      await database.addRecord(companion);
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
