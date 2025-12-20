import 'package:denik_zza/database/drift_database/database.dart';
import 'package:drift/drift.dart';

/// Seeder for the "Jurský park" standard test dataset.
///
/// This seeder creates a realistic camp scenario with 15 Czech participants
/// representing historical figures. The dataset includes diverse medical
/// scenarios (0-13 records per participant), medications, allergies, and
/// limitations.
///
/// ## Generated Data:
/// - 1 Event: "Jurský park" (July 10-24, 2025)
/// - 1 Paramedic: Jana Zdravotníková
/// - 2 Insurance Companies: VZP, OZP
/// - 15 Participants: Czech historical figures (ages 10-16)
/// - Medical records: 0-13 per participant (64 total)
/// - Medications: 6 participants
/// - Allergies/Limitations: 9 participants
///
/// ## Usage:
/// ```dart
/// final db = AppDatabase.testInMemory();
/// await JurskyParkSeeder.seed(db);
/// ```
class JurskyParkSeeder {
  /// Seeds the database with the complete Jurský Park dataset.
  static Future<void> seed(AppDatabase database) async {
    try {
      // Step 1: Create event
      final eventId = await _createEvent(database);

      // Step 2: Create insurance companies
      final insuranceIds = await _createInsuranceCompanies(database);

      // Step 3: Create paramedic
      final paramedicId = await _createParamedic(database);

      // Step 4: Create participants
      final participantIds = await _createParticipants(
        database,
        eventId,
        insuranceIds,
      );

      // Step 5: Create medical records
      await _createMedicalRecords(database, participantIds, paramedicId);

      // Step 6: Create medications
      await _createMedications(database, participantIds);

      // Step 7: Create allergies and limitations
      await _createAllergiesLimitations(database, participantIds);

      // Step 8: Set current event
      await database.updateCache(
        CacheCompanion(
          id: const Value(1),
          currentActionID: Value(eventId),
        ),
      );
    } catch (e) {
      // Re-throw to fail the test setup immediately
      rethrow;
    }
  }

  /// Creates the "Jurský park" event.
  static Future<int> _createEvent(AppDatabase database) async {
    return await database.addZzaAction(
      ZzaActionsCompanion(
        actionTitle: const Value('Jurský park'),
        actionDescription:
            const Value('Letní táborový turnus zaměřený na historii a přírodu'),
        dateFrom: Value(DateTime(2025, 7, 10)),
        dateTo: Value(DateTime(2025, 7, 24)),
        homeDirectory: const Value('jursky_park_2025'),
      ),
    );
  }

  /// Creates VZP and OZP insurance companies.
  ///
  /// Returns a map: {'VZP': id1, 'OZP': id2}
  static Future<Map<String, int>> _createInsuranceCompanies(
      AppDatabase database) async {
    final vzpId = await database.addInsuranceCompany(
      InsuranceCompaniesCompanion(
        name: const Value('Všeobecná zdravotní pojišťovna'),
      ),
    );

    final ozpId = await database.addInsuranceCompany(
      InsuranceCompaniesCompanion(
        name: const Value('Oborová zdravotní pojišťovna'),
      ),
    );

    return {'VZP': vzpId, 'OZP': ozpId};
  }

  /// Creates the test paramedic (Jana Zdravotníková).
  static Future<int> _createParamedic(AppDatabase database) async {
    return await database.addParamedic(
      ParamedicsCompanion(
        firstName: const Value('Jana'),
        lastName: const Value('Zdravotníková'),
        username: const Value('zdravotnik_jursky'),
        address: const Value('Tábor Jurský park, Česká republika'),
        birthDate: Value(DateTime(1985, 3, 15)),
        phoneNumber: const Value('+420723456789'),
      ),
    );
  }

