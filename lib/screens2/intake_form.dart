import 'dart:io';
import 'package:flutter/material.dart';
import 'package:denik_zza/screens2/widgets/app_drawer.dart';
import 'package:denik_zza/screens2/widgets/intake_bottom_row.dart';
import 'package:denik_zza/screens2/widgets/intake_main_content.dart';
import 'package:denik_zza/screens2/widgets/intake_person_row.dart';
import 'package:denik_zza/screens2/widgets/memory_restriction_widget.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/screens2/participant_registration_form.dart';
import '../database/database_wrapper.dart';
import '../input/file_manager.dart';

/// IntakeForm widget for managing participant check-in process
/// Handles person selection, form editing, restrictions, and file uploads
class IntakeForm extends StatefulWidget {
  const IntakeForm({super.key});

  @override
  State<IntakeForm> createState() => _IntakeFormState();
}

class _IntakeFormState extends State<IntakeForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Selected person and related data
  MemoryOsoba? selectedPerson;
  Directory? zpusobilostFolder;
  
  // Business logic instances
  final MemoryOmezeniLogic _omezeniLogic = MemoryOmezeniLogic();
  final MemoryLekLogic _lekLogic = MemoryLekLogic();
  
  // Form validation function
  bool Function()? _validateParticipantForm;
    // Widget instances
  ParticipantRegistrationForm? _participantRegistrationForm;

  @override
  void initState() {
    super.initState();
    _loadZpusobilostFolder();
    _initializeWidgets();
  }

  void _initializeWidgets() {
    _participantRegistrationForm = _createParticipantForm();
  }

  ParticipantRegistrationForm _createParticipantForm() {
    return ParticipantRegistrationForm(
      osoba: selectedPerson,
      onValidate: (validate) => _validateParticipantForm = validate,
      onOsobaEdited: (osoba) => setState(() => selectedPerson = osoba),
      onRefresh: _refreshPage,
    );
  }

  void _refreshPage() {
    setState(() {
      selectedPerson = null;
      _participantRegistrationForm = _createParticipantForm();
      _omezeniLogic.reset();
      _lekLogic.reset();
      // PersonAutocomplete will be rebuilt with new state
    });  }

  Future<void> _loadZpusobilostFolder() async {
    final folder = await FileManager().getZpusobilostFolder();
    setState(() => zpusobilostFolder = folder);  }

  void _onPersonSelected(MemoryOsoba person) {
    setState(() {
      selectedPerson = person;
      _omezeniLogic.fetchData(person.id);
      _lekLogic.fetchData(person.id);
      _participantRegistrationForm = _createParticipantForm();
    });  }

  void _onFileUploaded(String newFilePath) {
    if (selectedPerson != null) {
      setState(() => selectedPerson!.potvrzeniPath = newFilePath);
    }  }

  Future<void> _handleSave(BuildContext context, bool markAsArrived) async {
    if (_validateParticipantForm?.call() ?? false) {
      if (selectedPerson != null) {
        await _omezeniLogic.update();
        await _lekLogic.update();

        final filePath = selectedPerson?.potvrzeniPath;
        if (filePath != null && filePath.isNotEmpty) {
          selectedPerson?.potvrzeniPath = filePath;
          await DatabaseWrapper.getDatabase().updateParticipant(osoba: selectedPerson!);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(markAsArrived ? 'uložit a přišel' : 'uložit')),
          );
        }

        _refreshPage();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('něco nedopadlo')),
        );
      }
    }  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intake Form'),
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height
                    ),
                    child: Column(
                      children: [          
                             IntakePersonRow(
                          onPersonSelected: _onPersonSelected, 
                          onRefresh: _refreshPage,
                        ),
                        if (_participantRegistrationForm != null)
                          IntakeMainContent(
                            selectedPerson: selectedPerson,
                            onFileUploaded: _onFileUploaded,
                            zpusobilostFolder: zpusobilostFolder,
                            omezeniLogic: _omezeniLogic,
                            lekLogic: _lekLogic,
                            participantRegistrationForm: _participantRegistrationForm!,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_participantRegistrationForm != null)
                IntakeBottomRow(
                  formKey: _formKey,
                  selectedPerson: selectedPerson,
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
