import '../databaseInterface.dart';
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
  bool addZaznam(MemoryZaznam zaznam) {
    zaznam.idZaznamu = idZaznamu;
    idZaznamu++;
    zaznamy.add(zaznam);
    return true;
  }

  @override
  bool addOsoba(MemoryOsoba osoba) {
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
  void quickPrintAllOsoby() {
    for (var element in osoby) {
      print("${element.id} ${element.jmeno} ${element.prijmeni}");
    }
  }

  @override
  bool addQuickNewZaznam(String popis, {int idPacient = 0}) {
   return addZaznam(MemoryZaznam.short(popis, idPacient));
  }




}
