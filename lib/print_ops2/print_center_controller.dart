import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_lek.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_omezeni.dart';
import 'package:denik_zza/utils/record_sort_utils.dart';
import 'package:denik_zza/print_ops2/models/append_analysis.dart';
import 'print_center_service.dart';
import 'generate_pdf_template.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/utils/app_logger.dart';


/// Print mode (UI state).
enum PrintMode { full, append }

/// Print confirmation result.
enum PrintSimulationResult { success, repeat, noChange, reset, resetAndReprint }

/// Controller (ChangeNotifier) for Print Center state.
/// Responsible for loading data, reacting to changes and exposing values to the UI.
class PrintCenterController extends ChangeNotifier {
  final PrintCenterService _service;
  StreamSubscription<List<MemoryOsoba>>? _participantsSub;

  PrintCenterController(this._service);

  // Printer calibration state
  bool? _printerPage1OnTop; // null = not calibrated yet


  // Participants state
  List<MemoryOsoba> _participants = [];
  bool _loadingParticipants = true;
  String? _participantError;

  // Selected participant detail
  MemoryOsoba? _selected;
  List<MemoryZaznam> _records = [];
  List<MemoryLek> _leky = [];
  List<MemoryOmezeni> _omezeni = [];
  bool _loadingDetail = false;
  String? _detailError;

  // Mode & simulation
  PrintMode _mode = PrintMode.full;
  bool _simulatedPrinted =
      false; // whether simulated print success already happened
  PrintSimulationResult? _lastResult;

  // Append validation state
  bool? _appendPossible; // null = not evaluated yet
  bool _appendChecking = false;
  String? _appendError;

  // Append analysis state (for multi-page)
  AppendAnalysis? _appendAnalysis;
  bool _analysisInProgress = false;
  String? _analysisError;

  // PDF Generation state
  bool _generatingPdf = false;
  String? _pdfGenerationError;

  // Gettery
  List<MemoryOsoba> get participants => _participants;
  bool get loadingParticipants => _loadingParticipants;
  String? get participantError => _participantError;
  MemoryOsoba? get selected => _selected;
  List<MemoryZaznam> get records => _records;
  List<MemoryLek> get leky => _leky;
  List<MemoryOmezeni> get omezeni => _omezeni;
  bool get loadingDetail => _loadingDetail;
  String? get detailError => _detailError;
  bool get generatingPdf => _generatingPdf;
  String? get pdfGenerationError => _pdfGenerationError;
  PrintMode get mode => _mode;
  bool get simulatedPrinted => _simulatedPrinted;
  PrintSimulationResult? get lastResult => _lastResult;
  bool? get appendPossible => _appendPossible;
  bool get appendChecking => _appendChecking;
  String? get appendError => _appendError;

  // Append analysis getters
  AppendAnalysis? get appendAnalysis => _appendAnalysis;
  bool get analysisInProgress => _analysisInProgress;
  String? get analysisError => _analysisError;
  bool? get printerPage1OnTop => _printerPage1OnTop;


  /// Initialization – subscribe to participants stream.
  void init() {
    _loadPrinterCalibration();

    _participantsSub = _service.watchCurrentEventParticipants().listen((data) {

      _participants = data;
      _loadingParticipants = false;
      _participantError = null;
      notifyListeners();
    }, onError: (e) {
      _participantError = 'Chyba při načítání účastníků: $e';
      _loadingParticipants = false;
      notifyListeners();
    });
  }

  /// Select a participant and load its details (records, meds, restrictions).
  Future<void> selectParticipant(MemoryOsoba osoba) async {
    _selected = osoba;
    // Reset flow state only on new selection
    _mode = PrintMode.full;
    _simulatedPrinted = false;
    _lastResult = null;
    // Reset append analysis state
    _appendAnalysis = null;
    _analysisInProgress = false;
    _analysisError = null;

    await _loadParticipantDetails(osoba);
  }

  Future<void> _loadParticipantDetails(MemoryOsoba osoba) async {
    _loadingDetail = true;
    _detailError = null;
    _records = [];
    _leky = [];
    _omezeni = [];
    notifyListeners();

    try {
      final r = await _service.getRecords(osoba.id);
      final l = await _service.getLeky(osoba.id);
      final o = await _service.getOmezeni(osoba.id);
      _records = r
        ..sort(compareRecordsByTime);
      _leky = l;
      _omezeni = o;

      // Trigger append validation
      await _evaluateAppend();
    } catch (e) {
      _detailError = 'Chyba načítání detailu: $e';
    } finally {
      _loadingDetail = false;
      notifyListeners();
    }
  }

