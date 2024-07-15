/// MIght be subjected to change: rename refactor to different files:
library;

import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/input/csv_format.dart';
import 'package:denik_zza/input/input_hold.dart';
import 'package:denik_zza/input/rodne_cislo.dart';

import 'csv_definitions.dart';
import 'csv_reader.dart';

/// Controlling class (?)
class InputParser {
  late Future<List<
      List<dynamic>>?> loadedData; // note: this is like pointer magic in c++
  String filePath = '';
  List<InputHold> definition = CsvDefinitions().mainCsv;
  List<Answer> parsedData = [];
   PersonResult? result;

  /// Parses one line of data and returns the result
  Future<Answer> parseLine(List<dynamic> line) async {
    Answer answer = Answer();
    //basic check if both are same lengths
    if (line.length != definition.length) {
      //TODO: better handling of this
      answer.error.errorMsg += 'řádek nemá požadovaný počet sloupců';
      answer.error.lineContents = line.toString();
      return answer;
    }
    // for each item parse with coresponding parser
    for (int i = 0; i < line.length; i++) {
      InputHold hold = definition[i];
      hold.addInput(line[i]);
      answer.data.add(hold);
    }
    return answer;
  }

  /// Check errors from betwwen lines

  ///1) get file
  Future<void> getFile() async {
    CsvReader reader = CsvReader(filePath);
    if (reader.canLoadFile()) {
      loadedData = reader.readData();
      parseData();
    }
  }

  ///2) read file
  ///3) parse based on parser
  void parseData() async {
    List<List<dynamic>>? data = await loadedData;
    if (data == null) {
      //TODO: better handling of this
      print("No data loaded.");
      return;
    }
    // for each line - do async parseLine, capture results in a list
    // when entire finishies
    parsedData = await Future.wait(data.map(parseLine));
    result = PersonResult(parsedData);
  }
  Future<PersonResult?> getResult() async{
    if (result == null){
      getFile();
    }
    return result;
  }
}

class PersonResult{
  List<MemoryOsoba> persons = [];
  Map<MemoryOsoba,ErrorLine> warnPersons = {};
  List<ErrorLine> errors = [];
  List<Answer> answers =[];
  PersonResult(List<Answer> inAnswers) {
    answers = inAnswers;
    for(Answer answer in inAnswers){
     if(answer.lineStatus == ParseStatus.bad){
       //TODO: handle error;
       errors.add(answer.error);
       continue;
     }
     if(answer.lineStatus == ParseStatus.warn){
      warnPersons[answer.toPerson()] = answer.error;
      continue;
     }
     if(answer.lineStatus == ParseStatus.ok){
       persons.add(answer.toPerson());
       continue;
     }
     print("Person result unexpected value");
    }
  }
}
class ErrorLine{
  String errorMsg="";
  String lineContents="";
  int? lineNum;
}

  ///4) check errors between lines
  ///5) create persons for database


/// Holds result and stats of entire parsing process
/// Works regardless of shape
class InputResult{
  List<Answer> answers = [];

}
/// holds one line of processed data, with its outcome
class Answer{
  // String errorMsg = '';
  // String line = '';
  ErrorLine error = ErrorLine();
  List<InputHold> _data = [];
  ParseStatus lineStatus = ParseStatus.empty;
  bool cleanState = false;

  List<InputHold> get data {
    calculateStatus();
    cleanState =true;
    return _data;
  }

  set data(List<InputHold> value) {
    cleanState =false;
    _data = value;
  }



///TODO: fix hardcoded indexes
  /// Calculates status of the line before reading from it
  void calculateStatus() {
    if(cleanState){
      return;
    }
    if(data.isEmpty){
      return;
    }
    if(data.length < 3){
      lineStatus = ParseStatus.warn;
    }
    //IF name or surname missing
    if(data[0].status != ParseStatus.ok || data[1].status != ParseStatus.ok){
      error.errorMsg += 'Jméno nebo příjmení chybí,\n';
      lineStatus = ParseStatus.bad;
      return;
    }
    //IF rodneCislo missing - warn only
    if(data[2].status == ParseStatus.bad){
      error.errorMsg += 'Rodné číslo chybí,\n';
      if(lineStatus < ParseStatus.warn){
        lineStatus = ParseStatus.warn;
      }
      if(data[2].status == ParseStatus.ok){
        if(data[3].output ==null){
          lineStatus = ParseStatus.warn;
          error.errorMsg += "odhad pohlaví,\n";
        }
        if(data[4].output== null){
          lineStatus = ParseStatus.warn;
          error.errorMsg += "odhad data narození";
        }
      }

    }
    if(lineStatus == ParseStatus.empty){
      lineStatus = ParseStatus.ok;
    }
  }
  MemoryOsoba toPerson(){
    calculateStatus();
    MemoryOsoba osoba = MemoryOsoba.csvNamed(jmeno: data[0].toString(),
        prijmeni: data[1].toString(),
        cisloPojisteni: data[2].toString(),
        pohlavi: data[3].output,
      adresa: data[4].output,
      datumNarozeni: data[5].output,
        telefonniCislo: data[6].output,
      emailRodice: data[7].output,
      zpusobilost: data[8].output,
      zdravotniPojistovna: data[9].output,
      poznamka: data[10].output

    );
    // if rč
    if(data[2].status == ParseStatus.ok){
      // if rč in good format for guessing
      if(data[2].output is RodneCislo){
        RodneCislo rc = data[2].output;
        osoba.pohlavi ??= rc.getPohlavi();
        osoba.datumNarozeni ??= rc.getDatumNarozeni();

      }
    }
    return osoba;
  }

}

enum ParseStatus{ ok, format, warn, bad, empty }
extension ParseStatusCmp on ParseStatus {
  int compareTo(ParseStatus other) =>index.compareTo(other.index);
  bool operator <(ParseStatus other) => index < other.index;
  bool operator >(ParseStatus other) => index > other.index;
  bool operator <=(ParseStatus other) => index <= other.index;
  bool operator >=(ParseStatus other) => index >= other.index;
  //bool operator ==(ParseStatus other) => index == other.index; // cannot be overridden
  //bool operator !=(ParseStatus other) => index != other.index;
}