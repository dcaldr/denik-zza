import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/database/drift_database_connector.dart'; // Required for seeded health data
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_omezeni.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_lek.dart';
import 'package:denik_zza/input/file_manager.dart';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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

      // 3. Create participants (10 Czech figures)
      final participantIds = await _createTestParticipants(database, eventId);

      // 6. Create medical records (like HardcodedTestSetup)
      await _createCzechMedicalRecords(
          database, participantIds, testParamedicId);

      // 7. Create health data (alergie, omezení, léky) for UI testing
      // We pass the database instance to use a local connector, avoiding global DatabaseWrapper dependency
      await _createTestHealthData(database, participantIds);

      return database;
    } catch (e) {
      print('❌ Error setting up dev environment: $e');
      rethrow;
    }
  }

  /// Create test participants (exact copy from HardcodedTestSetup)
  static Future<List<int>> _createTestParticipants(
      AppDatabase database, int eventId) async {
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
      int? insuranceId =
          await database.getInsuranceCompanyIDbyName(insuranceName);
      if (insuranceId == null) {
        // Use Raw DB Access (Alignment with HardcodedTestSetup)
        insuranceId = await database.addInsuranceCompany(
            InsuranceCompaniesCompanion(name: Value(insuranceName)));
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
  static Future<void> _createCzechMedicalRecords(
      AppDatabase database, List<int> participantIds, int paramedicId) async {
    final czechRecords = [
      {
        'title': 'Kontrola zdraví',
        'description':
            'má velrybí stoličku a hodně ho bolí', // The requested easter egg
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
        'description':
            'trpí nesnesitelnou lehkostí bytí, doporučen filozofický klid',
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
        'description':
            'proměnil se v brouka během spánku, ale ráno byl zase normální',
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
