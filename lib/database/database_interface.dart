import 'in_memory_structures_tmp/memory_osoba.dart';
import 'in_memory_structures_tmp/memory_zaznam.dart';
/// interface between database and app
///
/// creates standards for databases to fulfil to be successfully used by the app
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
Future <bool> quickAddNewZaznam(String popis, int idPacient);

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
  /// Fetches a list of [MemoryZaznam] instances associated with a specific participant.
  ///
  /// This method takes an [id] as a parameter, which represents the ID of a participant.
  /// It queries the database for all [MemoryZaznam] instances that are associated with this participant.
  /// The method returns a [Future] that resolves to a [List] of [MemoryZaznam] instances.
  /// If no records are found for the given participant ID, the method returns an empty list.
Future<List<MemoryZaznam>> getRecordsByParticipantID(int id);

  /// Fetches a list of [MemoryOsoba] instances associated with a specific event.
  ///
  /// This method takes an [idEvent] as a parameter, which represents the ID of an event.
  /// It queries the database for all [MemoryOsoba] instances that are associated.
  /// The method returns a [Future] that resolves to a [List] of [MemoryOsoba] instances.
  /// If no participants are found for the given action ID, the method returns an empty list.
Future<List<MemoryOsoba>> getParticipantsByEvent(int idEvent);

  /// Updates the "settings" cache with a new [pinnedEventID].
  ///
  /// This method takes an [pinnedEventID] as a parameter, which represents the ID of an action that is to be pinned.
  /// It updates the cache with this new [pinnedEventID].
void updateCache(int? pinnedEventID);

  /// This method gets the pinned event ID
  ///
  /// The method returns a [Future] that resolves to an [int] which represents the pinned action ID.
  /// If no pinned action ID is found, the method returns `null`.
Future<int?> getPinnedEventID();
}