/// defines format of input csv files
/// RIGHT NOW DOES NOTHING
 abstract class CsvFormat{
  /// returns list of coulumn names
List<String> getColumnNames();
}


class PeopleImport implements CsvFormat {
  @override
  List<String> getColumnNames() {
    // TODO: implement getColumnNames
    throw UnimplementedError();
  }

}
