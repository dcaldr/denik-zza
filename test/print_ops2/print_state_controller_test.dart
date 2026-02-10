import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/print_ops2/print_state_controller.dart';
import 'package:denik_zza/print_ops2/print_center_service.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:denik_zza/print_ops2/models/person_print_state.dart';

import '../utils/print_test_helpers.dart';

class FakePrintCenterService extends PrintCenterService {
  final StreamController<List<PersonPrintState>> _streamController =
      StreamController<List<PersonPrintState>>.broadcast();

  // Internal state for "DB" simulation
  List<PersonPrintState> _currentStates = [];

  FakePrintCenterService({
    required List<PersonPrintState> initialStates,
  }) : super(database: null) {
    _currentStates = initialStates;
    // Emit initial after a slight delay to simulate async entry or immediate listen
    Future.microtask(() => _streamController.add(_currentStates));
  }

  void updateState(List<PersonPrintState> newStates) {
    _currentStates = newStates;
    _streamController.add(_currentStates);
  }

  @override
  Stream<List<PersonPrintState>> watchPersonPrintStates() {
    return _streamController.stream;
  }

  @override
  Future<bool> setParticipantPrintedFlag(
      int participantId, bool wasPrinted) async {
    final idx = _currentStates.indexWhere((s) => s.person.id == participantId);
    if (idx == -1) return false;

    // Simulate DB update
    final person = _currentStates[idx].person;
    person.wasPrinted = wasPrinted; // Mutating MemoryOsoba for simplicity in fake

    // Re-emit updated state (Controller relies on stream)
    updateState(List.from(_currentStates));
    return true;
  }

  @override
  Future<bool> setRecordPrintedFlag(int recordId, bool isPrinted) async {
    for (int i = 0; i < _currentStates.length; i++) {
      final state = _currentStates[i];
      final rIdx =
          state.records.indexWhere((r) => r.idZaznamu == recordId);
      if (rIdx != -1) {
        state.records[rIdx].isPrinted = isPrinted; // Mutating MemoryZaznam
        // Re-emit
        updateState(List.from(_currentStates));
        return true;
      }
    }
    return false;
  }

  @override
  Future<List<bool>> setMultipleRecordPrintedFlags(
      List<int> recordIds, bool isPrinted) async {
    final results = <bool>[];
    for (final recordId in recordIds) {
      final success = await setRecordPrintedFlag(recordId, isPrinted);
      results.add(success);
    }
    return results;
  }

  void dispose() {
    _streamController.close();
  }
}

