/// Test builders for CSV review data structures.
///
/// Provides factory methods for creating test instances of CSV import models
/// with reasonable defaults. Reduces duplication across test files.
library;

import 'package:denik_zza/input/csv_review_models.dart';
import 'package:denik_zza/input/input_parser.dart';
import 'package:denik_zza/input/rodne_cislo.dart';
import 'package:denik_zza/services/csv_import_service.dart';

/// Factory for building test `CsvReviewRow` instances.
class CsvReviewRowBuilder {
  /// Creates a review row with standard test defaults.
  ///
  /// All parameters have reasonable defaults for testing. Override only
  /// what's needed for specific test scenarios.
  ///
  /// **Rodné číslo**: If not provided, generates a valid RC for the given date
  /// using `RodneCislo.generateForDate()` to ensure it passes checksum validation.
  ///
  /// Example:
  /// ```dart
  /// final row = CsvReviewRowBuilder.build(
  ///   index: 1,
  ///   firstName: 'Jan',
  ///   lastName: 'Novák',
  ///   status: CsvRowReviewStatus.warn,
  /// );
  /// ```
  static CsvReviewRow build({
    required int index,
    required String firstName,
    required String lastName,
    CsvRowReviewStatus status = CsvRowReviewStatus.ok,
    String? rodneCislo,
    String datumNarozeni = '01.01.2010',
    String? pohlavi,
    bool eligible = true,
    List<CsvReviewMessage> messages = const <CsvReviewMessage>[],
    List<CsvReviewMessage> rodneCisloMessages = const <CsvReviewMessage>[],
    List<CsvReviewMessage> genderMessages = const <CsvReviewMessage>[],
    List<CsvReviewMessage> eligibilityMessages = const <CsvReviewMessage>[],
    Map<String, String>? additionalFields,
  }) {
    // Generate valid rodné číslo if not provided
    final String actualRodneCislo = rodneCislo ?? 
        RodneCislo.generateForDate(
          DateTime(2010, 1, 1),
          isFemale: pohlavi == '2',
        ).getRawRc();
    final List<CsvReviewMessage> rowMessages = <CsvReviewMessage>[
      ...messages,
      ...rodneCisloMessages,
      ...genderMessages,
      ...eligibilityMessages,
    ];

    final bool genderInferred = genderMessages.any(
      (CsvReviewMessage message) => message.code == 'gender_inferred_from_rc',
    );

    final Map<String, CsvDerivedValue> derived = <String, CsvDerivedValue>{
      'datum_narozeni': CsvDerivedValue(
        key: 'datum_narozeni',
        value: datumNarozeni,
        applied: true,
      ),
    };

    if (genderInferred) {
      derived['pohlavi'] = CsvDerivedValue(
        key: 'pohlavi',
        value: pohlavi ?? '1',
        applied: true,
      );
    }

    final Map<String, CsvFieldReview> fields = <String, CsvFieldReview>{
      'jmeno': CsvFieldReview(
        columnKey: 'jmeno',
        columnName: 'Jméno',
        status: CsvFieldReviewStatus.ok,
        originalValue: firstName,
        normalizedValue: firstName,
        inferred: false,
      ),
      'prijmeni': CsvFieldReview(
        columnKey: 'prijmeni',
        columnName: 'Příjmení',
        status: CsvFieldReviewStatus.ok,
        originalValue: lastName,
        normalizedValue: lastName,
        inferred: false,
      ),
      'rodne_cislo': CsvFieldReview(
        columnKey: 'rodne_cislo',
        columnName: 'Rodné číslo',
        status: rodneCisloMessages.isNotEmpty
            ? CsvFieldReviewStatus.warn
            : CsvFieldReviewStatus.ok,
        originalValue: actualRodneCislo,
        normalizedValue: actualRodneCislo,
        inferred: false,
        messages: rodneCisloMessages,
      ),
      'datum_narozeni': CsvFieldReview(
        columnKey: 'datum_narozeni',
        columnName: 'Datum narození',
        status: CsvFieldReviewStatus.ok,
        originalValue: datumNarozeni,
        normalizedValue: datumNarozeni,
        inferred: false,
      ),
      'pohlavi': CsvFieldReview(
        columnKey: 'pohlavi',
        columnName: 'Pohlaví',
        status: genderMessages.isNotEmpty
            ? CsvFieldReviewStatus.warn
            : CsvFieldReviewStatus.ok,
        originalValue: pohlavi ?? 'Muž',
        normalizedValue: pohlavi ?? '1',
        inferred: genderInferred,
        messages: genderMessages,
      ),
      'zpusobilost': CsvFieldReview(
        columnKey: 'zpusobilost',
        columnName: 'Způsobilost',
        status: eligibilityMessages.isNotEmpty || messages.isNotEmpty
            ? CsvFieldReviewStatus.warn
            : CsvFieldReviewStatus.ok,
        originalValue: eligible ? 'Má' : 'Nemá',
        normalizedValue: eligible ? 'true' : 'false',
        inferred: false,
        messages: eligibilityMessages.isNotEmpty ? eligibilityMessages : messages,
      ),
    };

    // Merge additional fields if provided
    if (additionalFields != null) {
      for (final entry in additionalFields.entries) {
        fields[entry.key] = CsvFieldReview(
          columnKey: entry.key,
          columnName: entry.key,
          status: CsvFieldReviewStatus.ok,
          originalValue: entry.value,
          normalizedValue: entry.value,
          inferred: false,
        );
      }
    }

    return CsvReviewRow(
      originalIndex: index,
      status: status,
      messages: rowMessages,
      fields: fields,
      derived: derived,
    );
  }

