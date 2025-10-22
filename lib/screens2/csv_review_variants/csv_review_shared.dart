import 'package:denik_zza/input/csv_review_models.dart';
import 'package:denik_zza/input/input_hold.dart';
import 'package:denik_zza/input/text_tools.dart';
import 'package:denik_zza/services/csv_import_service.dart';
import 'package:denik_zza/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

/// Signature for building a prototype widget once the controller is ready.
typedef CsvReviewPrototypeWidgetBuilder = Widget Function(
  BuildContext context,
  CsvReviewPrototypeController controller,
);

/// Shared controller used by all CSV review prototype screens. Provides
/// consistent access to review rows, decision state, duplicate matches, and
/// mutation helpers backed by [CsvReviewService].
class CsvReviewPrototypeController extends ChangeNotifier {
  CsvReviewPrototypeController({
    required this.filePath,
    CsvReviewService? service,
  })  : service = service ?? CsvImportService(),
        _logger = AppLogger.l;

  final String filePath;
  final CsvReviewService service;
  final Logger _logger;

  bool _isLoading = true;
  bool _isFinalizing = false;
  Object? _loadError;
  CsvImportSession? _session;
  List<CsvReviewRow> _rows = <CsvReviewRow>[];
  Map<CsvRowReviewStatus, List<CsvReviewRow>> _groupedRows =
      _emptyGroupedRows();
  Map<int, CsvRowDecision> _decisions = <int, CsvRowDecision>{};
  Set<int> _selectedRows = <int>{};
  final Map<int, Set<String>> _editedCells = <int, Set<String>>{};
  final Map<int, Map<String, String?>> _initialRowValues =
      <int, Map<String, String?>>{};
  Set<int> _loadingRows = <int>{};
  Map<int, List<CsvDuplicateCandidate>> _duplicateMatches =
      <int, List<CsvDuplicateCandidate>>{};

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

  CsvRowDecision decisionForRow(int rowIndex) =>
      _decisions[rowIndex] ?? CsvRowDecision.none;

  bool isRowEdited(int rowIndex) => _editedCells[rowIndex]?.isNotEmpty ?? false;
  bool isCellEdited(int rowIndex, String fieldKey) =>
      _editedCells[rowIndex]?.contains(fieldKey) ?? false;
  bool isRowLoading(int rowIndex) => _loadingRows.contains(rowIndex);
  bool hasDuplicate(int rowIndex) =>
      _duplicateMatches[rowIndex]?.isNotEmpty ?? false;
  bool isRowSelected(int rowIndex) => _selectedRows.contains(rowIndex);

