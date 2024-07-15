/// MIght be subjected to change: rename refactor to different files:
library;

import 'package:denik_zza/input/csv_format.dart';
import 'package:denik_zza/input/input_hold.dart';

import 'csv_definitions.dart';
import 'csv_reader.dart';

/// Controlling class (?)
class InputParser {
  late Future<List<
      List<dynamic>>?> loadedData; // note: this is like pointer magic in c++
  String filePath = '';
  List<InputHold> definition = CsvDefinitions().mainCsv;
  List<Answer> parsedData = [];

  /// Parses one line of data and returns the result
  Future<Answer> parseLine(List<dynamic> line) async {
    Answer answer = Answer();
    //basic check if both are same lengths
    if (line.length != definition.length) {
      //TODO: better handling of this
      answer.errorMsg += 'řádek nemá požadovaný počet sloupců';
      answer.line = line.toString();
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
  }
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
  String errorMsg = '';
  String line = '';
  List<InputHold> _data = [];
  ParseStatus lineStatus = ParseStatus.empty;

  List<InputHold> get data {
    calculateStatus();
    return _data;
  }

  set data(List<InputHold> value) {
    _data = value;
  }



///TODO: fix hardcoded indexes
  /// Calculates status of the line before reading from it
  void calculateStatus() {
    if(_data.isEmpty){
      return;
    }
    if(_data.length < 3){
      lineStatus = ParseStatus.bad;
    }
    //IF name or surname missing
    if(data[0].status != ParseStatus.ok || data[1].status != ParseStatus.ok){
      errorMsg += 'Jméno nebo příjmení chybí\n';
      lineStatus = ParseStatus.bad;
    }
    //IF rodneCislo missing - warn only
    if(data[2].status == ParseStatus.bad){
      errorMsg += 'Rodné číslo chybí\n';
      if(lineStatus < ParseStatus.warn){
        lineStatus = ParseStatus.warn;
      }

    }
    if(lineStatus == ParseStatus.empty){
      lineStatus = ParseStatus.ok;
    }
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