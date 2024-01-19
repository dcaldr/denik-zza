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
  String? poznamka;
  // may use -1 means not assigned
  late int idAuthor; // may use -1 means not assigned
  bool isPrinted = false; //preset

  MemoryZaznam(this.nazev, this.popis, this.poznamka, this.idZaznamu,
      this.idAuthor, this.idPacient);
  MemoryZaznam.short(this.popis, this.idPacient);
  MemoryZaznam.longer(this.nazev, this.popis, this.idPacient);

  @override
  String toString() {
    return 'MemoryZaznam{casZaznamu: $casZaznamu, idPacient: $idPacient, idZaznamu: $idZaznamu, nazev: $nazev, popis: $popis, poznamka: $poznamka, idAuthor: $idAuthor}';
  }
}