  /// Creates all 15 participants with complete field data.
  ///
  /// Each participant includes:
  /// - Jméno, Příjmení (required)
  /// - Datum narození, Rodné číslo
  /// - Adresa (varied Czech cities)
  /// - Telefon rodiče (8/15 have parent contacts)
  /// - Pojišťovna (VZP or OZP)
  /// - Pohlaví (1=male, 2=female)
  ///
  /// Returns list of participant IDs in order.
  static Future<List<int>> _createParticipants(
    AppDatabase database,
    int eventId,
    Map<String, int> insuranceIds,
  ) async {
    final participants = [
      // 1. Karel Čapek - 16, Male, 2 records
      {
        'jmeno': 'Karel',
        'prijmeni': 'Čapek',
        'pohlavi': 1,
        'datumNarozeni': DateTime(2009, 1, 9),
        'rodneCislo': '090109/0804',
        'adresa': 'Vinohrady 42, Praha',
        'telefonRodice': '+420601234567',
        'pojistovna': 'VZP',
      },
      // 2. Božena Němcová - 15, Female, 2 records
      {
        'jmeno': 'Božena',
        'prijmeni': 'Němcová',
        'pohlavi': 2,
        'datumNarozeni': DateTime(2010, 5, 15),
        'rodneCislo': '105515/9634',
        'adresa': 'Ratibořice 1, Červený Kostelec',
        'telefonRodice': '+420602345678',
        'pojistovna': 'VZP',
      },
      // 3. Jan Hus - 14, Male, 5 records
      {
        'jmeno': 'Jan',
        'prijmeni': 'Hus',
        'pohlavi': 1,
        'datumNarozeni': DateTime(2011, 7, 6),
        'rodneCislo': '110706/6792',
        'adresa': 'Husova 15, Praha 1',
        'telefonRodice': null,
        'pojistovna': 'VZP',
      },
      // 4. Tomáš Masaryk - 14, Male, 0 records
      {
        'jmeno': 'Tomáš',
        'prijmeni': 'Masaryk',
        'pohlavi': 1,
        'datumNarozeni': DateTime(2011, 3, 7),
        'rodneCislo': '110307/4713',
        'adresa': 'Hradčany 7, Praha',
        'telefonRodice': '+420603456789',
        'pojistovna': 'OZP',
      },
      // 5. Alfons Mucha - 13, Male, 0 records (but has allergies)
      {
        'jmeno': 'Alfons',
        'prijmeni': 'Mucha',
        'pohlavi': 1,
        'datumNarozeni': DateTime(2012, 7, 24),
        'rodneCislo': '120724/0177',
        'adresa': 'Ivančice 28, Brno',
        'telefonRodice': null,
        'pojistovna': 'OZP',
      },
      // 6. Emil Zátopek - 13, Male, 1 record
      {
        'jmeno': 'Emil',
        'prijmeni': 'Zátopek',
        'pohlavi': 1,
        'datumNarozeni': DateTime(2012, 9, 19),
        'rodneCislo': '120919/4350',
        'adresa': 'Kopřivnice 192, Zlín',
        'telefonRodice': '+420604567890',
        'pojistovna': 'VZP',
      },
      // 7. Milada Horáková - 12, Female, 9 records
      {
        'jmeno': 'Milada',
        'prijmeni': 'Horáková',
        'pohlavi': 2,
        'datumNarozeni': DateTime(2013, 12, 25),
        'rodneCislo': '136225/3663',
        'adresa': 'Staroměstské nám. 8, Praha',
        'telefonRodice': '+420605678901',
        'pojistovna': 'OZP',
      },
      // 8. Jaroslav Seifert - 12, Male, 3 records
      {
        'jmeno': 'Jaroslav',
        'prijmeni': 'Seifert',
        'pohlavi': 1,
        'datumNarozeni': DateTime(2013, 9, 23),
        'rodneCislo': '130923/9104',
        'adresa': 'Žižkov 34, Praha 3',
        'telefonRodice': '+420606789012',
        'pojistovna': 'VZP',
      },
      // 9. Věra Čáslavská - 11, Female, 4 records
      {
        'jmeno': 'Věra',
        'prijmeni': 'Čáslavská',
        'pohlavi': 2,
        'datumNarozeni': DateTime(2014, 10, 18),
        'rodneCislo': '146018/5746',
        'adresa': 'Roudnice n. L. 56',
        'telefonRodice': null,
        'pojistovna': 'OZP',
      },
      // 10. Franz Kafka - 11, Male, 13 records
      {
        'jmeno': 'Franz',
        'prijmeni': 'Kafka',
        'pohlavi': 1,
        'datumNarozeni': DateTime(2014, 7, 3),
        'rodneCislo': '140703/9140',
        'adresa': 'Dlouhá třída 39, Praha 1',
        'telefonRodice': '+420607890123',
        'pojistovna': 'VZP',
      },
      // 11. Antonín Dvořák - 10, Male, 8 records
      {
        'jmeno': 'Antonín',
        'prijmeni': 'Dvořák',
        'pohlavi': 1,
        'datumNarozeni': DateTime(2015, 9, 8),
        'rodneCislo': '150908/7426',
        'adresa': 'Nelahozeves 12, Mělník',
        'telefonRodice': null,
        'pojistovna': 'VZP',
      },
      // 12. Václav Havel - 10, Male, 1 record
      {
        'jmeno': 'Václav',
        'prijmeni': 'Havel',
        'pohlavi': 1,
        'datumNarozeni': DateTime(2015, 10, 5),
        'rodneCislo': '151005/6427',
        'adresa': 'Hrádek 1, Trutnov',
        'telefonRodice': '+420608901234',
        'pojistovna': 'VZP',
      },
      // 13. Ema Destinnová - 10, Female, 12 records
      {
        'jmeno': 'Ema',
        'prijmeni': 'Destinnová',
        'pohlavi': 2,
        'datumNarozeni': DateTime(2015, 2, 26),
        'rodneCislo': '155226/9939',
        'adresa': 'Schwarzova 13, České Budějovice',
        'telefonRodice': null,
        'pojistovna': 'OZP',
      },
      // 14. Jan Amos Komenský - 11, Male, 4 records
      {
        'jmeno': 'Jan Amos',
        'prijmeni': 'Komenský',
        'pohlavi': 1,
        'datumNarozeni': DateTime(2014, 3, 28),
        'rodneCislo': '140328/4564',
        'adresa': 'Přerov 78, Olomouc',
        'telefonRodice': null,
        'pojistovna': 'OZP',
      },
      // 15. Bedřich Smetana - 12, Male, 6 records
      {
        'jmeno': 'Bedřich',
        'prijmeni': 'Smetana',
        'pohlavi': 1,
        'datumNarozeni': DateTime(2013, 3, 2),
        'rodneCislo': '130302/3304',
        'adresa': 'Litomyšl 9, Pardubice',
        'telefonRodice': '+420609012345',
        'pojistovna': 'VZP',
      },
    ];

    final participantIds = <int>[];

    for (final p in participants) {
      final insuranceName = p['pojistovna'] as String;
      final insuranceId = insuranceIds[insuranceName]!;
      final telefonRodice = p['telefonRodice'] as String?;

      final id = await database.addParticipant(
        ParticipantsCompanion(
          firstName: Value(p['jmeno'] as String),
          lastName: Value(p['prijmeni'] as String),
          gender: Value(p['pohlavi'] as int),
          birthDate: Value(p['datumNarozeni'] as DateTime),
          birthNumber: Value(p['rodneCislo'] as String),
          address: Value(p['adresa'] as String),
          parentPhoneNumber:
              telefonRodice != null ? Value(telefonRodice) : const Value(null),
          insuranceCompanyFK: Value(insuranceId),
          zzaActionFK: Value(eventId),
          eligibleConfirmation: const Value(true),
          nonInfectiousConfirmation: const Value(true),
          arrivedConfirmation: const Value(true),
          wasPrinted: const Value(false),
        ),
      );

      participantIds.add(id);
    }

    return participantIds;
  }

