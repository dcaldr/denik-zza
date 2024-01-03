import 'in_memory_structures_tmp/memory_osoba.dart';
import 'in_memory_structures_tmp/memory_zaznam.dart';
/// interface between database and app
///
/// Temporary solution while developing the app.
/// creates standarts for databses to fulfil and one point of contact for app
abstract class DatabaseInterface {
/// Adds a `MemoryZaznam` instance to the database.
///
/// This method takes a `MemoryZaznam` instance as a parameter and adds it to the database.
/// Returns `true` if the operation is successful.
bool addZaznam(MemoryZaznam zaznam);

/// Adds a new `MemoryZaznam` instance to the database with a quick method.
///
/// This method creates a new `MemoryZaznam` instance with the provided `popis` and `idPacient` (default is 0),
/// and adds it to the database. Returns `true` if the operation is successful.
bool addQuickNewZaznam(String popis, {int idPacient=0});

/// Adds a `MemoryOsoba` instance to the database.
///
/// This method takes a `MemoryOsoba` instance as a parameter and adds it to the database.
/// Returns `true` if the operation is successful.
bool addOsoba(MemoryOsoba osoba);

/// Prints all `MemoryOsoba` instances in the database.
///
/// This method iterates over all `MemoryOsoba` instances in the database and prints their details.
void quickPrintAllOsoby();

/// Prints all `MemoryZaznam` instances of a specific `MemoryOsoba` in the database.
///
/// This method takes an `idOsoby` as a parameter, finds the corresponding `MemoryOsoba` in the database,
/// iterates over all its `MemoryZaznam` instances and prints their details.
/// Returns a `String` containing the details of all `MemoryZaznam` instances.
String quickPrintZaznamyOsoby(int idOsoby);
}