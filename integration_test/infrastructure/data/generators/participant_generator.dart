import 'dart:math';

import 'package:denik_zza/input/rodne_cislo.dart';

import '../models/test_medication.dart';
import '../models/test_participant.dart';
import '../models/test_record.dart';
import '../models/test_restriction.dart';
import 'name_pools.dart';

/// Generator for creating large test participant datasets.
///
/// Used for medium (50p), large (100p), xlarge (130p), and stress (300p)
/// volume tiers. Generates participants with:
/// - Valid rodné číslo (via [RodneCislo.generateForDate])
/// - Ages 10-16
/// - Random medical data (records, medications, allergies)
/// - ~35% parent contact coverage
///
/// ## Usage:
/// ```dart
/// final generator = ParticipantGenerator(seed: 42); // Reproducible
/// final participants = generator.generate(count: 100);
/// ```
class ParticipantGenerator {
  final Random _random;
  final int _baseYear;

  /// Creates a generator with optional seed for reproducibility.
  ///
  /// [seed] - Random seed for reproducible generation
  /// [baseYear] - Reference year for age calculation (default: 2025)
  ParticipantGenerator({int? seed, int baseYear = 2025})
      : _random = seed != null ? Random(seed) : Random(),
        _baseYear = baseYear;

  /// Generates a list of [count] test participants.
  ///
  /// Participants have:
  /// - Unique names (with suffix if duplicates: "Jan Novák2")
  /// - Valid rodné číslo for their birthdate
  /// - Ages 10-16
  /// - 0-10 records (mostly), up to 35 (rare)
  /// - ~35% chance of parent contact
  /// - Random medications, allergies, limitations
  List<TestParticipant> generate({required int count}) {
    final participants = <TestParticipant>[];
    final usedNames = <String, int>{};

    for (int i = 0; i < count; i++) {
      final isFemale = _random.nextBool();
      final firstName = _pickFirst(isFemale);
      final lastName = _pickLast();

      // Handle duplicate names with suffix
      final baseName = '$firstName $lastName';
      final occurrence = (usedNames[baseName] ?? 0) + 1;
      usedNames[baseName] = occurrence;

      final displayFirstName =
          occurrence > 1 ? '$firstName$occurrence' : firstName;

      // Generate birthdate (age 10-16)
      final age = 10 + _random.nextInt(7); // 10-16
      final birthYear = _baseYear - age;
      final birthMonth = 1 + _random.nextInt(12);
      final birthDay = 1 + _random.nextInt(28);
      final birthDate = DateTime(birthYear, birthMonth, birthDay);

      // Generate valid rodné číslo
      final rc = RodneCislo.generateForDate(birthDate, isFemale: isFemale);

      // Generate address (~80% have address)
      String? adresa;
      if (_random.nextDouble() < 0.8) {
        adresa = _generateAddress();
      }

      // Generate parent contact (~35%)
      String? telefonRodice;
      if (_random.nextDouble() < 0.35) {
        telefonRodice = _generatePhone();
      }

      // Pick insurance
      final pojistovna = _pickInsurance();

      // Generate medical data
      final leky = _generateMedications();
      final omezeni = _generateRestrictions();
      final zaznamy = _generateRecords();

      participants.add(TestParticipant(
        jmeno: displayFirstName,
        prijmeni: lastName,
        pohlavi: isFemale ? 2 : 1,
        datumNarozeni:
            '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}',
        rodneCislo: rc.getRc(),
        adresa: adresa,
        telefonRodice: telefonRodice,
        pojistovna: pojistovna,
        leky: leky,
        omezeni: omezeni,
        zaznamy: zaznamy,
      ));
    }

    return participants;
  }

  String _pickFirst(bool isFemale) {
    final pool = isFemale ? czechFirstNamesFemale : czechFirstNamesMale;
    return pool[_random.nextInt(pool.length)];
  }

  String _pickLast() {
    return czechLastNames[_random.nextInt(czechLastNames.length)];
  }

  String _generateAddress() {
    final street = czechStreets[_random.nextInt(czechStreets.length)];
    final number = 1 + _random.nextInt(200);
    final city = czechCities[_random.nextInt(czechCities.length)];
    return '$street $number, $city';
  }

  String _generatePhone() {
    final prefix = '+4206';
    final rest = List.generate(8, (_) => _random.nextInt(10)).join();
    return '$prefix$rest';
  }

  String _pickInsurance() {
    // Weighted: VZP most common
    final roll = _random.nextDouble();
    if (roll < 0.5) return 'VZP';
    if (roll < 0.75) return 'OZP';
    if (roll < 0.9) return 'ČPZP';
    return 'ZPŠ';
  }

  List<TestMedication> _generateMedications() {
    // ~20% chance of having medications
    if (_random.nextDouble() > 0.2) return [];

    final count = 1 + _random.nextInt(3); // 1-3 medications
    return List.generate(count, (_) {
      final nazev =
          commonMedications[_random.nextInt(commonMedications.length)];
      return TestMedication(
        nazev: nazev,
        davkovani: _random.nextBool() ? '1 tableta' : null,
        kdy: _random.nextBool() ? 'Dle potřeby' : null,
      );
    });
  }

  List<TestRestriction> _generateRestrictions() {
    final restrictions = <TestRestriction>[];

    // ~15% chance of allergy
    if (_random.nextDouble() < 0.15) {
      final allergy = commonAllergies[_random.nextInt(commonAllergies.length)];
      restrictions.add(TestRestriction.alergie('Alergie na $allergy'));
    }

    // ~10% chance of limitation
    if (_random.nextDouble() < 0.10) {
      final limitation =
          commonLimitations[_random.nextInt(commonLimitations.length)];
      restrictions.add(TestRestriction.omezeni(limitation));
    }

    return restrictions;
  }

  List<TestRecord> _generateRecords() {
    // Weighted record count: mostly 0-10, rare up to 35
    final roll = _random.nextDouble();
    int count;
    if (roll < 0.15) {
      count = 0; // 15% have 0 records
    } else if (roll < 0.85) {
      count = _random.nextInt(11); // 70% have 0-10
    } else if (roll < 0.95) {
      count = 11 + _random.nextInt(10); // 10% have 11-20
    } else {
      count = 21 + _random.nextInt(15); // 5% have 21-35
    }

    if (count == 0) return [];

    return List.generate(count, (i) {
      final title = recordTitles[_random.nextInt(recordTitles.length)];
      final desc =
          recordDescriptions[_random.nextInt(recordDescriptions.length)];
      final hoursAgo = _random.nextInt(168); // Up to 1 week ago

      return TestRecord(
        nazev: title,
        popis: desc,
        hoursAgo: hoursAgo,
        teplota:
            _random.nextDouble() < 0.1 ? 36.0 + _random.nextDouble() * 3 : null,
      );
    });
  }
}
