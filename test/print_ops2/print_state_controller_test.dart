import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/print_ops2/print_state_controller.dart';
import 'package:denik_zza/print_ops2/print_center_service.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';

import '../utils/print_test_helpers.dart';

class FakePrintCenterService extends PrintCenterService {
  final List<MemoryOsoba> participants;
  final Map<int, List<MemoryZaznam>> records;
  final StreamController<List<MemoryOsoba>> _streamController = StreamController<List<MemoryOsoba>>.broadcast();
  final bool throwOnGetRecords;

  FakePrintCenterService({
    required this.participants,
    required this.records,
    this.throwOnGetRecords = false,
  }) : super(database: null) {
      _streamController.add(participants);
  }

  void emitParticipants(List<MemoryOsoba> newParticipants) {
    _streamController.add(newParticipants);
  }

  @override
  Stream<List<MemoryOsoba>> watchCurrentEventParticipants() async* {
    yield participants;
    yield* _streamController.stream;
  }

  @override
  Future<List<MemoryZaznam>> getRecords(int participantId) async {
    if (throwOnGetRecords) {
      throw StateError('boom');
    }
    return records[participantId] ?? <MemoryZaznam>[];
  }

  @override
  Future<bool> setParticipantPrintedFlag(int participantId, bool wasPrinted) async {
    final idx = participants.indexWhere((p) => p.id == participantId);
    if (idx == -1) return false;
    participants[idx].wasPrinted = wasPrinted;
    
    // Simulate DB update emitting new stream value
    emitParticipants(List.from(participants)); 
    return true;
  }

