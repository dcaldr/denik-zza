import 'package:denik_zza/database/drift_database/database.dart';
import 'package:drift/drift.dart';

import '../generators/participant_generator.dart';
import '../models/test_participant.dart';
import '../shared_infrastructure.dart';

/// Seeder for generated test datasets (medium, large, xlarge, stress).
///
/// Uses [ParticipantGenerator] to create participants dynamically.
/// The seed value ensures reproducible data generation.
///
/// ## Usage:
/// ```dart
/// // Large dataset (100 participants)
/// await GeneratedSeeder.seed(db, count: 100, seed: 42);
/// ```
class GeneratedSeeder {
  /// Seeds the database with generated participants.
  ///
  /// [count] - Number of participants to generate
  /// [seed] - Random seed for reproducibility (optional)
  /// [eventTitle] - Name of the event to create
  static Future<void> seed(
    AppDatabase database, {
    required int count,
    int? seed,
    String eventTitle = 'Testovací akce',
  }) async {
    try {
      // Step 1: Create infrastructure
      final insuranceMap = await createTestInsuranceCompanies(database);
      final paramedicIds = await createTestParamedics(database);
      final primaryParamedicId = paramedicIds.first;

      // Step 2: Create event
      final now = DateTime.now();
      final eventId = await createTestEvent(
        database,
        title: eventTitle,
        description: 'Automaticky generovaná testovací akce ($count účastníků)',
        dateFrom: now,
        dateTo: now.add(const Duration(days: 14)),
      );

      // Step 3: Generate participants
      final generator = ParticipantGenerator(seed: seed);
      final participants = generator.generate(count: count);

      // Step 4: Insert participants with related data
      final baseTime = DateTime.now();

      for (final participant in participants) {
        await _insertParticipant(
          database,
          participant,
          eventId,
          insuranceMap,
          primaryParamedicId,
          baseTime,
        );
      }

      // Step 5: Set current event
      await database.updateCache(
        CacheCompanion(
          id: const Value(1),
          currentActionID: Value(eventId),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Seeds for medium profile (50 participants).
  static Future<void> seedMedium(AppDatabase database) async {
    await seed(database, count: 50, seed: 50, eventTitle: 'Střední tábor');
  }

  /// Seeds for large profile (100 participants).
  static Future<void> seedLarge(AppDatabase database) async {
    await seed(database, count: 100, seed: 100, eventTitle: 'Velký tábor');
  }

  /// Seeds for xlarge profile (130 participants).
  static Future<void> seedXLarge(AppDatabase database) async {
    await seed(database,
        count: 130, seed: 130, eventTitle: 'Extra velký tábor');
  }

  /// Seeds for stress profile (300 participants).
  static Future<void> seedStress(AppDatabase database) async {
    await seed(database, count: 300, seed: 300, eventTitle: 'Stress test akce');
  }

  static Future<void> _insertParticipant(
    AppDatabase database,
    TestParticipant participant,
    int eventId,
    Map<String, int> insuranceMap,
    int paramedicId,
    DateTime baseTime,
  ) async {
    // Resolve insurance
    final insuranceId = insuranceMap[participant.pojistovna] ??
        insuranceMap[insuranceShortNames[participant.pojistovna]];

    // Insert participant
    final participantId = await database.addParticipant(
      participant.toCompanion(eventId, insuranceId),
    );

    // Insert medications
    for (final lek in participant.leky) {
      await database.addMedication(lek.toCompanion(participantId));
    }

    // Insert restrictions
    for (final omezeni in participant.omezeni) {
      await database
          .addAllergiesLimitations(omezeni.toCompanion(participantId));
    }

    // Insert records
    for (final zaznam in participant.zaznamy) {
      await database.addRecord(
        zaznam.toCompanion(participantId, paramedicId, baseTime),
      );
    }
  }
}
