import 'dart:async';
import 'package:denik_zza/print_ops2/print_center_service.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_lek.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_omezeni.dart';

/// A DRY fake service specifically meant for Widget Tests testing the Print Ops UI.
/// This prevents the pure `FakeAsync` zone from colliding with real `Drift` SQLite 
/// thread isolates and background file I/O operations, ensuring instant and 
/// non-brittle test execution.
class FakePrintCenterService extends PrintCenterService {
  FakePrintCenterService({
    required this.streamFactory,
    required this.recordsByPerson,
    this.throwOnGetRecords = false,
  }) : super(database: null);

  final Stream<List<MemoryOsoba>> Function() streamFactory;
  final Map<int, List<MemoryZaznam>> recordsByPerson;
  final bool throwOnGetRecords;
  
  // Tracking for test assertions
  int watchCalls = 0;
  final Map<int, bool> personPrintedFlags = {};
  final Map<int, bool> recordPrintedFlags = {};

  @override
  Stream<List<MemoryOsoba>> watchCurrentEventParticipants() {
    watchCalls += 1;
    return streamFactory();
  }

  @override
  Future<List<MemoryZaznam>> getRecords(int participantId) async {
    if (throwOnGetRecords) {
      throw StateError('boom');
    }
    final records = recordsByPerson[participantId] ?? <MemoryZaznam>[];
    // Sync printed flags to the returned records for UI accuracy
    for (var r in records) {
      r.isPrinted = recordPrintedFlags[r.idZaznamu] ?? r.isPrinted;
    }
    return records;
  }

  @override
  Future<List<MemoryLek>> getLeky(int participantId) async => [];

  @override
  Future<List<MemoryOmezeni>> getOmezeni(int participantId) async => [];

  @override
  Future<bool> getParticipantPrintedFlag(int participantId) async {
    return personPrintedFlags[participantId] ?? false;
  }

  @override
  Future<Map<int, bool>> getRecordPrintedFlags(int participantId) async {
    final records = recordsByPerson[participantId] ?? [];
    return {
      for (final r in records) r.idZaznamu: recordPrintedFlags[r.idZaznamu] ?? r.isPrinted,
    };
  }

  @override
  Future<int> countPrintedRecords(int participantId) async {
    final flags = await getRecordPrintedFlags(participantId);
    return flags.values.where((v) => v).length;
  }

  @override
  Future<bool> setParticipantPrintedFlag(int participantId, bool wasPrinted) async {
    personPrintedFlags[participantId] = wasPrinted;
    return true;
  }

  @override
  Future<bool> setRecordPrintedFlag(int recordId, bool isPrinted) async {
    recordPrintedFlags[recordId] = isPrinted;
    return true;
  }

  @override
  Future<List<bool>> setMultipleRecordPrintedFlags(List<int> recordIds, bool isPrinted) async {
    final results = <bool>[];
    for (final id in recordIds) {
      recordPrintedFlags[id] = isPrinted;
      results.add(true);
    }
    return results;
  }

  @override
  Future<void> setPrinterPage1OnTop(bool? page1OnTop) async {}

  @override
  Future<void> completeCalibration(bool? page1OnTop) async {}
}
