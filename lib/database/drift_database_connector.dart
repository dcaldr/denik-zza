import 'package:denik_zza/database/in_memory_structures_tmp/memory_akce.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_lek.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_omezeni.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:drift/drift.dart';
import 'package:denik_zza/utils/app_logger.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import '../input/file_manager.dart';
import 'package:denik_zza/database/database_interface.dart';
import 'package:denik_zza/database/drift_database/database.dart';

/// Singleton Connector to Drift database
///
/// bridge between the app and the sqlite (drift) database
///
/// **Architecture Note (Testing):**
/// This class implements a "Resettable Lazy Singleton".
/// Unlike a standard final singleton, this instance can be destroyed via [reset].
/// This is required to support isolated tests where the database connection
/// must be potentially closed and re-opened pointing to a new path.
///
/// **Do not revert to `static final` without alternative isolation strategy.**
class DriftDatabaseConnector implements DatabaseInterface {
  static DriftDatabaseConnector? _singleton;

  // Singleton factory for default production usage
  factory DriftDatabaseConnector() {
    _singleton ??= DriftDatabaseConnector._internal();
    return _singleton!;
  }

  DriftDatabaseConnector._internal() : _driftDatabase = AppDatabase();

  /// Drift database instance (defaults to production AppDatabase()).
  /// In tests or dev runs, use [DriftDatabaseConnector.withDatabase] to inject
  /// an in-memory AppDatabase created with AppDatabase.testInMemory().
  AppDatabase _driftDatabase;

  /// Expose underlying AppDatabase for direct operations.
  ///
  /// Use sparingly - prefer interface methods when possible.
  AppDatabase get appDatabase => _driftDatabase;

  /// Test-only: Create a connector bound to a provided [AppDatabase].
  ///
  /// This is useful to inject an in-memory database for tests or dev runs
  /// without affecting the production singleton state globally.
  DriftDatabaseConnector.withDatabase(AppDatabase database)
      : _driftDatabase = database;

  /// Resets the singleton and closes the database connection.
  /// This is CRITICAL for test isolation.
  static Future<void> reset() async {
    if (_singleton != null) {
      await _singleton!.close();
      _singleton = null;
    }
  }

  @override
  Future<int?> addOsobaAndReturnId(MemoryOsoba osoba) async {
    final currentEventId = await _driftDatabase.getCurrentActionID();
    if (currentEventId == null) {
      AppLogger.l.w(
          '[Database] addOsobaAndReturnId called without current event; skipping insert');
      return null;
    }
    int? insCompId;
    if (osoba.zdravotniPojistovna != null &&
        osoba.zdravotniPojistovna!.trim().isNotEmpty) {
      insCompId = await _driftDatabase
          .getInsuranceCompanyIDbyName(osoba.zdravotniPojistovna);
    }

    // Only create insurance company if the name is not empty/null
    if (insCompId == null &&
        osoba.zdravotniPojistovna != null &&
        osoba.zdravotniPojistovna!.trim().isNotEmpty) {
      await _driftDatabase.addInsuranceCompany(InsuranceCompaniesCompanion(
        name: Value(osoba.zdravotniPojistovna!),
      ));
      // Update insCompId after creating the insurance company
      insCompId = await _driftDatabase
          .getInsuranceCompanyIDbyName(osoba.zdravotniPojistovna);
    }
    // If insurance company name is empty/null, insCompId remains null
    ///Now a function
    // ParticipantsCompanion c = ParticipantsCompanion(
    //   firstName: Value(osoba.jmeno),
    //   lastName: Value(osoba.prijmeni),
    //   gender: Value(osoba.pohlavi),
    //   address: Value(osoba.adresa),
    //   birthNumber: Value(osoba.cisloPojisteni),
    //   birthDate: Value(osoba.datumNarozeni),
    //   parentPhoneNumber: Value(osoba.telefonRodice),
    //   eligibleConfirmation: Value(osoba.zpusobilost!),
    //   nonInfectiousConfirmation: Value(osoba.bezinfekcnost!),
    //   insuranceCompanyFK: Value(await _driftDatabase.getInsuranceCompanyIDbyName(osoba.zdravotniPojistovna)),
    //   zzaActionFK: Value((await _driftDatabase.getCurrentActionID())!),
    //   // note: přidáno
    //   parentName: Value(osoba.jmenoRodice),
    //   parentEmail: Value(osoba.emailRodice),
    //   campUnit: Value(osoba.oddil),
    //   note: Value(osoba.poznamka),
    //   arrivedConfirmation: Value(osoba.prisel),
    //   eligibleConfirmationPath: Value(osoba.potvrzeniPath)
    //
    // );
    ParticipantsCompanion c2 =
      await _toParticipantsCompanion(osoba, currentEventId);
    int osobaID = await _driftDatabase.addParticipant(c2);
    //await _driftDatabase.addParticipant(c);

    return osobaID;
  }

