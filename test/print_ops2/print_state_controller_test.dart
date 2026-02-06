import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/print_ops2/print_state_controller.dart';
import 'package:denik_zza/print_ops2/print_center_service.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';

import '../utils/print_test_helpers.dart';

class FakePrintCenterService extends PrintCenterService {
  final List<MemoryOsoba> participants;
  final Map<int, List<MemoryZaznam>> records;
  final Stream<List<MemoryOsoba>>? participantsStream;

  FakePrintCenterService({
    required this.participants,
    required this.records,
    this.participantsStream,
  }) : super(database: null);

  @override
  Stream<List<MemoryOsoba>> watchCurrentEventParticipants() {
    return participantsStream ?? Stream.value(participants);
  }

  @override
  Future<List<MemoryZaznam>> getRecords(int participantId) async {
    return records[participantId] ?? <MemoryZaznam>[];
  }

  @override
  Future<bool> setParticipantPrintedFlag(int participantId, bool wasPrinted) async {
    final idx = participants.indexWhere((p) => p.id == participantId);
    if (idx == -1) return false;
    participants[idx].wasPrinted = wasPrinted;
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
}

void main() {
  group('PrintStateController', () {
    group('loadParticipants', () {
      test('loading participants populates personStates', () async {
        final personA = buildTestPerson(id: 1, jmeno: 'Test', prijmeni: 'One');
        final personB = buildTestPerson(id: 2, jmeno: 'Test', prijmeni: 'Two');
        final record = buildTestRecord(
          id: 1,
          participantId: 1,
          title: 'Record',
          description: 'Desc',
        );

        final service = FakePrintCenterService(
          participants: [personA, personB],
          records: {1: [record], 2: []},
        );
        final controller = PrintStateController(service);

        await controller.loadParticipants();

        expect(controller.loading, false);
        expect(controller.error, isNull);
        expect(controller.personStates.length, 2);
      });

      test('loading with no participants results in empty list', () async {
        final service = FakePrintCenterService(
          participants: [],
          records: const {},
        );
        final controller = PrintStateController(service);

        await controller.loadParticipants();

        expect(controller.personStates, isEmpty);
      });

      test('loading error sets error state', () async {
        final service = FakePrintCenterService(
          participants: [],
          records: const {},
          participantsStream: Stream.error(StateError('boom')),
        );
        final controller = PrintStateController(service);

        await controller.loadParticipants();

        expect(controller.error, isNotNull);
      });
    });

    group('togglePersonPrinted', () {
      test('toggle person from printed -> unprinted cascades records', () async {
        final person = buildTestPerson(id: 1, jmeno: 'Test', prijmeni: 'One')
          ..wasPrinted = true;
        final records = [
          buildTestRecord(id: 1, participantId: 1, title: 'A', description: 'a')
            ..isPrinted = true,
          buildTestRecord(id: 2, participantId: 1, title: 'B', description: 'b')
            ..isPrinted = true,
        ];

        final service = FakePrintCenterService(
          participants: [person],
          records: {1: records},
        );
        final controller = PrintStateController(service);
        await controller.loadParticipants();

        await controller.togglePersonPrinted(1);

        final state = controller.personStates.first;
        expect(state.person.wasPrinted, false);
        expect(state.records.every((r) => r.isPrinted == false), true);
      });

      test('toggle person from unprinted -> printed keeps records', () async {
        final person = buildTestPerson(id: 1, jmeno: 'Test', prijmeni: 'One')
          ..wasPrinted = false;
        final records = [
          buildTestRecord(id: 1, participantId: 1, title: 'A', description: 'a')
            ..isPrinted = false,
        ];

        final service = FakePrintCenterService(
          participants: [person],
          records: {1: records},
        );
        final controller = PrintStateController(service);
        await controller.loadParticipants();

        await controller.togglePersonPrinted(1);

        final state = controller.personStates.first;
        expect(state.person.wasPrinted, true);
        expect(state.records.first.isPrinted, false);
      });
    });

    group('toggleRecordPrinted – cascade logic', () {
      test('unmark middle record cascades to later records', () async {
        final person = buildTestPerson(id: 1, jmeno: 'Test', prijmeni: 'One')
          ..wasPrinted = true;
        final records = [
          buildTestRecord(id: 1, participantId: 1, title: 'A', description: 'a')
            ..isPrinted = true,
          buildTestRecord(id: 2, participantId: 1, title: 'B', description: 'b')
            ..isPrinted = true,
          buildTestRecord(id: 3, participantId: 1, title: 'C', description: 'c')
            ..isPrinted = true,
        ];

        final service = FakePrintCenterService(
          participants: [person],
          records: {1: records},
        );
        final controller = PrintStateController(service);
        await controller.loadParticipants();

        final success = await controller.toggleRecordPrinted(1, 2);
        expect(success, true);

        final state = controller.personStates.first;
        expect(state.records[0].isPrinted, true);
        expect(state.records[1].isPrinted, false);
        expect(state.records[2].isPrinted, false);
      });

      test('unmark last record does not cascade', () async {
        final person = buildTestPerson(id: 1, jmeno: 'Test', prijmeni: 'One')
          ..wasPrinted = true;
        final records = [
          buildTestRecord(id: 1, participantId: 1, title: 'A', description: 'a')
            ..isPrinted = true,
          buildTestRecord(id: 2, participantId: 1, title: 'B', description: 'b')
            ..isPrinted = true,
        ];

        final service = FakePrintCenterService(
          participants: [person],
          records: {1: records},
        );
        final controller = PrintStateController(service);
        await controller.loadParticipants();

        final success = await controller.toggleRecordPrinted(1, 2);
        expect(success, true);

        final state = controller.personStates.first;
        expect(state.records[0].isPrinted, true);
        expect(state.records[1].isPrinted, false);
      });

      test('mark record as printed blocked by earlier unprinted', () async {
        final person = buildTestPerson(id: 1, jmeno: 'Test', prijmeni: 'One')
          ..wasPrinted = true;
        final records = [
          buildTestRecord(id: 1, participantId: 1, title: 'A', description: 'a')
            ..isPrinted = false,
          buildTestRecord(id: 2, participantId: 1, title: 'B', description: 'b')
            ..isPrinted = false,
        ];

        final service = FakePrintCenterService(
          participants: [person],
          records: {1: records},
        );
        final controller = PrintStateController(service);
        await controller.loadParticipants();

        final success = await controller.toggleRecordPrinted(1, 2);
        expect(success, false);

        final state = controller.personStates.first;
        expect(state.records[1].isPrinted, false);
      });
    });

    group('previewToggleImpact', () {
      test('last record impact has zero cascade', () async {
        final person = buildTestPerson(id: 1, jmeno: 'Test', prijmeni: 'One')
          ..wasPrinted = true;
        final records = [
          buildTestRecord(id: 1, participantId: 1, title: 'A', description: 'a')
            ..isPrinted = true,
          buildTestRecord(id: 2, participantId: 1, title: 'B', description: 'b')
            ..isPrinted = true,
        ];

        final service = FakePrintCenterService(
          participants: [person],
          records: {1: records},
        );
        final controller = PrintStateController(service);
        await controller.loadParticipants();

        final impact = controller.previewToggleImpact(1, 2);
        expect(impact.affectedRecordCount, 0);
      });

      test('first of three printed records cascades two', () async {
        final person = buildTestPerson(id: 1, jmeno: 'Test', prijmeni: 'One')
          ..wasPrinted = true;
        final records = [
          buildTestRecord(id: 1, participantId: 1, title: 'A', description: 'a')
            ..isPrinted = true,
          buildTestRecord(id: 2, participantId: 1, title: 'B', description: 'b')
            ..isPrinted = true,
          buildTestRecord(id: 3, participantId: 1, title: 'C', description: 'c')
            ..isPrinted = true,
        ];

        final service = FakePrintCenterService(
          participants: [person],
          records: {1: records},
        );
        final controller = PrintStateController(service);
        await controller.loadParticipants();

        final impact = controller.previewToggleImpact(1, 1);
        expect(impact.affectedRecordCount, 2);
        expect(impact.appendStillPossible, true);
      });

      test('blocked append requires full reprint', () async {
        final person = buildTestPerson(id: 1, jmeno: 'Test', prijmeni: 'One')
          ..wasPrinted = true;
        final records = [
          buildTestRecord(id: 1, participantId: 1, title: 'A', description: 'a')
            ..isPrinted = false,
          buildTestRecord(id: 2, participantId: 1, title: 'B', description: 'b')
            ..isPrinted = false,
        ];

        final service = FakePrintCenterService(
          participants: [person],
          records: {1: records},
        );
        final controller = PrintStateController(service);
        await controller.loadParticipants();

        final impact = controller.previewToggleImpact(1, 2);
        expect(impact.appendStillPossible, false);
        expect(impact.requiresFullReprint, true);
      });
    });

    group('bulk operations', () {
      test('markAllPrintedForPerson marks person and records', () async {
        final person = buildTestPerson(id: 1, jmeno: 'Test', prijmeni: 'One')
          ..wasPrinted = false;
        final records = [
          buildTestRecord(id: 1, participantId: 1, title: 'A', description: 'a')
            ..isPrinted = false,
          buildTestRecord(id: 2, participantId: 1, title: 'B', description: 'b')
            ..isPrinted = false,
        ];

        final service = FakePrintCenterService(
          participants: [person],
          records: {1: records},
        );
        final controller = PrintStateController(service);
        await controller.loadParticipants();

        await controller.markAllPrintedForPerson(1);

        final state = controller.personStates.first;
        expect(state.person.wasPrinted, true);
        expect(state.records.every((r) => r.isPrinted), true);
      });

      test('resetAllForPerson resets person and records', () async {
        final person = buildTestPerson(id: 1, jmeno: 'Test', prijmeni: 'One')
          ..wasPrinted = true;
        final records = [
          buildTestRecord(id: 1, participantId: 1, title: 'A', description: 'a')
            ..isPrinted = true,
          buildTestRecord(id: 2, participantId: 1, title: 'B', description: 'b')
            ..isPrinted = true,
        ];

        final service = FakePrintCenterService(
          participants: [person],
          records: {1: records},
        );
        final controller = PrintStateController(service);
        await controller.loadParticipants();

        await controller.resetAllForPerson(1);

        final state = controller.personStates.first;
        expect(state.person.wasPrinted, false);
        expect(state.records.every((r) => r.isPrinted == false), true);
      });
    });
  });
}
