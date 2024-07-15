import 'package:denik_zza/input/rodne_cislo.dart';

import 'input_parser.dart';
import 'text_tools.dart';

/// This class parses one data item
abstract class InputHold{
  dynamic pureInput;
  String input ="";
  dynamic output;
  ParseStatus? status;
  String columnName;


  InputHold(this.pureInput, this.columnName) {
    if(pureInput is int || pureInput is double){
      input = pureInput.toString();
    } else {
      input = pureInput.trim();
    }

    if(input.isEmpty){
      status = ParseStatus.bad;
      output = null;
    } else {
      output = converter();
    }
    // Some converter didn't assign status
    status ??= ParseStatus.empty;

  }

  dynamic  converter();

  bool isEmpty(){
    if(input.isEmpty ){
      return false;
    }
    return true;
  }

}
/// for parsing Jméno and Příjmení
class JmenoHold extends InputHold{
  JmenoHold(super.input, super.columnName);
  @override
  dynamic converter() {
    status = ParseStatus.ok;
    return input;
  }
}

class PohlaviHold extends InputHold{
  List<String> possibleMuz=["m", "1", "muž", "chlapec", "kluk",];
  List<String> possibleZena=["ž", "2", "žena", "dívka", "holka",];

PohlaviHold(dynamic pureInput, {String columnName = "pohlaví"}) : super(pureInput, columnName);
  @override
  converter() {
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
  AdresaHold(dynamic pureInput, {String columnName = "adresa"}) : super(pureInput, columnName);
  @override
  converter() {
    status = ParseStatus.ok;
    return input;
  }
}
class CisloPojisteniHold extends InputHold{
  CisloPojisteniHold(dynamic pureInput, {String columnName = "rodné číslo"}) : super(pureInput, columnName);
  @override
  converter() {
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
  DatumNarozeniHold(dynamic pureInput, {String columnName = "datum narození"}) : super(pureInput, columnName);
  @override
  converter() {
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
  TelefonHold(dynamic pureInput, {String columnName = "telefon rodič"}) : super(pureInput, columnName);
  @override
  converter() {
    status = ParseStatus.ok;
    return input;
  }
}
class EmailHold extends InputHold{
  EmailHold(dynamic pureInput, {String columnName = "email rodič"}) : super(pureInput, columnName);
  @override
  converter() {
    if(input.contains("@")){
      status = ParseStatus.ok;
      return input;
    }
    status = ParseStatus.bad;
    return input;
  }
}
class PotvrzeniHold extends InputHold{
  PotvrzeniHold(super.pureInput, super.columnName);
  List<String> possibleYes = ["ano", "yes", "y", "1","true",];
  List<String> possibleNo = ["ne", "no", "n", "0", "false", ];


  @override
  converter() {
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
class TextHold extends InputHold{
  TextHold(super.pureInput, super.columnName);
  @override
  converter() {
    status = ParseStatus.ok;
    return input;
  }
}
