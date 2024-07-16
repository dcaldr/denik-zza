/// MIght be subjected to change: rename refactor to different files:
library;

import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/input/csv_format.dart';
import 'package:denik_zza/input/input_hold.dart';
import 'package:denik_zza/input/rodne_cislo.dart';
import 'package:logger/logger.dart';
import 'csv_definitions.dart';
import 'csv_reader.dart';



var logger = Logger(
  printer: PrettyPrinter(),
);

var loggerNoStack = Logger(
  printer: PrettyPrinter(methodCount: 0),
);


/// Controlling class (?)
class InputParser {
  late Future<List<
      List<String>>?> loadedData; // note: this is like pointer magic in c++
  String filePath = ''; //FIXME: change to Path object
  List<InputHold> definition = CsvDefinitions().mainCsv;
  List<Answer> parsedData = [];
   PersonResult? result;

  /// Parses one line of data and returns the result as [Answer]
  Future<Answer> parseLine(List<String> line) async {
    Answer answer = Answer();
    //basic check if both are same lengths
    if (line.length != definition.length) {
      //TODO: better handling of this
      answer.error.errorMsg += 'řádek nemá požadovaný počet sloupců';
      answer.error.lineContents = line.toString();
      answer.lineStatus = ParseStatus.bad;
      return answer;
    }
    // for each item parse with coresponding parser
    for (int i = 0; i < line.length; i++) {
      InputHold hold = definition[i];
      hold.addInput(line[i]);
      answer.data.add(hold);
    }
    /// TODO: Check errors from between lines
    answer.lineStatus = ParseStatus.ok;
    return answer;
  }



  ///Gets and loads data from file
  /// also calls [parseData]
  Future<void> getFile() async {
    CsvReader reader = CsvReader(filePath);
    if (reader.canLoadFile()) {
      loadedData = reader.readData();
      await parseData();
    }
  }
  /// Skip header line

  /// converts loaded data into [parsedData]
  /// also creates [PersonResult]
  Future<void> parseData() async {
    loggerNoStack.i("Parsing data");
    List<List<String>>? data = await loadedData;
    if (data == null) {
      //TODO: better handling of this
      loggerNoStack.i("No data loaded.");
      return;
    }
    // for each line - do async parseLine, capture results in a list
    // when entire finishies
try {
  parsedData = await Future.wait(data.map(parseLine));
} catch (e, stackTrace) {
logger.e("An error occurred: $e", stackTrace:  stackTrace);
}
    result = PersonResult(parsedData);
  }
  Future<PersonResult?> getResult() async{
    if (result == null){
      await getFile();
    }
    return  result;
  }
}

class PersonResult{
/// persons that were ok during parsing
  List<MemoryOsoba> goodPersons = [];
  /// persons with warnining during parsing
  ///
  /// mostly where something was guessed, in future this could be separeted into format and warn
  /// key is person, value is error
  Map<MemoryOsoba,ErrorLine> warnPersons = {};
  List<ErrorLine> errors = [];
  List<Answer> answers =[];
  PersonResult(List<Answer> inAnswers) {
    loggerNoStack.t("Person result");
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
       goodPersons.add(answer.toPerson());
       continue;
     }
     loggerNoStack.w("Person result unexpected value");
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
class Answer {
  // String errorMsg = '';
  // String line = '';
  ErrorLine error = ErrorLine();
  List<InputHold> _data = [];

  /// how was the line marked during parsing (ok, warn, bad) should be expected
  ParseStatus lineStatus = ParseStatus.empty;
  bool cleanState = false;

  List<InputHold> get data {
    calculateStatus();
    cleanState = true;
    return _data;
  }

  set data(List<InputHold> value) {
    cleanState = false;
    _data = value;
  }


  ///TODO: fix hardcoded indexes
  /// Calculates status of the line before reading from it
  void calculateStatus() {
    if (cleanState) {
      return;
    }

    if (_data.isEmpty) {
      return;
    }
    if (_data.length < 3) {
      lineStatus = ParseStatus.warn;
    }
    //IF name or surname missing
    if (data[0].status != ParseStatus.ok || data[1].status != ParseStatus.ok) {
      error.errorMsg += 'Jméno nebo příjmení chybí,\n';
      lineStatus = ParseStatus.bad;
      return;
    }
    //IF rodneCislo missing - warn only
    if (data[2].status == ParseStatus.bad) {
      error.errorMsg += 'Rodné číslo chybí,\n';
      if (lineStatus < ParseStatus.warn) {
        lineStatus = ParseStatus.warn;
      }
      if (data[2].status == ParseStatus.ok) {
        if (data[3].output == null) {
          lineStatus = ParseStatus.warn;
          error.errorMsg += "odhad pohlaví,\n";
        }
        if (data[4].output == null) {
          lineStatus = ParseStatus.warn;
          error.errorMsg += "odhad data narození";
        }
      }
    }
    if (lineStatus == ParseStatus.empty) {
      lineStatus = ParseStatus.ok;
    }
  }

  MemoryOsoba toPerson() {
    calculateStatus();

      CisloPojisteniHold rcHold = data[2] as CisloPojisteniHold;
      RodneCislo rc = rcHold.getOutput();

      //FIXME refactor to someting better
      MemoryOsoba osoba = MemoryOsoba.csvNamed(
          jmeno: data[0].getOutput(),
          prijmeni: data[1].getOutput(),
          cisloPojisteni: rc.getRc(),
          pohlavi: data[3].getOutput(),
          adresa: data[4].getOutput(),
          datumNarozeni: data[5].getOutput(),
          jmenoRodice: data[6].getOutput(),
          telefonniCislo: data[7].getOutput(),
          emailRodice: data[8].getOutput(),
          zpusobilost: data[9].getOutput(),
          zdravotniPojistovna: data[10].getOutput(),
          poznamka: data[11].getOutput()

      );
      // if rč
      if (data[2].status == ParseStatus.ok) {
        // if rč in good format for guessing
        if (data[2].output is RodneCislo) {
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