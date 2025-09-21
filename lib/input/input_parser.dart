/// CSV Input parsing controller class
/// 
/// Handles CSV file loading and converts data into person objects
/// Might be subject to change: rename/refactor to different files
library;

import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/input/input_hold.dart';
import 'package:denik_zza/input/rodne_cislo.dart';
import 'package:denik_zza/input/text_tools.dart';
import 'package:logger/logger.dart';
import 'csv_definitions.dart';
import 'csv_reader.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

var loggerNoStack = Logger(
  printer: PrettyPrinter(methodCount: 0),
);


/// Controlling class for CSV parsing and data processing
class InputParser {
  late Future<List<List<String>>?> loadedData; // CSV data loaded from file
  String filePath = ''; // FIXME: change to Path object
  List<InputHold> definition = CsvDefinitions().mainCsv;
  List<Answer> parsedData = [];
  PersonResult? result;
  // Header handling for order-agnostic mapping
  List<String>? _header;
  // Maps definition index -> header index, or -1 if not present
  final Map<int, int> _defToHeaderIdx = {};
  // Header indices not mapped to any definition (extra columns)
  final List<int> _extraHeaderIdx = [];
  bool _headerPrepared = false;

  /// Parses one line of data and returns the result as [Answer]
  Future<Answer> parseLine(List<String> line) async {
    Answer answer = Answer();
    
    // Basic check if both arrays have same lengths
    if (line.length != definition.length) {
      // TODO: better handling of column mismatch
      answer.error.errorMsg += 'řádek nemá požadovaný počet sloupců';
      answer.error.lineContents = line.toString();
      answer.lineStatus = ParseStatus.bad;
      logger.w('Line length mismatch: expected ${definition.length}, got ${line.length}');
      return answer;
    }
    
    // For each item parse with a fresh instance cloned from definition to avoid cross-line state sharing
    final List<InputHold> parsedHolds = [];
    for (int i = 0; i < line.length; i++) {
      final InputHold def = definition[i];
      final InputHold hold = def.fresh();
      hold.addInput(line[i]);
      parsedHolds.add(hold);
    }
    answer.data = parsedHolds;
    
    // TODO: Check errors from between lines
    answer.lineStatus = ParseStatus.ok;
    return answer;
  }

  /// Gets and loads data from file
  /// Also calls [parseData]
  Future<void> getFile() async {
    CsvReader reader = CsvReader(filePath);
    if (reader.canLoadFile()) {
      // Prepare header mapping before reading data (readData removes header)
      _prepareHeaderMapping(reader);
      loadedData = reader.readData();
      await parseData();
    } else {
      logger.e('Cannot load file: $filePath');
    }
  }

  /// Converts loaded data into [parsedData]
  /// Also creates [PersonResult]
  Future<void> parseData() async {
    loggerNoStack.i("Parsing data");
    List<List<String>>? data = await loadedData;
    if (data == null) {
      // TODO: better handling of this
      loggerNoStack.i("No data loaded.");
      return;
    }
    
    // For each line - do async parseLine, capture results in a list
    try {
      // If header wasn't prepared (e.g., manual injection of data), build a passthrough mapping
      if (!_headerPrepared) {
        _buildPassthroughMapping(data.isNotEmpty ? data.first.length : definition.length);
      }

      parsedData = await Future.wait(data.map((line) async {
        // Reorder incoming line according to definition order using header mapping
        final List<String> normalizedLine = List.filled(definition.length, '');
        for (int defIdx = 0; defIdx < definition.length; defIdx++) {
          final int hdrIdx = _defToHeaderIdx[defIdx] ?? -1;
          if (hdrIdx >= 0 && hdrIdx < line.length) {
            normalizedLine[defIdx] = line[hdrIdx];
          } else {
            normalizedLine[defIdx] = '';
          }
        }
        return parseLine(normalizedLine);
      }));
    } catch (e, stackTrace) {
      logger.e("An error occurred during parsing: $e", stackTrace: stackTrace);
    }
    result = PersonResult(parsedData);
  }

