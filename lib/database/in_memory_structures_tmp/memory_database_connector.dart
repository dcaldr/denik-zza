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
Future<List<MemoryOsoba>> getParticipantsByEvent(int idAction) async {
  // Assuming there's a field in MemoryOsoba that links to an action
  return osoby.where((osoba) => osoba.id == idAction).toList();
}

@override
Future<int?> getPinnedEventID() async {
throw UnimplementedError();
}

@override
void updateCache(int? pinnedActionID) async {
throw UnimplementedError();
}
}
