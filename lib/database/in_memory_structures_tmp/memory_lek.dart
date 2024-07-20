/// Lék class expected n:1 relation to @memory_osoba.dart
///
class MemoryLek{
   int id; // může se odebrat jde o pomoc databázi
   String nazev; // názvy by měly být vyhledatelné (autocomplete)
   /// human readable Davkovani information i.e. "4 tablety pod jazyk" can be null
   String? popisDavkovani;
   /// non-printable information similar  i.e. "musí být v lednici"
   String? poznamkaLek;
   bool bereSam = false; // v UI by šlo přidat ještě všechny léky bere sám zaškrtnutí
   /// for future -- schedule tables, notification etc.
   DavkaKdy? kdy;
   bool wasPrinted = false;


   MemoryLek(this.id, this.nazev, this.popisDavkovani, this.bereSam, this.kdy, this.poznamkaLek, this.wasPrinted);
}


/// enum representation of values
enum DavkaKdy {
  rano, dopoledne, poledne, odpoledne, vecer, jine,nic,
}
