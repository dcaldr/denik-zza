

import 'in_memory_structures_tmp/memory_database.dart';
import 'in_memory_structures_tmp/memory_osoba.dart';
import 'in_memory_structures_tmp/memory_zaznam.dart';

/// Methods for high-level database interactions.
///
/// Right now, this is just a empty Wrapper for database-in progress.
/// Later on could be rewritten to point to a database.
class DatabaseWrapper {
  static final DatabaseWrapper _singleton = DatabaseWrapper._internal();

  factory DatabaseWrapper() {
    return _singleton;
  }

  DatabaseWrapper._internal();

  final MemoryDatabase _memoryDatabase = MemoryDatabase();

  bool addZaznam(MemoryZaznam zaznam) {
    return _memoryDatabase.addSingleZaznam(zaznam);
  }
  bool addNewZaznam( String popis, {int idPacient = 1} ) {
    return _memoryDatabase.addSingleZaznam(MemoryZaznam.short( popis,  idPacient));
  }

  bool addOsoba(MemoryOsoba osoba) {
    return _memoryDatabase.addSingleOsoba(osoba);
  }
  void quickPrintAllOsoby() {
    for (var element in _memoryDatabase.osoby) {
      print("${element.id} ${element.jmeno} ${element.prijmeni}");
    }
  }
}