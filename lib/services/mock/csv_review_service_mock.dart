import 'package:denik_zza/input/csv_review_models.dart';
import 'package:denik_zza/services/csv_import_service.dart';

/// In-memory mock of [CsvReviewService] for widget tests and UI prototypes.
///
/// The mock records invocation metadata and allows callers to provide
/// custom handlers for CSV loading and row re-parse operations.
class CsvReviewServiceMock implements CsvReviewService {
  CsvReviewServiceMock({
    required Future<CsvImportSession> Function(String path) onLoad,
    Future<CsvReviewRow> Function(Map<String, String?> updatedFields)? onReparse,
    Future<CsvFinalizeResult> Function(CsvImportSession session, Map<int, CsvRowDecision> decisions)?
        onFinalize,
    Future<Map<int, List<CsvDuplicateCandidate>>> Function(CsvImportSession session)? onFindDuplicates,
  })  : _onLoad = onLoad,
        _onReparse = onReparse,
        _onFinalize = onFinalize,
        _onFindDuplicates = onFindDuplicates;

  /// Convenience factory that always returns the provided [session].
  factory CsvReviewServiceMock.fixed({
    required CsvImportSession session,
    CsvReviewRow? reparseRow,
    CsvFinalizeResult? finalizeResult,
    Map<int, List<CsvDuplicateCandidate>>? duplicateMatches,
  }) {
    return CsvReviewServiceMock(
      onLoad: (_) async => session,
      onReparse: (_) async {
        if (reparseRow != null) {
          return reparseRow;
        }
        if (session.review.rows.isEmpty) {
          throw StateError('CsvReviewServiceMock.fixed requires at least one row.');
        }
        return session.review.rows.first;
      },
      onFinalize: (_, __) async => finalizeResult ??
          CsvFinalizeResult(
            approvedCount: 0,
            rejectedCount: 0,
            savedRowIndices: const <int>[],
            failures: const <CsvFinalizeFailure>[],
          ),
      onFindDuplicates: (_) async => duplicateMatches ?? const <int, List<CsvDuplicateCandidate>>{},
    );
  }

  final Future<CsvImportSession> Function(String path) _onLoad;
  final Future<CsvReviewRow> Function(Map<String, String?> updatedFields)? _onReparse;
  final Future<CsvFinalizeResult> Function(
      CsvImportSession session, Map<int, CsvRowDecision> decisions)? _onFinalize;
  final Future<Map<int, List<CsvDuplicateCandidate>>> Function(CsvImportSession session)?
      _onFindDuplicates;

  int loadInvocations = 0;
  String? lastLoadPath;
  int reparseInvocations = 0;
  Map<String, String?>? lastReparsePayload;
  int finalizeInvocations = 0;
  CsvImportSession? lastFinalizeSession;
  Map<int, CsvRowDecision>? lastFinalizeDecisions;
  int findDuplicateInvocations = 0;

  @override
  Future<CsvImportSession> loadCsv(String path) async {
    loadInvocations += 1;
    lastLoadPath = path;
    return _onLoad(path);
  }

  @override
  Future<CsvReviewRow> reparseRow(Map<String, String?> updatedFields) async {
    final Future<CsvReviewRow> Function(Map<String, String?> updatedFields)? handler =
        _onReparse;
    if (handler == null) {
      throw UnimplementedError('No reparse handler registered for CsvReviewServiceMock.');
    }
    reparseInvocations += 1;
    lastReparsePayload = Map<String, String?>.from(updatedFields);
    return handler(updatedFields);
  }

  @override
  Future<CsvFinalizeResult> finalizeImport({
    required CsvImportSession session,
    required Map<int, CsvRowDecision> decisions,
  }) async {
    final Future<CsvFinalizeResult> Function(
            CsvImportSession session, Map<int, CsvRowDecision> decisions)? handler =
        _onFinalize;
    if (handler == null) {
      throw UnimplementedError('No finalize handler registered for CsvReviewServiceMock.');
    }
    finalizeInvocations += 1;
    lastFinalizeSession = session;
    lastFinalizeDecisions = Map<int, CsvRowDecision>.from(decisions);
    return handler(session, decisions);
  }

  @override
  Future<Map<int, List<CsvDuplicateCandidate>>> findPotentialDuplicates({
    required CsvImportSession session,
  }) async {
    final Future<Map<int, List<CsvDuplicateCandidate>>> Function(CsvImportSession session)?
        handler = _onFindDuplicates;
    if (handler == null) {
      return const <int, List<CsvDuplicateCandidate>>{};
    }
    findDuplicateInvocations += 1;
    return handler(session);
  }
}
