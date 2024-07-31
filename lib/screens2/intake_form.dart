import 'dart:io';
import 'package:denik_zza/screens2/widgets/memory_restriction_widget.dart';
import 'package:flutter/material.dart';
import 'package:denik_zza/screens2/widgets/app_drawer.dart';
import 'package:denik_zza/screens2/widgets/file_viewer_logic.dart';
import 'package:denik_zza/screens2/widgets/file_viewer_screen_widget.dart';
import 'package:denik_zza/screens2/widgets/person_autocomplete.dart';
import 'package:denik_zza/screens2/widgets/restrictions_widget.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/screens2/participant_registration_form.dart';
import '../database/database_wrapper.dart';
import '../input/file_manager.dart';

class IntakeForm extends StatefulWidget {
  const IntakeForm({super.key});

  @override
  _IntakeFormState createState() => _IntakeFormState();
}

class _IntakeFormState extends State<IntakeForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  MemoryOsoba? selectedPerson;
  Directory? zpusobilostFolder;
  final MemoryOmezeniLogic _omezeniLogic = MemoryOmezeniLogic();
  final MemoryLekLogic _lekLogic = MemoryLekLogic();
  late ParticipantRegistrationForm _participantRegistrationForm;
  bool Function()? _validateParticipantForm;

  @override
  void initState() {
    super.initState();
    _loadZpusobilostFolder();
    _participantRegistrationForm = ParticipantRegistrationForm(
      osoba: selectedPerson,
      onValidate: (validate) {
        _validateParticipantForm = validate;
      },
      onOsobaEdited: (osoba) {
        setState(() {
          selectedPerson = osoba;
        });
      },
    );
  }

  Future<void> _loadZpusobilostFolder() async {
    final folder = await FileManager().getZpusobilostFolder();
    setState(() {
      zpusobilostFolder = folder;
    });
  }

  void _onPersonSelected(MemoryOsoba person) {
    setState(() {
      selectedPerson = person;
      _omezeniLogic.fetchData(person.id);
      _lekLogic.fetchData(person.id);
      _participantRegistrationForm = ParticipantRegistrationForm(
        osoba: selectedPerson,
        onValidate: (validate) {
          _validateParticipantForm = validate;
        },
        onOsobaEdited: (osoba) {
          setState(() {
            selectedPerson = osoba;
          });
        },
      );
    });
  }

  void _onFileUploaded(String newFilePath) {
    if (selectedPerson != null) {
      setState(() {
        selectedPerson!.potvrzeniPath = newFilePath;
      });
    }
  }

  Future<void> _handleSave(BuildContext context, bool markAsArrived) async {
    if (_validateParticipantForm?.call() ?? false) {
      await _omezeniLogic.update();
      await _lekLogic.update();

      if (selectedPerson != null) {
        final filePath = selectedPerson!.potvrzeniPath;
        if (filePath != null && filePath.isNotEmpty) {
          selectedPerson!.potvrzeniPath = filePath;
        }
        await DatabaseWrapper.getDatabase().updateParticipant(osoba: selectedPerson!);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(markAsArrived ? 'uložit a přišel' : 'uložit')),
      );

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('něco nedopadlo')),
      );
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
                    constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
                    child: Column(
                      children: [
                        FirstRow(onPersonSelected: _onPersonSelected),
                        TwoColumnRow(
                          selectedPerson: selectedPerson,
                          onFileUploaded: _onFileUploaded,
                          zpusobilostFolder: zpusobilostFolder,
                          omezeniLogic: _omezeniLogic,
                          lekLogic: _lekLogic,
                          participantRegistrationForm: _participantRegistrationForm,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SecondRow(
                formKey: _formKey,
                selectedPerson: selectedPerson,
                onFileUploaded: _onFileUploaded,
                handleSave: _handleSave,
                participantRegistrationForm: _participantRegistrationForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FirstRow extends StatelessWidget {
  final Function(MemoryOsoba) onPersonSelected;

  const FirstRow({super.key, required this.onPersonSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const Text('First Row'),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: PersonAutocomplete(onPersonSelected: onPersonSelected),
            ),
          ),
        ],
      ),
    );
  }
}

class TwoColumnRow extends StatelessWidget {
  final MemoryOsoba? selectedPerson;
  final Function(String) onFileUploaded;
  final Directory? zpusobilostFolder;
  final MemoryOmezeniLogic omezeniLogic;
  final MemoryLekLogic lekLogic;
  final ParticipantRegistrationForm participantRegistrationForm;

  const TwoColumnRow({
    super.key,
    required this.selectedPerson,
    required this.onFileUploaded,
    required this.zpusobilostFolder,
    required this.omezeniLogic,
    required this.lekLogic,
    required this.participantRegistrationForm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('First Column'),
                Transform.scale(
                  scale: 0.85,
                  child: participantRegistrationForm,
                ),
                Transform.scale(
                  scale: 0.85,
                  child: Row(
                    children: [
                      Expanded(
                        child: RestrictionsWidget(
                          logic: omezeniLogic,
                          participantId: selectedPerson?.id,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RestrictionsWidget(
                          logic: lekLogic,
                          participantId: selectedPerson?.id,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Second Column'),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height / 1.6,
                  ),
                  child: zpusobilostFolder == null || (selectedPerson?.potvrzeniPath == null || selectedPerson!.potvrzeniPath!.isEmpty)
                      ? FileViewerLogic(onFileUploaded: onFileUploaded)
                      : FileViewerScreen(initialFilePath: '${zpusobilostFolder!.path}/${selectedPerson!.potvrzeniPath}'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SecondRow extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final MemoryOsoba? selectedPerson;
  final Function(String) onFileUploaded;
  final Function(BuildContext, bool) handleSave;
  final ParticipantRegistrationForm participantRegistrationForm;

  const SecondRow({
    super.key,
    required this.formKey,
    required this.selectedPerson,
    required this.onFileUploaded,
    required this.handleSave,
    required this.participantRegistrationForm,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('Second Row'),
            const SizedBox(width: 20),
            ActionButtons(
              formKey: formKey,
              selectedPerson: selectedPerson,
              onFileUploaded: onFileUploaded,
              handleSave: handleSave,
              participantRegistrationForm: participantRegistrationForm,
            ),
          ],
        ),
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final MemoryOsoba? selectedPerson;
  final Function(String) onFileUploaded;
  final Function(BuildContext, bool) handleSave;
  final ParticipantRegistrationForm participantRegistrationForm;

  const ActionButtons({
    super.key,
    required this.formKey,
    required this.selectedPerson,
    required this.onFileUploaded,
    required this.handleSave,
    required this.participantRegistrationForm,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Tooltip(
          message: 'uložit a přišel',
          child: ElevatedButton.icon(
            onPressed: () => handleSave(context, true),
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: const Text('uložit a přišel'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Tooltip(
          message: 'uložit',
          child: ElevatedButton.icon(
            onPressed: () => handleSave(context, false),
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text('uložit'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Tooltip(
          message: 'neukládat',
          child: ElevatedButton.icon(
            onPressed: () {
              // Add your onPressed code here!
            },
            icon: const Icon(Icons.cancel, color: Colors.white),
            label: const Text('neukládat'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
