import 'package:denik_zza/input/rodne_cislo.dart';

import 'input_parser.dart';
import 'text_tools.dart';

/// This class parses one data item
abstract class InputHold{
  late dynamic  pureInput;
  String input ="";
  dynamic output;
  ParseStatus? status;
  String columnName;

  InputHold(this.columnName);

/// Constructor, takes [pureInput] and [columnName] as arguments
   InputHold.full(this.pureInput, this.columnName) {
    if(pureInput == null){
      status = ParseStatus.empty;
      output = null;
    }

    if(pureInput is int || pureInput is double){
      input = pureInput.toString();
    } else {
      input = pureInput.trim();
    }

    if(input.isEmpty){
      status = ParseStatus.bad;
      output = null;
    } else {
      output = _converter();
    }
    // Some converter didn't assign status
    status ??= ParseStatus.empty;

  }
  InputHold.empty(this.columnName){
    columnName = columnName;
    status = ParseStatus.empty;

  }

  dynamic  _converter();
  dynamic addInput(dynamic intake){
    pureInput = intake;

    if(pureInput == null){
      status = ParseStatus.empty;
      output = null;
    }

    if(pureInput is int || pureInput is double){
      input = pureInput.toString();
    } else {
      input = pureInput.trim();
    }

    if(input.isEmpty){
      status = ParseStatus.bad;
      output = null;
    } else {
      output = _converter();
    }
    // Some converter didn't assign status
    status ??= ParseStatus.empty;
  }

  bool isEmpty(){
    if(input.isEmpty ){
      return false;
    }
    return true;
  }

}
/// for parsing Jméno and Příjmení
class JmenoHold extends InputHold{
  JmenoHold({String columnName = "jméno"}) : super(columnName);
  JmenoHold.full(dynamic pureInput, {String columnName = "jméno"}) : super.full(pureInput, columnName);
  @override
  dynamic _converter() {
    status = ParseStatus.ok;
    return input;
  }
}

class PohlaviHold extends InputHold{
  List<String> possibleMuz=["m", "1", "muž", "chlapec", "kluk",];
  List<String> possibleZena=["ž", "2", "žena", "dívka", "holka",];

  PohlaviHold({String columnName = "pohlaví"}) : super(columnName);
  PohlaviHold.full(dynamic pureInput, {String columnName = "pohlaví"}) : super.full(pureInput, columnName);

  @override
  _converter() {
    if(TextTools.looseCmpWithList(input, possibleMuz)){
      status = ParseStatus.ok;
      return 1;
    } else if(TextTools.looseCmpWithList(input, possibleZena)){
      status = ParseStatus.ok;
      return 2;
    } else {
      status = ParseStatus.bad;
      return null;
    }

  }
}

class AdresaHold extends InputHold{
  AdresaHold({String columnName = "adresa"}) : super(columnName);
  AdresaHold.full(dynamic pureInput, {String columnName = "adresa"}) : super.full(pureInput, columnName);

  @override
  _converter() {
    status = ParseStatus.ok;
    return input;
  }
}
class CisloPojisteniHold extends InputHold{
  CisloPojisteniHold({String columnName = "rodné číslo"}) : super(columnName);
  CisloPojisteniHold.full(dynamic pureInput, {String columnName = "rodné číslo"}) : super.full(pureInput, columnName);

  @override
  _converter() {
  RodneCislo rc = RodneCislo(input);
  if(!rc.hasValidFormat){
    status = ParseStatus.bad;
    return rc;
  }
  if(!rc.hasValidSum){
    status = ParseStatus.warn;
  }else{
    status = ParseStatus.ok;
  }
  return rc;
  }
}
class DatumNarozeniHold extends InputHold{
  DatumNarozeniHold({String columnName = "datum narození"}) : super(columnName);
  DatumNarozeniHold.full(dynamic pureInput, {String columnName = "datum narození"}) : super.full(pureInput, columnName);

  @override
  _converter() {
    DateTime? date = TextTools.parseDate(input);
    if(date == null){
      status = ParseStatus.bad;
      return null;
    }
    status = ParseStatus.ok;
    return date;
  }
}
class TelefonHold extends InputHold{
  TelefonHold({String columnName = "telefon rodič"}) : super(columnName);

  TelefonHold.full(dynamic pureInput, {String columnName = "telefon rodič"}) : super.full(pureInput, columnName);

  @override
  _converter() {
    status = ParseStatus.ok;
    return input;
  }
}
class EmailHold extends InputHold{
  EmailHold({String columnName = "email rodič"}) : super(columnName);
  EmailHold.full(dynamic pureInput, {String columnName = "email rodič"}) : super.full(pureInput, columnName);

  @override
  _converter() {
    if(input.contains("@")){
      status = ParseStatus.ok;
      return input;
    }
    status = ParseStatus.bad;
    return input;
  }
}
class PotvrzeniHold extends InputHold{
  PotvrzeniHold({String columnName = "potvrzení"}) : super(columnName);
PotvrzeniHold.full(dynamic pureInput, {String columnName = "potvrzení"}) : super.full(pureInput, columnName);
  List<String> possibleYes = ["ano", "yes", "y", "1","true",];
  List<String> possibleNo = ["ne", "no", "n", "0", "false", ];


  @override
  _converter() {
    if(TextTools.looseCmpWithList(input, possibleYes)){
      status = ParseStatus.ok;
      return true;
    }
    if(TextTools.looseCmpWithList(input, possibleNo)){
      status = ParseStatus.ok;
      return false;
    }
    status = ParseStatus.bad;
    return null;
  }
}
///TODO: implement logic
class PojistovnaHold extends InputHold{
  PojistovnaHold({String columnName = "pojišťovna"}) : super(columnName);
PojistovnaHold.full(dynamic pureInput, {String columnName = "pojišťovna"}) : super.full(pureInput, columnName);
  @override
  _converter() {
    status = ParseStatus.ok;
    return input;
  }
}


class TextHold extends InputHold{
  TextHold({String columnName = "poznámka"}) : super(columnName);
  TextHold.full(dynamic pureInput, {String columnName = "poznámka"}) : super.full(pureInput, columnName);
  @override
  _converter() {
    status = ParseStatus.ok;
    return input;
  }
}
