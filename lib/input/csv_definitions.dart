import 'package:denik_zza/input/input_hold.dart';


/// defines variants for csv files
class CsvDefinitions{
  List<InputHold> mainCsv = [
  JmenoHold(columnName: "jméno"),
  JmenoHold(columnName: "příjmení"),
  PohlaviHold(columnName: "pohlaví"),
  AdresaHold(columnName: "adresa"),
  CisloPojisteniHold(columnName: "rodné číslo"),
  DatumNarozeniHold(columnName: "datum narození"),
  TelefonHold(columnName: "telefon rodič"),
  EmailHold(columnName: "email rodič"),
  PotvrzeniHold(columnName: "způsobilost"),
  PojistovnaHold(columnName: "pojišťovna"),
  TextHold(columnName: "poznámka"),
];
}