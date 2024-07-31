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

  @override
  void initState() {
    super.initState();
    _loadZpusobilostFolder();
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
    });
  }

  void _onFileUploaded(String newFilePath) {
    if (selectedPerson != null) {
      setState(() {
        selectedPerson!.potvrzeniPath = newFilePath;
      });
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
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutStyle(
            selectedPerson: selectedPerson,
            onPersonSelected: _onPersonSelected,
            onFileUploaded: _onFileUploaded,
            zpusobilostFolder: zpusobilostFolder,
          ),
        ),
      ),
    );
  }
}

class LayoutStyle extends StatelessWidget {
  final MemoryOsoba? selectedPerson;
  final Function(MemoryOsoba) onPersonSelected;
  final Function(String) onFileUploaded;
  final Directory? zpusobilostFolder;

  const LayoutStyle({
    super.key,
    required this.selectedPerson,
    required this.onPersonSelected,
    required this.onFileUploaded,
    required this.zpusobilostFolder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
              child: Column(
                children: [
                  FirstRow(onPersonSelected: onPersonSelected),
                  TwoColumnRow(
                    selectedPerson: selectedPerson,
                    onFileUploaded: onFileUploaded,
                    zpusobilostFolder: zpusobilostFolder,
                  ),
                ],
              ),
            ),
          ),
        ),
        SecondRow(
          formKey: GlobalKey<FormState>(),
          selectedPerson: selectedPerson,
          onFileUploaded: onFileUploaded,
        ),
      ],
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

  const TwoColumnRow({super.key, required this.selectedPerson, required this.onFileUploaded, required this.zpusobilostFolder});

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
                  child: ParticipantRegistrationForm(osoba: selectedPerson),
                ),
                Transform.scale(
                  scale: 0.85,
                  child: Row(
                    children: [
                      Expanded(
                        child: RestrictionsWidget(
                          logic: MemoryOmezeniLogic(),
                          participantId: selectedPerson?.id,
                        ),
                      ),
                      const SizedBox(width: 10), // Add some spacing between the widgets
                      Expanded(
                        child: RestrictionsWidget(
                          logic: MemoryLekLogic(),
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

  const SecondRow({
    super.key,
    required this.formKey,
    required this.selectedPerson,
    required this.onFileUploaded,
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

  const ActionButtons({
    super.key,
    required this.formKey,
    required this.selectedPerson,
    required this.onFileUploaded,
  });

  Future<void> _handleSave(BuildContext context, bool markAsArrived) async {
    if (formKey.currentState!.validate()) {
      // Upload restrictions and medications to the database
      await MemoryOmezeniLogic().update();
      await MemoryLekLogic().update();

      // Update the person with the file path if needed
      if (selectedPerson != null) {
        final filePath = selectedPerson!.potvrzeniPath;
        if (filePath != null && filePath.isNotEmpty) {
          selectedPerson!.potvrzeniPath = filePath;
        }
        await DatabaseWrapper.getDatabase().updateParticipant(osoba: selectedPerson!);
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(markAsArrived ? 'uložit a přišel' : 'uložit')),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form validation failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Tooltip(
          message: 'uložit a přišel',
          child: ElevatedButton.icon(
            onPressed: () => _handleSave(context, true),
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
            onPressed: () => _handleSave(context, false),
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