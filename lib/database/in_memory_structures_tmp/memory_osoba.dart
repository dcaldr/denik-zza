/// development version of osoba class
///
/// More fileds can be added but use primary public methods
///
class MemoryOsoba {
  late int id; // may use -1 means not assigned
  String jmeno;
  String prijmeni;
  int? pohlavi; // muž ==1 ,žena == 2
  String? adresa;
  String? cisloPojisteni;
  DateTime? datumNarozeni;
  String? jmenoRodice; //FIXME: zařadit do aplikace
  String? telefonniCislo; // rodiče //TODO: rename telefoniCisloRodice
  String? emailRodice; //FIXME: zařadit do aplikace
  bool? zpusobilost;
  bool? bezinfekcnost;
  bool? wasPrinted;
  String? zdravotniPojistovna;
  String? oddil; //FIXME: zařadit do aplikace - lze změnit typ, jde o návrh

 /// Constructs a [MemoryOsoba] instance with essential parameters.
  MemoryOsoba( this.jmeno,  this.prijmeni, this.datumNarozeni, this.adresa,
      this.telefonniCislo, this.zdravotniPojistovna, this.cisloPojisteni, this.pohlavi,);

      /// Constructs a basic [MemoryOsoba] instance with only name and surname.
  MemoryOsoba.basic(this.jmeno, this.prijmeni);

/// Constructs a [MemoryOsoba] instance with named parameters.
  MemoryOsoba.named({
    required this.id,
    required this.jmeno,
    required this.prijmeni,
    this.pohlavi,
    this.adresa,
    this.cisloPojisteni,
    this.datumNarozeni,
    this.telefonniCislo,
    required this.zpusobilost,
    required this.bezinfekcnost,
    this.wasPrinted,
    this.zdravotniPojistovna,
  });

  /// Constructs a [MemoryOsoba] instance with dummy data.
  MemoryOsoba.dummyData( this.jmeno,  this.prijmeni, this.datumNarozeni, this.adresa,
      this.telefonniCislo, this.zdravotniPojistovna, this.cisloPojisteni, this.pohlavi,);
}
