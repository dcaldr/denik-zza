import 'package:denik_zza/database/drift_database/database.dart';
import 'package:drift/drift.dart';

import '../datasets/jursky_park_data.dart';
import '../shared_infrastructure.dart';

/// Seeder for the "Jurský park" standard test dataset.
///
/// This seeder uses the unified TestParticipant format from [jurskyParkParticipants]
/// and converts them to database records using [toCompanion()] methods.
///
/// ## Generated Data:
/// - 1 Event: "Jurský park" (July 10-24, 2025)
/// - 2 Paramedics (from shared infrastructure)
/// - 5 Insurance Companies (4 real + 1 fake)
/// - 15 Participants: Czech historical figures (ages 10-16)
/// - Medical records: 0-13 per participant (64 total)
/// - Medications, allergies, limitations
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
      // Step 1: Create insurance companies
      final insuranceMap = await createTestInsuranceCompanies(database);

      // Step 2: Create paramedics
      final paramedicIds = await createTestParamedics(database);
      final primaryParamedicId = paramedicIds.first;

      // Step 3: Create event
      final eventId = await createTestEvent(
        database,
        title: jurskyParkEvent.title,
        description: jurskyParkEvent.description,
        dateFrom: DateTime.parse(jurskyParkEvent.dateFrom),
        dateTo: DateTime.parse(jurskyParkEvent.dateTo),
        homeDirectory: jurskyParkEvent.homeDirectory,
      );

      // Step 4: Create participants with all related data
      final baseTime = DateTime.now();

      for (final participant in jurskyParkParticipants) {
        // Resolve insurance ID from name
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

        // Insert restrictions (allergies + limitations)
        for (final omezeni in participant.omezeni) {
          await database
              .addAllergiesLimitations(omezeni.toCompanion(participantId));
        }

        // Insert medical records
        for (final zaznam in participant.zaznamy) {
          await database.addRecord(
            zaznam.toCompanion(participantId, primaryParamedicId, baseTime),
          );
        }
      }

      // Step 5: Set current event
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
}
