import 'dart:async';
import 'package:denik_zza/print_ops2/print_center_service.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';

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
  int watchCalls = 0;

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
    return recordsByPerson[participantId] ?? <MemoryZaznam>[];
  }
}
