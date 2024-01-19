import 'package:drift/drift.dart';

import 'dart:io';

import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [InsuranceCompanies, ZzaActions, Participants,
  Paramedics, Records, AllergiesLimitations, Medications])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

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
    return select(insuranceCompanies).get();
  }

  /// Get all actions
  Future<List<ZzaAction>> getAllZzaActions() async {
    return select(zzaActions).get();
  }

  /// Get all participants
  Future<List<Participant>> getAllParticipants() async {
    return select(participants).get();
  }

  /// Get all paramedics
  Future<List<Paramedic>> getAllParamedics() async {
    return select(paramedics).get();
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
  Future<AllergiesLimitation?> getAllergiesLimitationsByParticipantID(int id) async {
    return await (select(allergiesLimitations)..where((a) =>
        a.participantFK.equals(id))).getSingleOrNull();
  }

  /// Get medications based on participant ID
  Future<List<Medication>> getMedicationsByParticipantID(int id) async {
    return await (select(medications)..where((m) =>
        m.participantFK.equals(id))).get();
  }

  //==================== UPDATES ===============================================
  //==================== DELETES ===============================================
}


/// Establish connection to sqlite database
/// TODO later change where sqlite file is created
LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.

    /// TODO change path here later
    //final dbFolder = await getApplicationDocumentsDirectory();
    final tmpDbFolder = Directory('.');
    final file = File(p.join(tmpDbFolder.path, 'db.sqlite'));

    // Make sqlite3 pick a more suitable location for temporary files - the
    // one from the system may be inaccessible due to sandboxing.
    final cachebase = (await getTemporaryDirectory()).path;
    // We can't access /tmp on Android, which sqlite3 would try by default.
    // Explicitly tell it about the correct temporary directory.
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}