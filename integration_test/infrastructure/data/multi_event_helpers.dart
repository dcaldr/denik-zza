import 'package:denik_zza/database/drift_database/database.dart';
import 'package:drift/drift.dart';

import 'shared_infrastructure.dart';

/// Helpers for testing multi-event scenarios (isolation, data pollution).
class MultiEventHelpers {
  /// Creates multiple independent events for isolation testing.
  ///
  /// Returns a list of created event IDs.
  ///
  /// Usage:
  /// ```dart
  /// final eventIds = await MultiEventHelpers.createMultipleEvents(db, count: 3);
  /// ```
  static Future<List<int>> createMultipleEvents(
    AppDatabase db, {
    required int count,
    String baseTitle = 'Izolovaný turnus',
  }) async {
    final eventIds = <int>[];
    final now = DateTime.now();

    for (int i = 1; i <= count; i++) {
      final id = await createTestEvent(
        db,
        title: '$baseTitle $i',
        description: 'Automaticky generovaný event pro test izolace dat #$i',
        dateFrom: now.add(Duration(days: i * 7)), // Staggered dates
        dateTo: now.add(Duration(days: i * 7 + 6)),
      );
      eventIds.add(id);
    }
    return eventIds;
  }

  /// Reassigns a list of participants to a specific event.
  ///
  /// Used to move participants between events to test data persistence
  /// or to set up initial state for specific isolation tests.
  static Future<void> reassignParticipants(
    AppDatabase db, {
    required List<int> participantIds,
    required int targetEventId,
  }) async {
    await (db.update(db.participants)
          ..where((tbl) => tbl.id.isIn(participantIds)))
        .write(ParticipantsCompanion(
      zzaActionFK: Value(targetEventId),
    ));
  }

  /// Distributes participants evenly across a list of events.
  ///
  /// Useful for setting up a scenario where multiple events happen simultaneously.
  static Future<void> distributeParticipantsEvenly(
    AppDatabase db, {
    required List<int> participantIds,
    required List<int> eventIds,
  }) async {
    if (participantIds.isEmpty || eventIds.isEmpty) return;

    final batchSize = (participantIds.length / eventIds.length).ceil();

    for (int i = 0; i < eventIds.length; i++) {
      final eventId = eventIds[i];
      final start = i * batchSize;
      if (start >= participantIds.length) break;

      final end = (start + batchSize < participantIds.length)
          ? start + batchSize
          : participantIds.length;

      final batch = participantIds.sublist(start, end);
      await reassignParticipants(db,
          participantIds: batch, targetEventId: eventId);
    }
  }
}
