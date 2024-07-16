///Manin [MemoryOsoba] class
///
/// Holds all nesserary data for one person, might be later restroctured to be multiple classes
///
class MemoryOsoba {
  late int id; // may use -1 means not assigned
  String jmeno;
  String prijmeni;
  int? pohlavi; // muž ==1 ,žena == 2 // TODO: add named constants for pohlavi
  String? adresa;
  String? cisloPojisteni;
  DateTime? datumNarozeni;
  String? jmenoRodice; //FIXME: zařadit do aplikace
  String? telefonRodice; // rodiče
  String? emailRodice; //FIXME: zařadit do aplikace
  bool? zpusobilost;
  bool? bezinfekcnost;
  bool? wasPrinted;
  String? zdravotniPojistovna;
  String? oddil; //FIXME: zařadit do aplikace - lze změnit typ, jde o návrh
  String? poznamka; //FIXME zařadit do aplikace
  bool prisel = false; //FIXME: zařadit do aplikace
  String? potvrzeniPath; //FIXME: zařadit do aplikace

 /// Constructs a [MemoryOsoba] instance with essential parameters.
  MemoryOsoba( this.jmeno,  this.prijmeni, this.datumNarozeni, this.adresa,
      this.telefonRodice, this.zdravotniPojistovna, this.cisloPojisteni, this.pohlavi,);

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
    this.telefonRodice,
    required this.zpusobilost,
    required this.bezinfekcnost,
    this.wasPrinted,
    this.zdravotniPojistovna,
  });

  /// Constructs a [MemoryOsoba] instance with dummy data.
  MemoryOsoba.dummyData( this.jmeno,  this.prijmeni, this.datumNarozeni, this.adresa,
      this.telefonRodice, this.zdravotniPojistovna, this.cisloPojisteni, this.pohlavi,);
/// Constructs a [MemoryOsoba] instance in cooperation with csv parser
  MemoryOsoba.csvNamed({
  required this.jmeno,
    required this.prijmeni,
    this.cisloPojisteni,
    this.pohlavi,
    this.adresa,
    this.datumNarozeni,
    this.jmenoRodice,
    this.telefonRodice,
    this.emailRodice,
    this.zpusobilost,
    this.zdravotniPojistovna,
    this.poznamka
  });
  /// Constructs a [MemoryOsoba] instance with all parameters.
  ///
  /// This constructor is used to convert between classes, will be tested that
  /// all parameters are present
  MemoryOsoba.fullNamed({
    required int? id,
    required this.jmeno,
    required this.prijmeni,
    required this.pohlavi,
    required this.adresa,
    required this.cisloPojisteni,
    required this.datumNarozeni,
    required this.jmenoRodice,
    required this.telefonRodice,
    required this.emailRodice,
    required  this.zpusobilost,
    required this.bezinfekcnost,
    required this.wasPrinted,
    required  this.zdravotniPojistovna,
    required  this.oddil,
    required  this.poznamka,
    required  bool? prisel,
    required  this.potvrzeniPath,
  }) {
    this.id = id ?? -1;
    this.prisel = prisel ?? false;

  }
}