  /// Creates a row with error status for testing error scenarios.
  static CsvReviewRow buildWithError({
    required int index,
    required String firstName,
    required String lastName,
    required String errorMessage,
    String? errorCode,
  }) {
    return build(
      index: index,
      firstName: firstName,
      lastName: lastName,
      status: CsvRowReviewStatus.rejected,
      messages: <CsvReviewMessage>[
        CsvReviewMessage(
          severity: CsvReviewMessageSeverity.error,
          message: errorMessage,
          code: errorCode,
        ),
      ],
    );
  }

  /// Creates a row with warning status for testing warning scenarios.
  static CsvReviewRow buildWithWarning({
    required int index,
    required String firstName,
    required String lastName,
    required String warningMessage,
    String? warningCode,
  }) {
    return build(
      index: index,
      firstName: firstName,
      lastName: lastName,
      status: CsvRowReviewStatus.warn,
      messages: <CsvReviewMessage>[
        CsvReviewMessage(
          severity: CsvReviewMessageSeverity.warn,
          message: warningMessage,
          code: warningCode,
        ),
      ],
    );
  }
}

/// Factory for building test `CsvImportSession` instances.
class CsvImportSessionBuilder {
  /// Creates a session with specified rows.
  ///
  /// Example:
  /// ```dart
  /// final session = CsvImportSessionBuilder.build(
  ///   rows: [
  ///     CsvReviewRowBuilder.build(index: 1, firstName: 'Jan', lastName: 'Novák'),
  ///     CsvReviewRowBuilder.build(index: 2, firstName: 'Eva', lastName: 'Svobodová'),
  ///   ],
  /// );
  /// ```
  static CsvImportSession build({
    required List<CsvReviewRow> rows,
    List<String> unparsedColumns = const <String>[],
  }) {
    final CsvImportReview review = CsvImportReview(
      unparsedColumns: unparsedColumns,
      rows: rows,
    );
    return CsvImportSession(
      review: review,
      personResult: PersonResult(<Answer>[]),
    );
  }

  /// Creates a session with default test data (2 rows: 1 OK, 1 WARN).
  static CsvImportSession buildDefault() {
    return build(
      rows: <CsvReviewRow>[
        CsvReviewRowBuilder.build(
          index: 1,
          firstName: 'Alena',
          lastName: 'Nováková',
          status: CsvRowReviewStatus.ok,
        ),
        CsvReviewRowBuilder.buildWithWarning(
          index: 2,
          firstName: 'Jana',
          lastName: 'Svobodová',
          warningMessage: 'Zkontrolujte telefonní číslo.',
        ),
      ],
    );
  }
}

/// Factory for building test `CsvReviewMessage` instances.
class CsvReviewMessageBuilder {
  /// Creates a warning message.
  static CsvReviewMessage warning(String message, {String? code}) {
    return CsvReviewMessage(
      severity: CsvReviewMessageSeverity.warn,
      message: message,
      code: code,
    );
  }

  /// Creates an error message.
  static CsvReviewMessage error(String message, {String? code}) {
    return CsvReviewMessage(
      severity: CsvReviewMessageSeverity.error,
      message: message,
      code: code,
    );
  }

  /// Creates an info message.
  static CsvReviewMessage info(String message, {String? code}) {
    return CsvReviewMessage(
      severity: CsvReviewMessageSeverity.info,
      message: message,
      code: code,
    );
  }

  /// Creates a gender inferred message (common test case).
  static CsvReviewMessage genderInferredFromRc() {
    return CsvReviewMessage(
      severity: CsvReviewMessageSeverity.info,
      message: 'Pohlaví bylo odvozeno z rodného čísla.',
      code: 'gender_inferred_from_rc',
    );
  }

  /// Creates an unknown gender message (common test case).
  static CsvReviewMessage unknownGender() {
    return CsvReviewMessage(
      severity: CsvReviewMessageSeverity.warn,
      message: 'Neznámá hodnota pohlaví',
      code: 'unknown_gender',
    );
  }

  /// Creates a missing eligibility confirmation message (common test case).
  static CsvReviewMessage missingEligibilityConfirmation() {
    return CsvReviewMessage(
      severity: CsvReviewMessageSeverity.warn,
      message: 'Chybí potvrzení od lékaře',
      code: 'missing_doctor_confirmation',
    );
  }
}

/// Factory for building test `CsvDuplicateCandidate` instances.
class CsvDuplicateCandidateBuilder {
  /// Creates a duplicate candidate with standard test defaults.
  static CsvDuplicateCandidate build({
    required int participantId,
    required String displayName,
    String reason = 'Stejné jméno a datum narození',
  }) {
    return CsvDuplicateCandidate(
      participantId: participantId,
      displayName: displayName,
      reason: reason,
    );
  }
}

/// Factory for building test `CsvFinalizeResult` instances.
class CsvFinalizeResultBuilder {
  /// Creates a finalize result with specified counts.
  static CsvFinalizeResult build({
    required int approvedCount,
    required int rejectedCount,
    List<int> savedRowIndices = const <int>[],
    List<CsvFinalizeFailure> failures = const <CsvFinalizeFailure>[],
  }) {
    return CsvFinalizeResult(
      approvedCount: approvedCount,
      rejectedCount: rejectedCount,
      savedRowIndices: savedRowIndices,
      failures: failures,
    );
  }
}
