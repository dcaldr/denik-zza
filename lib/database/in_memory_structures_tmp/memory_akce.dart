/// Represents a class for modeling a memory action.
///
/// [idAkce] is the internal ID of the action.
/// [nadpis] is the title of the action. must be present
/// [folderPath] will be "home folder" for the action
class MemoryAction{
  late int? idAkce ;
  String nadpis;
  String? popis;
  DateTime odkdy;
  DateTime dokdy;
  String? domovskyAdresarPath;
MemoryAction({ required this.idAkce ,required this.nadpis, this.popis, required this.odkdy,required this.dokdy, this.domovskyAdresarPath});
///Constructor for [MemoryAction] with all forced parameters
  ///
  /// good for converting between classes
MemoryAction.fullNamed({required this.idAkce, required this.nadpis, required this.popis, required this.odkdy, required this.dokdy, required this.domovskyAdresarPath});
}