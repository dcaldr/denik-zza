import 'input_hold.dart';

/// defines format of input csv files
/// RIGHT NOW DOES NOTHING
  class CsvFormat{
    CsvFormat(this.columns);

 List<InputHold> columns;

 List<String> getColumnsNames(){
   return columns.map((e) => e.columnName).toList();

 }
 List<InputHold> getColumnsDefinitions(){
   return columns;
 }


}

