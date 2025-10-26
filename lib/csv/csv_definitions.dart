import 'package:denik_zza/input/input_hold.dart';

/// Column definitions for CSV import formats.
/// Use static members instead of instantiation.
class CsvColumnDefinitions {
  // Private constructor to prevent instantiation
  CsvColumnDefinitions._();

  /// Standard participant CSV format with all required fields.
  static final List<InputHold> main = [
    JmenoHold(columnName: "jméno"),
    JmenoHold(columnName: "příjmení"),
    CisloPojisteniHold(columnName: "rodné číslo"),
    PohlaviHold(columnName: "pohlaví"),
    AdresaHold(columnName: "adresa"),
    DatumNarozeniHold(columnName: "datum narození"),
    JmenoHold(columnName: 'jméno rodič'),
    TelefonHold(columnName: "telefon rodič"),
    EmailHold(columnName: "email rodič"),
    PotvrzeniHold(columnName: "způsobilost"),
    PojistovnaHold(columnName: "pojišťovna"),
    TextHold(columnName: "poznámka"),
  ];

  /// Extract column names from a list of InputHold definitions.
  /// 
  /// Reserved for future use: Will be used to generate CSV header display
  /// on the upload/import page to show users the expected column format.
  static List<String> extractColumnNames(List<InputHold> columnsList) {
    return columnsList.map((InputHold item) => item.columnName).toList();
  }

  // NOTE: getColumnNamesAsCsv() was deleted - never used in codebase
}