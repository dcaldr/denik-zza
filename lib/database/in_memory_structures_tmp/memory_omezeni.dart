/// tmp mockup of omezeni/alergie class
class Omezeni{
  int? id;
  String omezeni;
  /// type of omezeni 1= omezeni 2=Alergie
  int typOmezeni =1;

  Omezeni.all(this.id, this.omezeni, this.typOmezeni);
  Omezeni({
    this.id,
    required this.omezeni,
    this.typOmezeni = 1,
  });
}