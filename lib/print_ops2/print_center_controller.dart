import 'dart:async';
import 'package:flutter/material.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_lek.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_omezeni.dart';
import 'package:denik_zza/print_ops2/models/append_analysis.dart';
import 'print_center_service.dart';
import 'generate_pdf_template.dart';

/// Print mode (UI state).
enum PrintMode { full, append }

/// Simulated print confirmation result (UI only for now).
enum PrintSimulationResult { success, repeat, noChange, reset, resetAndReprint }

/// Controller (ChangeNotifier) for Print Center state.
/// Responsible for loading data, reacting to changes and exposing values to the UI.
class PrintCenterController extends ChangeNotifier {
  final PrintCenterService _service;
  StreamSubscription<List<MemoryOsoba>>? _participantsSub;

  PrintCenterController(this._service);

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
  bool _simulatedPrinted = false; // whether simulated print success already happened
  PrintSimulationResult? _lastResult;

  // Append validation state
  bool? _appendPossible; // null = not evaluated yet
  bool _appendChecking = false;
  String? _appendError;

  // Append analysis state (for multi-page)
  AppendAnalysis? _appendAnalysis;
  bool _analysisInProgress = false;
  String? _analysisError;

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

  /// Initialization – subscribe to participants stream.
  void init() {
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
    _loadingDetail = true;
    _detailError = null;
    _records = [];
    _leky = [];
    _omezeni = [];
    _mode = PrintMode.full; // reset
    _simulatedPrinted = false;
    _lastResult = null;
    // Reset append analysis state
    _appendAnalysis = null;
    _analysisInProgress = false;
    _analysisError = null;
    notifyListeners();

    try {
      final r = await _service.getRecords(osoba.id);
      final l = await _service.getLeky(osoba.id);
      final o = await _service.getOmezeni(osoba.id);
      _records = r
        ..sort((a, b) {
          final ad = a.casZaznamu;
          final bd = b.casZaznamu;
          if (ad == null && bd == null) return 0;
          if (ad == null) return -1;
          if (bd == null) return 1;
          return ad.compareTo(bd);
        });
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

  /// Simulate confirmation result of printing – UI state only.
  void simulateResult(PrintSimulationResult result) {
    _lastResult = result;
    if (result == PrintSimulationResult.success) {
      _simulatedPrinted = true;
    }
    if (result == PrintSimulationResult.reset || result == PrintSimulationResult.resetAndReprint) {
      // Reset printed simulation flag; in future also clear DB flags.
      _simulatedPrinted = false;
    }
    // TODO: v budoucnu zde volat update printed flags v DB
    notifyListeners();
  }

  /// Rough (fallback) append possibility logic – legacy placeholder.
  bool get canAppendPlaceholder {
  // Kept for old UI compatibility; now only fallback if validated state is null
    if (_appendPossible != null) return _appendPossible!;
    if (_selected == null) return false;
    return _records.any((r) => !r.isPrinted);
  }

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
  Future<List<MemoryZaznam>> fetchAggregatedRecords(List<int> participantIds) async {
    List<MemoryZaznam> all = [];
    for (final id in participantIds) {
      try {
        final r = await _service.getRecords(id);
        all.addAll(r);
      } catch (_) {
        // Ignore individual failures; TODO add logging
      }
    }
    all.sort((a,b){
      final ad = a.casZaznamu;
      final bd = b.casZaznamu;
      if (ad == null && bd == null) return 0;
      if (ad == null) return -1;
      if (bd == null) return 1;
      return ad.compareTo(bd);
    });
    return all;
  }
  
  /// Check which participants have records to print
  Future<Map<int, bool>> checkParticipantsWithRecords(List<int> participantIds) async {
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
  Future<List<MemoryLek>> fetchMedicationsForParticipant(int participantId) async {
    try {
      return await _service.getLeky(participantId);
    } catch (_) {
      return []; // Return empty list on error
    }
  }
  
  /// Fetch restrictions for a specific participant
  Future<List<MemoryOmezeni>> fetchRestrictionsForParticipant(int participantId) async {
    try {
      return await _service.getOmezeni(participantId);
    } catch (_) {
      return []; // Return empty list on error
    }
  }
  
  /// Fetch all data needed for generating PDF for a specific participant
  Future<Map<String, dynamic>> fetchParticipantPdfData(int participantId) async {
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

  @override
  void dispose() {
    _participantsSub?.cancel();
    super.dispose();
  }
}
