/// CSV Input parsing controller class
/// 
/// Handles CSV file loading and converts data into person objects
/// Might be subject to change: rename/refactor to different files
/// 
/// TODO: CRITICAL - Implement conflict resolution for CSV import
/// - Detect duplicate persons (by name, rodné číslo, or other criteria)
/// - Handle person already exists in database scenarios
/// - Provide merge/skip/overwrite options
/// - Add import preview with conflict highlighting
/// - See docs/csv-import.md for detailed requirements
library;

import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/input/input_hold.dart';
import 'package:denik_zza/input/rodne_cislo.dart';
import 'package:denik_zza/input/text_tools.dart';
import 'package:logger/logger.dart';
import '../csv/csv_definitions.dart';
import '../csv/csv_reader.dart';

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
  /// Now accepts sparse data - only processes fields that are actually present
  Future<Answer> parseLine(Map<int, String> sparseData) async {
    Answer answer = Answer();
    
    // For each present field, parse with a fresh instance cloned from definition
    final Map<int, InputHold> parsedHolds = {};
    for (final entry in sparseData.entries) {
      final int defIdx = entry.key;
      final String value = entry.value;
      
      if (defIdx >= 0 && defIdx < definition.length) {
        final InputHold def = definition[defIdx];
        final InputHold hold = def.fresh();
        hold.addInput(value);
        parsedHolds[defIdx] = hold;
      }
    }
    answer.dataMap = parsedHolds;
    
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
        // Create sparse data map: only include fields that have corresponding headers
        final Map<int, String> sparseData = {};
        for (int defIdx = 0; defIdx < definition.length; defIdx++) {
          final int hdrIdx = _defToHeaderIdx[defIdx] ?? -1;
          if (hdrIdx >= 0 && hdrIdx < line.length) {
            sparseData[defIdx] = line[hdrIdx]; // Include even empty values for present columns
          }
          // Skip missing columns entirely - don't add them to sparseData
        }
        return parseLine(sparseData);
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
  Map<int, InputHold> _dataMap = {};

  /// how was the line marked during parsing (ok, warn, bad) should be expected
  ParseStatus lineStatus = ParseStatus.empty;
  bool cleanState = false;

  Map<int, InputHold> get dataMap {
    calculateStatus();
    cleanState = true;
    return _dataMap;
  }

  set dataMap(Map<int, InputHold> value) {
    cleanState = false;
    _dataMap = value;
  }

  // Legacy compatibility for existing code that expects _data list
  List<InputHold> get data {
    calculateStatus();
    cleanState = true;
    return _dataMap.values.toList();
  }

  set data(List<InputHold> value) {
    cleanState = false;
    _dataMap.clear();
    for (int i = 0; i < value.length; i++) {
      _dataMap[i] = value[i];
    }
  }


  ///TODO: fix hardcoded indexes
  /// Calculates status of the line before reading from it
  void calculateStatus() {
    if (cleanState) {
      return;
    }

    if (_dataMap.isEmpty) {
      return;
    }
    // Required minimum: jméno (0) and příjmení (1)
    if (!_dataMap.containsKey(0) || !_dataMap.containsKey(1)) {
      lineStatus = ParseStatus.bad;
      error.errorMsg += 'chybí povinné pole jméno nebo příjmení';
      return;
    }

    final s0 = _dataMap[0]!.status;
    final s1 = _dataMap[1]!.status;
    
    // Check if required fields (jméno, příjmení) are OK
    if (s0 != ParseStatus.ok || s1 != ParseStatus.ok) {
      error.errorMsg += 'Jméno nebo příjmení chybí,\n';
      lineStatus = ParseStatus.bad;
      return;
    }
    
    // If rodné číslo is present, check its status
    final s2 = _dataMap.containsKey(2) ? _dataMap[2]!.status : ParseStatus.empty;
    if (s2 == ParseStatus.bad) {
      // Missing or invalid RC → warn (not immediate hard fail)
      error.errorMsg += 'Rodné číslo chybí,\n';
      if (lineStatus < ParseStatus.warn) {
        lineStatus = ParseStatus.warn;
      }
    } else if (s2 == ParseStatus.ok) {
      // RC present and valid format; if gender or birthdate missing, we'll warn about inference
      if (!_dataMap.containsKey(3) || _dataMap[3]!.output == null) {
        lineStatus = ParseStatus.warn;
        error.errorMsg += "odhad pohlaví,\n";
      }
      if (!_dataMap.containsKey(5) || _dataMap[5]!.output == null) {
        lineStatus = ParseStatus.warn;
        error.errorMsg += "odhad data narození";
      }
    }
    if (lineStatus == ParseStatus.empty) {
      lineStatus = ParseStatus.ok;
    }
  }

  MemoryOsoba toPerson() {
    calculateStatus();

    // Helper function to safely get output from dataMap
    T? getFieldOutput<T>(int index) {
      if (_dataMap.containsKey(index)) {
        return _dataMap[index]!.getOutput() as T?;
      }
      
      // Provide defaults for missing fields that have business-meaningful defaults
      if (index == 9) { // způsobilost - defaults to false when missing
        return false as T?;
      }
      
      return null;
    }

    // Get required fields - these must exist for minimal CSV
    final String? jmeno = getFieldOutput<String>(0);
    final String? prijmeni = getFieldOutput<String>(1);
    
    if (jmeno == null || prijmeni == null) {
      throw StateError('Missing required fields: jméno or příjmení');
    }

    // Handle rodné číslo - it might not be present in minimal CSV
    RodneCislo? rc;
    String? cisloPojisteni;
    if (_dataMap.containsKey(2)) {
      final CisloPojisteniHold rcHold = _dataMap[2]! as CisloPojisteniHold;
      rc = rcHold.getOutput();
      cisloPojisteni = rc?.getRc();
    }

    //FIXME refactor to something better
    MemoryOsoba osoba = MemoryOsoba.csvNamed(
        jmeno: jmeno,
        prijmeni: prijmeni,
        cisloPojisteni: cisloPojisteni,
        pohlavi: getFieldOutput<int>(3),
        adresa: getFieldOutput<String>(4),
        datumNarozeni: getFieldOutput<DateTime>(5),
        jmenoRodice: getFieldOutput<String>(6),
        telefonRodice: getFieldOutput<String>(7),
        emailRodice: getFieldOutput<String>(8),
        zpusobilost: getFieldOutput<bool>(9),
        zdravotniPojistovna: getFieldOutput<String>(10),
        poznamka: getFieldOutput<String>(11)
    );
    
    // if rč is present and valid, use it for guessing missing fields
    if (_dataMap.containsKey(2) && _dataMap[2]!.status == ParseStatus.ok) {
      // if rč in good format for guessing
      if (_dataMap[2]!.output is RodneCislo) {
        RodneCislo validRc = _dataMap[2]!.output;
        osoba.pohlavi ??= validRc.getPohlavi();
        osoba.datumNarozeni ??= validRc.getDatumNarozeni();
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