import 'package:flutter_test/flutter_test.dart';

import '../helpers/db_verification_helpers.dart';
import 'models/test_participant.dart';
import 'models/test_record.dart';
import 'models/test_restriction.dart';

/// Mutable tracker of expected DB state across E2E test phases.
///
/// Initialized from a `const` dataset (e.g., [jurskyParkParticipants]),
/// creates mutable copies that evolve as the test performs mutations.
///
/// ## Mutation Policy
/// Apply mutations **at phase boundaries**, not inline with robot actions,
/// to avoid "blind spot" failures where both the app action and the tracker
/// update are skipped together.
///
/// ## Usage:
/// ```dart
/// final world = ExpectedWorldState(jurskyParkParticipants);
///
/// // Phase 1: participants are as registered (prisel: false)
///
/// // Phase 2: declare what intake SHOULD have produced
/// for (int i = 0; i < 15; i++) {
///   if (i == 3) continue; // Tomáš: save-only
///   world.markArrived(i);
/// }
/// world.setNote(1, 'Intake note...');
/// world.addRestriction(2, TestRestriction.omezeni('...'));
///
/// // Verify at phase boundary
/// await world.verifyAll(dbHelpers);
/// ```
class ExpectedWorldState {
  final List<TestParticipant> participants;

  /// Initialize from const dataset — creates mutable copies via copyWith.
  ExpectedWorldState(List<TestParticipant> dataset)
      : participants = dataset.map((p) => p.copyWith()).toList();

  // ==================== Mutation Methods ====================

  /// Mark participant as arrived (prisel: true)
  void markArrived(int index) =>
      participants[index] = participants[index].copyWith(prisel: true);

  /// Mark participant as NOT arrived (prisel: false) — e.g., save-only
  void markNotArrived(int index) =>
      participants[index] = participants[index].copyWith(prisel: false);

  /// Set participant note (full expected value, not partial)
  void setNote(int index, String note) =>
      participants[index] = participants[index].copyWith(poznamka: note);

  /// Append restriction to participant
  void addRestriction(int index, TestRestriction r) =>
      participants[index] = participants[index]
          .copyWith(omezeni: [...participants[index].omezeni, r]);

  /// Append medical record to participant
  void addRecord(int index, TestRecord r) =>
      participants[index] = participants[index]
          .copyWith(zaznamy: [...participants[index].zaznamy, r]);

  /// Set způsobilost (fitness certificate)
  void setZpusobilost(int index, bool value) =>
      participants[index] = participants[index].copyWith(zpusobilost: value);

  /// Set bezinfekčnost (infection-free certificate)
  void setBezinfekcnost(int index, bool value) =>
      participants[index] = participants[index].copyWith(bezinfekcnost: value);

  /// Mark participant as printed
  void markPrinted(int index) =>
      participants[index] = participants[index].copyWith(wasPrinted: true);

  // ==================== Verification ====================

  /// One-liner integrity check — verifies ALL participants against DB.
  ///
  /// Calls [DbVerificationHelpers.verifyCompleteParticipant] per participant,
  /// which checks all fields, medications, restrictions, and records.
  Future<void> verifyAll(DbVerificationHelpers dbHelpers) async {
    for (final p in participants) {
      await dbHelpers.verifyCompleteParticipant(p);
    }
  }

  /// Optional: 3-way check — verify tracked state against manual snapshot.
  ///
  /// Enables independent validation that the tracker itself is correct.
  /// Pass empty list to skip (non-existence does not break anything).
  // TODO: Expand to compare all fields when manual snapshots are authored.
  void verifyAgainst(List<TestParticipant> snapshot) {
    if (snapshot.isEmpty) return;
    expect(participants.length, snapshot.length,
        reason: 'Snapshot size mismatch');
    for (int i = 0; i < participants.length; i++) {
      final p = participants[i];
      final s = snapshot[i];
      expect(p.prisel, s.prisel,
          reason: '${p.fullName}: prisel tracker≠snapshot');
      expect(p.poznamka, s.poznamka,
          reason: '${p.fullName}: poznamka tracker≠snapshot');
      expect(p.wasPrinted, s.wasPrinted,
          reason: '${p.fullName}: wasPrinted tracker≠snapshot');
    }
  }
}
