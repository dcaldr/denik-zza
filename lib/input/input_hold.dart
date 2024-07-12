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

  return rc.getRc();
  }
}
