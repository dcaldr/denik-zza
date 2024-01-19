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
Future <bool> addZaznam(MemoryZaznam zaznam);

/// Adds a new [MemoryZaznam] for testing purposes.
///
/// This method creates a new `MemoryZaznam` instance with the provided `popis` and `idPacient` (default is 0),
/// and adds it to the database. Returns `true` if the operation is successful.
/// @Warning: uses idPacient 0 as default
Future <bool> quickAddNewZaznam(String popis, {int idPacient=0}); //FIXME: idPacient 0 as default

/// Adds a `MemoryOsoba` instance to the database.
///
/// This method takes a `MemoryOsoba` instance as a parameter and adds it to the database.
/// Returns `true` if the operation is successful.
Future <bool> addOsoba(MemoryOsoba osoba);

/// Prints all `MemoryOsoba` instances in the database. (for testing purposes)
///
/// This method iterates over all `MemoryOsoba` instances in the database and prints their details.
Future <void> quickPrintAllOsoby();

/// Prints all `MemoryZaznam` instances of a specific `MemoryOsoba` in the database.
///
/// This method takes an `idOsoby` as a parameter, finds the corresponding `MemoryOsoba` in the database,
/// iterates over all its `MemoryZaznam` instances and prints their details.
/// Returns a `String` containing the details of all `MemoryZaznam` instances.
String quickPrintZaznamyOsoby(int idOsoby);

//========= Vojtovy přidané metody =============================================

Future<List<MemoryZaznam>> getRecordsByParticipantID(int id);
}