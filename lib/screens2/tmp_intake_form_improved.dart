import 'package:flutter/material.dart';
import 'package:denik_zza/screens2/widgets/app_drawer.dart';
import 'package:denik_zza/screens2/widgets/intake_bottom_row.dart';
import 'package:denik_zza/screens2/widgets/intake_main_content.dart';
import 'package:denik_zza/screens2/widgets/intake_person_row.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/screens2/participant_registration_form.dart';
import 'package:denik_zza/screens2/controllers/intake_controller.dart';

/// Improved IntakeForm widget using IntakeController for business logic
/// This version separates UI concerns from business logic
class TmpIntakeFormImproved extends StatefulWidget {
  const TmpIntakeFormImproved({super.key});

  @override
  State<TmpIntakeFormImproved> createState() => _TmpIntakeFormImprovedState();
}

class _TmpIntakeFormImprovedState extends State<TmpIntakeFormImproved> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Controller for business logic
  late final IntakeController _controller;
  
  // Widget instances
  ParticipantRegistrationForm? _participantRegistrationForm;
  
  // Key for PersonAutocomplete to force rebuild
  Key _personAutocompleteKey = UniqueKey();

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
    setState(() {
      // Rebuild participant form when person changes (always show form)
      _participantRegistrationForm = _createParticipantForm();
      
      // If the controller was reset, also clear the autocomplete
      if (_controller.isNewPerson && 
          _controller.selectedPerson!.jmeno.isEmpty && 
          _controller.selectedPerson!.prijmeni.isEmpty) {
        _personAutocompleteKey = UniqueKey();
      }
    });
  }

  Future<void> _initializeController() async {
    await _controller.initialize();
  }

  void _initializeWidgets() {
    _participantRegistrationForm = _createParticipantForm();
  }

  ParticipantRegistrationForm _createParticipantForm() {
    return ParticipantRegistrationForm(
      osoba: _controller.selectedPerson,
      onValidate: (validate) => _controller.setValidationFunction(validate),
      onOsobaEdited: (osoba) => _controller.updatePersonData(osoba),
      onRefresh: _refreshPage,
    );
  }

  void _refreshPage() {
    _controller.reset();
    // Force rebuild of PersonAutocomplete to clear search field
    _personAutocompleteKey = UniqueKey();
    // The form will be recreated automatically due to the listener
  }
  void _onPersonSelected(MemoryOsoba person) async {
    await _controller.selectPerson(person);
  }

  void _onFileUploaded(String newFilePath) {
    _controller.uploadFile(newFilePath);
  }

  Future<void> _handleSave(BuildContext context, bool markAsArrived) async {
    final success = await _controller.saveData(markAsArrived);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(markAsArrived ? 'uložit a přišel' : 'uložit')),
        );
        // No need to call _refreshPage() - controller automatically resets state
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('něco nedopadlo')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intake Form (Improved)'),
      ),
      drawer: const AppDrawer(),      
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600),
          child: Column(
            children: [
              IntakePersonRow(
                key: _personAutocompleteKey,
                onPersonSelected: _onPersonSelected, 
                onRefresh: _refreshPage,
              ),
              // Always show the form since we always have a person (even if new)
              Expanded(
                child: SingleChildScrollView(
                  child: IntakeMainContent(
                    selectedPerson: _controller.selectedPerson,
                    onFileUploaded: _onFileUploaded,
                    zpusobilostFolder: _controller.zpusobilostFolder,
                    omezeniLogic: _controller.omezeniLogic,
                    lekLogic: _controller.lekLogic,
                    participantRegistrationForm: _participantRegistrationForm!,
                  ),
                ),
              ),
              // Always show the bottom row since we always have a form
              IntakeBottomRow(
                formKey: _formKey,
                selectedPerson: _controller.selectedPerson,
                onFileUploaded: _onFileUploaded,
                handleSave: _handleSave,
                participantRegistrationForm: _participantRegistrationForm!,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
