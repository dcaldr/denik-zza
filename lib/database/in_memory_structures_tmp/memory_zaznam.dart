/// development version of [Zaznam] class
///
/// More fileds can be added but use primary public methods
///
class MemoryZaznam {
  DateTime? casZaznamu = DateTime.now();
  late int idPacient;
  late int idZaznamu;
  String? nazev;
  String popis;
  String? lecba;
  String? poznamka;
  // may use -1 means not assigned
  late int idAuthor; // may use -1 means not assigned
  bool isPrinted = false; //preset

 /// Constructs a [MemoryZaznam] instance with essential parameters.
  MemoryZaznam(this.nazev, this.popis, this.poznamka, this.idZaznamu,
      this.idAuthor, this.idPacient);

  /// Constructs a [MemoryZaznam] instance with a short description and participant ID.
  MemoryZaznam.short(this.popis, this.idPacient);

  /// Constructs a [MemoryZaznam] instance with a longer description, name, and participant ID.
  MemoryZaznam.longer(this.nazev, this.popis, this.idPacient);

  /// Constructs a [MemoryZaznam] instance with named parameters.
  MemoryZaznam.named({
    required this.idZaznamu,
    required this.casZaznamu,
    required this.nazev,
    required this.popis,
    this.lecba,
    required this.isPrinted,
    required this.idAuthor,
    required this.idPacient
  });

 /// Overrides the default toString() method to provide a formatted representation of the [MemoryZaznam] instance.
  @override
  String toString() {
    return 'MemoryZaznam{casZaznamu: $casZaznamu, idPacient: $idPacient, idZaznamu: $idZaznamu, nazev: $nazev, popis: $popis, poznamka: $poznamka, idAuthor: $idAuthor}';
  }
}