void main() {
  group('PrintStateController', () {
    late FakePrintCenterService service;
    late PrintStateController controller;

    setUp(() {
      // Setup handled in each test
    });

    tearDown(() {
      service.dispose();
      controller.dispose();
    });

    group('Initialization', () {
      test('initializes validation and state from stream', () async {
        final person = buildTestPerson(id: 1);
        final state = PersonPrintState(
          person: person,
          records: [],
          appendPossible: false,
          hasSequenceIssue: false,
        );

        service = FakePrintCenterService(initialStates: [state]);
        controller = PrintStateController(service);

        // Wait for stream to emit
        await Future.delayed(Duration.zero);

        expect(controller.loading, false);
        expect(controller.personStates.length, 1);
        expect(controller.personStates.first.person.id, 1);
      });
    });

    group('Manual Control - No Cascades', () {
      // Requirement: "Manual Control... Remove automatic cascading logic"

      test('unmarking a person does NOT cascade to records', () async {
        final person = buildTestPerson(id: 1)..wasPrinted = true;
        final record =
            buildTestRecord(id: 101, participantId: 1, title: 'T', description: 'D')
              ..isPrinted = true;

        final state = PersonPrintState(
            person: person,
            records: [record],
            appendPossible: false,
            hasSequenceIssue: false);

        service = FakePrintCenterService(initialStates: [state]);
        controller = PrintStateController(service);
        await Future.delayed(Duration.zero);

        // Unmark person
        await controller.togglePersonPrinted(1);

        // Wait for stream update
        await Future.delayed(Duration.zero);

        final updatedState = controller.personStates.first;
        expect(updatedState.person.wasPrinted, false);
        expect(updatedState.records.first.isPrinted, true,
            reason: "Record should remain printed (no cascade)");
      });

      test('unmarking a middle record does NOT cascade to later records',
          () async {
        final person = buildTestPerson(id: 1)..wasPrinted = true;
        final r1 =
            buildTestRecord(id: 101, participantId: 1, title: 'T', description: 'D')
              ..isPrinted = true; // Unmark this
        final r2 =
            buildTestRecord(id: 102, participantId: 1, title: 'T', description: 'D')
              ..isPrinted = true; // Should stay printed

        final state = PersonPrintState(
            person: person,
            records: [r1, r2],
            appendPossible: false,
            hasSequenceIssue: false);

        service = FakePrintCenterService(initialStates: [state]);
        controller = PrintStateController(service);
        await Future.delayed(Duration.zero);

        // Unmark r1
        await controller.toggleRecordPrinted(1, 101);
        await Future.delayed(Duration.zero);

        final updatedState = controller.personStates.first;
        expect(updatedState.records[0].isPrinted, false);
        expect(updatedState.records[1].isPrinted, true,
            reason: "Later record should remain printed (no cascade)");
        // Note: hasSequenceIssue logic is now in Service, controller just reflects it
      });
    });

    group('Strict Validation', () {
      // Requirement: "Prevent marking a record as printed if earlier records are unprinted"

      test('cannot mark record as printed if previous is unprinted', () async {
        final person = buildTestPerson(id: 1);
        final r1 =
            buildTestRecord(id: 101, participantId: 1, title: 'T', description: 'D')
              ..isPrinted = false;
        final r2 =
            buildTestRecord(id: 102, participantId: 1, title: 'T', description: 'D')
              ..isPrinted = false; // Try to mark this

        final state = PersonPrintState(
            person: person,
            records: [r1, r2],
            appendPossible: false,
            hasSequenceIssue: false);

        service = FakePrintCenterService(initialStates: [state]);
        controller = PrintStateController(service);
        await Future.delayed(Duration.zero);

        // Try to mark r2
        await controller.toggleRecordPrinted(1, 102);
        await Future.delayed(Duration.zero);

        final updatedState = controller.personStates.first;
        expect(updatedState.records[1].isPrinted, false,
            reason: "Should be blocked by unprinted r1");
      });
    });

    group('Bulk Operations', () {
      test('markAllPrintedForPerson sets all true', () async {
        final person = buildTestPerson(id: 1);
        final r1 =
            buildTestRecord(id: 101, participantId: 1, title: 'T', description: 'D')
              ..isPrinted = false;
        final r2 =
            buildTestRecord(id: 102, participantId: 1, title: 'T', description: 'D')
              ..isPrinted = false;

        final state = PersonPrintState(
            person: person,
            records: [r1, r2],
            appendPossible: false,
            hasSequenceIssue: false);

        service = FakePrintCenterService(initialStates: [state]);
        controller = PrintStateController(service);
        await Future.delayed(Duration.zero);

        await controller.markAllPrintedForPerson(1);
        await Future.delayed(Duration.zero);

        final updatedState = controller.personStates.first;
        expect(updatedState.person.wasPrinted, true);
        expect(updatedState.records.every((r) => r.isPrinted), true);
      });

      test('resetAllForPerson sets all false', () async {
        final person = buildTestPerson(id: 1)..wasPrinted = true;
        final r1 =
            buildTestRecord(id: 101, participantId: 1, title: 'T', description: 'D')
              ..isPrinted = true;
        final r2 =
            buildTestRecord(id: 102, participantId: 1, title: 'T', description: 'D')
              ..isPrinted = true;

        final state = PersonPrintState(
            person: person,
            records: [r1, r2],
            appendPossible: false,
            hasSequenceIssue: false);

        service = FakePrintCenterService(initialStates: [state]);
        controller = PrintStateController(service);
        await Future.delayed(Duration.zero);

        await controller.resetAllForPerson(1);
        await Future.delayed(Duration.zero);

        final updatedState = controller.personStates.first;
        expect(updatedState.person.wasPrinted, false);
        expect(updatedState.records.every((r) => !r.isPrinted), true);
      });
    });
  });
}
