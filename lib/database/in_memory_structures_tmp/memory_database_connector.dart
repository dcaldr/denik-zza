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

 // Initialize with a default participant for development purposes.
  MemoryDatabase._internal() {
    addOsoba(notNull);
  }

  int idOsoby = 0;
  int idZaznamu = 0;
  List<MemoryZaznam> zaznamy = [];
  List<MemoryOsoba> osoby = [];

  /// for development to always have someone to work with
  MemoryOsoba notNull = MemoryOsoba.basic("Not", "Null");

// Adds a record, assign an ID, and increment the counter.
  @override
  Future<bool> addZaznam(MemoryZaznam zaznam) async {
    zaznam.idZaznamu = idZaznamu;
    idZaznamu++;
    zaznamy.add(zaznam);
    return true;
  }

 // Adds a participant, assigns an ID, and increments the counter.
  @override
  Future<bool> addOsoba(MemoryOsoba osoba) async {
    osoba.id = idOsoby;
    idOsoby++;
    osoby.add(osoba);
    return true;
  }

// Prints participant information and associated records.
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


// Prints information for all participants.
  @override
  Future<void> quickPrintAllOsoby() async {
    for (var element in osoby) {
      print("${element.id} ${element.jmeno} ${element.prijmeni}");
    }
  }

// Quickly adds a new record.
  @override
  Future<bool> quickAddNewZaznam(String popis,  idPacient ) async {
   return addZaznam(MemoryZaznam.short(popis, idPacient));
  }


 @override
Future<List<MemoryZaznam>> getRecordsByParticipantID(int id) async {
  return zaznamy.where((zaznam) => zaznam.idPacient == id).toList();
}

// Gets records associated with a participant ID.
@override
Future<List<MemoryOsoba>> getParticipantsByEvent(int idEvent) async {
  // Assuming there's a field in MemoryOsoba that links to an action
  return osoby.where((osoba) => osoba.id == idEvent).toList();
}

 // Gets participants associated with an event (assumes a field in MemoryOsoba linking to an action).
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

  @override
  Future<int> getParticipantCountInAction(int idAction) {
    // TODO: implement getParticipantCountInAction
    throw UnimplementedError();
  }

  @override
  bool setParticipantPrintedValue(int id, bool value) {
    // TODO: implement setParticipantPrintedValue
    throw UnimplementedError();
  }

  @override
  bool setRecordPrintedValue(int id, bool value) {
    // TODO: implement setRecordPrintedValue
    throw UnimplementedError();
  }
}
