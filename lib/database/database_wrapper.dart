import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/database/drift_database_connector.dart';
import 'database_interface.dart';
import 'in_memory_structures_tmp/memory_database_connector.dart';


/// Selects the correct [DatabaseInterface] instance.
///
///  **Always use as ```dart
///   DatabaseInterface dbInterface = DatabaseWrapper().getDatabase();
///   ``` **
///   or ```dart
///   DatabaseInterface dbInterface = getDatabase();
///   ```
/// Right now, it's singleton by historical reasons.
/// new databases should be easier to implement.
class DatabaseWrapper  {


  static final DatabaseWrapper _singleton = DatabaseWrapper._internal();

  factory DatabaseWrapper() {
    return _singleton;
  }
  DatabaseWrapper._internal();
/// Database to be used by the app.
  ///
  /// 1 - in memory database
  ///
  /// 0 - default database ( now [DriftDatabaseConnector] )
  static int databaseID = 0;

  @Deprecated("Remove when possible")
  final MemoryDatabase _memoryDatabase = MemoryDatabase();
  @Deprecated("Remove when possible")
  final _driftDatabase = AppDatabase();

  /**===================== REMOVE WHEN POSSIBLE ↓ =========================== */
/**
  @override
  Future<bool> addZaznam(MemoryZaznam zaznam) async => _memoryDatabase.addZaznam(zaznam);
  @override


  @override
  Future<bool> addOsoba(MemoryOsoba osoba) async {
    return _memoryDatabase.addOsoba(osoba);
  }

  Future<bool> quickAddNewZaznam( String popis, int idPacient  ) async {
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
  Future<List<MemoryOsoba>> getParticipantsByAction(int idAction) async {
    List<Participant> participants = await
    _driftDatabase.getParticipantsByAction(idAction);

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
  Future<int> updateCache(int? pinnedActionID) async {
    return _driftDatabase.updateCache(CacheCompanion(
      id: Value(1),
      pinnedActionID: Value(pinnedActionID)
    ));
  }

  @override
  Future<int?> getPinnedActionID() async {
    return _driftDatabase.getPinnedActionID();
  }
*/
  /**===================== REMOVE WHEN POSSIBLE ↑ ============================*/

  /// Returns the correct database instance.
  ///
  /// This method returns the correct database instance based on the [_databaseID] variable.
  /// If [_databaseID] is undefinded it falls back to [DriftDatabaseConnector].
  static DatabaseInterface getDatabase() {
    if(databaseID == 1 ){
      return MemoryDatabase();
}
    return DriftDatabaseConnector();
  }
}