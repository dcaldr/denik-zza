/// development version of osoba class
///
/// More fileds can be added but use primary public methods
///
class MemoryOsoba {
  String jmeno;
  String prijmeni;
  DateTime? datumNarozeni;
  String? adresa;
  String? telefonniCislo; // rodiče
  String? zdravotniPojistovna;
  String? cisloPojisteni;
  int? pohlavi; // muž ==1 ,žena == 2
  late   int id; // may use -1 means not assigned

  MemoryOsoba(this.jmeno, this.prijmeni, this.datumNarozeni, this.adresa,
      this.telefonniCislo, this.zdravotniPojistovna, this.cisloPojisteni, this.pohlavi,);
  MemoryOsoba.basic(this.jmeno, this.prijmeni);



}
