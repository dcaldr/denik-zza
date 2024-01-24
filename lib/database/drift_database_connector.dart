import 'package:denik_zza/database/in_memory_structures_tmp/memory_action.dart';
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
  Future<bool> addOsoba(MemoryOsoba osoba) async {
    int? insCompId = await _driftDatabase.getInsuranceCompanyIDbyName(osoba.zdravotniPojistovna);

    if(insCompId == null) {
      _driftDatabase.addInsuranceCompany(
        InsuranceCompaniesCompanion(
          name: Value(osoba.zdravotniPojistovna!)
        )
      );
    }

    ParticipantsCompanion c = ParticipantsCompanion(
      firstName: Value(osoba.jmeno),
      lastName: Value(osoba.prijmeni),
      gender: Value(osoba.pohlavi),
      address: Value(osoba.adresa),
      birthNumber: Value(osoba.cisloPojisteni),
      birthDate: Value(osoba.datumNarozeni),
      parentPhoneNumber: Value(osoba.telefonniCislo),
      eligibleConfirmation: Value(osoba.zpusobilost!),
      nonInfectiousConfirmation: Value(osoba.bezinfekcnost!),
      insuranceCompanyFK: Value(await _driftDatabase.getInsuranceCompanyIDbyName(osoba.zdravotniPojistovna)),
      zzaActionFK: Value((await _driftDatabase.getCurrentActionID())!)
    );

    _driftDatabase.addParticipant(c);

    return true;
  }

  @override
  Future<bool> addZaznam(MemoryZaznam zaznam) async {
    RecordsCompanion c = RecordsCompanion(
      dateAndTime: Value(DateTime.now()),
      title: Value(zaznam.nazev!),
      description: Value(zaznam.popis),
      treatment: Value(""),
      paramedicFK: Value(zaznam.idAuthor),
      participantFK: Value(zaznam.idPacient)
    );

    _driftDatabase.addRecord(c);

    return true;
  }

  @override
  bool addEvent(MemoryAction action) {
    if(action.nadpis.isEmpty) {
      return false;
    }

    ZzaActionsCompanion c = ZzaActionsCompanion(
      actionTitle: Value(action.nadpis),
      actionDescription: Value(action.popis),
      dateFrom: Value(action.odkdy),
      dateTo: Value(action.dokdy)
    );

    _driftDatabase.addZzaAction(c);

    return true;
  }

  @override
  Future<List<MemoryOsoba>> getParticipantsByEvent(int idEvent) async {
    List<Participant> participants = await
    _driftDatabase.getParticipantsByAction(idEvent);

    List<MemoryOsoba> memoryParticipants = [];

    for(Participant p in participants) {
      int? insCompFK = p.insuranceCompanyFK;
      InsuranceCompany? ic;
      String? insCompName;

      if(insCompFK != null) {
        ic = await _driftDatabase.getInsuranceCompanyByID(insCompFK);
        insCompName = ic?.name;
      }

      memoryParticipants.add(
        MemoryOsoba.named(id: p.id, jmeno: p.firstName, prijmeni: p.lastName,
        pohlavi: p.gender, adresa: p.address, cisloPojisteni: p.birthNumber,
        datumNarozeni: p.birthDate, telefonniCislo: p.parentPhoneNumber,
        zpusobilost: p.eligibleConfirmation, bezinfekcnost: p.nonInfectiousConfirmation,
        wasPrinted: p.wasPrinted, zdravotniPojistovna: insCompName)
      );
    }

    return memoryParticipants;
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
  Future<List<MemoryZaznam>> getRecordsByParticipantID(int id) async {
    List<Record> records = await _driftDatabase.getRecordsByParticipantID(id);
    List<MemoryZaznam> memoryRecords = [];

    String description = "";

    for(Record r in records) {
      if(r.treatment != null) {
        description = '${r.description}\n${r.treatment}';
      }

      memoryRecords.add(MemoryZaznam.named(
          idZaznamu: r.id,
          casZaznamu: r.dateAndTime,
          nazev: r.title,
          popis: description,
          isPrinted: r.wasPrinted,
          idAuthor: r.paramedicFK,
          idPacient: r.participantFK
      ));
    }

    return memoryRecords;
  }

  @override
  void updatePinnedEvent(int? pinnedEventID) async {
    _driftDatabase.updateCache(CacheCompanion(
        id: const Value(1),
        pinnedActionID: Value(pinnedEventID)
    ));
  }

  @override
  void updateCurrentEvent(int? currentEventID) async {
    _driftDatabase.updateCache(CacheCompanion(
        id: const Value(1),
        currentActionID: Value(currentEventID)
    ));
  }

  @override
  Future<List<MemoryOsoba>> getParticipantsByCurrentEvent() async {
    int? currentEvent = await _driftDatabase.getCurrentActionID();
    List<MemoryOsoba> memoryParticipants = [];

    if(currentEvent != null) {
      memoryParticipants = await getParticipantsByEvent(currentEvent);
    }

    return memoryParticipants;
  }

  @override
  Future<List<MemoryAction>> getAllZzaActions() async {
    List<ZzaAction> actions = await _driftDatabase.getAllZzaActions();
    List<MemoryAction> memoryActions = [];

    for(ZzaAction a in actions) {
      memoryActions.add(MemoryAction(
          idAkce: a.id,
          nadpis: a.actionTitle,
          popis: a.actionDescription,
          odkdy: a.dateFrom,
          dokdy: a.dateTo
      ));
    }

    return memoryActions;
  }

  @override
  Future<int> getParticipantCountInAction(int idAction) async {
    List<Participant> p = await _driftDatabase.getParticipantsByAction(idAction);

    return p.length;
  }

  @override
  bool setRecordPrintedValue(int id, bool value) {
    _driftDatabase.setRecordPrintedValue(id, value);
    return true;
  }

  @override
  bool setParticipantPrintedValue(int id, bool value) {
    _driftDatabase.setParticipantPrintedValue(id, value);
    return true;
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
}