  @override
  Future<bool> addOsoba(MemoryOsoba osoba) {
    return addOsobaAndReturnId(osoba).then((id) => id != null);
  }

  @override
  Future<bool> addZaznam(MemoryZaznam zaznam) async {
    // now a function
    // RecordsCompanion c = RecordsCompanion(
    //   dateAndTime: Value(DateTime.now()),
    //   title: Value(zaznam.nazev!),
    //   description: Value(zaznam.popis!),
    //   treatment: const Value(""),
    //   paramedicFK: Value(zaznam.idAuthor),
    //   participantFK: Value(zaznam.idPacient),
    //     //note: přidáno
    //     note: Value(zaznam.poznamka),
    //     picturePath: Value(zaznam.obrazekPath)
    // );
    await _driftDatabase.addRecord(_toRecordsCompanion(zaznam));
    //_driftDatabase.addRecord(c);

    return true;
  }

  @override
  Future<bool> addEvent(MemoryAction action) async {
    if (action.nadpis.isEmpty) return false;
    // now a function
    // final c = ZzaActionsCompanion(
    //   actionTitle: Value(action.nadpis),
    //   actionDescription: Value(action.popis),
    //   dateFrom: Value(action.odkdy),
    //   dateTo: Value(action.dokdy),
    //   homeDirectory: Value(action.domovskyAdresarPath),
    // );

    try {
      await _driftDatabase.addZzaAction(_toZzaActionsCompanion(action));
      //await _driftDatabase.addZzaAction(c);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<MemoryOsoba>> getParticipantsByEvent(int idEvent) async {
    List<Participant> participants =
        await _driftDatabase.getParticipantsByAction(idEvent);
    if (participants.isEmpty) {
      return [];
    }

    final mappedParticipants = await Future.wait(
      participants.map((participant) async {
        try {
          return await _toMemoryOsoba(participant);
        } catch (e, st) {
          AppLogger.l.e(
            '[Database] Failed to map participant id=${participant.id} for event=$idEvent',
            error: e,
            stackTrace: st,
          );
          return null;
        }
      }),
    );

    return mappedParticipants.whereType<MemoryOsoba>().toList();
  }

  @override
  Future<int?> getPinnedEventID() async {
    return _driftDatabase.getPinnedActionID();
  }

  @override
  Future<int?> getCurrentEventID() async {
    return _driftDatabase.getCurrentActionID();
  }

  @override
  Future<bool?> getPrinterPage1OnTop() async {
    return _driftDatabase.getPrinterPage1OnTop();
  }

  @override
  Future<void> setPrinterPage1OnTop(bool? value) async {
    await _driftDatabase.updateCache(CacheCompanion(
      id: const Value(1),
      printerPage1OnTop: Value(value),
    ));
  }

  @override
  Future<List<MemoryZaznam>> getRecordsByParticipantID(int id) async {
    List<Record> records = await _driftDatabase.getRecordsByParticipantID(id);
    // now a function
    // List<MemoryZaznam> memoryRecords = [];
    //
    // String description = "";
    //
    // for(Record r in records) {
    //   if(r.treatment != null) {
    //     description = '${r.description}\n${r.treatment}';
    //   }
    //
    //   memoryRecords.add(MemoryZaznam.fullNamed(
    //       idZaznamu: r.id,
    //       casZaznamu: r.dateAndTime,
    //       nazev: r.title,
    //       popis: description,
    //       isPrinted: r.wasPrinted,
    //       idAuthor: r.paramedicFK,
    //       idPacient: r.participantFK,
    //       poznamka: r.note,
    //       teplota: r.temperature,
    //       obrazekPath: r.picturePath
    //
    //
    //   ));
    // }

    //return memoryRecords;
    return records.map(_toMemoryZaznam).toList();
  }

  @Deprecated("Remove when possible")
  @override
  Future<void> updatePinnedEvent(int? pinnedEventID) async {
    await _driftDatabase.updateCache(CacheCompanion(
        id: const Value(1), pinnedActionID: Value(pinnedEventID)));
  }

  @override
  Future<void> updateCurrentEvent(int? currentEventID) async {
    // FIRST: Update cache so getCurrentActionID() returns correct value
    await _driftDatabase.updateCache(CacheCompanion(
        id: const Value(1), currentActionID: Value(currentEventID)));
    // THEN: Sync FileManager.eventDir from the updated cache
    await FileManager().changeEvent();
  }

  @override
  Future<List<MemoryOsoba>> getParticipantsByCurrentEvent() async {
    int? currentEvent = await _driftDatabase.getCurrentActionID();

    // now a function
    //   List<MemoryOsoba> memoryParticipants = [];
    //
    //   if(currentEvent != null) {
    //     memoryParticipants = await getParticipantsByEvent(currentEvent);
    //   }
    //
    // return memoryActions;
    return currentEvent != null
        ? await getParticipantsByEvent(currentEvent)
        : [];
  }

  //
  @override
  Future<List<MemoryAction>> getAllZzaActions() async {
    List<ZzaAction> actions = await _driftDatabase.getAllZzaActions();
    // now a function
    // List<MemoryAction> memoryActions = [];
    //
    // for(ZzaAction a in actions) {
    //   memoryActions.add(MemoryAction.fullNamed(
    //       idAkce: a.id,
    //       nadpis: a.actionTitle,
    //       popis: a.actionDescription,
    //       odkdy: a.dateFrom,
    //       dokdy: a.dateTo,
    //       domovskyAdresarPath: a.homeDirectory,
    //   ));
    // }
    return actions.map(_toMemoryAction).toList();
    //   return memoryActions;
  }

  @override
  Future<int> getParticipantCountInAction(int idAction) async {
    List<Participant> p =
        await _driftDatabase.getParticipantsByAction(idAction);

    return p.length;
  }

  @override
  Future<bool> setRecordPrintedValue(int id, bool value) async {
    final rows = await _driftDatabase.setRecordPrintedValue(id, value);
    return rows > 0;
  }

  @override
  Future<bool> setParticipantPrintedValue(int id, bool value) async {
    final rows = await _driftDatabase.setParticipantPrintedValue(id, value);
    return rows > 0;
  }

  @override
  Future<bool> quickAddNewZaznam(String popis, int idPacient) {
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

//note: přidáno -- TODO: rewrite to db side of the code (ie return finished MemoryAction)
  @override
  Future<MemoryAction?> getCurrentAction() async {
    final currentActionId = await _driftDatabase.getCurrentActionID();
    if (currentActionId == null) {
      return null;
    }
    final zzaAction = await _driftDatabase.getZzaActionByID(currentActionId);
    if (zzaAction == null) {
      return null;
    }
    // now a function
    // return MemoryAction.fullNamed(
    //   idAkce: zzaAction.id,
    //   nadpis: zzaAction.actionTitle,
    //   popis: zzaAction.actionDescription,
    //   odkdy: zzaAction.dateFrom,
    //   dokdy: zzaAction.dateTo,
    //   domovskyAdresarPath: zzaAction.homeDirectory,
    // );
    // return memoryActions;
    return _toMemoryAction(zzaAction);
  }

  @override
  Future<bool> setNoteValue(int personId, String value) {
    return _driftDatabase.setNoteValue(personId, value);
  }

  @override
  Future<int> updateParticipant(
      {int? idOverride, required MemoryOsoba osoba}) async {
    final id = idOverride ?? osoba.id;
    final currentEventId = await _driftDatabase.getCurrentActionID();
    if (currentEventId == null) {
      AppLogger.l.w(
          '[Database] updateParticipant called without current event; skipping update for participant id=$id');
      return 0;
    }
    final c = await _toParticipantsCompanion(osoba, currentEventId);
    return _driftDatabase.updateParticipant(id, c);
  }

  @override
  Future<int> updateEvent(
      {int? idOverride, required MemoryAction action}) async {
    final id = idOverride ?? action.idAkce;
    final c = _toZzaActionsCompanion(action);

    return _driftDatabase.updateEvent(id!, c);
  }

  @override
  Future<bool> addLek(MemoryLek lek) async {
    MedicationsCompanion c = _toMedicationCompanion(lek);

    int a = await _driftDatabase.addMedication(c);
    if (a > 0) {
      return true;
    }
    return false;
  }

  @override
  Future<bool> addOmezeni(MemoryOmezeni omezeni) async {
    int a = await _driftDatabase
        .addAllergiesLimitations(_toRestrictionCompanion(omezeni));
    if (a > 0) {
      return true;
    }
    return false;
  }

  @override
  Future<List<MemoryLek>> getAllLeky() {
    return _driftDatabase.getAllMedications().then(
        (medications) => medications.map<MemoryLek>(_toMemoryLek).toList());
  }

  @override
  Future<List<MemoryOmezeni>> getAllOmezeni() {
    return _driftDatabase.getAllAllergiesLimitations().then(
        (allergiesLimitations) =>
            allergiesLimitations.map(_toMemoryOmezeni).toList());
  }

  @override
  Future<List<MemoryLek>> getLekyByParticipantID(int id) {
    return _driftDatabase
        .getMedicationsByParticipantID(id)
        .then((medications) => medications.map(_toMemoryLek).toList());
  }

  @override
  Future<List<MemoryOmezeni>> getOmezeniByParticipantID(int id) {
    return _driftDatabase.getAllergiesLimitationsByParticipantID(id).then(
        (allergiesLimitations) =>
            allergiesLimitations.map(_toMemoryOmezeni).toList());
  }

  @override
  Future<MemoryOsoba> getOsobaById(int id) async {
    try {
      final participant = await _driftDatabase.getParticipantByID(id);
      if (participant == null) {
        final error = StateError('Participant id=$id was not found');
        AppLogger.l.e('[Database] getOsobaById failed', error: error);
        throw error;
      }

      return await _toMemoryOsoba(participant);
    } catch (e, st) {
      AppLogger.l.e('[Database] Failed to load participant id=$id',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Stream<List<MemoryOsoba>> watchParticipantsByEvent(int idAction) {
    return _driftDatabase
        .watchParticipantsByAction(idAction)
        .asyncMap((participants) async {
      if (DatabaseWrapper.isShuttingDown()) {
        return <MemoryOsoba>[];
      }

      AppLogger.l.i(
          '[WatchParticipants] event=$idAction rawCount=${participants.length}');
      for (final p in participants) {
        AppLogger.l.i(
            '[WatchParticipants] RAW participant id=${p.id} first="${p.firstName}" last="${p.lastName}" insuranceFK=${p.insuranceCompanyFK}');
      }

      List<MemoryOsoba> memoryParticipants = [];
      for (Participant p in participants) {
        if (DatabaseWrapper.isShuttingDown()) {
          return <MemoryOsoba>[];
        }
        memoryParticipants.add(await _toMemoryOsoba(p));
      }

      for (final p in memoryParticipants) {
        AppLogger.l.i(
            '[WatchParticipants] MAPPED participant id=${p.id} jmeno="${p.jmeno}" prijmeni="${p.prijmeni}" display="${p.jmeno} ${p.prijmeni}" insurance="${p.zdravotniPojistovna}"');
      }
      return memoryParticipants;
    });
  }

  /// Watch participants by current event with real-time updates
  ///
  /// Uses watchSingleOrNull to avoid throwing when the cache table is empty
  /// (common in tests before setup). Emits an empty list until a current event
  /// is set.
  @override
  Stream<List<MemoryOsoba>> watchParticipantsByCurrentEvent() {
    return _driftDatabase
        .select(_driftDatabase.cache)
        .watchSingleOrNull()
        .asyncExpand((cache) {
      final currentEvent = cache?.currentActionID;
      AppLogger.l.i(
          '[WatchParticipants] currentEvent from cache=$currentEvent');
      if (currentEvent != null) {
        return watchParticipantsByEvent(currentEvent);
      } else {
        AppLogger.l.w(
            '[WatchParticipants] currentEvent is null, emitting empty participants list');
        return Stream.value(<MemoryOsoba>[]);
      }
    });
  }

  @override
  Stream<List<({MemoryOsoba person, List<MemoryZaznam> records})>>
      watchPersonDetailsByCurrentEvent() {
    return _driftDatabase
        .select(_driftDatabase.cache)
        .watchSingleOrNull()
        .asyncExpand((cache) {
      if (DatabaseWrapper.isShuttingDown()) {
        return Stream.value(
            <({MemoryOsoba person, List<MemoryZaznam> records})>[]);
      }

      final currentEventId = cache?.currentActionID;
      if (currentEventId == null) {
        return Stream.value(
            <({MemoryOsoba person, List<MemoryZaznam> records})>[]);
      }

      final query = _driftDatabase.select(_driftDatabase.participants).join([
        leftOuterJoin(
          _driftDatabase.records,
          _driftDatabase.records.participantFK
              .equalsExp(_driftDatabase.participants.id),
        ),
      ]);
      
      query.where(_driftDatabase.participants.zzaActionFK.equals(currentEventId));
      query.orderBy([OrderingTerm(expression: _driftDatabase.participants.lastName), OrderingTerm(expression: _driftDatabase.participants.firstName)]);

      return query.watch().asyncMap((rows) async {
        if (DatabaseWrapper.isShuttingDown()) {
          return <({MemoryOsoba person, List<MemoryZaznam> records})>[];
        }

        final grouped = <int,
            ({MemoryOsoba person, List<MemoryZaznam> records})>{};

        for (final row in rows) {
          if (DatabaseWrapper.isShuttingDown()) {
            return <({MemoryOsoba person, List<MemoryZaznam> records})>[];
          }

          final participant = row.readTable(_driftDatabase.participants);
          final record = row.readTableOrNull(_driftDatabase.records);

          if (!grouped.containsKey(participant.id)) {
            grouped[participant.id] = (
              person: await _toMemoryOsoba(participant),
              records: <MemoryZaznam>[],
            );
          }

          if (record != null) {
            grouped[participant.id]!.records.add(_toMemoryZaznam(record));
          }
        }

        return grouped.values.toList();
      });
    });
  }

  /// Translators from MemoryOsoba, MemoryZaznam, MemoryAction to Drift Companions
  /// TODO: rewrite to use MemoryX directly as db companion (
    Future<ParticipantsCompanion> _toParticipantsCompanion(
      MemoryOsoba osoba, int currentEventId) async {
    // Get insurance company ID, but only if name is not empty
    int? insCompId;
    if (osoba.zdravotniPojistovna != null &&
        osoba.zdravotniPojistovna!.trim().isNotEmpty) {
      insCompId = await _driftDatabase
          .getInsuranceCompanyIDbyName(osoba.zdravotniPojistovna);
    }

    return ParticipantsCompanion(
      firstName: Value(osoba.jmeno),
      lastName: Value(osoba.prijmeni),
      gender: Value(osoba.pohlavi),
      address: Value(osoba.adresa),
      birthNumber: Value(osoba.cisloPojisteni),
      birthDate: Value(osoba.datumNarozeni),
      parentPhoneNumber: Value(osoba.telefonRodice),
      eligibleConfirmation: Value(osoba.zpusobilost ?? false),
      nonInfectiousConfirmation: Value(osoba.bezinfekcnost ?? false),
      insuranceCompanyFK: Value(insCompId),
      zzaActionFK: Value(currentEventId),
      parentName: Value(osoba.jmenoRodice),
      parentEmail: Value(osoba.emailRodice),
      campUnit: Value(osoba.oddil),
      note: Value(osoba.poznamka),
      arrivedConfirmation: Value(osoba.prisel),
      eligibleConfirmationPath: Value(osoba.potvrzeniPath),
    );
  }

  RecordsCompanion _toRecordsCompanion(MemoryZaznam zaznam) {
    return RecordsCompanion(
      dateAndTime: Value(zaznam.casZaznamu ?? DateTime.now()),
      title: Value(zaznam.nazev!),
      description: Value(zaznam.popis!),
      treatment: const Value(""),
      paramedicFK: Value(zaznam.idAuthor),
      participantFK: Value(zaznam.idPacient),
      note: Value(zaznam.poznamka),
      temperature: Value(zaznam.teplota),
      picturePath: Value(zaznam.obrazekPath),
    );
  }

  ZzaActionsCompanion _toZzaActionsCompanion(MemoryAction action) {
    return ZzaActionsCompanion(
      actionTitle: Value(action.nadpis),
      actionDescription: Value(action.popis),
      dateFrom: Value(action.odkdy),
      dateTo: Value(action.dokdy),
      homeDirectory: Value(action.domovskyAdresarPath),
    );
  }

  Future<MemoryOsoba> _toMemoryOsoba(Participant p) async {
    int? insCompFK = p.insuranceCompanyFK;
    InsuranceCompany? ic;
    String? insCompName;

    if (insCompFK != null) {
      ic = await _driftDatabase.getInsuranceCompanyByID(insCompFK);
      insCompName = ic?.name;
    }

    if (p.lastName.trim().isEmpty) {
      AppLogger.l.w(
          '[WatchParticipants] EMPTY LAST NAME detected during mapping: id=${p.id}, first="${p.firstName}", rawLast="${p.lastName}"');
    }

    return MemoryOsoba.fullNamed(
      id: p.id,
      jmeno: p.firstName,
      prijmeni: p.lastName,
      pohlavi: p.gender,
      adresa: p.address,
      cisloPojisteni: p.birthNumber,
      datumNarozeni: p.birthDate,
      telefonRodice: p.parentPhoneNumber,
      zpusobilost: p.eligibleConfirmation,
      bezinfekcnost: p.nonInfectiousConfirmation,
      wasPrinted: p.wasPrinted,
      zdravotniPojistovna: insCompName,
      jmenoRodice: p.parentName,
      emailRodice: p.parentEmail,
      poznamka: p.note,
      oddil: p.campUnit,
      prisel: p.arrivedConfirmation,
      potvrzeniPath: p.eligibleConfirmationPath,
    );
  }

  MemoryZaznam _toMemoryZaznam(Record r) {
    String description = r.treatment != null
        ? '${r.description}\n${r.treatment}'
        : r.description;
    return MemoryZaznam.fullNamed(
      idZaznamu: r.id,
      casZaznamu: r.dateAndTime,
      nazev: r.title,
      popis: description,
      isPrinted: r.wasPrinted,
      idAuthor: r.paramedicFK,
      idPacient: r.participantFK,
      poznamka: r.note,
      teplota: r.temperature,
      obrazekPath: r.picturePath,
    );
  }

  MemoryAction _toMemoryAction(ZzaAction a) {
    return MemoryAction.fullNamed(
      idAkce: a.id,
      nadpis: a.actionTitle,
      popis: a.actionDescription,
      odkdy: a.dateFrom,
      dokdy: a.dateTo,
      domovskyAdresarPath: a.homeDirectory,
    );
  }

  MedicationsCompanion _toMedicationCompanion(MemoryLek lek) {
    final details = lek.popisDavkovani?.trim();
    String? dosage;
    String? dosageTiming;

    if (details != null && details.isNotEmpty) {
      final commaIndex = details.indexOf(',');
      if (commaIndex >= 0) {
        dosage = details.substring(0, commaIndex).trim();
        dosageTiming = details.substring(commaIndex + 1).trim();
        if (dosageTiming.isEmpty) {
          dosageTiming = null;
        }
      } else {
        dosage = details;
      }
    }

    return MedicationsCompanion(
      name: Value(lek.nazev),
      dosage: dosage != null ? Value(dosage) : const Value(null),
      dosageTiming: dosageTiming != null ? Value(dosageTiming) : const Value(null),
      wasPrinted: Value(lek.wasPrinted),
      participantFK: Value(lek.idOsoby),
    );
  }

  AllergiesLimitationsCompanion _toRestrictionCompanion(MemoryOmezeni omezeni) {
    return AllergiesLimitationsCompanion(
      //id: Value(omezeni.id),
      description: Value(omezeni.omezeni),
      type: Value(omezeni.typOmezeni),
      wasPrinted: Value(omezeni.wasPrinted),
      participantFK: Value(omezeni.idOsoby ?? -1),
    );
  }

  MemoryLek _toMemoryLek(Medication lek) {
    final details = <String>[];
    final dosage = lek.dosage?.trim();
    final dosageTiming = lek.dosageTiming?.trim();
    if (dosage != null && dosage.isNotEmpty) {
      details.add(dosage);
    }
    if (dosageTiming != null && dosageTiming.isNotEmpty) {
      details.add(dosageTiming);
    }

    return MemoryLek.fullNamed(
      id: lek.id,
      nazev: lek.name,
      popisDavkovani: details.isEmpty ? null : details.join(', '),
      idOsoby: lek.participantFK,

      wasPrinted: lek.wasPrinted,
      //poznamka: lek.note,
    );
  }

  MemoryOmezeni _toMemoryOmezeni(AllergiesLimitation omezeni) {
    return MemoryOmezeni.fullNamed(
      id: omezeni.id,
      omezeni: omezeni.description,
      typOmezeni: omezeni.type,
      idOsoby: omezeni.participantFK,
      wasPrinted: omezeni.wasPrinted,
    );
  }

  @override
  Future<void> close() async {
    await _driftDatabase.close();
  }
}
