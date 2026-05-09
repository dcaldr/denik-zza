import 'dart:async';

import 'package:denik_zza/input/file_manager.dart';
import 'package:denik_zza/utils/app_logger.dart';
import 'package:drift/drift.dart';

import 'dart:io';

import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'tables.dart';

part 'database.g.dart';



/// The main [AppDatabase] class representing the Drift database for the Zza app.
@DriftDatabase(tables: [InsuranceCompanies, ZzaActions, Participants,
  Paramedics, Records, AllergiesLimitations, Medications, Cache])
class AppDatabase extends _$AppDatabase {
  AppDatabase([String? path]) : super(_openConnection(path));

  /// Test / custom constructor: Create from a provided DatabaseConnection.
  ///
  /// Use this for in-memory databases in tests as recommended by Drift docs,
  /// e.g. `AppDatabase.fromConnection(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true))`.
  AppDatabase.fromConnection(super.connection);

  /// Convenience: Create an in-memory database suitable for tests.
  ///
  /// This follows Drift's official testing guidance by enabling closeStreamsSynchronously
  /// to avoid open timers at the end of widget tests.
  /// See: https://drift.simonbinder.eu/testing/#writing-tests
  factory AppDatabase.testInMemory() {
    return AppDatabase.fromConnection(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
  }

  @override
  int get schemaVersion => 1;

  //==================== INSERTS ===============================================

  /// Insert insuranceCompanyCompanion into database
  Future<int> addInsuranceCompany(InsuranceCompaniesCompanion c) async {
    return into(insuranceCompanies).insert(c);
  }

  /// Insert zzaActionCompanion into database
  Future<int> addZzaAction(ZzaActionsCompanion c) async {
    return into(zzaActions).insert(c);
  }

  /// Insert participantsCompanion into database
  Future<int> addParticipant(ParticipantsCompanion c) async {
    return into(participants).insert(c);
  }

  /// Insert paramedicsCompanion into database
  Future<int> addParamedic(ParamedicsCompanion c) async {
    return into(paramedics).insert(c);
  }

  /// Insert recordsCompanion into database
  Future<int> addRecord(RecordsCompanion c) async {
    return into(records).insert(c);
  }

  /// Insert allergiesLimitations companion into database
  Future<int> addAllergiesLimitations(AllergiesLimitationsCompanion c) async {
    return into(allergiesLimitations).insert(c);
  }

  /// Insert medicationsCompanion into database
  Future<int> addMedication(MedicationsCompanion c) async {
    return into(medications).insert(c);
  }

  //==================== GETTERS ===============================================

  /// Get all insurance companies
  Future<List<InsuranceCompany>> getAllInsuranceCompanies() async {
    return (select(insuranceCompanies)..orderBy([(c) =>
        OrderingTerm(expression: c.name)])).get();
  }

  /// Get all actions
  Future<List<ZzaAction>> getAllZzaActions() async {
    final actions = await (select(zzaActions)..orderBy([(a) => OrderingTerm(expression: a.dateFrom)])).get();
    if (actions.isEmpty) {
      return []; // Return an empty list if no actions are found
    }
    return actions;
  }

  /// Get all participants
  Future<List<Participant>> getAllParticipants() async {
    return (select(participants)..orderBy([(p) =>
        OrderingTerm(expression: p.firstName), (p) =>
        OrderingTerm(expression: p.lastName)])).get();
  }

  /// Get all paramedics
  Future<List<Paramedic>> getAllParamedics() async {
    return (select(paramedics)..orderBy([(p) =>
        OrderingTerm(expression: p.username)])).get();
  }

  /// Get insurance company by ID
  Future<InsuranceCompany?> getInsuranceCompanyByID(int id) async {
    return await (select(insuranceCompanies)..where((i)
    => i.id.equals(id))).getSingleOrNull();
  }

  /// Get zzaAction based on ID
  Future<ZzaAction?> getZzaActionByID(int id) async {
    return await (select(zzaActions)..where((z) =>
        z.id.equals(id))).getSingleOrNull();
  }

  /// Get list of participants assigned to a zza action
  Future<List<Participant>> getParticipantsByAction(int idAction) async {
    return await (select(participants)..where((p) =>
        p.zzaActionFK.equals(idAction))..orderBy([(p) =>
        OrderingTerm(expression: p.firstName), (p) =>
        OrderingTerm(expression: p.lastName)])).get();
  }

  /// Watch list of participants assigned to a zza action (Stream for real-time updates)
  Stream<List<Participant>> watchParticipantsByAction(int idAction) {
    return (select(participants)..where((p) =>
        p.zzaActionFK.equals(idAction))..orderBy([(p) =>
        OrderingTerm(expression: p.firstName), (p) =>
        OrderingTerm(expression: p.lastName)])).watch();
  }

  /// Watch records based on participant ID (Stream for real-time updates)
  Stream<List<Record>> watchRecordsByParticipantID(int id) {
    return (select(records)..where((r) =>
        r.participantFK.equals(id))..orderBy([(r) =>
        OrderingTerm(expression: r.dateAndTime)])).watch();
  }

  /// Get participant based on ID
  Future<Participant?> getParticipantByID(int id) async {
    return await (select(participants)..where((p) =>
        p.id.equals(id))).getSingleOrNull();
  }

  /// Get paramedic based on ID
  Future<Paramedic?> getParamedicByID(int id) async {
    return await (select(paramedics)..where((p) =>
        p.id.equals(id))).getSingleOrNull();
  }

  /// Get records based on participant ID
  Future<List<Record>> getRecordsByParticipantID(int id) async {
    return await (select(records)..where((r) =>
        r.participantFK.equals(id))..orderBy([(r) =>
        OrderingTerm(expression: r.dateAndTime)])).get();
  }

  /// Get allergies and limitations based on participant ID,
  Future<List<AllergiesLimitation>> getAllergiesLimitationsByParticipantID(int id) async {
    return await (select(allergiesLimitations)..where((a) =>
        a.participantFK.equals(id))).get();
  }

  /// Get medications based on participant ID
  Future<List<Medication>> getMedicationsByParticipantID(int id) async {
    return await (select(medications)..where((m) =>
        m.participantFK.equals(id))).get();
  }

  /// Get pinned action ID, returns either int or null
  Future<int?> getPinnedActionID() async {
    final cacheData = await _readCacheData('getPinnedActionID');
    return cacheData?.pinnedActionID;
  }

  /// Get pinned action ID, returns either int or null
  Future<int?> getCurrentActionID() async {
    final cacheData = await _readCacheData('getCurrentActionID');
    return cacheData?.currentActionID;
  }

  /// Get printer calibration: true = page 1 on top, false = page 2 on top, null = not calibrated
  Future<bool?> getPrinterPage1OnTop() async {
    final cacheData = await _readCacheData('getPrinterPage1OnTop');
    return cacheData?.printerPage1OnTop;
  }
  /// Get insurance company ID by name
  Future<int?> getInsuranceCompanyIDbyName(String? name) async {
    if(name == null || name.trim().isEmpty) {
      return null;
    }

    InsuranceCompany? i = await (select(insuranceCompanies)..where((i) =>
    i.name.equals(name))).getSingleOrNull();

    if(i == null) {
      return null;
    }

    return i.id;
  }


  //==================== UPDATES ===============================================

  /// Update or insert into cache
  Future<int> updateCache(CacheCompanion c) async {
    return into(cache).insertOnConflictUpdate(c);
  }

  /// Update record wasPrinted value
  Future<int> setRecordPrintedValue(int id, bool value) async {
    return (update(records)..where((r) =>
        r.id.equals(id))).write(RecordsCompanion(wasPrinted: Value(value)));
  }

  /// Update participant wasPrinted value
  Future<int> setParticipantPrintedValue(int id, bool value) async {
    return (update(participants)..where((r) =>
        r.id.equals(id))).write(ParticipantsCompanion(wasPrinted: Value(value)));
  }

  Future<bool> setNoteValue(int personId, String value) { //FIXME: 100% make tests for this
    return (update(participants)..where((p) =>
    p.id.equals(personId))).write(ParticipantsCompanion(note: Value(value))).then((rowsUpdated) => rowsUpdated > 0);
  }

  Future<int> updateParticipant(int id, ParticipantsCompanion osoba) {
  return (update(participants)..where((p) => p.id.equals(id))).write(osoba);
}

Future<int> updateEvent(int id, ZzaActionsCompanion action) {
  return (update(zzaActions)..where((z) => z.id.equals(id))).write(action);
}

  Future<List<Medication>> getAllMedications() {
    return select(medications).get();
  }
  Future<List<AllergiesLimitation>> getAllAllergiesLimitations() {
    return select(allergiesLimitations).get();
  }

  //==================== DELETES ===============================================

  Future<CacheData?> _readCacheData(String operation) async {
    try {
      return await (select(cache)..where((c) => c.id.equals(1)))
          .getSingleOrNull();
    } catch (e, st) {
      AppLogger.l.e('[Database] $operation failed while reading cache row',
          error: e, stackTrace: st);
      return null;
    }
  }
}


/// Establish connection to sqlite database
///
///
///

LazyDatabase _openConnection([String? path]) {
  return LazyDatabase(() async {
    // Special case for in-memory database (commonly used in tests)
    if (path == ':memory:') {
      return NativeDatabase.memory();
    }
    // If a concrete file path was provided (ends with .db), use it directly
    if (path != null && path.toLowerCase().endsWith('.db')) {
      final dbFile = File(path);
      final directory = dbFile.parent;
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      }
      return NativeDatabase.createInBackground(dbFile);
    }
    
    // Backward-compat: Special case for historic test file paths (contain 'testDB')
    if (path != null && path.contains('testDB')) {
      final dbFile = File(path);
      final directory = dbFile.parent;
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      }
      return NativeDatabase.createInBackground(dbFile);
    }
    
    // Use FileManager to get the database path
    final fileManager = FileManager();
  /// makes path to the database file if null or missing use current directory;
    final dbPath = path ?? await fileManager.getDbFilePath() ?? '.';
    final dbFile = File(p.join(dbPath, 'db.sqlite'));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    // Make sqlite3 pick a more suitable location for temporary files - the
    // one from the system may be inaccessible due to sandboxing.
    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(dbFile);
  });
}