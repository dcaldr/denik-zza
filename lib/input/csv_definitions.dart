import 'package:denik_zza/input/input_hold.dart';

class CsvDefinitions{
  List<InputHold> mainCsv = [
    JmenoHold("CHANGEME", "jméno"),
    JmenoHold("CHANGEME", "příjmení"),
    PohlaviHold("CHANGEME", columnName: "pohlaví"),
    AdresaHold("CHANGEME", columnName: "adresa"),
    CisloPojisteniHold("CHANGEME", columnName: "rodné číslo"),
    DatumNarozeniHold("CHANGEME", columnName: "datum narození"),
    TelefonHold("changeme"),
     EmailHold("changeme"),
    PotvrzeniHold("CHANGEME",  "způsobilost"),
    PojistovnaHold("CHANGEME", "pojišťovna"),
    TextHold("CHANGEME", "poznámka"),





  ];
}