  void _prepareHeaderMapping(CsvReader reader) {
    try {
      _header = reader.getHeader();
      _defToHeaderIdx.clear();
      _extraHeaderIdx.clear();
      if (_header == null || _header!.isEmpty) {
        _buildPassthroughMapping(definition.length);
        _headerPrepared = true;
        return;
      }

      final List<bool> headerTaken = List<bool>.filled(_header!.length, false);
      for (int defIdx = 0; defIdx < definition.length; defIdx++) {
        final String want = definition[defIdx].columnName;
        int matchIdx = -1;
        for (int i = 0; i < _header!.length; i++) {
          if (headerTaken[i]) continue;
          if (TextTools.looseCmp(_header![i], want)) {
            matchIdx = i;
            headerTaken[i] = true;
            break;
          }
        }
        _defToHeaderIdx[defIdx] = matchIdx; // -1 when not found
      }
      // Collect extra header indices
      for (int i = 0; i < _header!.length; i++) {
        if (!headerTaken[i]) {
          _extraHeaderIdx.add(i);
        }
      }

      // Log mandatory headers if missing
      final int jmenoIdx = definition.indexWhere((d) => TextTools.looseCmp(d.columnName, 'jméno'));
      final int prijmeniIdx = definition.indexWhere((d) => TextTools.looseCmp(d.columnName, 'příjmení'));
      if (jmenoIdx >= 0) {
        if ((_defToHeaderIdx[jmenoIdx] ?? -1) == -1) {
          logger.w('Mandatory column "jméno" not found in header.');
        }
      }
      if (prijmeniIdx >= 0) {
        if ((_defToHeaderIdx[prijmeniIdx] ?? -1) == -1) {
          logger.w('Mandatory column "příjmení" not found in header.');
        }
      }

      if (_extraHeaderIdx.isNotEmpty) {
        final extras = _extraHeaderIdx.map((i) => _header![i]).join(', ');
        loggerNoStack.i('Extra columns ignored: $extras');
      }
      _headerPrepared = true;
    } catch (e, st) {
      logger.w('Failed to prepare header mapping, using passthrough. Error: $e', stackTrace: st);
      _buildPassthroughMapping(definition.length);
      _headerPrepared = true;
    }
  }

  void _buildPassthroughMapping(int columns) {
    _defToHeaderIdx.clear();
    for (int i = 0; i < definition.length; i++) {
      _defToHeaderIdx[i] = i < columns ? i : -1;
    }
    _extraHeaderIdx.clear();
  }

  /// Returns the parsing result, loading file if necessary
  Future<PersonResult?> getResult() async {
    if (result == null) {
      await getFile();
    }
    return result;
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
    final s0 = _data[0].status;
    final s1 = _data[1].status;
    if (s0 != ParseStatus.ok || s1 != ParseStatus.ok) {
      error.errorMsg += 'Jméno nebo příjmení chybí,\n';
      lineStatus = ParseStatus.bad;
      return;
    }
    //IF rodneCislo missing - warn only
    final s2 = _data[2].status;
    if (s2 == ParseStatus.bad) {
      error.errorMsg += 'Rodné číslo chybí,\n';
      if (lineStatus < ParseStatus.warn) {
        lineStatus = ParseStatus.warn;
      }
      if (s2 == ParseStatus.ok) {
        if (_data[3].output == null) {
          lineStatus = ParseStatus.warn;
          error.errorMsg += "odhad pohlaví,\n";
        }
        if (_data[4].output == null) {
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

      CisloPojisteniHold rcHold = _data[2] as CisloPojisteniHold;
      RodneCislo rc = rcHold.getOutput();

      //FIXME refactor to someting better
      MemoryOsoba osoba = MemoryOsoba.csvNamed(
          jmeno: _data[0].getOutput(),
          prijmeni: _data[1].getOutput(),
          cisloPojisteni: rc.getRc(),
          pohlavi: _data[3].getOutput(),
          adresa: _data[4].getOutput(),
          datumNarozeni: _data[5].getOutput(),
          jmenoRodice: _data[6].getOutput(),
          telefonRodice: _data[7].getOutput(),
          emailRodice: _data[8].getOutput(),
          zpusobilost: _data[9].getOutput(),
          zdravotniPojistovna: _data[10].getOutput(),
          poznamka: _data[11].getOutput()

      );
      // if rč
      if (_data[2].status == ParseStatus.ok) {
        // if rč in good format for guessing
        if (_data[2].output is RodneCislo) {
          RodneCislo rc = _data[2].output;
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