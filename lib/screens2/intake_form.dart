import 'dart:io';
import 'package:flutter/material.dart';
import 'package:denik_zza/screens2/widgets/app_drawer.dart';
import 'package:denik_zza/screens2/widgets/intake_bottom_row.dart';
import 'package:denik_zza/screens2/widgets/intake_main_content.dart';
import 'package:denik_zza/screens2/widgets/intake_person_row.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/screens2/participant_registration_form.dart';
import '../database/database_wrapper.dart';
import '../input/file_manager.dart';

/// IntakeForm widget for managing participant check-in process
/// Handles person selection, form editing, restrictions, and file uploads
@Deprecated('Use NewIntakeFormImproved instead')
class OldIntakeForm extends StatefulWidget {
  const OldIntakeForm({super.key});

  @override
  State<OldIntakeForm> createState() => _OldIntakeFormState();
}

class _OldIntakeFormState extends State<OldIntakeForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Selected person and related data
  MemoryOsoba? selectedPerson;
  Directory? zpusobilostFolder;
  
  // Form validation function
  bool Function()? _validateParticipantForm;
    // Widget instances
  ParticipantRegistrationForm? _participantRegistrationForm;
  
  // Available persons for autocomplete (minimal implementation)
  List<MemoryOsoba> _availablePersons = [];

  @override
  void initState() {
    super.initState();
    _loadZpusobilostFolder();
    _loadAvailablePersons();
    _initializeWidgets();
  }

  void _initializeWidgets() {
    _participantRegistrationForm = _createParticipantForm();
  }

  ParticipantRegistrationForm _createParticipantForm() {
    return ParticipantRegistrationForm(
      osoba: selectedPerson,
      onValidate: (validate) => _validateParticipantForm = validate,
      onOsobaEdited: (osoba) {
        if (!mounted) {
          return;
        }
        setState(() => selectedPerson = osoba);
      },
      onRefresh: _refreshPage,
    );
  }

  void _refreshPage() {
    if (!mounted) {
      return;
    }
    setState(() {
      selectedPerson = null;
      _participantRegistrationForm = _createParticipantForm();
      // PersonAutocomplete will be rebuilt with new state
    });
    // Refresh available persons
    _loadAvailablePersons();
  }

  Future<void> _loadZpusobilostFolder() async {
    try {
      final folder = await FileManager().getZpusobilostFolder();
      if (!mounted) {
        return;
      }
      setState(() => zpusobilostFolder = folder);
    } catch (_) {
      if (mounted) {
        setState(() => zpusobilostFolder = null);
      }
    }
  }

  /// Load available persons for autocomplete (minimal implementation for compatibility)
  Future<void> _loadAvailablePersons() async {
    try {
      final persons = await DatabaseWrapper.getDatabase().getParticipantsByCurrentEvent();
      if (!mounted) {
        return;
      }
      setState(() => _availablePersons = persons);
    } catch (e) {
      if (mounted) {
        setState(() => _availablePersons = []);
      }
    }
  }

  void _onPersonSelected(MemoryOsoba person) {
    if (!mounted) {
      return;
    }
    setState(() {
      selectedPerson = person;
      _participantRegistrationForm = _createParticipantForm();
    });
  }

  void _onFileUploaded(String newFilePath) {
    if (selectedPerson != null) {
      setState(() => selectedPerson!.potvrzeniPath = newFilePath);
    }
  }

  Future<void> _handleSave(bool markAsArrived) async {
    if (_validateParticipantForm?.call() ?? false) {
      if (selectedPerson != null) {
        // Restrictions are now handled automatically by ParticipantRegistrationForm
        // via its internal service, so we only need to handle file upload
        final filePath = selectedPerson?.potvrzeniPath;
        if (filePath != null && filePath.isNotEmpty) {
          selectedPerson?.potvrzeniPath = filePath;
          await DatabaseWrapper.getDatabase().updateParticipant(osoba: selectedPerson!);
          if (!mounted) {
            return;
          }
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
    }
  }

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
                          availablePersons: _availablePersons,
                        ),
                        if (_participantRegistrationForm != null)
                          IntakeMainContent(
                            selectedPerson: selectedPerson,
                            onFileUploaded: _onFileUploaded,
                            zpusobilostFolder: zpusobilostFolder,
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
