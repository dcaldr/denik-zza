import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/widgets/center_toast.dart';
import 'package:denik_zza/screens2/widgets/app_drawer.dart';
import 'package:denik_zza/screens2/widgets/intake_bottom_row.dart';
import 'package:denik_zza/screens2/widgets/intake_main_content.dart';
import 'package:denik_zza/screens2/widgets/intake_person_row.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/screens2/participant_registration_form.dart';
import 'package:denik_zza/screens2/controllers/intake_controller.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/utils/app_logger.dart';

/// Improved IntakeForm widget using IntakeController for business logic
/// This version separates UI concerns from business logic
class NewIntakeFormImproved extends StatefulWidget {
  const NewIntakeFormImproved({super.key});

  @override
  State<NewIntakeFormImproved> createState() => _NewIntakeFormImprovedState();
}

class _NewIntakeFormImprovedState extends State<NewIntakeFormImproved> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controller for business logic
  late final IntakeController _controller;

  // Key for accessing form state to sync data before save
  final GlobalKey<ParticipantRegistrationFormState> _participantFormKey =
      GlobalKey<ParticipantRegistrationFormState>();

  // Widget instances
  ParticipantRegistrationForm? _participantRegistrationForm;

  // Key for PersonAutocomplete to force rebuild
  Key _personAutocompleteKey = UniqueKey();

  // Loading state - prevents interaction before data is ready
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = IntakeController();
    _controller.addListener(_onControllerStateChanged);
    _initializeController();
    _initializeWidgets();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerStateChanged);
    _controller.dispose();
    super.dispose();
  }

  /// Called when controller state changes
  void _onControllerStateChanged() {
    if (!mounted) {
      return;
    }
    setState(() {
      // Rebuild participant form when person changes (always show form)
      _participantRegistrationForm = _createParticipantForm();

      // Only regenerate key for actual UI reset (when creating truly new person)
      // Add null safety check
      if (_controller.isNewPerson &&
          _controller.selectedPerson != null &&
          _controller.selectedPerson!.jmeno.isEmpty &&
          _controller.selectedPerson!.prijmeni.isEmpty) {
        _personAutocompleteKey = UniqueKey();
      }
    });
  }

  Future<void> _initializeController() async {
    try {
      await _controller.initialize();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e, st) {
      AppLogger.l.e('Intake init failed', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      CenterToast.show(
        context,
        'Nepodařilo se načíst data pro intake.',
        icon: Icons.error_outline,
        iconColor: Colors.red.shade600,
      );
    }
  }

  void _initializeWidgets() {
    _participantRegistrationForm = _createParticipantForm();
  }

  ParticipantRegistrationForm _createParticipantForm() {
    return ParticipantRegistrationForm(
      key: _participantFormKey,
      osoba: _controller.selectedPerson,
      onValidate: (validate) => _controller.setValidationFunction(validate),
      onOsobaEdited: (osoba) => _controller.updatePersonData(osoba),
      onRefresh: _refreshPage,
      enableStickyFooter:
          true, // Hide internal button (handled by IntakeBottomRow)
      // Inject shared logic instances so restrictions added in the UI
      // are saved when IntakeController.saveData() calls update().
      omezeniLogic: _controller.omezeniLogic,
      lekLogic: _controller.lekLogic,
    );
  }

  void _refreshPage() {
    _controller.reset();
    // Force rebuild of PersonAutocomplete to clear search field
    _personAutocompleteKey = UniqueKey();
    // The form will be recreated automatically due to the listener
  }

  void _onPersonSelected(MemoryOsoba person) async {
    try {
      await _controller.selectPerson(person);
    } catch (e, st) {
      AppLogger.l.w('Selecting participant in intake failed', error: e, stackTrace: st);
      if (mounted) {
        CenterToast.show(
          context,
          'Nepodařilo se vybrat účastníka.',
          icon: Icons.error_outline,
          iconColor: Colors.red.shade600,
        );
      }
    }
  }

  void _onFileUploaded(String newFilePath) {
    _controller.uploadFile(newFilePath);
  }

  /// Handles save + toast feedback.
  Future<void> _handleSave(bool markAsArrived) async {
    final currentEventId =
        await DatabaseWrapper.getDatabase().getCurrentEventID();
    if (!mounted) return;
    if (currentEventId == null) {
      CenterToast.show(
        context,
        'Nejprve vytvořte akci',
        icon: Icons.error_outline,
        iconColor: Colors.red.shade600,
      );
      return;
    }

    if (_controller.selectedPerson == null) {
      CenterToast.show(
        context,
        'Vyberte účastníka',
        icon: Icons.error_outline,
        iconColor: Colors.red.shade600,
      );
      return;
    }

    // CRITICAL: Sync form data to controller before save
    // Form edits are stored in form's controllers, not in selectedPerson
    final formData = _participantFormKey.currentState?.createMemoryOsoba();
    if (formData != null) {
      _controller.updatePersonData(formData);
    }
    
    // Capture participant name and gender before save (for toast message)
    final participantName = _controller.selectedPerson != null
        ? '${_controller.selectedPerson!.jmeno} ${_controller.selectedPerson!.prijmeni}'.trim()
        : 'Účastník';
    final isFemale = _controller.selectedPerson?.pohlavi == MemoryOsoba.POHLAVI_ZENA;
    
    final success = await _controller.saveData(markAsArrived);

    if (!mounted) return;
    
    if (success) {
      if (markAsArrived) {
        // Green for "přišel/přišla" (arrived)
        CenterToast.show(
          context,
          '$participantName ${isFemale ? 'přišla' : 'přišel'}',
          icon: Icons.check_circle,
          iconColor: Colors.green.shade600,
        );
      } else {
        // Blue for "uložen/uložena" (saved only)
        CenterToast.show(
          context,
          '$participantName ${isFemale ? 'uložena' : 'uložen'}',
          icon: Icons.save,
          iconColor: Colors.blue.shade600,
        );
      }
      // No need to call _refreshPage() - controller automatically resets state
    } else {
      // Red for error
      CenterToast.show(
        context,
        '$participantName ${isFemale ? 'neuložena' : 'neuložen'}',
        icon: Icons.error_outline,
        iconColor: Colors.red.shade600,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intake Form (Improved)'),
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(
              key: Key('IntakeForm_loading'),
              child: CircularProgressIndicator(),
            )
          : Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600),
          child: Column(
            children: [
              ListenableBuilder(
                listenable: _controller,
                builder: (context, child) {
                  return IntakePersonRow(
                    key: _personAutocompleteKey,
                    onPersonSelected: _onPersonSelected,
                    onRefresh: _refreshPage,
                    availablePersons: _controller.availablePersons,
                  );
                },
              ),
              // Always show the form since we always have a person (even if new)
              // Always show the form since we always have a person (even if new)
              Expanded(
                child: IntakeMainContent(
                  selectedPerson: _controller.selectedPerson,
                  onFileUploaded: _onFileUploaded,
                  zpusobilostFolder: _controller.zpusobilostFolder,
                  participantRegistrationForm: _participantRegistrationForm!,
                ),
              ),
              // Always show the bottom row since we always have a form
              IntakeBottomRow(
                formKey: _formKey,
                selectedPerson: _controller.selectedPerson,
                onFileUploaded: _onFileUploaded,
                handleSave: _handleSave,
                participantRegistrationForm: _participantRegistrationForm!,
                onCancel: _refreshPage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
