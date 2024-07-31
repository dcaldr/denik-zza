/// tmp mockup of omezeni/alergie class
class MemoryOmezeni{
  int? id;
  String omezeni;
  /// type of omezeni 1= omezeni 2=Alergie
  int typOmezeni =1;
  bool wasPrinted = false;
  int? idOsoby = -1;
  MemoryOmezeni.fullNamed({required  this.id,required this.idOsoby , required this.omezeni, required this.typOmezeni, this.wasPrinted = false});
  MemoryOmezeni.all(this.id, this.omezeni, this.typOmezeni, this.wasPrinted);
  MemoryOmezeni({
    this.id,
    required this.omezeni,
    this.typOmezeni = 1,
    this.wasPrinted = false,
    this.idOsoby =-1,
  }
  );
}