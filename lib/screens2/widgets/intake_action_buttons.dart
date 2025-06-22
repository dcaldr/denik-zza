import 'package:flutter/material.dart';
import '../../database/in_memory_structures_tmp/memory_osoba.dart';
import '../participant_registration_form.dart';

class IntakeActionButtons extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final MemoryOsoba? selectedPerson;
  final Function(String) onFileUploaded;
  final Function(BuildContext, bool) handleSave;
  final ParticipantRegistrationForm participantRegistrationForm;

  const IntakeActionButtons({
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
              foregroundColor: Colors.white, 
              backgroundColor: Colors.green,
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
              foregroundColor: Colors.white, 
              backgroundColor: Colors.blue,
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
              foregroundColor: Colors.white, 
              backgroundColor: Colors.red,
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
