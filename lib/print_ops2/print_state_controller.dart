import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:denik_zza/print_ops2/print_center_service.dart';
import 'package:denik_zza/print_ops2/models/person_print_state.dart';
import 'package:denik_zza/utils/app_logger.dart';

/// Controller for manual print state management.
///
/// Allows users to manually toggle isPrinted/wasPrinted flags
/// as a fallback when automatic tracking produces incorrect state.
/// Maintains the contiguous-prefix invariant via cascade logic.
/// Controller for manual print state management.
///
/// Simplified implementation that:
/// 1. Listens to participant changes (DB Stream) via Service
/// 2. Manually toggles print flags (Service updates DB, Stream refreshes UI)
/// 3. Removes all "smart" cascading/blocking logic - manual control only.
class PrintStateController extends ChangeNotifier {
  final PrintCenterService _service;
  StreamSubscription<List<PersonPrintState>>? _stateSub;

  // State
  List<PersonPrintState> _personStates = [];
  bool _loading = true; // Start loading
  String? _error;

  // Getters
  List<PersonPrintState> get personStates => _personStates;
  bool get loading => _loading;
  String? get error => _error;

  PrintStateController(this._service) {
    _init();
  }

  /// Compatibility method for UI.
  /// The controller is reactive and auto-loads, so this is a no-op
  /// or could optionally trigger a re-subscription if needed.
  Future<void> loadParticipants() async {
    // No-op: Stream is already watching
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    super.dispose();
  }

  /// Initialize the reactive stream.
  void _init() {
    _stateSub = _service.watchPersonPrintStates().listen((states) {
      _personStates = states;
      _loading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      AppLogger.l.e('Failed to watch print states', error: e);
      _error = 'Chyba při načítání: $e';
      _loading = false;
      notifyListeners();
    });
  }

  /// Toggles a person's wasPrinted flag.
  ///
  /// Directly updates DB. Stream will trigger refresh automatically.
  Future<void> togglePersonPrinted(int personId) async {
    // Find current state to toggle
    final currentState =
        _personStates.firstWhere((s) => s.person.id == personId);
    final newValue = !currentState.personPrinted;

    final success =
        await _service.setParticipantPrintedFlag(personId, newValue);
    if (!success) {
      AppLogger.l.e('Failed to set person printed flag');
      // No need to notify error to UI for this, but could add SnackBar trigger if needed
    }
    // Stream handles UI update
  }

  /// Toggles a record's isPrinted flag.
  ///
  /// Directly updates DB. Stream will trigger refresh automatically.
  Future<void> toggleRecordPrinted(int personId, int recordId) async {
    // Find current state
    final personState =
        _personStates.firstWhere((s) => s.person.id == personId);
    final record =
        personState.records.firstWhere((r) => r.idZaznamu == recordId);
    final newValue = !record.isPrinted;

    // Strict Validation: Prevent marking as printed if earlier records are unprinted
    if (newValue) {
      final recordIdx =
          personState.records.indexWhere((r) => r.idZaznamu == recordId);
      for (int i = 0; i < recordIdx; i++) {
        if (!personState.records[i].isPrinted) {
          AppLogger.l.w(
              'Cannot mark record $recordId as printed: earlier records are unprinted.');
          return; // Block action
        }
      }
    }

    final success = await _service.setRecordPrintedFlag(recordId, newValue);
    if (!success) {
      AppLogger.l.e('Failed to set record printed flag');
    }
    // Stream handles UI update
  }

  /// Marks all records as printed for a person.
  Future<void> markAllPrintedForPerson(int personId) async {
    final state = _personStates.firstWhere((s) => s.person.id == personId);

    // 1. Mark Person
    if (!state.personPrinted) {
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
    // Stream handles UI update
  }

  /// Resets all print flags for a person.
  Future<void> resetAllForPerson(int personId) async {
    final state = _personStates.firstWhere((s) => s.person.id == personId);

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
    // Stream handles UI update
  }
}
