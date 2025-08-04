import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../database/in_memory_structures_tmp/memory_osoba.dart';
import '../../database/database_wrapper.dart';
import '../../input/file_manager.dart';
import '../widgets/memory_restriction_widget.dart';

/// Controller for handling intake form business logic
/// Separates business operations from UI concerns
/// Uses ChangeNotifier for reactive state management
class IntakeController extends ChangeNotifier {
  // Business logic instances
  final MemoryOmezeniLogic _omezeniLogic = MemoryOmezeniLogic();
  final MemoryLekLogic _lekLogic = MemoryLekLogic();
  
  // Current state
  MemoryOsoba? selectedPerson;
  Directory? zpusobilostFolder;
  List<MemoryOsoba> _availablePersons = [];
  
  // Validation function reference
  bool Function()? _validateParticipantForm;
    /// Initialize the controller
  Future<void> initialize() async {
    zpusobilostFolder = await FileManager().getZpusobilostFolder();
    
    // Fetch available persons for autocomplete
    await _fetchAvailablePersons();
    
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
    } catch (e) {
      _availablePersons = [];
    }
  }
  
  /// Set the validation function
  void setValidationFunction(bool Function()? validate) {
    _validateParticipantForm = validate;
  }
    /// Handle person selection
  Future<void> selectPerson(MemoryOsoba person) async {
    selectedPerson = person;
    await _omezeniLogic.fetchData(person.id);
    await _lekLogic.fetchData(person.id);
    // Note: No need to refresh available persons when just selecting existing person
    notifyListeners();
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
    if (_validateParticipantForm?.call() ?? false) {
      if (selectedPerson != null) {
        await _omezeniLogic.update();
        await _lekLogic.update();

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
          // New person - use addOsoba
          success = await DatabaseWrapper.getDatabase().addOsoba(selectedPerson!);
        } else {
          // Existing person - use updateParticipant
          final updateResult = await DatabaseWrapper.getDatabase().updateParticipant(osoba: selectedPerson!);
          success = updateResult > 0;
        }
        
        // If successful, automatically reset state for next person
        if (success) {
          reset();
        }
        
        return success;
      }
    }
    return false;
  }
    /// Reset controller state
  void reset() {
    // Create a new empty person for the form
    selectedPerson = MemoryOsoba.basic('', '');
    selectedPerson!.id = -1; // -1 indicates this is a new person
    
    _omezeniLogic.reset();
    _lekLogic.reset();
    
    // Refresh available persons after reset (async but don't await to avoid blocking)
    _fetchAvailablePersons().then((_) {
      // Notify listeners after data is refreshed
      notifyListeners();
    }).catchError((e) {
      // Even if fetch fails, still notify for UI update
      notifyListeners();
    });
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
