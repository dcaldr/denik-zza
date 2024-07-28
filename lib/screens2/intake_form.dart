import 'package:denik_zza/screens2/widgets/file_viewer_logic.dart';
import 'package:denik_zza/screens2/widgets/person_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/screens2/participant_registration_form.dart';

class IntakeForm extends StatelessWidget {
  const IntakeForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intake Form'),
      ),
      body: const Center(
        child: SizedBox(
        //  height: double.infinity,
          child: LayoutStyle(),
        ),
      ),
    );
  }
}

class LayoutStyle extends StatelessWidget {
  const LayoutStyle({super.key});

  @override
Widget build(BuildContext context) {
    //todo:SecondRow doesnt react to vertical resize of the screen
  return LayoutBuilder(
    builder: (context, constraints) {
      return Stack(
        children: [
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  const Column(
                    children: [
                      FirstRow(),
                      TwoColumnRow(),
                    ],
                  ),
                  SizedBox(height: constraints.maxHeight), // Spacer to push SecondRow to the bottom
                ],
              ),
            ),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SecondRow(),
          ),
        ],
      );
    },
  );
}
}

class FirstRow extends StatelessWidget {
  const FirstRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('First Row'),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(8),
            child: PersonAutocomplete(onPersonSelected: (MemoryOsoba person) {
              // Dummy function
            }),
          ),
        ),
      ],
    );
  }
}

class TwoColumnRow extends StatelessWidget {
  const TwoColumnRow({super.key});

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
                child: const ParticipantRegistrationForm(),
              ),
            ],
          ),
        ),
         const Flexible(
          flex: 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Second Column'),
              Flexible(
                fit: FlexFit.loose,
                child: FileViewerLogic(),
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
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Second Row'),
          SizedBox(width: 20),
          ActionButtons(),
        ],
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