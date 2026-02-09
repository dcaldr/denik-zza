import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:denik_zza/print_ops2/print_center_service.dart';
import 'package:denik_zza/print_ops2/generate_pdf_template.dart';
import 'package:denik_zza/print_ops2/models/person_print_state.dart';
import 'package:denik_zza/utils/record_sort_utils.dart';
import 'package:denik_zza/utils/app_logger.dart';
import 'package:denik_zza/print_ops2/print_utils.dart' as import_utils;

/// Controller for manual print state management.
///
/// Allows users to manually toggle isPrinted/wasPrinted flags
/// as a fallback when automatic tracking produces incorrect state.
/// Maintains the contiguous-prefix invariant via cascade logic.
/// Controller for manual print state management.
///
/// Simplified implementation that:
/// 1. Listens to participant changes (DB Stream)
/// 2. Manually refreshes on record changes (since DB stream doesn't watch records)
/// 3. Removes all "smart" cascading/blocking logic - pure manual control.
class PrintStateController extends ChangeNotifier {
  final PrintCenterService _service;
  StreamSubscription<List<MemoryOsoba>>? _participantsSub;

  // State
  List<PersonPrintState> _personStates = [];
  List<MemoryOsoba> _lastParticipants = []; // Cache for manual refresh
  bool _loading = false;
  String? _error;

  // Getters
  List<PersonPrintState> get personStates => _personStates;
  bool get loading => _loading;
  String? get error => _error;

  PrintStateController(this._service);

  @override
  void dispose() {
    _participantsSub?.cancel();
    super.dispose();
  }

  /// Loads participants and subscribes to updates.
  Future<void> loadParticipants() async {
    _loading = true;
    _error = null;
    notifyListeners();

    _participantsSub?.cancel();
    _participantsSub = _service.watchCurrentEventParticipants().listen((participants) {
      _lastParticipants = participants;
      _refreshStates(participants);
    }, onError: (e) {
      AppLogger.l.e('Failed to watch participants', error: e);
      _error = 'Chyba při načítání: $e';
      _loading = false;
      notifyListeners();
    });
  }

  /// Internal method to rebuild states from a list of participants.
  /// Fetches records for each person to build the full state.
  Future<void> _refreshStates(List<MemoryOsoba> participants) async {
    try {
      final states = <PersonPrintState>[];
      for (final person in participants) {
        final records = await _service.getRecords(person.id);
        
        // Sort records by time for consistent display/logic
        sortRecordsByTime(records);
        
        states.add(_buildPersonState(person, records));
      }
      _personStates = states;
      _error = null;
    } catch (e) {
      AppLogger.l.e('Failed to refresh print states', error: e);
      _error = 'Chyba při aktualizaci: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Toggles a person's wasPrinted flag.
  ///
  /// Directly updates DB. Stream will trigger refresh automatically.
  Future<void> togglePersonPrinted(int personId) async {
    final stateIdx = _personStates.indexWhere((s) => s.person.id == personId);
    if (stateIdx == -1) return;

    final person = _personStates[stateIdx].person;
    final newValue = !(person.wasPrinted ?? false);

    final success = await _service.setParticipantPrintedFlag(personId, newValue);
    if (!success) {
      AppLogger.l.e('Failed to set person printed flag');
    }
    // No manual refresh needed - setParticipantPrintedFlag updates 'participants' table, triggering stream.
  }

  /// Toggles a record's isPrinted flag.
  ///
  /// Directly updates DB. REQUIRES manual refresh (stream doesn't watch records).
  Future<void> toggleRecordPrinted(int personId, int recordId) async {
    final stateIdx = _personStates.indexWhere((s) => s.person.id == personId);
    if (stateIdx == -1) return;

    final state = _personStates[stateIdx];
    final recordIdx = state.records.indexWhere((r) => r.idZaznamu == recordId);
    if (recordIdx == -1) return;

    final record = state.records[recordIdx];
    final newValue = !record.isPrinted;

    // Strict Validation: Prevent marking as printed if earlier records are unprinted
    if (newValue) {
      for (int i = 0; i < recordIdx; i++) {
        if (!state.records[i].isPrinted) {
          AppLogger.l.w('Cannot mark record $recordId as printed: earlier records are unprinted.');
          return; // Block action
        }
      }
    }

    final success = await _service.setRecordPrintedFlag(recordId, newValue);
    if (!success) {
      AppLogger.l.e('Failed to set record printed flag');
      return;
    }
    
    // Manual refresh needed because DB stream doesn't watch 'records' table
    await _refreshStates(_lastParticipants);
  }

  /// Marks all records as printed for a person.
  Future<void> markAllPrintedForPerson(int personId) async {
    final stateIdx = _personStates.indexWhere((s) => s.person.id == personId);
    if (stateIdx == -1) return;

    final state = _personStates[stateIdx];

    // 1. Mark Person (triggers stream eventually, but we want immediate update)
    if (!(state.person.wasPrinted ?? false)) {
      await _service.setParticipantPrintedFlag(personId, true);
    }

    // 2. Mark Records
    final unprintedIds = state.records
        .where((r) => !r.isPrinted)
        .map((r) => r.idZaznamu)
        .toList();
    
    if (unprintedIds.isNotEmpty) {
      await _service.setMultipleRecordPrintedFlags(unprintedIds, true);
    }

    // Full refresh to sync everything
    // Note: setParticipantPrintedFlag triggers stream, but might race with record updates.
    // Calling _refreshStates manually ensures we see record updates even if stream fires early.
    await _refreshStates(_lastParticipants);
  }

  /// Resets all print flags for a person.
  Future<void> resetAllForPerson(int personId) async {
    final stateIdx = _personStates.indexWhere((s) => s.person.id == personId);
    if (stateIdx == -1) return;

    final state = _personStates[stateIdx];

    // 1. Reset Person
    await _service.setParticipantPrintedFlag(personId, false);

    // 2. Reset Records
    final printedIds = state.records
        .where((r) => r.isPrinted)
        .map((r) => r.idZaznamu)
        .toList();

    if (printedIds.isNotEmpty) {
      await _service.setMultipleRecordPrintedFlags(printedIds, false);
    }

    await _refreshStates(_lastParticipants);
  }

  /// Builds a [PersonPrintState] with computed append status using simplified logic.
  PersonPrintState _buildPersonState(MemoryOsoba person, List<MemoryZaznam> records) {
    // Use GeneratePdfTemplate to check append status (strict validation)
    final template = GeneratePdfTemplate.named(
      osoba: person,
      zaznamList: List.of(records),
    );
    final canAppend = template.canAppend();

    // Check for "Gap" (Sequence Issue) for UI warning
    // We can use the same utility logic used by GeneratePdfTemplate
    final flags = records.map((r) => r.isPrinted).toList();
    final isSequenceValid = import_utils.isSequenceValid(flags);

    return PersonPrintState(
      person: person,
      records: records,
      appendPossible: canAppend,
      hasSequenceIssue: !isSequenceValid, // Issue if NOT valid
    );
  }
}
