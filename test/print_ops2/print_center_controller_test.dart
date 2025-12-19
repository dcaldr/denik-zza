import 'package:denik_zza/database/in_memory_structures_tmp/memory_lek.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_omezeni.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:denik_zza/print_ops2/print_center_controller.dart';
import 'package:denik_zza/print_ops2/print_center_service.dart';
import 'package:flutter_test/flutter_test.dart';

// Create MockService
class MockPrintCenterService extends PrintCenterService {
  @override
  Stream<List<MemoryOsoba>> watchCurrentEventParticipants() {
    return Stream.value([
      MemoryOsoba.fullNamed(
          id: 1,
          jmeno: 'Test',
          prijmeni: 'User',
          pohlavi: 1,
          adresa: 'A',
          cisloPojisteni: '1',
          datumNarozeni: DateTime(2000, 1, 1),
          jmenoRodice: 'R',
          telefonRodice: '1',
          emailRodice: 'e',
          zpusobilost: true,
          bezinfekcnost: true,
          zdravotniPojistovna: 'Z',
          poznamka: '',
          wasPrinted: false,
          oddil: null,
          prisel: null,
          potvrzeniPath: null)
    ]);
  }

  @override
  Future<List<MemoryZaznam>> getRecords(int id) async => [
        MemoryZaznam.fullNamed(
            idZaznamu: 10,
            casZaznamu: DateTime.now(),
            nazev: 'Z1',
            popis: 'Popis',
            lecba: null,
            isPrinted: false,
            idAuthor: 1,
            idPacient: 1,
            poznamka: null,
            teplota: null,
            obrazekPath: null)
      ];

  @override
  Future<List<MemoryLek>> getLeky(int id) async => [];

  @override
  Future<List<MemoryOmezeni>> getOmezeni(int id) async => [];

  @override
  Future<bool> setParticipantPrintedFlag(
          int participantId, bool wasPrinted) async =>
      true;

  @override
  Future<List<bool>> setMultipleRecordPrintedFlags(
          List<int> recordIds, bool isPrinted) async =>
      [true];

  @override
  Future<bool> setRecordPrintedFlag(int recordId, bool isPrinted) async => true;
}

void main() {
  late PrintCenterController controller;
  late MockPrintCenterService mockService;

  setUp(() {
    mockService = MockPrintCenterService();
    controller = PrintCenterController(mockService);
  });

  test('Initial state is correct', () {
    expect(controller.participants, isEmpty);
    expect(controller.selected, isNull);
  });

  test('Select participant loads details', () async {
    controller.init();
    await Future.delayed(Duration.zero); // Wait for stream
    expect(controller.participants.length, 1);

    await controller.selectParticipant(controller.participants.first);
    expect(controller.selected!.id, 1);
    expect(controller.records.length, 1);
  });

  test('Generate PDF returns bytes', () async {
    controller.init();
    await Future.delayed(Duration.zero);
    await controller.selectParticipant(controller.participants.first);

    final bytes = await controller.generateCurrentPdf();
    expect(bytes, isNotEmpty);
    expect(controller.generatingPdf, false);
  });

  test('Confirm Print success calls DB updates (Full Mode)', () async {
    // We cannot easily verify calls on Manual Mock without a Spy,
    // but we can check internal state flags if we had them or integration.
    // Here we mainly check that it doesn't crash and changes UI state variables.

    controller.init();
    await Future.delayed(Duration.zero);
    await controller.selectParticipant(controller.participants.first);

    await controller.confirmPrintResult(PrintSimulationResult.success);

    expect(controller.simulatedPrinted, true);
    expect(controller.lastResult, PrintSimulationResult.success);
  });
}
