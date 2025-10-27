import 'dart:io';


import 'package:csv/csv.dart';
import 'package:csv/csv_settings_autodetection.dart';


/// class responsible for reading from a csv file and then sending it to parsers
/// [wasPathOk] is true if last access to file was successful, first get set in ocnstructor
/// [errorMsg] shows last error message, resets on ok
class CsvReader{
final String? _path;
bool wasPathOk = false;
String errorMsg ='' ;

CsvReader(this._path){
  canLoadFile();
}

/// reaads first line (column names) in "raw" format from file contents
   List<String>? getHeader(){
    if(!canLoadFile()){
      return null;
    }
    final file = File(_path!);
    final data = file.readAsStringSync();
    final table = CsvParserSettings().converter.convert(data);
    if(table.isEmpty){
      return null;
    }
    return table.first.map((e) => e.toString()).toList();
  }
  /// pulls data from file into memory
/// returns null if file was not processed
/// Also removes first line (column names) so it is not processed
  Future<List<List<String>>?> readData() async{
    if(!canLoadFile()){
      return null;
    }
    File file = File(_path!);
    String data = await file.readAsString();
    
    // parsing csv
    List<List<String>>? csvTable =  CsvParserSettings().converter.convert(data);
    csvTable = _removeFirstLine(csvTable);


   // return CsvParserSettings().converter.convert(data);
    return csvTable;
  }

  /// test if file exist and is readable
  /// can be called to provide quick response
    bool canLoadFile() {
     if(_path == null){
       wasPathOk = false;
       return false;
     }
     if (_path.isEmpty) {
       wasPathOk = false;
       return false;
     }
      File file = File(_path);
      if (!file.existsSync()) {
        wasPathOk = false;
        return false; // File does not exist
      }
      try {
        // Synchronous open/close to avoid leaving pending async subscriptions that may lock the file on Windows
        final raf = file.openSync(mode: FileMode.read);
        raf.closeSync();
        wasPathOk = true;
        errorMsg = '';
        return true;
      } catch (e) {
        errorMsg = e.toString();
        wasPathOk = false;
        return false;
      }

    }

/// removes first line from csv table (column names)
  List<List<String>>? _removeFirstLine(List<List<String>>? csvTable) {
    if(csvTable == null){
      return null;
    }
    csvTable.removeAt(0);
    return csvTable;
  }



}
/// holds settings for csv parser to be able to detect delimiters line endings etc.
/// [detector] contains default options  for csv settings for csv lib default parser
class CsvParserSettings {
  static final CsvParserSettings _instance = CsvParserSettings._internal();

  static const FirstOccurrenceSettingsDetector detector = FirstOccurrenceSettingsDetector(
    fieldDelimiters: [',', ';', '\t', ':'],
    textDelimiters: ['"', "'"],
    textEndDelimiters: ['"', "'"],
    eols: ['\n', '\r\n', '\r'],
  );

  final CsvToListConverter converter = const CsvToListConverter(csvSettingsDetector: detector, shouldParseNumbers: false);

  // Private constructor
  CsvParserSettings._internal();

  // Factory constructor to return the instance
  factory CsvParserSettings() {
    return _instance;
  }
}
