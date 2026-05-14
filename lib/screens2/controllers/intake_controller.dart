import 'dart:io';
import '../../database/in_memory_structures_tmp/memory_osoba.dart';
import '../../database/database_wrapper.dart';
import '../../input/file_manager.dart';
import '../../utils/app_logger.dart';
import '../widgets/memory_restriction_widget.dart';
import '../../shared/safe_change_notifier.dart';

/// Controller for handling intake form business logic
/// Separates business operations from UI concerns
/// Uses ChangeNotifier for reactive state management
class IntakeController extends SafeChangeNotifier {
  // Business logic instances
  final MemoryOmezeniLogic _omezeniLogic = MemoryOmezeniLogic();
  final MemoryLekLogic _lekLogic = MemoryLekLogic();
  final _logger = AppLogger.l;
  
  // Current state
  MemoryOsoba? selectedPerson;
  Directory? zpusobilostFolder;
  List<MemoryOsoba> _availablePersons = [];
  
  // Validation function reference
  bool Function()? _validateParticipantForm;
    /// Initialize the controller
  Future<void> initialize() async {
    // Try to get zpusobilost folder, but don't fail if unavailable
    // (may be null in test environments or when no event is selected)
    try {
      zpusobilostFolder = await FileManager().getZpusobilostFolder();
    } catch (e, st) {
      // Event directory not configured - zpusobilost folder unavailable
      // This is expected in some test scenarios; log for diagnostics
      _logger.d('Zpusobilost folder unavailable: $e', error: e, stackTrace: st);
      zpusobilostFolder = null;
    }
    
    // Fetch available persons for autocomplete
    await _fetchAvailablePersons();
    if (isDisposed) {
      return;
    }
    
    // Start with a new empty person
    if (selectedPerson == null) {
      selectedPerson = MemoryOsoba.basic('', '');
      selectedPerson!.id = -1; // -1 indicates this is a new person
    }
    
    notifyListeners();
  }
  
  /// Fetch available persons from database
  Future<void> _fetchAvailablePersons() async {
    try {
      _availablePersons = await DatabaseWrapper.getDatabase().getParticipantsByCurrentEvent();
      _logger.i('_fetchAvailablePersons: Loaded ${_availablePersons.length} persons');
    } catch (e, st) {
      _logger.e('_fetchAvailablePersons failed', error: e, stackTrace: st);
      _availablePersons = [];
    }
  }
  
  /// Set the validation function
  void setValidationFunction(bool Function()? validate) {
    _validateParticipantForm = validate;
  }
    /// Handle person selection
  ///
  /// Notifies listeners immediately so the form shows basic person data
  /// (name, DOB, insurance) instantly, then fetches restrictions/medications
  /// in background and notifies again when those are ready.
  Future<void> selectPerson(MemoryOsoba person) async {
    selectedPerson = person;
    notifyListeners(); // Immediate: form shows basic data right away

    // Background: fetch restrictions & medications, then update
    await _omezeniLogic.fetchData(person.id);
    if (isDisposed) {
      return;
    }
    await _lekLogic.fetchData(person.id);
    if (isDisposed) {
      return;
    }
    notifyListeners(); // Second update: restrictions/meds now populated
  }
    /// Handle file upload
  void uploadFile(String newFilePath) {
    if (selectedPerson != null) {
      selectedPerson!.potvrzeniPath = newFilePath;
      notifyListeners();
    }
  }

  /// Update selected person data (called from form)
  void updatePersonData(MemoryOsoba updatedPerson) {
    selectedPerson = updatedPerson;
    notifyListeners();
  }
    /// Handle save operation
  Future<bool> saveData(bool markAsArrived) async {
    final validationResult = _validateParticipantForm?.call() ?? false;
    if (!validationResult) {
      AppLogger.l.d('IntakeController: Form validation failed (markAsArrived=$markAsArrived)');
      return false;
    }
    if (selectedPerson != null) {
        final filePath = selectedPerson?.potvrzeniPath;
        if (filePath != null && filePath.isNotEmpty) {
          selectedPerson?.potvrzeniPath = filePath;
        }
        
        // Set arrived status if requested
        if (markAsArrived) {
          selectedPerson!.prisel = true;
        }
        
        bool success = false;
        // Distinguish between new and existing persons
        if (selectedPerson!.id == -1) {
          // New person: create first to get real ID, then patch logics before persisting
          final newId = await DatabaseWrapper.getDatabase().addOsobaAndReturnId(selectedPerson!);
          if (newId == null) {
            return false;
          }
          selectedPerson!.id = newId;
          _omezeniLogic.updateParticipantId(newId);
          _lekLogic.updateParticipantId(newId);
          success = true;
        } else {
          // Existing person - use updateParticipant
          final updateResult = await DatabaseWrapper.getDatabase().updateParticipant(osoba: selectedPerson!);
          success = updateResult > 0;
        }

        await _omezeniLogic.update();
        await _lekLogic.update();
        if (isDisposed) {
          return false;
        }
        
        // If successful, automatically reset state for next person
        if (success) {
          reset();
        }
        
        return success;
    }
    return false;
  }

  /// Reset controller state
  Future<void> reset() async {
    // Create a new empty person for the form
    selectedPerson = MemoryOsoba.basic('', '');
    selectedPerson!.id = -1; // -1 indicates this is a new person

    _omezeniLogic.reset();
    _lekLogic.reset();

    // Refresh available persons after reset (await to prevent race conditions)
    try {
      await _fetchAvailablePersons();
    } catch (e, st) {
      // Fetch failed, but continue - availablePersons will be stale but usable
      _logger.w('reset: _fetchAvailablePersons failed', error: e, stackTrace: st);
    }

    if (isDisposed) {
      return;
    }

    notifyListeners();
  }
    // Getters for accessing logic instances and data
  MemoryOmezeniLogic get omezeniLogic => _omezeniLogic;
  MemoryLekLogic get lekLogic => _lekLogic;
  List<MemoryOsoba> get availablePersons => _availablePersons;
  
  // Convenience getters for UI state
  bool get hasSelectedPerson => selectedPerson != null;
  bool get hasValidationFunction => _validateParticipantForm != null;
  bool get hasZpusobilostFolder => zpusobilostFolder != null;
  
  /// Check if there are unsaved changes (basic implementation)
  bool get hasUnsavedChanges => 
    selectedPerson != null && 
    (selectedPerson!.jmeno.isNotEmpty || selectedPerson!.prijmeni.isNotEmpty);
  
  /// Get display name for selected person
  String get selectedPersonDisplayName {
    if (selectedPerson == null) return '';
    return '${selectedPerson!.jmeno} ${selectedPerson!.prijmeni}';
  }
  
  /// Check if current person is new (not yet saved)
  bool get isNewPerson => selectedPerson?.id == -1;
  
  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}
