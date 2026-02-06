import 'dart:async';
import 'package:denik_zza/database/database_interface.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_lek.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_omezeni.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';

/// Service vrstva pro Tisk Centrum.
/// Nemá žádnou UI logiku, pouze získává data a vrací je dále controlleru.
class PrintCenterService {
  final DatabaseInterface _db;

  /// Constructor injection for testing and DI.
  PrintCenterService({DatabaseInterface? database})
      : _db = database ?? DatabaseWrapper.getDatabase();

  /// Factory for use with AppDependencies (future).
  // factory PrintCenterService.fromDeps(AppDependencies deps) =>
  //     PrintCenterService(database: deps.database);

  /// Sleduje účastníky aktuální akce.
  Stream<List<MemoryOsoba>> watchCurrentEventParticipants() {
    return _db.watchParticipantsByCurrentEvent();
  }

  Future<List<MemoryZaznam>> getRecords(int participantId) {
    return _db.getRecordsByParticipantID(participantId);
  }

  Future<List<MemoryLek>> getLeky(int participantId) {
    return _db.getLekyByParticipantID(participantId);
  }

  Future<List<MemoryOmezeni>> getOmezeni(int participantId) {
    return _db.getOmezeniByParticipantID(participantId);
  }

  /// Sets participant printed flag with error handling
  Future<bool> setParticipantPrintedFlag(
      int participantId, bool wasPrinted) async {
    try {
      final success = await _db.setParticipantPrintedValue(participantId, wasPrinted);
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Sets record printed flag with error handling
  Future<bool> setRecordPrintedFlag(int recordId, bool isPrinted) async {
    try {
      final success = await _db.setRecordPrintedValue(recordId, isPrinted);
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Sets multiple record printed flags
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
