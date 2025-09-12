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
  final DatabaseInterface _db = DatabaseWrapper.getDatabase();

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
}
