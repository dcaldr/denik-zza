import 'package:denik_zza/screens2/widgets/file_viewer_logic.dart';
import 'package:denik_zza/screens2/widgets/file_viewer_screen_widget.dart';
import 'package:denik_zza/screens2/widgets/person_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/screens2/participant_registration_form.dart';

class IntakeForm extends StatefulWidget {
  const IntakeForm({super.key});

  @override
  _IntakeFormState createState() => _IntakeFormState();
}

class _IntakeFormState extends State<IntakeForm> {
  MemoryOsoba? selectedPerson;

  void _onPersonSelected(MemoryOsoba person) {
    setState(() {
      selectedPerson = person;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intake Form'),
      ),
      body: Center(
        child: SizedBox(
          child: LayoutStyle(
            selectedPerson: selectedPerson,
            onPersonSelected: _onPersonSelected,
          ),
        ),
      ),
    );
  }
}

class LayoutStyle extends StatelessWidget {
  final MemoryOsoba? selectedPerson;
  final Function(MemoryOsoba) onPersonSelected;

  const LayoutStyle({super.key, required this.selectedPerson, required this.onPersonSelected});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      FirstRow(onPersonSelected: onPersonSelected),
                      TwoColumnRow(selectedPerson: selectedPerson),
                      SizedBox(height: constraints.maxHeight),
                    ],
                  ),
                ),
              ),
            ),
            const SecondRow(),
          ],
        );
      },
    );
  }
}

class FirstRow extends StatelessWidget {
  final Function(MemoryOsoba) onPersonSelected;

  const FirstRow({super.key, required this.onPersonSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('First Row'),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(8),
            child: PersonAutocomplete(onPersonSelected: onPersonSelected),
          ),
        ),
      ],
    );
  }
}

class TwoColumnRow extends StatelessWidget {
  final MemoryOsoba? selectedPerson;

  const TwoColumnRow({super.key, required this.selectedPerson});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: Column(
            children: [
              const Text('First Column'),
              Transform.scale(
                scale: 0.85,
                child: ParticipantRegistrationForm(osoba: selectedPerson),
              ),
            ],
          ),
        ),
        Flexible(
          flex: 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Second Column'),
              Flexible(
                fit: FlexFit.loose,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height / 1.6,
                  ),
                  child: selectedPerson?.potvrzeniPath != null
                      ? FileViewerScreen(initialFilePath: selectedPerson!.potvrzeniPath!)
                      : const FileViewerLogic(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SecondRow extends StatelessWidget {
  const SecondRow({super.key});

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
            const ActionButtons(),
          ],
        ),
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Tooltip(
          message: 'uložit a přišel',
          child: ElevatedButton.icon(
            onPressed: () {
              // Add your onPressed code here!
            },
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
            onPressed: () {
              // Add your onPressed code here!
            },
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