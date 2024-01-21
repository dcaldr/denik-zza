

import 'package:denik_zza/database/drift_database/database.dart';

import 'database_interface.dart';
import 'in_memory_structures_tmp/memory_database.dart';
import 'in_memory_structures_tmp/memory_osoba.dart';
import 'in_memory_structures_tmp/memory_zaznam.dart';

/// Methods for high-level database interactions.
///
///  **Always use as ```dart
///   DatabaseInterface dbInterface = DatabaseWrapper();
///   ``` **
/// Right now, this is just a empty Wrapper for database-in progress.
/// Later on could be rewritten to point to a database.
class DatabaseWrapper implements DatabaseInterface {
  static final DatabaseWrapper _singleton = DatabaseWrapper._internal();

  factory DatabaseWrapper() {
    return _singleton;
  }

  DatabaseWrapper._internal();

  final MemoryDatabase _memoryDatabase = MemoryDatabase();
  final driftDatabase = AppDatabase();

  @override
  Future<bool> addZaznam(MemoryZaznam zaznam) async => _memoryDatabase.addZaznam(zaznam);
  @override


  @override
  Future<bool> addOsoba(MemoryOsoba osoba) async {
    return _memoryDatabase.addOsoba(osoba);
  }

  Future<bool> quickAddNewZaznam( String popis, {int idPacient = 0} ) async {
    return _memoryDatabase.addZaznam(MemoryZaznam.short( popis,  idPacient));
  }

  @override
  Future<void> quickPrintAllOsoby() async {
    _memoryDatabase.quickPrintAllOsoby();
  }
  @override
  String quickPrintZaznamyOsoby(int idOsoby) {
    return _memoryDatabase.quickPrintZaznamyOsoby(idOsoby);
  }

  //========= Vojtovy přidané metody ===========================================

  @override
  Future<List<MemoryZaznam>> getRecordsByParticipantID(int id) async {
    List<Record> records = await driftDatabase.getRecordsByParticipantID(id);
    List<MemoryZaznam> memoryRecords = [];
    
    for(Record r in records) {
      memoryRecords.add(MemoryZaznam.complete(r.id, r.dateAndTime, r.title,
          r.description, r.treatment, r.wasPrinted,
          r.paramedicFK, r.participantFK));
    }
    
    return memoryRecords;
  }

  @override
  Future<List<MemoryOsoba>> getParticipantsByAction(int idAction) async {
    List<Participant> participants = await
    driftDatabase.getParticipantsByAction(idAction);

    List<MemoryOsoba> memoryParticipants = [];

    for(Participant p in participants) {
      memoryParticipants.add(MemoryOsoba.complete(p.id, p.firstName, p.lastName,
        p.address, p.birthNumber, p.birthDate, p.parentPhoneNumber,
        p.eligibleConfirmation, p.nonInfectiousConfirmation, p.wasPrinted,
        p.insuranceCompanyFK, p.zzaActionFK));
    }

    return memoryParticipants;
  }
}