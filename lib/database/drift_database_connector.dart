import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:drift/drift.dart';
import 'database_interface.dart';
import 'package:denik_zza/database/drift_database/database.dart';

/// Singleton Connector to Drift database
///
/// bridge between the app and the sqlite (drift) database
class DriftDatabaseConnector implements DatabaseInterface {
  static final DriftDatabaseConnector _singleton = DriftDatabaseConnector._internal();
// sigleton factory
  factory DriftDatabaseConnector() {
    return _singleton;
  }
  DriftDatabaseConnector._internal();
  ///Drift database instance
  final _driftDatabase = AppDatabase();


  @override
  Future<bool> addOsoba(MemoryOsoba osoba) {
    // TODO: implement addOsoba
    throw UnimplementedError();
  }

  @override
  Future<bool> addZaznam(MemoryZaznam zaznam) {
    // TODO: implement addZaznam
    throw UnimplementedError();
  }

  @override
  Future<List<MemoryOsoba>> getParticipantsByEvent(int idEvent) async {
    List<Participant> participants = await
    _driftDatabase.getParticipantsByAction(idEvent);

    List<MemoryOsoba> memoryParticipants = [];

    for(Participant p in participants) {
      memoryParticipants.add(MemoryOsoba.complete(p.id, p.firstName, p.lastName,
          p.address, p.birthNumber, p.birthDate, p.parentPhoneNumber,
          p.eligibleConfirmation, p.nonInfectiousConfirmation, p.wasPrinted,
          p.insuranceCompanyFK, p.zzaActionFK));
    }

    return memoryParticipants;
  }

  @override
  Future<int?> getPinnedEventID() async {
    return _driftDatabase.getPinnedActionID();
  }

  @override
  Future<List<MemoryZaznam>> getRecordsByParticipantID(int id) async {
    List<Record> records = await _driftDatabase.getRecordsByParticipantID(id);
    List<MemoryZaznam> memoryRecords = [];

    for(Record r in records) {
      memoryRecords.add(MemoryZaznam.complete(r.id, r.dateAndTime, r.title,
          r.description, r.treatment, r.wasPrinted,
          r.paramedicFK, r.participantFK));
    }

    return memoryRecords;
  }

  @override
  Future<bool> quickAddNewZaznam(String popis, int idPacient ) {
    // TODO: implement quickAddNewZaznam
    throw UnimplementedError();
  }

  @override
  Future<void> quickPrintAllOsoby() {
    // TODO: implement quickPrintAllOsoby
    throw UnimplementedError();
  }

  @override
  String quickPrintZaznamyOsoby(int idOsoby) {
    // TODO: implement quickPrintZaznamyOsoby
    throw UnimplementedError();
  }

  @override
  void updateCache(int? pinnedEventID) async {
    _driftDatabase.updateCache(CacheCompanion(
        id: const Value(1),
        pinnedActionID: Value(pinnedEventID)
    ));
  }
}