import 'package:flutter/material.dart';
import '../../database/in_memory_structures_tmp/memory_osoba.dart';
import '../participant_registration_form.dart';
import '../shared/intake_types.dart';

/// Action buttons for the Intake Form.
///
/// ⚠️ PROTECTED STYLING - DO NOT MODIFY BUTTON COLORS ⚠️
/// The green/blue/red colors are intentional design choices that must remain
/// exactly as they are. Do not replace with design system tokens.
class IntakeActionButtons extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final MemoryOsoba? selectedPerson;
  final FileUploadedCallback onFileUploaded;
  final SaveCallback handleSave;
  final ParticipantRegistrationForm participantRegistrationForm;
  final VoidCallback? onCancel;

  const IntakeActionButtons({
    super.key,
    required this.formKey,
    required this.selectedPerson,
    required this.onFileUploaded,
    required this.handleSave,
    required this.participantRegistrationForm,
    this.onCancel,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Tooltip(
          message: 'uložit a přišel',
          child: ElevatedButton.icon(
            key: const Key('IntakeForm_saveAndArrived_button'),
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
            key: const Key('IntakeForm_save_button'),
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
            key: const Key('IntakeForm_cancel_button'),
            onPressed: onCancel,
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
