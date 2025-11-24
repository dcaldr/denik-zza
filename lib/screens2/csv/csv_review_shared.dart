import 'package:denik_zza/input/csv_review_models.dart';
import 'package:denik_zza/input/input_hold.dart';
import 'package:denik_zza/input/input_parser.dart' show ParseStatus;
import 'package:denik_zza/input/text_tools.dart';
import 'package:denik_zza/services/csv_import_service.dart';
import 'package:denik_zza/services/models/csv_import_payload.dart';
import 'package:denik_zza/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;

/// Signature for building a prototype widget once the controller is ready.
typedef CsvReviewPrototypeWidgetBuilder = Widget Function(
  BuildContext context,
  CsvReviewPrototypeController controller,
);

/// Shared controller for CSV review prototype screens.
///
/// Manages comprehensive state for the CSV import review workflow:
/// - Session loading and initialization
/// - Row selection and filtering
/// - User decisions (approve/reject)
/// - Cell editing and change tracking
/// - Duplicate detection results
/// - Finalization orchestration
///
/// This is a coordinating controller following Flutter's ChangeNotifier pattern.
/// It delegates complex operations to [CsvImportService] and maintains UI state.
///
/// Organization (use Ctrl+F with section markers to navigate):
/// - CONSTRUCTOR & CONFIGURATION
/// - STATE FIELDS (Core data)
/// - PUBLIC GETTERS (Read-only access)
/// - ROW QUERY METHODS (Simple lookups)
/// - ROW SELECTION MANAGEMENT
/// - INITIALIZATION & LOADING
/// - DECISION & APPROVAL OPERATIONS
/// - ROW EDITING & MODIFICATION
/// - FINALIZATION
/// - UTILITY FUNCTIONS (Pure, static)
class CsvReviewPrototypeController extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════════
  // CONSTRUCTOR & CONFIGURATION
  // ═══════════════════════════════════════════════════════════════

  CsvReviewPrototypeController({
    required this.payload,
    CsvImportService? service,
  })  : service = service ?? DefaultCsvImportService(),
        _logger = AppLogger.l;

  /// Convenience constructor preserving legacy path-based setup.
  factory CsvReviewPrototypeController.fromPath({
    required String path,
    String? displayName,
    CsvImportService? service,
  }) {
    final String label = (displayName ?? p.basename(path)).trim();
    return CsvReviewPrototypeController(
      payload: CsvImportPayload.fromPath(
        path: path,
        displayName: label,
      ),
      service: service,
    );
  }

  /// Platform-aware description of the source CSV.
  final CsvImportPayload payload;
  final CsvImportService service;
  final Logger _logger;

  // ═══════════════════════════════════════════════════════════════
  // STATE FIELDS (Core data managed by this controller)
  // ═══════════════════════════════════════════════════════════════

  /// Loading states
  bool _isLoading = true;
  bool _isFinalizing = false;
  Object? _loadError;

  /// Core session data loaded from CSV file
  CsvImportSession? _session;

  /// Flat list of all rows, sorted by priority (rejected/warned first)
  /// Operators see problems immediately with this ordering.
  List<CsvReviewRow> _rows = <CsvReviewRow>[];

  /// Same rows grouped by status for filtered views.
  /// Invariant: flatten(_groupedRows.values) == _rows
  Map<CsvRowReviewStatus, List<CsvReviewRow>> _groupedRows =
      _emptyGroupedRows();

  /// User decisions (approve/reject) keyed by original row index.
  /// Sparse map: only rows with explicit decisions are included.
  Map<int, CsvRowDecision> _decisions = <int, CsvRowDecision>{};

  /// Currently selected rows for bulk operations
  Set<int> _selectedRows = <int>{};

  /// Tracks which cells have been edited (rowIndex -> field keys).
  /// Used for highlighting changes and audit trail.
  final Map<int, Set<String>> _editedCells = <int, Set<String>>{};

  /// Snapshot of initial values for change tracking.
  /// Medical records context requires knowing what was changed.
  final Map<int, Map<String, String?>> _initialRowValues =
      <int, Map<String, String?>>{};

  /// Rows currently being processed (shows loading indicators)
  Set<int> _loadingRows = <int>{};

  /// Potential duplicate matches found during loading.
  /// Helps operators identify data quality issues.
  Map<int, List<CsvDuplicateCandidate>> _duplicateMatches =
      <int, List<CsvDuplicateCandidate>>{};

  // ═══════════════════════════════════════════════════════════════
  // PUBLIC GETTERS (Read-only state access for UI)
  // ═══════════════════════════════════════════════════════════════

  /// Filename label exposed to the UI.
  String? get importFileLabel {
    final String label = payload.displayName.trim();
    return label.isEmpty ? null : label;
  }

  bool get isLoading => _isLoading;
  bool get isFinalizing => _isFinalizing;
  Object? get loadError => _loadError;
  CsvImportSession? get session => _session;
  List<CsvReviewRow> get rows => List<CsvReviewRow>.unmodifiable(_rows);
  Map<CsvRowReviewStatus, List<CsvReviewRow>> get groupedRows =>
      Map<CsvRowReviewStatus, List<CsvReviewRow>>.unmodifiable(_groupedRows);
  Map<int, CsvRowDecision> get decisions =>
      Map<int, CsvRowDecision>.unmodifiable(_decisions);
  Set<int> get selectedRows => Set<int>.unmodifiable(_selectedRows);
  int get selectedRowCount => _selectedRows.length;
  bool get hasRejectedDecisions => _decisions.values
      .any((CsvRowDecision decision) => decision == CsvRowDecision.rejected);

  /// Count of valid rows (not rejected, no duplicates).
  /// Used to determine if "approve all valid" button should be enabled.
  int get validRowCount {
    int count = 0;
    for (final CsvReviewRow row in _rows) {
      if (_isValidStatus(row.status) && !hasDuplicate(row.originalIndex)) {
        count++;
      }
    }
    return count;
  }

  bool get canApproveAllValid => validRowCount > 0;
  Set<int> get editedRows => Set<int>.unmodifiable(_editedCells.keys);
  Set<int> get loadingRows => Set<int>.unmodifiable(_loadingRows);
  Map<int, List<CsvDuplicateCandidate>> get duplicateMatches =>
      Map<int, List<CsvDuplicateCandidate>>.unmodifiable(_duplicateMatches);

  bool get hasSession => _session != null;
  int get totalRowCount => _rows.length;
  int get approvedCount => _decisions.values
      .where((CsvRowDecision decision) => decision == CsvRowDecision.approved)
      .length;
  int get rejectedCount => _decisions.values
      .where((CsvRowDecision decision) => decision == CsvRowDecision.rejected)
      .length;
  int get undecidedCount => totalRowCount - approvedCount - rejectedCount;
  int get duplicateRowCount => _duplicateMatches.entries
      .where((MapEntry<int, List<CsvDuplicateCandidate>> entry) =>
          entry.value.isNotEmpty)
      .length;

  // ═══════════════════════════════════════════════════════════════
  // ROW QUERY METHODS (Find rows by various criteria)
  // ═══════════════════════════════════════════════════════════════

  /// Get decision for specific row (approved/rejected/none).
  /// Returns CsvRowDecision.none if no decision exists.
  CsvRowDecision decisionForRow(int rowIndex) =>
      _decisions[rowIndex] ?? CsvRowDecision.none;

  /// Check if a row has been edited by the user.
  /// Returns true if any cell in the row has pending edits.
  bool isRowEdited(int rowIndex) => _editedCells[rowIndex]?.isNotEmpty ?? false;
  bool isCellEdited(int rowIndex, String fieldKey) =>
      _editedCells[rowIndex]?.contains(fieldKey) ?? false;
  bool isRowLoading(int rowIndex) => _loadingRows.contains(rowIndex);
  bool hasDuplicate(int rowIndex) =>
      _duplicateMatches[rowIndex]?.isNotEmpty ?? false;
  bool isRowSelected(int rowIndex) => _selectedRows.contains(rowIndex);

  /// Find row data by row index (0-based from CSV).
  /// Returns null if row not found - used by UI selection handlers.
  CsvReviewRow? getRowByIndex(int index) {
    for (final CsvReviewRow row in _rows) {
      if (row.originalIndex == index) {
        return row;
      }
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════
  // ROW SELECTION MANAGEMENT (Multi-select state coordination)
  // ═══════════════════════════════════════════════════════════════

  /// Toggle selection for a single row.
  /// BUSINESS RULE: Cannot select rejected rows (they're already decided).
  /// This prevents accidental bulk operations on rows meant to be excluded.
  void toggleRowSelection(int rowIndex, bool isSelected) {
    CsvReviewRow? targetRow;
    for (final CsvReviewRow row in _rows) {
      if (row.originalIndex == rowIndex) {
        targetRow = row;
        break;
      }
    }
    if (isSelected &&
        targetRow != null &&
        targetRow.status == CsvRowReviewStatus.rejected) {
      return;
    }
    bool changed = false;
    if (isSelected) {
      changed = _selectedRows.add(rowIndex) || changed;
    } else {
      changed = _selectedRows.remove(rowIndex) || changed;
    }
    if (changed) {
      notifyListeners();
    }
  }

  /// Bulk selection update for multiple rows.
  /// Also enforces the "no selecting rejected rows" rule.
  void setRowsSelected(Iterable<int> rowIndices, bool isSelected) {
    bool changed = false;
    for (final int rowIndex in rowIndices) {
      final CsvReviewRow? row = _findRowByIndex(rowIndex);
      if (row == null) {
        continue;
      }
      if (isSelected && row.status == CsvRowReviewStatus.rejected) {
        continue;
      }
      if (isSelected) {
        if (_selectedRows.add(rowIndex)) {
          changed = true;
        }
      } else {
        if (_selectedRows.remove(rowIndex)) {
          changed = true;
        }
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  /// Get rows filtered by review status.
  /// Used by UI to show grouped views (e.g., "show only rows with issues").
  List<CsvReviewRow> rowsForStatus(CsvRowReviewStatus? status) {
    if (status == null) {
      return List<CsvReviewRow>.unmodifiable(_rows);
    }
    return List<CsvReviewRow>.unmodifiable(
        _groupedRows[status] ?? const <CsvReviewRow>[]);
  }

  // ═══════════════════════════════════════════════════════════════
  // INITIALIZATION & LOADING (Populate state from CSV file)
  // ═══════════════════════════════════════════════════════════════

  /// Load CSV data and prepare for review.
  /// WORKFLOW: Parse CSV → detect duplicates → build row objects → sort by priority
  /// Sets up all initial state including groupedRows and duplicateMatches.
  Future<void> load() async {
    _isLoading = true;
    _loadError = null;
    notifyListeners();

    try {
      final CsvImportSession loadedSession =
          await service.loadCsvFromPayload(payload);
      Map<int, List<CsvDuplicateCandidate>> duplicates =
          <int, List<CsvDuplicateCandidate>>{};
      try {
        duplicates = await service.findPotentialDuplicates(
          session: loadedSession,
        );
      } catch (error, stackTrace) {
        _logger.w(
          'Duplicate detection failed for CSV review prototype session.',
          error: error,
          stackTrace: stackTrace,
        );
      }

      final List<CsvReviewRow> sessionRows =
          List<CsvReviewRow>.from(loadedSession.review.rows)
            ..sort(
              (CsvReviewRow a, CsvReviewRow b) =>
                  a.originalIndex.compareTo(b.originalIndex),
            );

      _sortRowsByPriority(sessionRows);

      _session = loadedSession;
      _rows = sessionRows;
      _groupedRows = _groupRows(sessionRows);
      _decisions = <int, CsvRowDecision>{};
      _selectedRows = <int>{};
      _editedCells.clear();
      _loadingRows = <int>{};
      _duplicateMatches = _cloneDuplicateMatches(duplicates);
      _snapshotInitialRows(sessionRows);
      _isLoading = false;
      _isFinalizing = false;
      notifyListeners();
    } catch (error, stackTrace) {
      _logger.e(
        'Failed to load CSV review session for prototype.',
        error: error,
        stackTrace: stackTrace,
      );
      _session = null;
      _rows = <CsvReviewRow>[];
      _groupedRows = _emptyGroupedRows();
      _decisions = <int, CsvRowDecision>{};
      _selectedRows = <int>{};
      _editedCells.clear();
      _loadingRows = <int>{};
      _duplicateMatches = <int, List<CsvDuplicateCandidate>>{};
      _initialRowValues.clear();
      _isLoading = false;
      _isFinalizing = false;
      _loadError = error;
      notifyListeners();
    }
  }

  /// Reload the CSV data from scratch (e.g., after file change).
  Future<void> reload() => load();

  // ═══════════════════════════════════════════════════════════════
  // DECISION & APPROVAL OPERATIONS (User review workflow actions)
  // ═══════════════════════════════════════════════════════════════

  /// Record user decision for a single row (approve/reject).
  /// Setting decision to CsvRowDecision.none removes the decision.
  void updateDecision(int rowIndex, CsvRowDecision decision) {
    if (decision == CsvRowDecision.none) {
      _decisions.remove(rowIndex);
    } else {
      _decisions[rowIndex] = decision;
    }
    notifyListeners();
  }

  /// Bulk approve all rows with status "ok" (no validation issues).
  /// BUSINESS RULE: Skip rows with duplicates - user must manually review those.
  /// This is a convenience feature for clean data scenarios.
  void bulkApproveOk() {
    if (_groupedRows[CsvRowReviewStatus.ok] == null) {
      return;
    }
    for (final CsvReviewRow row in _groupedRows[CsvRowReviewStatus.ok]!) {
      if (hasDuplicate(row.originalIndex)) {
        continue;
      }
      _decisions[row.originalIndex] = CsvRowDecision.approved;
    }
    notifyListeners();
  }

  /// Bulk approve rows with status "ok" or "info" (minor issues acceptable).
  /// BUSINESS RULE: Skip rows with duplicates - user must manually review those.
  /// Expands approval criteria to include informational warnings.
  void bulkApproveUpToInfo() {
    const Set<CsvRowReviewStatus> autoStatuses = <CsvRowReviewStatus>{
      CsvRowReviewStatus.ok,
      CsvRowReviewStatus.info,
    };
    for (final CsvReviewRow row in _rows) {
      if (!autoStatuses.contains(row.status)) {
        continue;
      }
      if (hasDuplicate(row.originalIndex)) {
        continue;
      }
      _decisions[row.originalIndex] = CsvRowDecision.approved;
    }
    notifyListeners();
  }

  /// Clear all approved decisions (reset to undecided).
  /// Rejected decisions remain - only affects approved rows.
  void bulkClearApprovals() {
    _decisions.removeWhere(
      (int _, CsvRowDecision value) => value == CsvRowDecision.approved,
    );
    notifyListeners();
  }

  /// Reject all rows in the import - nuclear option for bad data files.
  void bulkRejectAll() {
    for (final CsvReviewRow row in _rows) {
      _decisions[row.originalIndex] = CsvRowDecision.rejected;
    }
    notifyListeners();
  }

  /// Reject only rows that have validation errors (status: rejected).
  /// Clears incorrect rejections - synchronizes decisions with actual validation.
  void bulkRejectOnlyRejected() {
    for (final CsvReviewRow row in _rows) {
      if (row.status == CsvRowReviewStatus.rejected) {
        _decisions[row.originalIndex] = CsvRowDecision.rejected;
      } else if (_decisions[row.originalIndex] == CsvRowDecision.rejected) {
        _decisions.remove(row.originalIndex);
      }
    }
    notifyListeners();
  }

  /// Select all valid rows (not rejected, no duplicates).
  /// Renamed from approveAllValid - now just selects rows without hidden approval state.
  void selectAllValid() {
    bool changed = false;
    for (final CsvReviewRow row in _rows) {
      if (!_isValidStatus(row.status)) {
        continue;
      }
      if (hasDuplicate(row.originalIndex)) {
        continue;
      }
      if (!_selectedRows.contains(row.originalIndex)) {
        _selectedRows.add(row.originalIndex);
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  /// Deselect all rows.
  /// Renamed from toggleRejectAll - now simply clears selection.
  void deselectAll() {
    if (_clearSelection()) {
      notifyListeners();
    }
  }

  /// Helper to clear selection state (used after bulk operations).
  /// Returns true if selection was modified.
  bool _clearSelection() {
    if (_selectedRows.isEmpty) {
      return false;
    }
    _selectedRows.clear();
    return true;
  }

  /// Helper to find row by index (used internally).
  CsvReviewRow? _findRowByIndex(int rowIndex) {
    for (final CsvReviewRow row in _rows) {
      if (row.originalIndex == rowIndex) {
        return row;
      }
    }
    return null;
  }

  /// Helper to check if a status is valid (not rejected).
  bool _isValidStatus(CsvRowReviewStatus status) {
    switch (status) {
      case CsvRowReviewStatus.rejected:
        return false;
      case CsvRowReviewStatus.warn:
      case CsvRowReviewStatus.info:
      case CsvRowReviewStatus.ok:
        return true;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ROW EDITING & MODIFICATION (In-place data corrections)
  // ═══════════════════════════════════════════════════════════════

  /// Re-parse and validate a row after user edits fields.
  /// WORKFLOW: Show loading → validate new data → update row in place → refresh grouping
  /// Preserves original index for decision tracking.
  Future<CsvReviewRow?> editRow(
    CsvReviewRow row,
    Map<String, String?> updatedFields,
  ) async {
    final int rowIndex = row.originalIndex;
    _loadingRows.add(rowIndex);
    notifyListeners();

    try {
      CsvReviewRow updatedRow = await service.reparseRow(updatedFields);
      if (updatedRow.originalIndex != row.originalIndex) {
        updatedRow = CsvReviewRow(
          originalIndex: row.originalIndex,
          status: updatedRow.status,
          messages: updatedRow.messages,
          fields: updatedRow.fields,
          derived: updatedRow.derived,
        );
      }
      _loadingRows.remove(rowIndex);
      _updateEditedCells(rowIndex, updatedRow);
      _duplicateMatches.remove(rowIndex);
      updatedRow = _applyPrototypeWarnings(updatedRow, updatedFields);
      _replaceRow(updatedRow);
      notifyListeners();
      return updatedRow;
    } catch (error, stackTrace) {
      _logger.e(
        'Failed to reparse CSV row $rowIndex during prototype edit.',
        error: error,
        stackTrace: stackTrace,
      );
      _loadingRows.remove(rowIndex);
      notifyListeners();
      rethrow;
    }
  }

  /// Apply manual validation warnings for edited rows (prototype UI only).
  /// BUSINESS LOGIC: If user enters unrecognized gender value, add warning.
  /// WHY: Gender can be inferred from Czech national ID (rodné číslo), but user
  /// might override. If override is non-standard, warn them but allow it.
  CsvReviewRow _applyPrototypeWarnings(
    CsvReviewRow updatedRow,
    Map<String, String?> updatedFields,
  ) {
    final String? genderInput = updatedFields['pohlavi'];
    if (genderInput == null) {
      return updatedRow;
    }
    final String trimmed = genderInput.trim();
    if (trimmed.isEmpty || _isRecognizedGenderToken(trimmed)) {
      return updatedRow;
    }

    final CsvFieldReview? genderField = updatedRow.fields['pohlavi'];
    if (genderField == null) {
      return updatedRow;
    }

    const String warningText = 'Neznámá hodnota pohlaví';
    const String genderInferredCode = 'gender_inferred_from_rc';
    const String genderWarningCode = 'gender_unrecognized_input';
    final CsvReviewMessage warning = CsvReviewMessage(
      severity: CsvReviewMessageSeverity.warn,
      message: warningText,
      code: genderWarningCode,
    );

    // Update field messages: remove old gender warnings, add new one.
    // WHY: User might edit gender multiple times - don't accumulate duplicate warnings.
    final Map<String, CsvFieldReview> updatedFieldsMap =
        Map<String, CsvFieldReview>.from(updatedRow.fields);
    final List<CsvReviewMessage> filteredFieldMessages =
        genderField.messages.where((CsvReviewMessage message) {
      final String? code = message.code;
      if (message.message == warningText) {
        return false;
      }
      if (code == genderInferredCode || code == genderWarningCode) {
        return false;
      }
      return true;
    }).toList()
          ..add(warning);
    final CsvFieldReview updatedGenderField = CsvFieldReview(
      columnKey: genderField.columnKey,
      columnName: genderField.columnName,
      status: CsvFieldReviewStatus.warn,
      originalValue: trimmed,
      normalizedValue: trimmed,
      inferred: false,
      messages: filteredFieldMessages,
    );
    updatedFieldsMap['pohlavi'] = updatedGenderField;

    final List<CsvReviewMessage> rowMessages = <CsvReviewMessage>[
      ...updatedRow.messages.where(
        (CsvReviewMessage message) {
          final String? code = message.code;
          if (message.message == warningText) {
            return false;
          }
          if (code == genderInferredCode || code == genderWarningCode) {
            return false;
          }
          return true;
        },
      ),
      warning,
    ];

    // If gender was inferred from national ID but user overrode it with non-standard value,
    // mark inference as not applied (shows user manually changed it).
    final Map<String, CsvDerivedValue> derivedMap =
        Map<String, CsvDerivedValue>.from(updatedRow.derived);
    final CsvDerivedValue? genderDerived =
        derivedMap[updatedGenderField.columnKey];
    if (genderDerived != null && genderDerived.applied) {
      derivedMap[updatedGenderField.columnKey] = CsvDerivedValue(
        key: genderDerived.key,
        value: genderDerived.value,
        applied: false,
      );
    }

    // Escalate row status to "warn" if it was OK or INFO.
    // WHY: Unrecognized gender deserves user attention before import.
    CsvRowReviewStatus status = updatedRow.status;
    if (status == CsvRowReviewStatus.ok || status == CsvRowReviewStatus.info) {
      status = CsvRowReviewStatus.warn;
    }

    return CsvReviewRow(
      originalIndex: updatedRow.originalIndex,
      status: status,
      messages: rowMessages,
      fields: updatedFieldsMap,
      derived: derivedMap,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // FINALIZATION (Commit approved records to database)
  // ═══════════════════════════════════════════════════════════════

  /// Execute the import - save SELECTED rows to database.
  /// WORKFLOW: Validate session exists → build decisions from selection → call service → return result
  /// Returns null if no session loaded (shouldn't happen in normal flow).
  Future<CsvFinalizeResult?> finalizeImport() async {
    if (_session == null) {
      return null;
    }
    _isFinalizing = true;
    notifyListeners();
    try {
      // Build approval decisions from selected rows
      final Map<int, CsvRowDecision> decisions = <int, CsvRowDecision>{};
      for (final int rowIndex in _selectedRows) {
        decisions[rowIndex] = CsvRowDecision.approved;
      }

      final CsvFinalizeResult result = await service.finalizeImport(
        session: _session!,
        decisions: decisions,
      );
      _isFinalizing = false;
      notifyListeners();
      return result;
    } catch (error, stackTrace) {
      _logger.e(
        'Finalize import failed for CSV review prototype.',
        error: error,
        stackTrace: stackTrace,
      );
      _isFinalizing = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Build a flat string map from row data (for service calls).
  /// Prefers normalized values over original CSV values.
  Map<String, String?> buildPayload(CsvReviewRow row) {
    final Map<String, String?> result = <String, String?>{};
    row.fields.forEach((String key, CsvFieldReview field) {
      result[key] = field.normalizedValue ?? field.originalValue;
    });
    return result;
  }

  // ═══════════════════════════════════════════════════════════════
  // UTILITY FUNCTIONS (Private helpers and static logic)
  // ═══════════════════════════════════════════════════════════════

  /// Replace a row in the list after editing and re-sort/re-group.
  /// Used internally after editRow() completes validation.
  void _replaceRow(CsvReviewRow updatedRow) {
    final int index = _rows.indexWhere(
        (CsvReviewRow row) => row.originalIndex == updatedRow.originalIndex);
    if (index == -1) {
      return;
    }
    _rows[index] = updatedRow;
    _sortRowsByPriority(_rows);
    _groupedRows = _groupRows(_rows);
  }

  /// Track which cells in a row have been modified from baseline.
  /// Used to show "edited" indicators in UI.
  void _updateEditedCells(
    int rowIndex,
    CsvReviewRow updated,
  ) {
    final Map<String, String?> baseline =
        _initialRowValues[rowIndex] ?? const <String, String?>{};
    final Set<String> changed = <String>{};
    final Set<String> keys = <String>{
      ...baseline.keys,
      ...updated.fields.keys,
    };
    for (final String key in keys) {
      final String? baselineValue = baseline[key];
      final String? currentValue = _valueForComparison(updated.fields[key]);
      if (baselineValue != currentValue) {
        changed.add(key);
      }
    }
    if (changed.isEmpty) {
      _editedCells.remove(rowIndex);
    } else {
      _editedCells[rowIndex] = changed;
    }
  }

  /// Capture initial state of all rows for edit tracking.
  /// Called once during load() to establish baseline.
  void _snapshotInitialRows(List<CsvReviewRow> rows) {
    _initialRowValues
      ..clear()
      ..addEntries(rows.map((CsvReviewRow row) {
        final Map<String, String?> fieldValues = <String, String?>{};
        row.fields.forEach((String key, CsvFieldReview field) {
          fieldValues[key] = _valueForComparison(field);
        });
        return MapEntry<int, Map<String, String?>>(
          row.originalIndex,
          fieldValues,
        );
      }));
  }

  /// Extract comparable value from field (normalized preferred).
  String? _valueForComparison(CsvFieldReview? field) {
    if (field == null) {
      return null;
    }
    return field.normalizedValue ?? field.originalValue;
  }

  // --- Static utility methods (pure functions) ---

  /// Group rows by their review status for categorized display.
  /// Returns map with all statuses present (empty lists for unused statuses).
  static Map<CsvRowReviewStatus, List<CsvReviewRow>> _groupRows(
      List<CsvReviewRow> rows) {
    final Map<CsvRowReviewStatus, List<CsvReviewRow>> grouped =
        _emptyGroupedRows();
    for (final CsvReviewRow row in rows) {
      grouped[row.status]!.add(row);
    }
    for (final List<CsvReviewRow> statusRows in grouped.values) {
      _sortRowsByPriority(statusRows);
    }
    return grouped;
  }

  /// Sort rows: errors first, then warnings, then info, then OK.
  /// Within same priority, preserve CSV row order (originalIndex).
  /// This ensures critical issues are always visible at top of lists.
  static void _sortRowsByPriority(List<CsvReviewRow> rows) {
    rows.sort((CsvReviewRow a, CsvReviewRow b) {
      final int priorityA = _statusPriority(a.status);
      final int priorityB = _statusPriority(b.status);
      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }
      return a.originalIndex.compareTo(b.originalIndex);
    });
  }

  /// Priority values for sorting: rejected=0 (highest), warn=1, info=2, ok=3 (lowest).
  static int _statusPriority(CsvRowReviewStatus status) {
    switch (status) {
      case CsvRowReviewStatus.rejected:
        return 0;
      case CsvRowReviewStatus.warn:
        return 1;
      case CsvRowReviewStatus.info:
        return 2;
      case CsvRowReviewStatus.ok:
        return 3;
    }
  }

  /// Create empty grouped rows map with all statuses present.
  static Map<CsvRowReviewStatus, List<CsvReviewRow>> _emptyGroupedRows() =>
      <CsvRowReviewStatus, List<CsvReviewRow>>{
        CsvRowReviewStatus.ok: <CsvReviewRow>[],
        CsvRowReviewStatus.info: <CsvReviewRow>[],
        CsvRowReviewStatus.warn: <CsvReviewRow>[],
        CsvRowReviewStatus.rejected: <CsvReviewRow>[],
      };

  /// Deep clone duplicate matches map (prevents shared reference issues).
  static Map<int, List<CsvDuplicateCandidate>> _cloneDuplicateMatches(
    Map<int, List<CsvDuplicateCandidate>> source,
  ) {
    return source.map(
      (int key, List<CsvDuplicateCandidate> value) =>
          MapEntry<int, List<CsvDuplicateCandidate>>(
        key,
        List<CsvDuplicateCandidate>.from(value),
      ),
    );
  }
}

/// Czech label for the provided row status.
String statusLabel(CsvRowReviewStatus status) {
  switch (status) {
    case CsvRowReviewStatus.ok:
      return 'V pořádku';
    case CsvRowReviewStatus.info:
      return 'Informace';
    case CsvRowReviewStatus.warn:
      return 'Varování';
    case CsvRowReviewStatus.rejected:
      return 'Chyba';
  }
}

/// Accent color used to highlight a status in the UI.
Color statusColor(ThemeData theme, CsvRowReviewStatus status) {
  switch (status) {
    case CsvRowReviewStatus.ok:
      return theme.colorScheme.primary;
    case CsvRowReviewStatus.info:
      return theme.colorScheme.secondary;
    case CsvRowReviewStatus.warn:
      return theme.colorScheme.tertiary;
    case CsvRowReviewStatus.rejected:
      return theme.colorScheme.error;
  }
}

/// Returns a field value formatted for Czech UI display.
String formatCsvFieldDisplay(String fieldKey, CsvFieldReview? field) {
  final String rawValue = field?.normalizedValue ?? field?.originalValue ?? '';
  if (rawValue.isEmpty) {
    return '';
  }
  switch (fieldKey) {
    case 'pohlavi':
      return _formatGenderLabel(rawValue);
    case 'datum_narozeni':
      final DateTime? parsed = TextTools.parseDate(rawValue);
      if (parsed != null) {
        return _czechDateFormatter.format(parsed);
      }
      return rawValue;
    case 'zpusobilost':
    case 'bezinfekcnost':
      return _formatBooleanLabel(rawValue);
    default:
      return rawValue;
  }
}

/// Normalizes a user-facing value back to a payload-friendly normalized value.
String normalizeCsvFieldInput(
  String fieldKey,
  String input,
  CsvFieldReview? originalField,
) {
  final String trimmed = input.trim();
  if (trimmed.isEmpty) {
    return '';
  }

  switch (fieldKey) {
    case 'pohlavi':
      return _normalizeWithHold(
        fieldKey: fieldKey,
        input: trimmed,
        originalField: originalField,
        holdBuilder: () => PohlaviHold(columnName: 'pohlaví'),
        formatter: (dynamic value) => value?.toString() ?? '',
      );
    case 'datum_narozeni':
      return _normalizeWithHold(
        fieldKey: fieldKey,
        input: trimmed,
        originalField: originalField,
        holdBuilder: () => DatumNarozeniHold(columnName: 'datum narození'),
        formatter: (dynamic value) =>
            value is DateTime ? _czechDateFormatter.format(value) : '',
      );
    case 'zpusobilost':
    case 'bezinfekcnost':
      final String normalizedBoolean = TextTools.normText(trimmed);
      if (_matchesYes(normalizedBoolean)) {
        return 'true';
      }
      if (_matchesNo(normalizedBoolean)) {
        return 'false';
      }
      return _normalizeWithHold(
        fieldKey: fieldKey,
        input: trimmed,
        originalField: originalField,
        holdBuilder: () => PotvrzeniHold(columnName: 'potvrzení'),
        formatter: (dynamic value) => value is bool ? value.toString() : '',
      );
    default:
      return trimmed;
  }
}

String _normalizeWithHold({
  required String fieldKey,
  required String input,
  required CsvFieldReview? originalField,
  required InputHold Function() holdBuilder,
  required String Function(dynamic value) formatter,
}) {
  final InputHold hold = holdBuilder();
  hold.addInput(input);
  if (hold.status == ParseStatus.ok) {
    final String formatted = formatter(hold.getOutput());
    if (formatted.isNotEmpty) {
      return formatted;
    }
  }
  if (originalField != null &&
      input == formatCsvFieldDisplay(fieldKey, originalField)) {
    return originalField.normalizedValue ??
        originalField.originalValue ??
        input;
  }
  return input;
}

final DateFormat _czechDateFormatter = DateFormat('dd.MM.yyyy');

String _formatGenderLabel(String rawValue) {
  return TextTools.formatGenderLabel(rawValue);
}

String _formatBooleanLabel(String rawValue) {
  final String trimmed = rawValue.trim();
  if (trimmed.isEmpty) {
    return '';
  }
  final String normalized = TextTools.normText(trimmed);
  if (_matchesYes(normalized)) {
    return 'Má';
  }
  if (_matchesNo(normalized)) {
    return 'Nemá';
  }
  return rawValue;
}

bool _isRecognizedGenderToken(String value) {
  return TextTools.isRecognizedGenderToken(value);
}

final PotvrzeniHold _potvrzeniPrototype = PotvrzeniHold();

bool _matchesYes(String normalizedInput) {
  if (normalizedInput == 'ma') {
    return true;
  }
  return TextTools.looseCmpWithList(
      normalizedInput, _potvrzeniPrototype.possibleYes);
}

bool _matchesNo(String normalizedInput) {
  if (normalizedInput == 'nema') {
    return true;
  }
  return TextTools.looseCmpWithList(
      normalizedInput, _potvrzeniPrototype.possibleNo);
}

/// Returns display list of derived values for quick badge rendering.
List<DerivedValueDisplay> derivedValueDisplays(CsvReviewRow row) {
  return row.derived.entries
      .map(
        (MapEntry<String, CsvDerivedValue> entry) => DerivedValueDisplay(
          key: entry.key,
          value: entry.value.value,
          applied: entry.value.applied,
        ),
      )
      .toList(growable: false);
}

/// DTO used by prototypes to show derived values in badges or lists.
class DerivedValueDisplay {
  const DerivedValueDisplay({
    required this.key,
    required this.value,
    required this.applied,
  });

  final String key;
  final String value;
  final bool applied;

  String get label => key;
  String get formattedValue => value;
  String get appliedFlag => applied ? 'použito' : 'neaplikováno';
}

/// Convenience widget hosting a [CsvReviewPrototypeController] lifecycle and
/// exposing basic loading/error UI before delegating to the supplied builder.
class CsvReviewPrototypeHost extends StatefulWidget {
  const CsvReviewPrototypeHost({
    super.key,
    this.filePath,
    this.payload,
    required this.builder,
    this.service,
    this.loadingBuilder,
    this.errorBuilder,
  }) : assert(
          filePath != null || payload != null,
          'Either filePath or payload must be provided.',
        );

  final String? filePath;
  final CsvImportPayload? payload;
  final CsvReviewPrototypeWidgetBuilder builder;
  final CsvImportService? service;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  @override
  State<CsvReviewPrototypeHost> createState() => _CsvReviewPrototypeHostState();
}

class _CsvReviewPrototypeHostState extends State<CsvReviewPrototypeHost> {
  late CsvReviewPrototypeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _createController();
    _controller.addListener(_handleControllerChanged);
    _controller.load();
  }

  @override
  void didUpdateWidget(covariant CsvReviewPrototypeHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldRecreateController(oldWidget)) {
      _controller.removeListener(_handleControllerChanged);
      _controller.dispose();
      _controller = _createController();
      _controller.addListener(_handleControllerChanged);
      _controller.load();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  CsvReviewPrototypeController _createController() {
    if (widget.payload != null) {
      return CsvReviewPrototypeController(
        payload: widget.payload!,
        service: widget.service,
      );
    }
    return CsvReviewPrototypeController.fromPath(
      path: widget.filePath!,
      service: widget.service,
    );
  }

  bool _shouldRecreateController(CsvReviewPrototypeHost oldWidget) {
    if (widget.service != oldWidget.service) {
      return true;
    }
    if (widget.payload != null || oldWidget.payload != null) {
      return widget.payload != oldWidget.payload;
    }
    return widget.filePath != oldWidget.filePath;
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      final WidgetBuilder? loadingBuilder = widget.loadingBuilder;
      if (loadingBuilder != null) {
        return loadingBuilder(context);
      }
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.loadError != null) {
      final Widget Function(BuildContext context, Object error)? errorBuilder =
          widget.errorBuilder;
      if (errorBuilder != null) {
        return errorBuilder(context, _controller.loadError!);
      }
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.error_outline,
                color: Theme.of(context).colorScheme.error, size: 48),
            const SizedBox(height: 12),
            Text(
              'Import CSV se nepodařilo načíst.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextButton(
              key: const Key('CsvReviewPrototypeHost_retry'),
              onPressed: _controller.reload,
              child: const Text('Zkusit znovu'),
            ),
          ],
        ),
      );
    }

    return widget.builder(context, _controller);
  }
}
