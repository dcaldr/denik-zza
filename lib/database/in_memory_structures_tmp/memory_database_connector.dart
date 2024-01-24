import 'package:denik_zza/database/in_memory_structures_tmp/memory_action.dart';

import '../database_interface.dart';
import 'memory_osoba.dart';
import 'memory_zaznam.dart';

/// in-memory Singleton representation of database for deveping app
///
/// This is a temporary solution for developing the app.
/// will be replaced by a real database later on.

class MemoryDatabase implements DatabaseInterface {
  static final MemoryDatabase _singleton = MemoryDatabase._internal();
  factory MemoryDatabase() {
    return _singleton;
  }

  MemoryDatabase._internal() {
    addOsoba(notNull);
  }

  int idOsoby = 0;
  int idZaznamu = 0;
  List<MemoryZaznam> zaznamy = [];
  List<MemoryOsoba> osoby = [];

  /// for development to always have someone to work with
  MemoryOsoba notNull = MemoryOsoba.basic("Not", "Null");

  @override
  Future<bool> addZaznam(MemoryZaznam zaznam) async {
    zaznam.idZaznamu = idZaznamu;
    idZaznamu++;
    zaznamy.add(zaznam);
    return true;
  }

  @override
  Future<bool> addOsoba(MemoryOsoba osoba) async {
    osoba.id = idOsoby;
    idOsoby++;
    osoby.add(osoba);
    return true;
  }

  @override
  String quickPrintZaznamyOsoby(int idOsoby) {
    String result = "";
    // if id not present return empty string if present append name and surname
    bool found = false;
    for (var element in osoby) {
      if (idOsoby == element.id) {
        result += "${element.jmeno} ${element.prijmeni}\n";
        found = true;
        break;
      }
    }
    if (!found) {
      result = "not found";
    }

    for (var element in zaznamy) {
      if (element.idPacient == idOsoby) {
        result += "$element\n";
      }
    }
    return result;
  }
  MemoryOsoba? getOsoba(int idOsoby) {
    // if id not present return empty string if present append name and surname
    for (var element in osoby) {
      if (idOsoby == element.id) {
        return element;
      }
    }
    return null;
  }



  @override
  Future<void> quickPrintAllOsoby() async {
    for (var element in osoby) {
      print("${element.id} ${element.jmeno} ${element.prijmeni}");
    }
  }

  @override
  Future<bool> quickAddNewZaznam(String popis,  idPacient ) async {
   return addZaznam(MemoryZaznam.short(popis, idPacient));
  }

 @override
Future<List<MemoryZaznam>> getRecordsByParticipantID(int id) async {
  return zaznamy.where((zaznam) => zaznam.idPacient == id).toList();
}

@override
Future<List<MemoryOsoba>> getParticipantsByEvent(int idEvent) async {
  // Assuming there's a field in MemoryOsoba that links to an action
  return osoby.where((osoba) => osoba.id == idEvent).toList();
}

@override
Future<int?> getPinnedEventID() async {
throw UnimplementedError();
}

@override
Future<List<MemoryOsoba>> getParticipantsByCurrentEvent() {
  // TODO: implement getParticipantsByPinnedEvent
  throw UnimplementedError();
}

@override
void updateCurrentEvent(int? currentEventID) {
  // TODO: implement updateCurrentEvent
}

@override
void updatePinnedEvent(int? pinnedEventID) {
  // TODO: implement updatePinnedEvent
}

@override
Future<int?> getCurrentEventID() {
  // TODO: implement getCurrentEventID
  throw UnimplementedError();
}

  @override
  Future<List<MemoryAction>> getAllZzaActions() {
    // TODO: implement getAllZzaActions
    throw UnimplementedError();
  }

  @override
  bool addEvent(MemoryAction action) {
    // TODO: implement addEvent
    throw UnimplementedError();
  }
}
