

import 'dart:io';

import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
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
      List<List<String>>? csvTable =  CsvParserSettings().converter.convert(contents);
    //  print(csvTable);
      expect(csvTable, isNotNull);
      expect(csvTable[0][0], 'jméno');
    });
    test('my check',() async {
     CsvReader reader = CsvReader('test/data/first.csv');
      expect(reader.canLoadFile(), isTrue);

    });
  });
  group('Full csv parsing (my logic) ',(){
    //final file = File('test/data/first.csv');
    test('best case parse',()async{
      InputParser inputParser = InputParser();
      expect(inputParser, isNotNull);
      inputParser.filePath = 'test/data/first.csv';

       await inputParser.getFile();
      List<List<String>>? testus = await inputParser.loadedData;
       //loggerNoStack.i(testus.toString());
      PersonResult? result = inputParser.result;
      //loggerNoStack.i(inputParser.loadedData.toString());
      expect(result, isNotNull);
      MemoryOsoba? person = result?.goodPersons[0];
      expect(person, isNotNull);
      // here very literal check
      //print(person?.jmeno);
      expect(person?.jmeno, 'Jan');
      expect(person?.prijmeni, 'Hus');
      expect(person?.cisloPojisteni, '130610/2567');
      expect(person?.pohlavi, 1);
      expect(person?.datumNarozeni, DateTime(2013, 06, 10));
      expect(person?.jmenoRodice, 'Mr Rodič');
      expect(person?.telefonRodice, '123456');
      expect(person?.emailRodice,'hello@proble.com');
      expect(person?.zpusobilost, true);
      expect(person?.zdravotniPojistovna, 'ozp');
      expect(person?.poznamka, 'není');


     // loggerNoStack.i(result?.persons.toString());
    });
  });
}