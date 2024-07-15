

import 'dart:io';

import 'package:denik_zza/input/csv_definitions.dart';
import 'package:denik_zza/input/csv_reader.dart';
import 'package:denik_zza/input/input_parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';



var logger = Logger(
  printer: PrettyPrinter(),
);

var loggerNoStack = Logger(
  printer: PrettyPrinter(methodCount: 0),
);


void main(){
  //print(CsvDefinitions().getColumnNamesAsCsv(CsvDefinitions().mainCsv));
  group('InputParser basic preflight logic',(){
    final file = File('test/data/first.csv');
    test('fully basic read check',() async {

      final contents = await file.readAsString();
      //print(contents);
      expect(contents, isNotEmpty);
    });
    test('basic read csv file',() async {
     // final file = File('test/data/first.csv');
      final contents = await file.readAsString();
      List<List<dynamic>>? csvTable =  CsvParserSettings().converter.convert(contents);
    //  print(csvTable);
      expect(csvTable, isNotNull);
    });
    test('my check',() async {
     CsvReader reader = CsvReader('test/data/first.csv');
      expect(reader.canLoadFile(), isTrue);

    });
  });
  group('Full csv parsing (my logic) ',(){
    final file = File('test/data/first.csv');
    test('best case parse',()async{
      InputParser inputParser = InputParser();
      expect(inputParser, isNotNull);
      inputParser.filePath = 'test/data/first.csv';

       await inputParser.getFile();
      List<List<dynamic>>? testus = await inputParser.loadedData;
       logger.i(testus.toString());
      PersonResult? result = inputParser.result;
      //loggerNoStack.i(inputParser.loadedData.toString());
      expect(result, isNotNull);
     // loggerNoStack.i(result?.persons.toString());
    });
  });
}