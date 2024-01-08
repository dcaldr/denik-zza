import 'package:drift/drift.dart';

import 'dart:io';

import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [InsuranceCompanies, ZzaActions, Participants,
  Paramedics, Records])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

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

  /// Get zzaAction based on ID
  /// Returns null if id is not present in database
  Future<ZzaAction?> getZzaActionById(int id) async {
    List<ZzaAction> actionResult = await (select(zzaActions)
      ..where((a) => a.id.equals(id))
    ).get();

    return actionResult.firstOrNull;
  }

  /// Get records based on participant ID
  Future<List<Record>> getRecordsByParticipant(int id) async {
    List<Record> recordsResult = await (select(records)
      ..where((r) => r.participant.equals(id))
    ).get();

    return recordsResult;
  }

  /// Get insurance company by ID
  /// Returns null if id is not present in database
  Future<InsuranceCompany?> getInsuranceCompanyById(int id) async {
    List<InsuranceCompany> insCompanyResult = await (select(insuranceCompanies)
      ..where((i) => i.id.equals(id))
    ).get();

    return insCompanyResult.firstOrNull;
  }
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