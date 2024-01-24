/// Represents a class for modeling a memory action.
class MemoryAction{
  late int? idAkce ;
  String nadpis;
  String? popis;
  DateTime odkdy;
  DateTime dokdy;
MemoryAction({ required this.idAkce ,required this.nadpis, this.popis, required this.odkdy,required this.dokdy});
}