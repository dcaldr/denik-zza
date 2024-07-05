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



/// reaad first line (coulmn names) in "raw" format
   List<String>? getHeader(){
    return null;
  }
  /// pull data from file into memory
/// returns null if file was not processed
  Future<List<dynamic>?> readData() async{
    if(!canLoadFile()){
      return null;
    }
    File file = File(_path!);
    String data = await file.readAsString(); // note: learn "asynchronous prefetching" or "fire and forget"
    // TODO: do tests on settings
    // parsing csv
    List<List<dynamic>> csvTable = CsvParserSettings().converter.convert(data);
    return csvTable;
  }
  /// when file is found not ok this gets called,
/// it is for possible future changes
  bool setBadFile(){
     wasPathOk = false;
     return false;
  }
  /// when file is found ok this gets called,
///   it is for possible future changes
  bool setGoodFile(){
    wasPathOk = true;
    errorMsg = '';
    return true;
  }


  /// test if file exist and is readable
  /// can be called to provide quick response
    bool canLoadFile() {
     if(_path == null){
     return setBadFile();
     }
     if (_path.isEmpty) {
      return setBadFile();
     }
      File file = File(_path);
      if (!file.existsSync()) {
       return setBadFile(); // File does not exist
      }
      try {
        file.openRead().listen((_) {}).cancel(); // Attempt to read and immediately cancel to not actually process data
        wasPathOk = true;
        return true;
      } catch (e) {
        errorMsg = e.toString();
       return setBadFile();
      }
      return setBadFile();

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

  final CsvToListConverter converter = const CsvToListConverter(csvSettingsDetector: detector);

  // Private constructor
  CsvParserSettings._internal();

  // Factory constructor to return the instance
  factory CsvParserSettings() {
    return _instance;
  }
}
