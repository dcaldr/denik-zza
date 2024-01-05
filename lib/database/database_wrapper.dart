

import 'database_interface.dart';
import 'in_memory_structures_tmp/memory_database.dart';
import 'in_memory_structures_tmp/memory_osoba.dart';
import 'in_memory_structures_tmp/memory_zaznam.dart';

/// Methods for high-level database interactions.
///
///  **Always use as ```dart
///   DatabaseInterface dbInterface = DatabaseWrapper();
///   ``` **
/// Right now, this is just a empty Wrapper for database-in progress.
/// Later on could be rewritten to point to a database.
class DatabaseWrapper implements DatabaseInterface {
  static final DatabaseWrapper _singleton = DatabaseWrapper._internal();

  factory DatabaseWrapper() {
    return _singleton;
  }

  DatabaseWrapper._internal();

  final MemoryDatabase _memoryDatabase = MemoryDatabase();

  @override
  Future<bool> addZaznam(MemoryZaznam zaznam) async => _memoryDatabase.addZaznam(zaznam);
  @override
  Future<bool> addQuickNewZaznam( String popis, {int idPacient = 1} ) async {
    return _memoryDatabase.addZaznam(MemoryZaznam.short( popis,  idPacient));
  }

  @override
  Future<bool> addOsoba(MemoryOsoba osoba) async {
    return _memoryDatabase.addOsoba(osoba);
  }
  @override
  Future<void> quickPrintAllOsoby() async {
    _memoryDatabase.quickPrintAllOsoby();
  }
  @override
  String quickPrintZaznamyOsoby(int idOsoby) {
    return _memoryDatabase.quickPrintZaznamyOsoby(idOsoby);
  }
}