  /// Creates medical records for participants with varied scenarios.
  ///
  /// Distribution:
  /// - 0 records: Masaryk, Mucha (2 participants)
  /// - 1-2 records: Čapek, Němcová, Zátopek, Havel (4 participants)
  /// - 3-4 records: Seifert, Čáslavská, Komenský (3 participants)
  /// - 5-6 records: Hus, Smetana (2 participants)
  /// - 8-9 records: Dvořák, Horáková (2 participants)
  /// - 12-13 records: Destinnová, Kafka (2 participants)
  ///
  /// Total: ~64 medical records across all participants
  static Future<void> _createMedicalRecords(
    AppDatabase database,
    List<int> participantIds,
    int paramedicId,
  ) async {
    // Record templates with Czech descriptions
    final now = DateTime.now();

    // Helper to create record
    Future<void> addRecord(int participantIndex, String title,
        String description, int hoursAgo) async {
      await database.addRecord(
        RecordsCompanion(
          title: Value(title),
          description: Value(description),
          note: const Value(''),
          participantFK: Value(participantIds[participantIndex]),
          paramedicFK: Value(paramedicId),
          dateAndTime: Value(now.subtract(Duration(hours: hoursAgo))),
          wasPrinted: const Value(false),
        ),
      );
    }

    // Participant 0: Karel Čapek (2 records)
    await addRecord(0, 'Noční můry',
        'Sní o robotech, které ovládly tábor. Doporučen klid.', 48);
    await addRecord(0, 'Nespavost',
        'Potíže s usínáním kvůli obavám z budoucnosti technologie.', 24);

    // Participant 1: Božena Němcová (2 records)
    await addRecord(1, 'Stesk po babičce',
        'Stesk po domově. Doporučen telefonát s rodičem.', 60);
    await addRecord(1, 'Odřenina z lezení po stromech',
        'Drobné odřeniny na kolen a loktech. Ošetřeno.', 36);

    // Participant 2: Jan Hus (5 records)
    await addRecord(2, 'Spálení sluncem',
        'Odmítl použít opalovací krém. Výrazné zarudnutí.', 72);
    await addRecord(2, 'Spálení sluncem - pokrač.',
        'Pokračující problémy s kůží. Panthenol aplikován.', 48);
    await addRecord(2, 'Přehřátí',
        'Příznaky slunečního úpalu. Doporučen stín a tekutiny.', 40);
    await addRecord(
        2, 'Puchýř na patě', 'Puchýř z turistiky. Ošetřen náplastí.', 30);
    await addRecord(2, 'Drobné popáleniny z ohně',
        'Lehké popálení při stavbě ohně. Ironické.', 12);

    // Participant 3: Tomáš Masaryk - 0 records (stoic)

    // Participant 4: Alfons Mucha - 0 records (healthy, artistic)

    // Participant 5: Emil Zátopek (1 record)
    await addRecord(5, 'Křeč svalů',
        'Křeč v lýtku po nadměrném běhání. Doporučeno omezení.', 50);

    // Participant 6: Milada Horáková (9 records - bravery injuries)
    await addRecord(6, 'Modřina z obrany kamaráda',
        'Zasáhla při šikaně. Modřina na paži.', 80);
    await addRecord(6, 'Odřeniny z intervence',
        'Odřené koleno při pomoci mladšímu účastníkovi.', 70);
    await addRecord(
        6, 'Natažený sval', 'Natažení při zastavení konfliktu.', 65);
    await addRecord(
        6, 'Modřina na zádech', 'Další modřina z obhajoby druhých.', 55);
    await addRecord(6, 'Malá tržná rána', 'Tržná rána na ruce. Sešita.', 45);
    await addRecord(6, 'Oděrky', 'Četné oděrkyy po pádu během zásahu.', 38);
    await addRecord(6, 'Pohmoždění', 'Pohmoždění žeber. Doporučen klid.', 28);
    await addRecord(
        6, 'Bolest hlavy', 'Bolest hlavy ze stresu. Ibalgin podán.', 15);
    await addRecord(
        6, 'Únava', 'Vyčerpání z nadbytečné aktivity. Doporučen odpočinek.', 6);

    // Participant 7: Jaroslav Seifert (3 records)
    await addRecord(
        7, 'Říznutí papírem', 'Papírové říznutí při psaní básní.', 55);
    await addRecord(7, 'Únava očí', 'Únava z četby při svitu baterky.', 40);
    await addRecord(7, 'Bolest hlavy', 'Tenze hlavy z dlouhého psaní.', 20);

    // Participant 8: Věra Čáslavská (4 records - gymnastics)
    await addRecord(8, 'Vykloubený zápěstí',
        'Lehké vykloubení při gymnastice. Voltaren aplikován.', 60);
    await addRecord(8, 'Kroucení kotníku', 'Natažení kotníku při cvičen.', 45);
    await addRecord(8, 'Natažení svalů', 'Natažení svalů stehna.', 30);
    await addRecord(
        8, 'Dehydratace', 'Nedostatek tekutin po intenzivním cvičení.', 15);

    // Participant 9: Franz Kafka (13 records - existential)
    await addRecord(9, 'Existenciální úzkost',
        'Úzkost z táborové stravy. Doporučena konzultace.', 100);
    await addRecord(
        9, 'Existenciální úzkost 2', 'Pokračující úzkostné stavy.', 92);
    await addRecord(9, 'Existenciální úzkost 3',
        'Další vlna úzkosti. Rescue Remedy podána.', 85);
    await addRecord(
        9, 'Existenciální úzkost 4', 'Obavy z absurdity života v táboře.', 78);
    await addRecord(
        9, 'Nespavost', 'Potíže se spánkem. Melatonin doporučen.', 70);
    await addRecord(9, 'Nespavost 2', 'Pokračující problémy s usínáním.', 62);
    await addRecord(9, 'Nespavost 3', 'Třetí noc špatného spánku.', 54);
    await addRecord(
        9, 'Psychosomatická bolest břicha', 'Bolest bez fyzické příčiny.', 46);
    await addRecord(
        9, 'Psychosomatická bolest břicha 2', 'Opakující se bolesti.', 38);
    await addRecord(9, 'Bolest hlavy', 'Tenze bolest hlavy.', 30);
    await addRecord(9, 'Bolest hlavy 2', 'Další den bolesti hlavy.', 22);
    await addRecord(
        9, 'Obecná nevolnost', 'Celková nevolnost bez jasné diagnózy.', 14);
    await addRecord(
        9, 'Strach z jídla', 'Strach z konzumace táborové stravy.', 6);

    // Participant 10: Antonín Dvořák (8 records)
    await addRecord(10, 'Stesk po Novém světě',
        'Stesk po domově. Doporučena hudební terapie.', 88);
    await addRecord(10, 'Stesk 2', 'Pokračující stesk po domově.', 75);
    await addRecord(10, 'Nedostatek spánku', 'Komponoval v noci. Únava.', 68);
    await addRecord(
        10, 'Nedostatek spánku 2', 'Další noc málo spánku kvůli hudbě.', 58);
    await addRecord(10, 'Podvýživa',
        'Zapomíná jíst kvůli skládání. Multivitamin doporučen.', 48);
    await addRecord(10, 'Bolest hlavy', 'Bolest z přepracování.', 35);
    await addRecord(10, 'Bolest zad', 'Špatné držení těla při psaní not.', 25);
    await addRecord(
        10, 'Úzkost z vystoupení', 'Nervozita z táborového koncertu.', 10);

    // Participant 11: Václav Havel (1 record)
    await addRecord(11, 'Pohmoždění kolena',
        'Pád z improvizovaného jeviště při divadelní improvizaci.', 42);

    // Participant 12: Ema Destinnová (12 records - vocal drama)
    await addRecord(
        12, 'Bolest v krku', 'Přetížení hlasivek z nadměrného zpěvu.', 95);
    await addRecord(
        12, 'Bolest v krku 2', 'Pokračující problémy s hlasem.', 87);
    await addRecord(12, 'Bolest v krku 3', 'Třetí den bolesti v krku.', 79);
    await addRecord(12, 'Laryngitida', 'Zánět hrtanu. Hlasový klid nařen.', 71);
    await addRecord(12, 'Laryngitida 2', 'Pokračující laryngitida.', 63);
    await addRecord(12, 'Alergická reakce na pyl',
        'Kýchání a slzení. Cetirizin podán.', 55);
    await addRecord(12, 'Alergická reakce 2', 'Další alergická reakce.', 47);
    await addRecord(12, 'Dehydratace',
        'Nedostatek tekutin. Doporučeno zvýšení příjmu vody.', 39);
    await addRecord(
        12, 'Hlasový klid', 'Kontrola dodržování hlasového klidu.', 31);
    await addRecord(12, 'Úzkost', 'Nervozita z možného poškození hlasu.', 23);
    await addRecord(
        12, 'Dušnost', 'Dramatické potíže s dýcháním (psychosomatické).', 15);
    await addRecord(
        12, 'Porucha spánku', 'Potíže se spánkem z obav o hlas.', 7);

    // Participant 13: Jan Amos Komenský (4 records - teaching stress)
    await addRecord(13, 'Stres z organizace',
        'Přílišná snaha organizovat vzdělávací akce.', 65);
    await addRecord(13, 'Únava očí', 'Únava z tvorby vzdělávacích plánů.', 50);
    await addRecord(13, 'Opakované zatížení', 'RSI z nadměrného psaní.', 35);
    await addRecord(13, 'Stres 2', 'Pokračující stres z výuky druhých.', 18);

    // Participant 14: Bedřich Smetana (6 records - ear issues)
    await addRecord(14, 'In infekce ucha',
        'Zánět středního ucha. Otipax kapky předepsány.', 75);
    await addRecord(14, 'Infekce ucha 2', 'Pokračující problémy.', 65);
    await addRecord(
        14, 'Tinnitus', 'Pískání v uších. Kontrola doporučena.', 55);
    await addRecord(14, 'Test sluchu', 'Preventivní kontrola sluchu.', 45);
    await addRecord(14, 'Úzkost z řeky',
        'Strach z plynoucí řeky (vtl Vltava flashback).', 30);
    await addRecord(
        14, 'Pískání v uších', 'Stížnost na pískání. Monitorováno.', 15);
  }