  void changeMode(PrintMode newMode) {
    _mode = newMode;
    notifyListeners();
  }

  Future<Uint8List> generateCurrentPdf() async {
    if (_selected == null) {
      throw Exception("No person selected");
    }
    // Note: We intentionally avoid notifyListeners() here to prevent
    // infinite rebuild loops when this is called from PdfPreview.build()

    try {
      if (_mode == PrintMode.append) {
        // Append mode: strict usage of the 3-pass algorithm
        final template = GeneratePdfTemplate();
        final result = await template.analyzeAndBuildAppend(
          osoba: _selected!,
          omezeniList: _omezeni,
          lekList: _leky,
          zaznamList: _records,
        );
        return Uint8List.fromList(result.pdfBytes);
      } else {
        // Full mode: Standard generation logic
        final template = GeneratePdfTemplate();
        final pages = await template.getPdfPages(
          osoba: _selected!,
          omezeniList: _omezeni,
          lekList: _leky,
          zaznamList: _records,
        );

        final doc = pw.Document();
        for (final p in pages) {
          doc.addPage(p);
        }
        return await doc.save();
      }
    } catch (e) {
      _pdfGenerationError = "Chyba generování PDF: $e";
      // We notify on error so UI can show it, but only on error
      notifyListeners();
      rethrow;
    }
  }

  /// Generates aggregated PDF for multiple participants (Full Mode for each).
  Future<Uint8List> generateAggregatedPdf(List<int> ids) async {
    _generatingPdf = true;
    _pdfGenerationError = null;
    notifyListeners();

    try {
      final doc = pw.Document();
      final template = GeneratePdfTemplate();

      for (final pid in ids) {
        final person = _participants.firstWhere((p) => p.id == pid,
            orElse: () => throw Exception('Person $pid not found'));

        // Load details for this person
        final records = await _service.getRecords(pid);
        final meds = await _service.getLeky(pid);
        final restr = await _service.getOmezeni(pid);

        // Sort records standard way
        records.sort(compareRecordsByTime);

        // Generate pages
        final pages = await template.getPdfPages(
          osoba: person,
          omezeniList: restr,
          lekList: meds,
          zaznamList: records,
        );

        for (final p in pages) {
          doc.addPage(p);
        }
      }

      return await doc.save();
    } catch (e) {
      _pdfGenerationError = "Chyba generování hromadného PDF: $e";
      notifyListeners();
      rethrow;
    } finally {
      _generatingPdf = false;
      notifyListeners();
    }
  }

  /// Confirm aggregated print success.
  /// Mark all selected participants and their records as printed.
  Future<void> confirmAggregatedPrint(List<int> ids) async {
    for (final pid in ids) {
      // 1. Mark Person
      await _service.setParticipantPrintedFlag(pid, true);

      // 2. Mark Records (we need to fetch them to get IDs)
      // This is slightly inefficient but safe.
      try {
        final records = await _service.getRecords(pid);
        final recIds = records.map((r) => r.idZaznamu).toList();
        if (recIds.isNotEmpty) {
          await _service.setMultipleRecordPrintedFlags(recIds, true);
        }
      } catch (e) {
        // Log error but continue with others
        AppLogger.l.e('Error confirming print for person $pid', error: e);
      }
    }
  }

  /// Confirm result of actual printing.
  /// Calls DB service to persist changes.
  Future<void> confirmPrintResult(PrintSimulationResult result) async {
    _lastResult = result;

    // UI state update
    if (result == PrintSimulationResult.success) {
      _simulatedPrinted = true;

      // DB persistence update
      if (_selected != null) {
        // 1. Mark Person as printed
        await _service.setParticipantPrintedFlag(_selected!.id, true);

        // 2. Mark records
        List<int> recordsToMark = [];
        if (_mode == PrintMode.full) {
          // Mark ALL records
          recordsToMark = _records.map((e) => e.idZaznamu).toList();
        } else {
          // Append: Mark only currently unprinted records
          recordsToMark = _records
              .where((e) => !e.isPrinted)
              .map((e) => e.idZaznamu)
              .toList();
        }

        if (recordsToMark.isNotEmpty) {
          await _service.setMultipleRecordPrintedFlags(recordsToMark, true);
        }

        // Refresh data to reflect changes WITHOUT resetting UI state
        await _loadParticipantDetails(_selected!);
      }
    } else if (result == PrintSimulationResult.reset ||
        result == PrintSimulationResult.resetAndReprint) {
      _simulatedPrinted = false;

      if (_selected != null) {
        await _service.setParticipantPrintedFlag(_selected!.id, false);
        final allIds = _records.map((e) => e.idZaznamu).toList();
        if (allIds.isNotEmpty) {
          await _service.setMultipleRecordPrintedFlags(allIds, false);
        }
        await _loadParticipantDetails(_selected!);
      }
    }

    notifyListeners();
  }

