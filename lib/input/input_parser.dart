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
import 'package:denik_zza/input/csv_review_models.dart';
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
  CsvImportReview? review;
  // Header handling for order-agnostic mapping
  List<String>? _header;
  // Maps definition index -> header index, or -1 if not present
  final Map<int, int> _defToHeaderIdx = {};
  // Header indices not mapped to any definition (extra columns)
  final List<int> _extraHeaderIdx = [];
  final Set<int> _missingColumnIndices = {};
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

      parsedData = await Future.wait(List<Future<Answer>>.generate(data.length, (int rowIndex) async {
        final List<String> line = data[rowIndex];
        // Create sparse data map: only include fields that have corresponding headers
        final Map<int, String> sparseData = {};
        for (int defIdx = 0; defIdx < definition.length; defIdx++) {
          final int hdrIdx = _defToHeaderIdx[defIdx] ?? -1;
          if (hdrIdx >= 0 && hdrIdx < line.length) {
            sparseData[defIdx] = line[hdrIdx]; // Include even empty values for present columns
          }
          // Skip missing columns entirely - don't add them to sparseData
        }
        final Answer answer = await parseLine(sparseData);
        answer.originalIndex = rowIndex + 1;
        return answer;
      }));
    } catch (e, stackTrace) {
      logger.e("An error occurred during parsing: $e", stackTrace: stackTrace);
    }
    review = CsvImportReviewBuilder(
      definition: definition,
      missingColumnIndices: _missingColumnIndices,
      unparsedColumns: _computeUnparsedColumns(),
    ).build(parsedData);
    result = PersonResult(parsedData, review: review);
  }

  void _prepareHeaderMapping(CsvReader reader) {
    try {
      _header = reader.getHeader();
      _defToHeaderIdx.clear();
      _extraHeaderIdx.clear();
      _missingColumnIndices.clear();
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
        if (matchIdx == -1) {
          _missingColumnIndices.add(defIdx);
        }
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
    _missingColumnIndices.clear();
    for (int i = 0; i < definition.length; i++) {
      if (i < columns) {
        _defToHeaderIdx[i] = i;
      } else {
        _defToHeaderIdx[i] = -1;
        _missingColumnIndices.add(i);
      }
    }
    _extraHeaderIdx.clear();
  }

  List<String> _computeUnparsedColumns() {
    if (_header == null) {
      return const [];
    }
    return _extraHeaderIdx.map((i) => _header![i]).toList();
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
  CsvImportReview? review;
  PersonResult(List<Answer> inAnswers, {this.review}) {
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

class CsvReviewMessageCatalog {
  static const String missingFirstNameValue = 'Jméno nesmí být prázdné.';
  static const String missingFirstNameColumn = 'Sloupec "jméno" chybí v souboru.';
  static const String missingSurnameValue = 'Příjmení nesmí být prázdné.';
  static const String missingSurnameColumn = 'Sloupec "příjmení" chybí v souboru.';
  static const String rcMissing = 'Rodné číslo není vyplněno.';
  static const String rcInvalidFormat = 'Rodné číslo má neplatný formát.';
  static const String rcInvalidChecksum = 'Rodné číslo má podezřelý kontrolní součet.';
  static const String genderInferred = 'Pohlaví bylo odvozeno z rodného čísla.';
  static const String genderMismatch = 'Pohlaví neodpovídá rodnému číslu.';
  static const String birthdateInferred = 'Datum narození bylo odvozeno z rodného čísla.';
  static const String birthdateMismatch = 'Datum narození neodpovídá rodnému číslu.';
  static const String birthdateInvalid = 'Datum narození má neplatný formát.';
  static const String parentEmailInvalid = 'Email rodič má neplatný formát.';
}

/// Builds the enriched CSV import review data contract consumed by the UI.
///
/// Row status precedence rule: rejected > warn > info > ok. The builder
/// upgrades the row status whenever a new message with higher severity is
/// emitted, ensuring UI summaries can rely on the aggregated value.
class CsvImportReviewBuilder {
  CsvImportReviewBuilder({
    required this.definition,
    Set<int>? missingColumnIndices,
    List<String>? unparsedColumns,
  })  : _missingColumnIndices = Set<int>.unmodifiable(missingColumnIndices ?? const <int>{}),
        _unparsedColumns = List<String>.unmodifiable(unparsedColumns ?? const <String>[]);

  final List<InputHold> definition;
  final Set<int> _missingColumnIndices;
  final List<String> _unparsedColumns;
  int _nextFallbackIndex = 1;

  CsvImportReview build(List<Answer> answers) {
    final List<CsvReviewRow> rows = <CsvReviewRow>[];
    for (final Answer answer in answers) {
      rows.add(_buildRow(answer));
    }
    return CsvImportReview(unparsedColumns: _unparsedColumns, rows: rows);
  }

  CsvReviewRow _buildRow(Answer answer) {
    final Map<int, InputHold> answerMap = answer.dataMap;
    final Map<int, InputHold> holds = <int, InputHold>{};
    final List<_FieldComputation> fields = <_FieldComputation>[];
    final List<CsvReviewMessage> rowMessages = <CsvReviewMessage>[];
    CsvRowReviewStatus rowStatus = CsvRowReviewStatus.ok;
    final Map<String, CsvDerivedValue> derived = <String, CsvDerivedValue>{};

    void pushMessage(_FieldComputation? target, CsvReviewMessage message) {
      if (target != null) {
        target.messages.add(message);
      }
      rowMessages.add(message);
      rowStatus = _promoteRowStatus(rowStatus, message.severity);
    }

    for (int defIdx = 0; defIdx < definition.length; defIdx++) {
      final InputHold template = definition[defIdx];
      InputHold hold;
      if (answerMap.containsKey(defIdx)) {
        hold = answerMap[defIdx]!;
      } else {
        hold = template.fresh();
        hold.addInput(null);
      }
      holds[defIdx] = hold;

      final _FieldComputation computation = _FieldComputation(
        index: defIdx,
        columnKey: _columnKey(template.columnName),
        columnName: template.columnName,
        hold: hold,
        status: _mapFieldStatus(hold.status),
        columnMissing: _missingColumnIndices.contains(defIdx),
        originalValue: _originalValue(hold),
        normalizedValue: _formatOutput(hold.output),
      );
      fields.add(computation);

      _applyFieldSpecificMessages(
        computation: computation,
        pushMessage: pushMessage,
      );
    }

    _handleRodneCisloDerived(
      fields: fields,
      holds: holds,
      derived: derived,
      pushMessage: pushMessage,
    );

    final Map<String, CsvFieldReview> fieldMap = <String, CsvFieldReview>{};
    for (final _FieldComputation field in fields) {
      fieldMap[field.columnKey] = field.toFieldReview();
    }

    final int rowIndex = answer.originalIndex > 0 ? answer.originalIndex : _nextFallbackIndex++;

    return CsvReviewRow(
      originalIndex: rowIndex,
      status: rowStatus,
      messages: List.unmodifiable(rowMessages),
      fields: Map.unmodifiable(fieldMap),
      derived: Map.unmodifiable(derived),
    );
  }

  static CsvFieldReviewStatus _mapFieldStatus(ParseStatus? status) {
    switch (status) {
      case ParseStatus.ok:
        return CsvFieldReviewStatus.ok;
      case ParseStatus.warn:
        return CsvFieldReviewStatus.warn;
      case ParseStatus.bad:
      case ParseStatus.format:
        return CsvFieldReviewStatus.bad;
      case ParseStatus.empty:
      default:
        return CsvFieldReviewStatus.empty;
    }
  }

  static String _columnKey(String columnName) {
    final String normalized = TextTools.normText(columnName);
    return normalized.replaceAll(RegExp(r'\s+'), '_');
  }

  static String? _originalValue(InputHold hold) {
    return hold.input.isEmpty ? null : hold.input;
  }

  static String? _formatOutput(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    }
    if (value is bool) {
      return value ? 'true' : 'false';
    }
    return value.toString();
  }

  static CsvRowReviewStatus _promoteRowStatus(
    CsvRowReviewStatus current,
    CsvReviewMessageSeverity severity,
  ) {
    final CsvRowReviewStatus candidate = _statusFromSeverity(severity);
    if (_rowStatusWeights[candidate]! > _rowStatusWeights[current]!) {
      return candidate;
    }
    return current;
  }

  static CsvRowReviewStatus _statusFromSeverity(CsvReviewMessageSeverity severity) {
    switch (severity) {
      case CsvReviewMessageSeverity.error:
        return CsvRowReviewStatus.rejected;
      case CsvReviewMessageSeverity.warn:
        return CsvRowReviewStatus.warn;
      case CsvReviewMessageSeverity.info:
        return CsvRowReviewStatus.info;
    }
  }

  static const Map<CsvRowReviewStatus, int> _rowStatusWeights = <CsvRowReviewStatus, int>{
    CsvRowReviewStatus.ok: 0,
    CsvRowReviewStatus.info: 1,
    CsvRowReviewStatus.warn: 2,
    CsvRowReviewStatus.rejected: 3,
  };

  static bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _applyFieldSpecificMessages({
    required _FieldComputation computation,
    required void Function(_FieldComputation?, CsvReviewMessage) pushMessage,
  }) {
    final bool isMandatory = computation.index == 0 || computation.index == 1;
    if (computation.columnMissing) {
      if (isMandatory) {
        final CsvReviewMessage message = CsvReviewMessage(
          severity: CsvReviewMessageSeverity.error,
          message: computation.index == 0
              ? CsvReviewMessageCatalog.missingFirstNameColumn
              : CsvReviewMessageCatalog.missingSurnameColumn,
          code: computation.index == 0 ? 'missing_column_jmeno' : 'missing_column_prijmeni',
        );
        pushMessage(computation, message);
      }
      return;
    }

    if (isMandatory) {
      if (computation.status == CsvFieldReviewStatus.bad || computation.status == CsvFieldReviewStatus.empty) {
        final CsvReviewMessage message = CsvReviewMessage(
          severity: CsvReviewMessageSeverity.error,
          message: computation.index == 0
              ? CsvReviewMessageCatalog.missingFirstNameValue
              : CsvReviewMessageCatalog.missingSurnameValue,
          code: computation.index == 0 ? 'missing_value_jmeno' : 'missing_value_prijmeni',
        );
        pushMessage(computation, message);
      }
      return;
    }

    switch (computation.index) {
      case 2:
        _handleRodneCisloMessages(computation, pushMessage);
        break;
      case 5:
        _handleBirthDateMessages(computation, pushMessage);
        break;
      case 8:
        _handleEmailMessages(computation, pushMessage);
        break;
      default:
        break;
    }
  }

  void _handleRodneCisloMessages(
    _FieldComputation computation,
    void Function(_FieldComputation?, CsvReviewMessage) pushMessage,
  ) {
    final InputHold hold = computation.hold;
    if (hold is! CisloPojisteniHold) {
      return;
    }
    if (hold.input.isEmpty) {
      pushMessage(
        computation,
        CsvReviewMessage(
          severity: CsvReviewMessageSeverity.warn,
          message: CsvReviewMessageCatalog.rcMissing,
          code: 'rc_missing',
        ),
      );
      return;
    }
    final RodneCislo? rc = hold.output is RodneCislo ? hold.output as RodneCislo : null;
    if (rc == null) {
      pushMessage(
        computation,
        CsvReviewMessage(
          severity: CsvReviewMessageSeverity.warn,
          message: CsvReviewMessageCatalog.rcInvalidFormat,
          code: 'rc_invalid_format',
        ),
      );
      return;
    }
    if (!rc.hasValidFormat || hold.status == ParseStatus.bad) {
      pushMessage(
        computation,
        CsvReviewMessage(
          severity: CsvReviewMessageSeverity.warn,
          message: CsvReviewMessageCatalog.rcInvalidFormat,
          code: 'rc_invalid_format',
        ),
      );
      return;
    }
    if (!rc.hasValidSum || hold.status == ParseStatus.warn) {
      pushMessage(
        computation,
        CsvReviewMessage(
          severity: CsvReviewMessageSeverity.warn,
          message: CsvReviewMessageCatalog.rcInvalidChecksum,
          code: 'rc_invalid_checksum',
        ),
      );
    }
  }

  void _handleBirthDateMessages(
    _FieldComputation computation,
    void Function(_FieldComputation?, CsvReviewMessage) pushMessage,
  ) {
    final InputHold hold = computation.hold;
    if (hold.input.isEmpty) {
      return;
    }
    if (hold.status == ParseStatus.warn) {
      pushMessage(
        computation,
        CsvReviewMessage(
          severity: CsvReviewMessageSeverity.warn,
          message: CsvReviewMessageCatalog.birthdateInvalid,
          code: 'birthdate_invalid',
        ),
      );
    }
  }

  void _handleEmailMessages(
    _FieldComputation computation,
    void Function(_FieldComputation?, CsvReviewMessage) pushMessage,
  ) {
    final InputHold hold = computation.hold;
    if (hold.input.isEmpty) {
      return;
    }
    if (hold.status == ParseStatus.bad) {
      pushMessage(
        computation,
        CsvReviewMessage(
          severity: CsvReviewMessageSeverity.warn,
          message: CsvReviewMessageCatalog.parentEmailInvalid,
          code: 'email_invalid',
        ),
      );
    }
  }

  void _handleRodneCisloDerived({
    required List<_FieldComputation> fields,
    required Map<int, InputHold> holds,
    required Map<String, CsvDerivedValue> derived,
    required void Function(_FieldComputation?, CsvReviewMessage) pushMessage,
  }) {
    final InputHold? rcHold = holds[2];
    if (rcHold is! CisloPojisteniHold) {
      return;
    }
    if (rcHold.input.isEmpty) {
      return;
    }
    final RodneCislo rc = rcHold.output as RodneCislo;
    if (!rc.hasValidFormat) {
      return;
    }

    final _FieldComputation? genderField = _findField(fields, 3);
    if (genderField != null) {
      final dynamic genderValue = genderField.hold.output;
      final int? providedGender = genderValue is int ? genderValue : null;
      final int derivedGender = rc.getPohlavi();
      final String derivedGenderValue = derivedGender.toString();
      if (providedGender == null) {
        pushMessage(
          genderField,
          CsvReviewMessage(
            severity: CsvReviewMessageSeverity.info,
            message: CsvReviewMessageCatalog.genderInferred,
            code: 'gender_inferred_from_rc',
          ),
        );
        genderField.inferred = true;
        genderField.status = CsvFieldReviewStatus.ok;
        genderField.normalizedValue = derivedGenderValue;
        derived[genderField.columnKey] = CsvDerivedValue(
          key: genderField.columnKey,
          value: derivedGenderValue,
          applied: true,
        );
      } else if (providedGender != derivedGender) {
        pushMessage(
          genderField,
          CsvReviewMessage(
            severity: CsvReviewMessageSeverity.warn,
            message: CsvReviewMessageCatalog.genderMismatch,
            code: 'gender_mismatch_with_rc',
          ),
        );
        derived[genderField.columnKey] = CsvDerivedValue(
          key: genderField.columnKey,
          value: derivedGenderValue,
          applied: false,
        );
      } else {
        derived[genderField.columnKey] = CsvDerivedValue(
          key: genderField.columnKey,
          value: derivedGenderValue,
          applied: false,
        );
      }
    }

    final _FieldComputation? birthField = _findField(fields, 5);
    if (birthField != null) {
      final dynamic birthValue = birthField.hold.output;
      final DateTime? providedBirth = birthValue is DateTime ? birthValue : null;
      final DateTime derivedBirth = rc.getDatumNarozeni();
      final String derivedBirthValue = _formatOutput(derivedBirth)!;
      if (providedBirth == null) {
        pushMessage(
          birthField,
          CsvReviewMessage(
            severity: CsvReviewMessageSeverity.info,
            message: CsvReviewMessageCatalog.birthdateInferred,
            code: 'birthdate_inferred_from_rc',
          ),
        );
        birthField.inferred = true;
        birthField.status = CsvFieldReviewStatus.ok;
        birthField.normalizedValue = derivedBirthValue;
        derived[birthField.columnKey] = CsvDerivedValue(
          key: birthField.columnKey,
          value: derivedBirthValue,
          applied: true,
        );
      } else if (!_sameDay(providedBirth, derivedBirth)) {
        pushMessage(
          birthField,
          CsvReviewMessage(
            severity: CsvReviewMessageSeverity.warn,
            message: CsvReviewMessageCatalog.birthdateMismatch,
            code: 'birthdate_mismatch_with_rc',
          ),
        );
        derived[birthField.columnKey] = CsvDerivedValue(
          key: birthField.columnKey,
          value: derivedBirthValue,
          applied: false,
        );
      } else {
        derived[birthField.columnKey] = CsvDerivedValue(
          key: birthField.columnKey,
          value: derivedBirthValue,
          applied: false,
        );
      }
    }
  }

  _FieldComputation? _findField(List<_FieldComputation> fields, int index) {
    for (final _FieldComputation field in fields) {
      if (field.index == index) {
        return field;
      }
    }
    return null;
  }
}

class _FieldComputation {
  _FieldComputation({
    required this.index,
    required this.columnKey,
    required this.columnName,
    required this.hold,
    required this.status,
    required this.columnMissing,
    required this.originalValue,
    required this.normalizedValue,
  });

  final int index;
  final String columnKey;
  final String columnName;
  final InputHold hold;
  CsvFieldReviewStatus status;
  bool inferred = false;
  final bool columnMissing;
  final List<CsvReviewMessage> messages = <CsvReviewMessage>[];
  String? originalValue;
  String? normalizedValue;

  CsvFieldReview toFieldReview() {
    return CsvFieldReview(
      columnKey: columnKey,
      columnName: columnName,
      status: status,
      originalValue: originalValue,
      normalizedValue: normalizedValue,
      inferred: inferred,
      messages: List.unmodifiable(messages),
    );
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
class Answer {
  // String errorMsg = '';
  // String line = '';
  ErrorLine error = ErrorLine();
  Map<int, InputHold> _dataMap = {};
  int originalIndex = 0;

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
    } else if (s2 == ParseStatus.warn) {
      error.errorMsg += 'Rodné číslo má podezřelý kontrolní součet,\n';
      if (lineStatus < ParseStatus.warn) {
        lineStatus = ParseStatus.warn;
      }
    } else if (s2 == ParseStatus.ok) {
      // RC present and valid format; if gender or birthdate missing, we'll warn about inference
      if (!_dataMap.containsKey(3) || _dataMap[3]!.output == null) {
        error.errorMsg += "odhad pohlaví,\n";
      }
      if (!_dataMap.containsKey(5) || _dataMap[5]!.output == null) {
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