import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:denik_zza/print_ops2/print_center_service.dart';
import 'package:denik_zza/print_ops2/generate_pdf_template.dart';
import 'package:denik_zza/print_ops2/models/person_print_state.dart';
import 'package:denik_zza/print_ops2/models/toggle_impact.dart';
import 'package:denik_zza/utils/record_sort_utils.dart';
import 'package:denik_zza/utils/app_logger.dart';

/// Controller for manual print state management.
///
/// Allows users to manually toggle isPrinted/wasPrinted flags
/// as a fallback when automatic tracking produces incorrect state.
/// Maintains the contiguous-prefix invariant via cascade logic.
class PrintStateController extends ChangeNotifier {
  final PrintCenterService _service;

  PrintStateController(this._service);

  // State
  List<PersonPrintState> _personStates = [];
  bool _loading = false;
  String? _error;

  // Getters
  List<PersonPrintState> get personStates => _personStates;
  bool get loading => _loading;
  String? get error => _error;

  /// Loads all participants and their records for the current event.
  Future<void> loadParticipants() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final participants = await _service
          .watchCurrentEventParticipants()
          .first;

      final states = <PersonPrintState>[];
      for (final person in participants) {
        final records = await _service.getRecords(person.id);
        sortRecordsByTime(records);
        sortRecordsByTime(records);
        states.add(_buildPersonState(person, records));
      }