  /// Creates medications for 6 participants.
  static Future<void> _createMedications(
    AppDatabase database,
    List<int> participantIds,
  ) async {
    // Participant 6: Milada Horáková - Ibalgin
    await database.addMedication(
      MedicationsCompanion(
        name: const Value('Ibalgin 400mg'),
        dosageTiming: const Value('Při bolesti'),
        dosage: const Value('1 tableta'),
        participantFK: Value(participantIds[6]),
        wasPrinted: const Value(false),
      ),
    );

    // Participant 8: Věra Čáslavská - Voltaren gel
    await database.addMedication(
      MedicationsCompanion(
        name: const Value('Voltaren gel'),
        dosageTiming: const Value('2x denně'),
        dosage: const Value('Aplikovat na zápěstí'),
        participantFK: Value(participantIds[8]),
        wasPrinted: const Value(false),
      ),
    );

    // Participant 9: Franz Kafka - Melatonin + Rescue Remedy
    await database.addMedication(
      MedicationsCompanion(
        name: const Value('Melatonin 3mg'),
        dosageTiming: const Value('Před spaním'),
        dosage: const Value('1 tableta'),
        participantFK: Value(participantIds[9]),
        wasPrinted: const Value(false),
      ),
    );
    await database.addMedication(
      MedicationsCompanion(
        name: const Value('Rescue Remedy kapky'),
        dosageTiming: const Value('Při úzkosti'),
        dosage: const Value('4 kapky pod jazyk'),
        participantFK: Value(participantIds[9]),
        wasPrinted: const Value(false),
      ),
    );

    // Participant 10: Antonín Dvořák - Multivitamin + Omega-3
    await database.addMedication(
      MedicationsCompanion(
        name: const Value('Multivitamin'),
        dosageTiming: const Value('Ráno'),
        dosage: const Value('1 tableta'),
        participantFK: Value(participantIds[10]),
        wasPrinted: const Value(false),
      ),
    );
    await database.addMedication(
      MedicationsCompanion(
        name: const Value('Omega-3'),
        dosageTiming: const Value('S jídlem'),
        dosage: const Value('1 kapsle'),
        participantFK: Value(participantIds[10]),
        wasPrinted: const Value(false),
      ),
    );

    // Participant 12: Ema Destinnová - Cetirizin + Pastilky
    await database.addMedication(
      MedicationsCompanion(
        name: const Value('Cetirizin 10mg'),
        dosageTiming: const Value('Večer'),
        dosage: const Value('1 tableta'),
        participantFK: Value(participantIds[12]),
        wasPrinted: const Value(false),
      ),
    );
    await database.addMedication(
      MedicationsCompanion(
        name: const Value('Hlasové pastilky'),
        dosageTiming: const Value('Dle potřeby'),
        dosage: const Value('Každé 3 hodiny'),
        participantFK: Value(participantIds[12]),
        wasPrinted: const Value(false),
      ),
    );

    // Participant 14: Bedřich Smetana - Otipax
    await database.addMedication(
      MedicationsCompanion(
        name: const Value('Otipax kapky do uší'),
        dosageTiming: const Value('2x denně'),
        dosage: const Value('3 kapky do každého ucha'),
        participantFK: Value(participantIds[14]),
        wasPrinted: const Value(false),
      ),
    );
  }

