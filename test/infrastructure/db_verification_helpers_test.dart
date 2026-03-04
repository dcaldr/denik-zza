import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/database/database_interface.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_akce.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_lek.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_omezeni.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/input/file_manager.dart';
import '../../integration_test/infrastructure/helpers/db_verification_helpers.dart';
import '../../integration_test/infrastructure/data/models/test_participant.dart';
import '../../integration_test/infrastructure/data/models/test_medication.dart';
import '../../integration_test/infrastructure/data/models/test_restriction.dart';
import '../../integration_test/infrastructure/data/models/test_record.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseInterface db;
  late DbVerificationHelpers helpers;

  setUp(() async {
    db = DatabaseWrapper.getDatabase();
    helpers = DbVerificationHelpers(db);

    // Create event and set as current for participant operations.
    final now = DateTime.now();
    await db.addEvent(
      MemoryAction(
        idAkce: null,
        nadpis: 'DB Verification Event',
        popis: 'Test event for DbVerificationHelpers',
        odkdy: now,
        dokdy: now.add(const Duration(days: 1)),
        domovskyAdresarPath: FileManager().eventDir?.path,
      ),
    );
    final events = await db.getAllZzaActions();
    final eventId = events.last.idAkce;
    expect(eventId, isNotNull);
    await db.updateCurrentEvent(eventId);
  });

  test('verifyCompleteParticipant checks all provided fields', () async {
    final osoba = MemoryOsoba.fullNamed(
      id: null,
      jmeno: 'Test',
      prijmeni: 'Verifier',
      pohlavi: 1,
      adresa: 'Ulice 1',
      cisloPojisteni: '900101/1234',
      datumNarozeni: DateTime(1990, 1, 1),
      jmenoRodice: 'Rodič Test',
      telefonRodice: '+420600111222',
      emailRodice: 'rodic@example.com',
      zpusobilost: true,
      bezinfekcnost: false,
      wasPrinted: false,
      zdravotniPojistovna: 'VZP',
      oddil: 'Oddíl A',
      poznamka: 'Poznámka',
      prisel: true,
      potvrzeniPath: 'path/to/confirmation.pdf',
    );

    final participantId = await db.addOsobaAndReturnId(osoba);
    expect(participantId, isNotNull);

    await db.addLek(MemoryLek.fullNamed(
      id: null,
      nazev: 'Ibalgin 400mg',
      popisDavkovani: '1 tableta',
      idOsoby: participantId!,
      wasPrinted: false,
    ));
    await db.addOmezeni(MemoryOmezeni(
      omezeni: 'Alergie na pyl',
      typOmezeni: 2,
      idOsoby: participantId,
    ));

    final testData = TestParticipant(
      jmeno: 'Test',
      prijmeni: 'Verifier',
      pohlavi: 1,
      datumNarozeni: '1990-01-01',
      rodneCislo: '900101/1234',
      adresa: 'Ulice 1',
      telefonRodice: '+420600111222',
      emailRodice: 'rodic@example.com',
      jmenoRodice: 'Rodič Test',
      pojistovna: 'VZP',
      leky: const [
        TestMedication(nazev: 'Ibalgin 400mg', davkovani: '1 tableta'),
      ],
      omezeni: const [
        TestRestriction.alergie('Alergie na pyl'),
      ],
      bezinfekcnost: false,
      zpusobilost: true,
      prisel: true,
    );

    await helpers.verifyCompleteParticipant(testData);
  });

  test('verifyCompleteParticipant fails on RC mismatch', () async {
    final osoba = MemoryOsoba.fullNamed(
      id: null,
      jmeno: 'Test',
      prijmeni: 'Mismatch',
      pohlavi: 2,
      adresa: 'Ulice 2',
      cisloPojisteni: '915101/5678',
      datumNarozeni: DateTime(1991, 5, 1),
      jmenoRodice: 'Rodič',
      telefonRodice: '+420600333444',
      emailRodice: 'rodic2@example.com',
      zpusobilost: true,
      bezinfekcnost: true,
      wasPrinted: false,
      zdravotniPojistovna: 'OZP',
      oddil: 'Oddíl B',
      poznamka: 'Poznámka 2',
      prisel: true,
      potvrzeniPath: 'path/to/confirmation2.pdf',
    );

    final participantId = await db.addOsobaAndReturnId(osoba);
    expect(participantId, isNotNull);

    final badData = TestParticipant(
      jmeno: 'Test',
      prijmeni: 'Mismatch',
      pohlavi: 2,
      datumNarozeni: '1991-05-01',
      rodneCislo: '999999/9999',
      adresa: 'Ulice 2',
      telefonRodice: '+420600333444',
      emailRodice: 'rodic2@example.com',
      jmenoRodice: 'Rodič',
      pojistovna: 'OZP',
      bezinfekcnost: true,
      zpusobilost: true,
      prisel: true,
    );

    await expectLater(
      helpers.verifyCompleteParticipant(badData),
      throwsA(isA<TestFailure>()),
    );
  });

  test('verifyCompleteParticipant fails when restriction missing', () async {
    final osoba = MemoryOsoba.fullNamed(
      id: null,
      jmeno: 'Test',
      prijmeni: 'Restriction',
      pohlavi: 1,
      adresa: 'Ulice 3',
      cisloPojisteni: '920101/2222',
      datumNarozeni: DateTime(1992, 1, 1),
      jmenoRodice: 'Rodič R',
      telefonRodice: '+420600555666',
      emailRodice: 'rodic3@example.com',
      zpusobilost: true,
      bezinfekcnost: false,
      wasPrinted: false,
      zdravotniPojistovna: 'VZP',
      oddil: 'Oddíl C',
      poznamka: 'Poznámka 3',
      prisel: true,
      potvrzeniPath: 'path/to/confirmation3.pdf',
    );

    final participantId = await db.addOsobaAndReturnId(osoba);
    expect(participantId, isNotNull);

    // Add a different restriction than expected
    await db.addOmezeni(MemoryOmezeni(
      omezeni: 'Alergie na prach',
      typOmezeni: 2,
      idOsoby: participantId!,
    ));

    final badData = TestParticipant(
      jmeno: 'Test',
      prijmeni: 'Restriction',
      pohlavi: 1,
      datumNarozeni: '1992-01-01',
      rodneCislo: '920101/2222',
      adresa: 'Ulice 3',
      telefonRodice: '+420600555666',
      emailRodice: 'rodic3@example.com',
      jmenoRodice: 'Rodič R',
      pojistovna: 'VZP',
      omezeni: const [
        TestRestriction.alergie('Alergie na pyl'),
      ],
      bezinfekcnost: false,
      zpusobilost: true,
      prisel: true,
    );

    await expectLater(
      helpers.verifyCompleteParticipant(badData),
      throwsA(isA<TestFailure>()),
    );
  });

  test('verifyMedications fails when meds missing', () async {
    final osoba = MemoryOsoba.fullNamed(
      id: null,
      jmeno: 'Test',
      prijmeni: 'NoMeds',
      pohlavi: 1,
      adresa: 'Ulice 4',
      cisloPojisteni: '930101/3333',
      datumNarozeni: DateTime(1993, 1, 1),
      jmenoRodice: 'Rodič M',
      telefonRodice: '+420600777888',
      emailRodice: 'rodic4@example.com',
      zpusobilost: true,
      bezinfekcnost: true,
      wasPrinted: false,
      zdravotniPojistovna: 'VZP',
      oddil: 'Oddíl D',
      poznamka: 'Poznámka 4',
      prisel: true,
      potvrzeniPath: 'path/to/confirmation4.pdf',
    );

    final participantId = await db.addOsobaAndReturnId(osoba);
    expect(participantId, isNotNull);

    await expectLater(
      helpers.verifyMedications(
        participantId: participantId!,
        expectedMedications: const [
          TestMedication(nazev: 'Ibalgin 400mg'),
        ],
        participantName: 'Test NoMeds',
      ),
      throwsA(isA<TestFailure>()),
    );
  });

  test('verifyRestrictions fails when restrictions missing', () async {
    final osoba = MemoryOsoba.fullNamed(
      id: null,
      jmeno: 'Test',
      prijmeni: 'NoRestrictions',
      pohlavi: 2,
      adresa: 'Ulice 5',
      cisloPojisteni: '940101/4444',
      datumNarozeni: DateTime(1994, 1, 1),
      jmenoRodice: 'Rodič R',
      telefonRodice: '+420600999000',
      emailRodice: 'rodic5@example.com',
      zpusobilost: true,
      bezinfekcnost: false,
      wasPrinted: false,
      zdravotniPojistovna: 'OZP',
      oddil: 'Oddíl E',
      poznamka: 'Poznámka 5',
      prisel: true,
      potvrzeniPath: 'path/to/confirmation5.pdf',
    );

    final participantId = await db.addOsobaAndReturnId(osoba);
    expect(participantId, isNotNull);

    await expectLater(
      helpers.verifyRestrictions(
        participantId: participantId!,
        expectedRestrictions: const [
          TestRestriction.alergie('Alergie na pyl'),
        ],
        participantName: 'Test NoRestrictions',
      ),
      throwsA(isA<TestFailure>()),
    );
  });

  test('verifyRecords fails when records missing', () async {
    final osoba = MemoryOsoba.fullNamed(
      id: null,
      jmeno: 'Test',
      prijmeni: 'NoRecords',
      pohlavi: 1,
      adresa: 'Ulice 6',
      cisloPojisteni: '950101/5555',
      datumNarozeni: DateTime(1995, 1, 1),
      jmenoRodice: 'Rodič Z',
      telefonRodice: '+420601111222',
      emailRodice: 'rodic6@example.com',
      zpusobilost: true,
      bezinfekcnost: true,
      wasPrinted: false,
      zdravotniPojistovna: 'VZP',
      oddil: 'Oddíl F',
      poznamka: 'Poznámka 6',
      prisel: true,
      potvrzeniPath: 'path/to/confirmation6.pdf',
    );

    final participantId = await db.addOsobaAndReturnId(osoba);
    expect(participantId, isNotNull);

    await expectLater(
      helpers.verifyRecords(
        participantId: participantId!,
        expectedRecords: const [
          TestRecord(
            nazev: 'Bolest hlavy',
            popis: 'Test popis',
          ),
        ],
      ),
      throwsA(isA<TestFailure>()),
    );
  });
}