  @override
  Future<bool> setRecordPrintedFlag(int recordId, bool isPrinted) async {
    for (final list in records.values) {
      final idx = list.indexWhere((r) => r.idZaznamu == recordId);
      if (idx != -1) {
        list[idx].isPrinted = isPrinted;
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
       // Setup handled in each test or we can extract common setup if needed
    });

    tearDown(() {
       // service.dispose(); // If we had one global
    });

    group('loadParticipants', () {
      test('loading participants populates personStates via stream', () async {
        final personA = buildTestPerson(id: 1, jmeno: 'Test', prijmeni: 'One');
        final record = buildTestRecord(id: 101, participantId: 1, title: 'T', description: 'D');
        
        service = FakePrintCenterService(
          participants: [personA],
          records: {1: [record]},
        );
        controller = PrintStateController(service);

        await controller.loadParticipants();

        // Wait for async stream processing
        await Future.delayed(Duration.zero);

        expect(controller.loading, false);
        expect(controller.personStates.length, 1);
        expect(controller.personStates.first.records.length, 1);
      });
    });

    group('Manual Control - No Cascades', () {
        // Requirement: "Manual Control... Remove automatic cascading logic"
        
        test('unmarking a person does NOT cascade to records', () async {
            final person = buildTestPerson(id: 1)..wasPrinted = true;
            final record = buildTestRecord(id: 101, participantId: 1, title: 'T', description: 'D')..isPrinted = true;
            
            service = FakePrintCenterService(
              participants: [person],
              records: {1: [record]},
            );
            controller = PrintStateController(service);
            await controller.loadParticipants();
            await Future.delayed(Duration.zero);
            
            // Unmark person
            await controller.togglePersonPrinted(1);
            
            // Wait for stream update
            await Future.delayed(Duration.zero);
            
            final state = controller.personStates.first;
            expect(state.person.wasPrinted, false);
            expect(state.records.first.isPrinted, true, reason: "Record should remain printed (no cascade)");
        });

        test('unmarking a middle record does NOT cascade to later records', () async {
            final person = buildTestPerson(id: 1)..wasPrinted = true;
            final r1 = buildTestRecord(id: 101, participantId: 1, title: 'T', description: 'D')..isPrinted = true; // Unmark this
            final r2 = buildTestRecord(id: 102, participantId: 1, title: 'T', description: 'D')..isPrinted = true; // Should stay printed
            
            service = FakePrintCenterService(
              participants: [person],
              records: {1: [r1, r2]},
            );
            controller = PrintStateController(service);
            await controller.loadParticipants();
            await Future.delayed(Duration.zero);
            
            // Unmark r1
            await controller.toggleRecordPrinted(1, 101);
            
            final state = controller.personStates.first;
            expect(state.records[0].isPrinted, false);
            expect(state.records[1].isPrinted, true, reason: "Later record should remain printed (no cascade)");
            expect(state.hasSequenceIssue, true, reason: "Should flag sequence issue (Gap)");
        });
    });

    group('Strict Validation', () {
        // Requirement: "Prevent marking a record as printed if earlier records are unprinted"
        
        test('cannot mark record as printed if previous is unprinted', () async {
            final person = buildTestPerson(id: 1);
            final r1 = buildTestRecord(id: 101, participantId: 1, title: 'T', description: 'D')..isPrinted = false;
            final r2 = buildTestRecord(id: 102, participantId: 1, title: 'T', description: 'D')..isPrinted = false; // Try to mark this
            
            service = FakePrintCenterService(
              participants: [person],
              records: {1: [r1, r2]},
            );
            controller = PrintStateController(service);
            await controller.loadParticipants();
            await Future.delayed(Duration.zero);
            
            // Try to mark r2
            await controller.toggleRecordPrinted(1, 102);
            
            final state = controller.personStates.first;
            expect(state.records[1].isPrinted, false, reason: "Should be blocked by unprinted r1");
        });

        test('can mark record as printed if previous is printed', () async {
            final person = buildTestPerson(id: 1);
            final r1 = buildTestRecord(id: 101, participantId: 1, title: 'T', description: 'D')..isPrinted = true;
            final r2 = buildTestRecord(id: 102, participantId: 1, title: 'T', description: 'D')..isPrinted = false; // Try to mark this
            
            service = FakePrintCenterService(
              participants: [person],
              records: {1: [r1, r2]},
            );
            controller = PrintStateController(service);
            await controller.loadParticipants();
            await Future.delayed(Duration.zero);
            
            // Try to mark r2
            await controller.toggleRecordPrinted(1, 102);
            
            final state = controller.personStates.first;
            expect(state.records[1].isPrinted, true, reason: "Should be allowed");
        });
    });

    group('Bulk Operations', () {
        test('markAllPrintedForPerson sets all true', () async {
            final person = buildTestPerson(id: 1);
            final r1 = buildTestRecord(id: 101, participantId: 1, title: 'T', description: 'D')..isPrinted = false;
            final r2 = buildTestRecord(id: 102, participantId: 1, title: 'T', description: 'D')..isPrinted = false;
            
            service = FakePrintCenterService(
              participants: [person],
              records: {1: [r1, r2]},
            );
            controller = PrintStateController(service);
            await controller.loadParticipants();
            await Future.delayed(Duration.zero);
            
            await controller.markAllPrintedForPerson(1);
            
            final state = controller.personStates.first;
            expect(state.person.wasPrinted, true);
            expect(state.records.every((r) => r.isPrinted), true);
        });

         test('resetAllForPerson sets all false', () async {
            final person = buildTestPerson(id: 1)..wasPrinted = true;
            final r1 = buildTestRecord(id: 101, participantId: 1, title: 'T', description: 'D')..isPrinted = true;
            final r2 = buildTestRecord(id: 102, participantId: 1, title: 'T', description: 'D')..isPrinted = true;
            
            service = FakePrintCenterService(
              participants: [person],
              records: {1: [r1, r2]},
            );
            controller = PrintStateController(service);
            await controller.loadParticipants();
            await Future.delayed(Duration.zero);
            
            await controller.resetAllForPerson(1);
            
            final state = controller.personStates.first;
            expect(state.person.wasPrinted, false);
            expect(state.records.every((r) => !r.isPrinted), true);
        });
    });
  });
}