  // Placeholder logic removed. UI must rely on _appendPossible (validated) or wait.

  void resetFlow() {
    _selected = null;
    _mode = PrintMode.full;
    _simulatedPrinted = false;
    _lastResult = null;
    _appendPossible = null;
    _appendChecking = false;
    _appendError = null;
    // Reset append analysis state
    _appendAnalysis = null;
    _analysisInProgress = false;
    _analysisError = null;
    notifyListeners();
  }

  /// Load all records for given participant IDs, aggregate them and sort ascending by time.
  Future<List<MemoryZaznam>> fetchAggregatedRecords(
      List<int> participantIds) async {
    List<MemoryZaznam> all = [];
    for (final id in participantIds) {
      try {
        final r = await _service.getRecords(id);
        all.addAll(r);
      } catch (e) {
        AppLogger.l.e('Error fetching records for aggregated print', error: e);
      }
    }
    all.sort(compareRecordsByTime);
    return all;
  }

  /// Check which participants have records to print
  Future<Map<int, bool>> checkParticipantsWithRecords(
      List<int> participantIds) async {
    final Map<int, bool> result = {};
    for (final id in participantIds) {
      try {
        final records = await _service.getRecords(id);
        result[id] = records.isNotEmpty;
      } catch (_) {
        result[id] = false; // Error occurred, consider as no records
      }
    }
    return result;
  }

  /// Fetch medications for a specific participant
  Future<List<MemoryLek>> fetchMedicationsForParticipant(
      int participantId) async {
    try {
      return await _service.getLeky(participantId);
    } catch (_) {
      return []; // Return empty list on error
    }
  }

  /// Fetch restrictions for a specific participant
  Future<List<MemoryOmezeni>> fetchRestrictionsForParticipant(
      int participantId) async {
    try {
      return await _service.getOmezeni(participantId);
    } catch (_) {
      return []; // Return empty list on error
    }
  }

  /// Fetch all data needed for generating PDF for a specific participant
  Future<Map<String, dynamic>> fetchParticipantPdfData(
      int participantId) async {
    try {
      final records = await _service.getRecords(participantId);
      final medications = await _service.getLeky(participantId);
      final restrictions = await _service.getOmezeni(participantId);

      return {
        'records': records,
        'medications': medications,
        'restrictions': restrictions,
      };
    } catch (e) {
      return {
        'records': <MemoryZaznam>[],
        'medications': <MemoryLek>[],
        'restrictions': <MemoryOmezeni>[],
        'error': e.toString(),
      };
    }
  }

  Future<void> _evaluateAppend() async {
    if (_selected == null) return;
    _appendChecking = true;
    _appendPossible = null;
    _appendError = null;
    notifyListeners();
    try {
      final template = GeneratePdfTemplate.named(
        osoba: _selected,
        zaznamList: List.of(_records), // copy to avoid mutation side-effects
      );
      final result = template.canAppend();
      _appendPossible = result;
    } catch (e) {
      _appendError = 'Nepodařilo se ověřit append: $e';
    } finally {
      _appendChecking = false;
      notifyListeners();
    }
  }

  /// Analyze append scenario using three-pass algorithm
  Future<void> analyzeAppendScenario() async {
    if (_selected == null) return;

    _analysisInProgress = true;
    _appendAnalysis = null;
    _analysisError = null;
    notifyListeners();

    try {
      final template = GeneratePdfTemplate();

      final result = await template.analyzeAndBuildAppend(
        osoba: _selected!,
        omezeniList: _omezeni,
        lekList: _leky,
        zaznamList: _records,
      );

      _appendAnalysis = result.analysis;
    } catch (e) {
      _analysisError = 'Nepodařilo se analyzovat: $e';
    } finally {
      _analysisInProgress = false;
      notifyListeners();
    }
  }

  /// Load printer calibration setting
  Future<void> _loadPrinterCalibration() async {
    try {
      final db = DatabaseWrapper.getDatabase();
      _printerPage1OnTop = await db.getPrinterPage1OnTop();
      notifyListeners();
    } catch (e) {
      AppLogger.l.w('Failed to load printer calibration: $e');
    }
  }


  @override
  void dispose() {
    _participantsSub?.cancel();
    super.dispose();
  }
}
