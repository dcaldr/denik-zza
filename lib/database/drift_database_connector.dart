import 'package:denik_zza/database/in_memory_structures_tmp/memory_akce.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_lek.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_omezeni.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:drift/drift.dart';
import '../input/file_manager.dart';
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
    ParticipantsCompanion c2 = await _toParticipantsCompanion(osoba);
    await _driftDatabase.addParticipant(c2);
    //await _driftDatabase.addParticipant(c);

    return true;
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
    List<Participant> participants = await
    _driftDatabase.getParticipantsByAction(idEvent);
    // now a function
    // List<MemoryOsoba> memoryParticipants = [];
    //
    // for(Participant p in participants) {
    //   int? insCompFK = p.insuranceCompanyFK;
    //   InsuranceCompany? ic;
    //   String? insCompName;
    //
    //   if(insCompFK != null) {
    //     ic = await _driftDatabase.getInsuranceCompanyByID(insCompFK);
    //     insCompName = ic?.name;
    //   }
    //
    //   memoryParticipants.add(
    //     MemoryOsoba.fullNamed(id: p.id, jmeno: p.firstName, prijmeni: p.lastName,
    //     pohlavi: p.gender, adresa: p.address, cisloPojisteni: p.birthNumber,
    //     datumNarozeni: p.birthDate, telefonRodice: p.parentPhoneNumber,
    //     zpusobilost: p.eligibleConfirmation, bezinfekcnost: p.nonInfectiousConfirmation,
    //     wasPrinted: p.wasPrinted, zdravotniPojistovna: insCompName,
    //         jmenoRodice: p.parentName, emailRodice: p.parentEmail,
    //         poznamka: p.note, oddil: p.campUnit, prisel: p.arrivedConfirmation,
    //       potvrzeniPath: p.eligibleConfirmationPath,
    //
    //
    //     )
    //   );
    // }

    //return memoryParticipants;
    return Future.wait(participants.map(_toMemoryOsoba).toList()); //může být asi i bez wait
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
    return  records.map(_toMemoryZaznam).toList();
  }
  @Deprecated("Remove when possible")
  @override
  void updatePinnedEvent(int? pinnedEventID) async {
    _driftDatabase.updateCache(CacheCompanion(
        id: const Value(1),
        pinnedActionID: Value(pinnedEventID)
    ));
  }

  @override
  void updateCurrentEvent(int? currentEventID) async {
    FileManager().changeEvent();
    _driftDatabase.updateCache(CacheCompanion(
        id: const Value(1),
        currentActionID: Value(currentEventID)
    ));
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
    return currentEvent != null ? await getParticipantsByEvent(currentEvent) : [];
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
  return _toMemoryAction(zzaAction) ;
  }



  @override
  Future<bool> setNoteValue(int personId, String value) {
    return _driftDatabase.setNoteValue(personId, value);

  }

@override
Future<int> updateParticipant({int? idOverride, required MemoryOsoba osoba}) async {
  final id = idOverride ?? osoba.id;
final c = await _toParticipantsCompanion(osoba);
 return _driftDatabase.updateParticipant(id,  c);
  throw UnimplementedError();
}

@override
Future<int> updateEvent({int? idOverride, required MemoryAction action}) async {
  final id = idOverride ?? action.idAkce;
  final c = _toZzaActionsCompanion(action);

return _driftDatabase.updateEvent(id!, c);
  throw UnimplementedError();
}

  @override
  Future<bool> addLek(MemoryLek lek) async {
    int a = await _driftDatabase.addMedication(_toMedicationCompanion(lek));
   if(a> 0){
     return true;
   }
   return false;
  }

  @override
  Future<bool> addOmezeni(MemoryOmezeni omezeni) async{
    int a = await _driftDatabase.addAllergiesLimitations(_toRestrictionCompanion(omezeni));
    if(a> 0){
      return true;
    }
    return false;
  }

  @override
  Future<List<MemoryLek>> getAllLeky() {
    return _driftDatabase.getAllMedications().then((medications) => medications.map(_toMemoryLek).toList() as List<MemoryLek>);
  }
  @override
  Future<List<MemoryOmezeni>> getAllOmezeni() {
    return _driftDatabase.getAllAllergiesLimitations().then((allergiesLimitations) => allergiesLimitations.map(_toMemoryOmezeni).toList() as List<MemoryOmezeni>);
  }


 /// Translators from MemoryOsoba, MemoryZaznam, MemoryAction to Drift Companions
  /// TODO: rewrite to use MemoryX directly as db companion (

  Future<ParticipantsCompanion> _toParticipantsCompanion(MemoryOsoba osoba) async {
    return ParticipantsCompanion(
      firstName: Value(osoba.jmeno),
      lastName: Value(osoba.prijmeni),
      gender: Value(osoba.pohlavi),
      address: Value(osoba.adresa),
      birthNumber: Value(osoba.cisloPojisteni),
      birthDate: Value(osoba.datumNarozeni),
      parentPhoneNumber: Value(osoba.telefonRodice),
      eligibleConfirmation: Value(osoba.zpusobilost!),
      nonInfectiousConfirmation: Value(osoba.bezinfekcnost!),
        insuranceCompanyFK: Value(await _driftDatabase.getInsuranceCompanyIDbyName(osoba.zdravotniPojistovna)),
    zzaActionFK: Value((await _driftDatabase.getCurrentActionID())!),
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
      dateAndTime: Value(DateTime.now()),
      title: Value(zaznam.nazev!),
      description: Value(zaznam.popis!),
      treatment: const Value(""),
      paramedicFK: Value(zaznam.idAuthor),
      participantFK: Value(zaznam.idPacient),
      note: Value(zaznam.poznamka),
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
    String description = r.treatment != null ? '${r.description}\n${r.treatment}' : r.description;
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
  _toMedicationCompanion(lek) {
    return MedicationsCompanion(
      id: Value(lek.id),
      name: Value(lek.nazev),
      dosage: Value(lek.davkovani),
     //wasPrinted: Value(lek.wasPrinted),




     // note: Value(lek.poznamka),
    );
  }
  _toRestrictionCompanion(omezeni) {
    return AllergiesLimitationsCompanion(
      id: Value(omezeni.id),
      description: Value(omezeni.nazev),
      type: Value(omezeni.typ),
      //wasPrinted: Value(omezeni.wasPrinted),

    );
  }
  _toMemoryLek(Medication lek) {
    return MemoryLek.fullNamed(
      id: lek.id,
      nazev: lek.name,
      popisDavkovani: lek.dosage,

      //wasPrinted: lek.wasPrinted,
      //poznamka: lek.note,
    );
  }
  _toMemoryOmezeni(AllergiesLimitation omezeni) {
    return MemoryOmezeni.fullNamed(
      id: omezeni.id,
      omezeni: omezeni.description,
      typOmezeni: omezeni.type,


      //wasPrinted: omezeni.wasPrinted,
    );
  }


}