  void toggleRowSelection(int rowIndex, bool isSelected) {
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

  List<CsvReviewRow> rowsForStatus(CsvRowReviewStatus? status) {
    if (status == null) {
      return List<CsvReviewRow>.unmodifiable(_rows);
    }
    return List<CsvReviewRow>.unmodifiable(
        _groupedRows[status] ?? const <CsvReviewRow>[]);
  }

  Future<void> load() async {
    _isLoading = true;
    _loadError = null;
    notifyListeners();

    try {
      final CsvImportSession loadedSession = await service.loadCsv(filePath);
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

  Future<void> reload() => load();

  void updateDecision(int rowIndex, CsvRowDecision decision) {
    if (decision == CsvRowDecision.none) {
      _decisions.remove(rowIndex);
    } else {
      _decisions[rowIndex] = decision;
    }
    notifyListeners();
  }

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

  void bulkClearApprovals() {
    _decisions.removeWhere(
      (int _, CsvRowDecision value) => value == CsvRowDecision.approved,
    );
    notifyListeners();
  }

  void bulkRejectAll() {
    for (final CsvReviewRow row in _rows) {
      _decisions[row.originalIndex] = CsvRowDecision.rejected;
    }
    notifyListeners();
  }

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

  void approveAllValid() {
    bool changed = false;
    for (final CsvReviewRow row in _rows) {
      if (!_isValidStatus(row.status)) {
        continue;
      }
      if (hasDuplicate(row.originalIndex)) {
        continue;
      }
      if (_decisions[row.originalIndex] != CsvRowDecision.approved) {
        _decisions[row.originalIndex] = CsvRowDecision.approved;
        changed = true;
      }
    }
    if (_clearSelection()) {
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }

  void approveSelected() {
    if (_selectedRows.isEmpty) {
      return;
    }
    bool changed = false;
    for (final int rowIndex in List<int>.from(_selectedRows)) {
      final CsvReviewRow? row = _findRowByIndex(rowIndex);
      if (row == null) {
        continue;
      }
      if (hasDuplicate(rowIndex)) {
        continue;
      }
      if (_decisions[rowIndex] != CsvRowDecision.approved) {
        _decisions[rowIndex] = CsvRowDecision.approved;
        changed = true;
      }
    }
    if (_clearSelection()) {
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }

  void toggleRejectAll() {
    bool changed = false;
    if (hasRejectedDecisions) {
      changed = _clearRejectedDecisions();
    } else {
      for (final CsvReviewRow row in _rows) {
        if (_decisions[row.originalIndex] != CsvRowDecision.rejected) {
          _decisions[row.originalIndex] = CsvRowDecision.rejected;
          changed = true;
        }
      }
    }
    if (_clearSelection()) {
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }

  bool _clearSelection() {
    if (_selectedRows.isEmpty) {
      return false;
    }
    _selectedRows.clear();
    return true;
  }

  bool _clearRejectedDecisions() {
    final int before = _decisions.length;
    _decisions.removeWhere(
      (int _, CsvRowDecision decision) => decision == CsvRowDecision.rejected,
    );
    return before != _decisions.length;
  }

  CsvReviewRow? _findRowByIndex(int rowIndex) {
    for (final CsvReviewRow row in _rows) {
      if (row.originalIndex == rowIndex) {
        return row;
      }
    }
    return null;
  }

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

  Future<CsvFinalizeResult?> finalizeImport() async {
    if (_session == null) {
      return null;
    }
    _isFinalizing = true;
    notifyListeners();
    try {
      final CsvFinalizeResult result = await service.finalizeImport(
        session: _session!,
        decisions: _decisions,
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

  Map<String, String?> buildPayload(CsvReviewRow row) {
    final Map<String, String?> result = <String, String?>{};
    row.fields.forEach((String key, CsvFieldReview field) {
      result[key] = field.normalizedValue ?? field.originalValue;
    });
    return result;
  }

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

  String? _valueForComparison(CsvFieldReview? field) {
    if (field == null) {
      return null;
    }
    return field.normalizedValue ?? field.originalValue;
  }

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

  static Map<CsvRowReviewStatus, List<CsvReviewRow>> _emptyGroupedRows() =>
      <CsvRowReviewStatus, List<CsvReviewRow>>{
        CsvRowReviewStatus.ok: <CsvReviewRow>[],
        CsvRowReviewStatus.info: <CsvReviewRow>[],
        CsvRowReviewStatus.warn: <CsvReviewRow>[],
        CsvRowReviewStatus.rejected: <CsvReviewRow>[],
      };

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
      final String normalized = TextTools.normText(trimmed);
      if (_maleTokens.contains(normalized)) {
        return '1';
      }
      if (_femaleTokens.contains(normalized)) {
        return '2';
      }
      if (originalField != null &&
          trimmed == formatCsvFieldDisplay(fieldKey, originalField)) {
        return originalField.normalizedValue ??
            originalField.originalValue ??
            trimmed;
      }
      return trimmed;
    case 'datum_narozeni':
      final DateTime? parsed = TextTools.parseDate(trimmed);
      if (parsed != null) {
        return _czechDateFormatter.format(parsed);
      }
      if (originalField != null &&
          trimmed == formatCsvFieldDisplay(fieldKey, originalField)) {
        return originalField.normalizedValue ??
            originalField.originalValue ??
            trimmed;
      }
      return trimmed;
    case 'zpusobilost':
    case 'bezinfekcnost':
      final String normalizedBoolean = TextTools.normText(trimmed);
      if (_matchesYes(normalizedBoolean)) {
        return 'true';
      }
      if (_matchesNo(normalizedBoolean)) {
        return 'false';
      }
      if (originalField != null &&
          trimmed == formatCsvFieldDisplay(fieldKey, originalField)) {
        return originalField.normalizedValue ??
            originalField.originalValue ??
            trimmed;
      }
      return trimmed;
    default:
      return trimmed;
  }
}

final DateFormat _czechDateFormatter = DateFormat('dd.MM.yyyy');

String _formatGenderLabel(String rawValue) {
  final String normalized = TextTools.normText(rawValue);
  if (normalized.isEmpty) {
    return '';
  }
  if (_maleTokens.contains(normalized)) {
    return 'Muž';
  }
  if (_femaleTokens.contains(normalized)) {
    return 'Žena';
  }
  return rawValue;
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

const Set<String> _maleTokens = <String>{
  '1',
  'm',
  'muz',
  'male',
};

const Set<String> _femaleTokens = <String>{
  '2',
  'z',
  'zena',
  'f',
  'female',
};

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
    required this.filePath,
    required this.builder,
    this.service,
    this.loadingBuilder,
    this.errorBuilder,
  });

  final String filePath;
  final CsvReviewPrototypeWidgetBuilder builder;
  final CsvReviewService? service;
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
    _controller = CsvReviewPrototypeController(
      filePath: widget.filePath,
      service: widget.service,
    );
    _controller.addListener(_handleControllerChanged);
    _controller.load();
  }

  @override
  void didUpdateWidget(covariant CsvReviewPrototypeHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filePath != oldWidget.filePath ||
        widget.service != oldWidget.service) {
      _controller.removeListener(_handleControllerChanged);
      _controller.dispose();
      _controller = CsvReviewPrototypeController(
        filePath: widget.filePath,
        service: widget.service,
      );
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
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
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