      _personStates = states;
    } catch (e) {
      AppLogger.l.e('Failed to load participants for print state management', error: e);
      _error = 'Nepodařilo se načíst účastníky: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Toggles a person's wasPrinted flag.
  ///
  /// When setting to false, cascades: all records are also set to false
  /// (append is impossible without a printed header).
  Future<void> togglePersonPrinted(int personId) async {
    final stateIdx = _personStates.indexWhere((s) => s.person.id == personId);
    if (stateIdx == -1) return;

    final state = _personStates[stateIdx];
    final newValue = !(state.person.wasPrinted ?? false);

    // Persist person flag
    final success = await _service.setParticipantPrintedFlag(personId, newValue);
    if (!success) {
      AppLogger.l.e('Failed to toggle person printed flag for id=$personId');
      return;
    }

    // Update local model
    state.person.wasPrinted = newValue;

    // Cascade: if setting person to unprinted, all records must also be unprinted
    if (!newValue && state.records.any((r) => r.isPrinted)) {
      final printedIds = state.records
          .where((r) => r.isPrinted)
          .map((r) => r.idZaznamu)
          .toList();
      await _service.setMultipleRecordPrintedFlags(printedIds, false);
      for (final r in state.records) {
        r.isPrinted = false;
      }
    }

    // Rebuild state for this person
    _personStates[stateIdx] = _buildPersonState(state.person, state.records);
    notifyListeners();
  }

  /// Toggles a record's isPrinted flag with cascade logic.
  ///
  /// - Setting to FALSE: all chronologically-later printed records are also
  ///   set to false (maintains contiguous prefix).
  /// - Setting to TRUE: only succeeds if all chronologically-earlier records
  ///   are already printed. Returns false if precondition not met.
  Future<bool> toggleRecordPrinted(int personId, int recordId) async {
    final stateIdx = _personStates.indexWhere((s) => s.person.id == personId);
    if (stateIdx == -1) return false;

    final state = _personStates[stateIdx];
    final records = state.records; // already sorted by time
    final recordIdx = records.indexWhere((r) => r.idZaznamu == recordId);
    if (recordIdx == -1) return false;

    final record = records[recordIdx];
    final newValue = !record.isPrinted;

    if (newValue) {
      // MARKING AS PRINTED: check all earlier records are printed
      for (int i = 0; i < recordIdx; i++) {
        if (!records[i].isPrinted) {
          // Cannot mark as printed — earlier records are unprinted
          return false;
        }
      }

      // Persist
      final success = await _service.setRecordPrintedFlag(recordId, true);
      if (!success) return false;
      record.isPrinted = true;

    } else {
      // MARKING AS UNPRINTED: cascade all later printed records
      final idsToUnprint = <int>[recordId];
      for (int i = recordIdx + 1; i < records.length; i++) {
        if (records[i].isPrinted) {
          idsToUnprint.add(records[i].idZaznamu);
        }
      }

      await _service.setMultipleRecordPrintedFlags(idsToUnprint, false);
      for (final r in records) {
        if (idsToUnprint.contains(r.idZaznamu)) {
          r.isPrinted = false;
        }
      }
    }

    // Rebuild state for this person
    _personStates[stateIdx] = _buildPersonState(state.person, records);
    notifyListeners();
    return true;
  }

  /// Previews what toggling a record would do WITHOUT persisting.
  ///
  /// Returns a [ToggleImpact] describing cascade effects and resulting state.
  ToggleImpact previewToggleImpact(int personId, int recordId) {
    final stateIdx = _personStates.indexWhere((s) => s.person.id == personId);
    if (stateIdx == -1) return const ToggleImpact.none();

    final state = _personStates[stateIdx];
    final records = state.records;
    final recordIdx = records.indexWhere((r) => r.idZaznamu == recordId);
    if (recordIdx == -1) return const ToggleImpact.none();

    final record = records[recordIdx];
    final newValue = !record.isPrinted;

    if (newValue) {
      // Marking as printed — check if earlier records block it
      bool blocked = false;
      for (int i = 0; i < recordIdx; i++) {
        if (!records[i].isPrinted) {
          blocked = true;
          break;
        }
      }
      // No cascade when marking as printed
      return ToggleImpact(
        affectedRecordCount: 0,
        affectedRecordIds: const [],
        appendStillPossible: !blocked && (state.person.wasPrinted ?? false),
        requiresFullReprint: blocked,
      );
    } else {
      // Marking as unprinted — find cascade targets
      final cascadeIds = <int>[];
      for (int i = recordIdx + 1; i < records.length; i++) {
        if (records[i].isPrinted) {
          cascadeIds.add(records[i].idZaznamu);
        }
      }

      // Simulate: will append still be possible?
      // After toggle, the printed prefix ends before recordIdx
      final personPrinted = state.person.wasPrinted ?? false;
      final appendPossible = personPrinted;

      return ToggleImpact(
        affectedRecordCount: cascadeIds.length,
        affectedRecordIds: cascadeIds,
        appendStillPossible: appendPossible,
        requiresFullReprint: false,
      );
    }
  }

  /// Marks all records as printed for a person.
  Future<void> markAllPrintedForPerson(int personId) async {
    final stateIdx = _personStates.indexWhere((s) => s.person.id == personId);
    if (stateIdx == -1) return;

    final state = _personStates[stateIdx];

    // Mark person as printed
    if (!(state.person.wasPrinted ?? false)) {
      await _service.setParticipantPrintedFlag(personId, true);
      state.person.wasPrinted = true;
    }

    // Mark all records as printed
    final unprintedIds = state.records
        .where((r) => !r.isPrinted)
        .map((r) => r.idZaznamu)
        .toList();
    if (unprintedIds.isNotEmpty) {
      await _service.setMultipleRecordPrintedFlags(unprintedIds, true);
      for (final r in state.records) {
        r.isPrinted = true;
      }
    }

    _personStates[stateIdx] = _buildPersonState(state.person, state.records);
    notifyListeners();
  }

  /// Resets all print flags for a person (person + all records to unprinted).
  Future<void> resetAllForPerson(int personId) async {
    final stateIdx = _personStates.indexWhere((s) => s.person.id == personId);
    if (stateIdx == -1) return;

    final state = _personStates[stateIdx];

    // Reset person
    await _service.setParticipantPrintedFlag(personId, false);
    state.person.wasPrinted = false;

    // Reset all records
    final printedIds = state.records
        .where((r) => r.isPrinted)
        .map((r) => r.idZaznamu)
        .toList();
    if (printedIds.isNotEmpty) {
      await _service.setMultipleRecordPrintedFlags(printedIds, false);
      for (final r in state.records) {
        r.isPrinted = false;
      }
    }

    _personStates[stateIdx] = _buildPersonState(state.person, state.records);
    notifyListeners();
  }

  /// Builds a [PersonPrintState] with computed append status.
  PersonPrintState _buildPersonState(MemoryOsoba person, List<MemoryZaznam> records) {
    // Use GeneratePdfTemplate to check append status (same logic as print flow)
    final template = GeneratePdfTemplate.named(
      osoba: person,
      zaznamList: List.of(records),
    );
    final canAppend = template.canAppend();

    // Check for sequence issues: any printed record after an unprinted one
    bool hasSequenceIssue = false;
    bool seenUnprinted = false;
    for (final r in records) {
      if (!r.isPrinted) {
        seenUnprinted = true;
      } else if (seenUnprinted) {
        hasSequenceIssue = true;
        break;
      }
    }

    return PersonPrintState(
      person: person,
      records: records,
      appendPossible: canAppend,
      hasSequenceIssue: hasSequenceIssue,
    );
  }
}