  /// Creates allergies and limitations for 9 participants.
  static Future<void> _createAllergiesLimitations(
    AppDatabase database,
    List<int> participantIds,
  ) async {
    // Participant 1: Božena Němcová - Bee sting allergy
    await database.addAllergiesLimitations(
      AllergiesLimitationsCompanion(
        description: const Value(
            'Včelí štípnutí (epipen není nutný, ale opatrnost vyžadována)'),
        type: const Value(1), // 1 = allergy
        participantFK: Value(participantIds[1]),
        wasPrinted: const Value(false),
      ),
    );

    // Participant 2: Jan Hus - Sunscreen requirement
    await database.addAllergiesLimitations(
      AllergiesLimitationsCompanion(
        description:
            const Value('Nutné používat opalovací krém SPF 50+ (citlivá kůže)'),
        type: const Value(2), // 2 = limitation
        participantFK: Value(participantIds[2]),
        wasPrinted: const Value(false),
      ),
    );

    // Participant 4: Alfons Mucha - Paint allergy + limitation
    await database.addAllergiesLimitations(
      AllergiesLimitationsCompanion(
        description: const Value('Alergie na malířské látky (barvy, ředidla)'),
        type: const Value(1),
        participantFK: Value(participantIds[4]),
        wasPrinted: const Value(false),
      ),
    );
    await database.addAllergiesLimitations(
      AllergiesLimitationsCompanion(
        description: const Value('Vyhnout se výtvarným aktivitám s barvami'),
        type: const Value(2),
        participantFK: Value(participantIds[4]),
        wasPrinted: const Value(false),
      ),
    );

    // Participant 5: Emil Zátopek - Running limitation
    await database.addAllergiesLimitations(
      AllergiesLimitationsCompanion(
        description: const Value(
            'Běh omezen na max. 30 minut denně (prevence přetížení svalů)'),
        type: const Value(2),
        participantFK: Value(participantIds[5]),
        wasPrinted: const Value(false),
      ),
    );

    // Participant 6: Milada Horáková - Latex allergy
    await database.addAllergiesLimitations(
      AllergiesLimitationsCompanion(
        description:
            const Value('Alergie na latex (používat nitrilové rukavice)'),
        type: const Value(1),
        participantFK: Value(participantIds[6]),
        wasPrinted: const Value(false),
      ),
    );

    // Participant 7: Jaroslav Seifert - Dust allergy
    await database.addAllergiesLimitations(
      AllergiesLimitationsCompanion(
        description: const Value('Alergie na prach (knihy, staré prostory)'),
        type: const Value(1),
        participantFK: Value(participantIds[7]),
        wasPrinted: const Value(false),
      ),
    );

    // Participant 8: Věra Čáslavská - Gymnastics limitation
    await database.addAllergiesLimitations(
      AllergiesLimitationsCompanion(
        description:
            const Value('Gymnastika omezena na 2 týdny (zranění zápěstí)'),
        type: const Value(2),
        participantFK: Value(participantIds[8]),
        wasPrinted: const Value(false),
      ),
    );

    // Participant 12: Ema Destinnová - Pollen allergy + Voice rest
    await database.addAllergiesLimitations(
      AllergiesLimitationsCompanion(
        description: const Value('Alergie na pyl (trávy, stromy)'),
        type: const Value(1),
        participantFK: Value(participantIds[12]),
        wasPrinted: const Value(false),
      ),
    );
    await database.addAllergiesLimitations(
      AllergiesLimitationsCompanion(
        description: const Value('Hlasový klid nutný (laryngitida)'),
        type: const Value(2),
        participantFK: Value(participantIds[12]),
        wasPrinted: const Value(false),
      ),
    );
  }
}
