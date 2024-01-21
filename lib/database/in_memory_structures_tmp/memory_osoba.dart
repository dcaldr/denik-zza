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

  String? rodneCislo;
  bool? zpusobilost;
  bool? bezinfekcnost;
  bool? wasPrinted;
  int? insuranceCompanyFK;
  int? zzaActionFK;

  MemoryOsoba( this.jmeno,  this.prijmeni, this.datumNarozeni, this.adresa,
      this.telefonniCislo, this.zdravotniPojistovna, this.cisloPojisteni, this.pohlavi,);
  MemoryOsoba.basic(this.jmeno, this.prijmeni);

  MemoryOsoba.named({
    required this.jmeno,
    required this.prijmeni,
    this.datumNarozeni,
    this.adresa,
    this.telefonniCislo,
    this.zdravotniPojistovna,
    this.cisloPojisteni,
    this.pohlavi,
  });
  MemoryOsoba.dummyData( this.jmeno,  this.prijmeni, this.datumNarozeni, this.adresa,
      this.telefonniCislo, this.zdravotniPojistovna, this.cisloPojisteni, this.pohlavi,);

  MemoryOsoba.complete(this.id, this.jmeno, this.prijmeni, this.adresa,
      this.rodneCislo, this.datumNarozeni, this.telefonniCislo, this.zpusobilost,
      this.bezinfekcnost, this.wasPrinted, this.insuranceCompanyFK, this.zzaActionFK);
}
