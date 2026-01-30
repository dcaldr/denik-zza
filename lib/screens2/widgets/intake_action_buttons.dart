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
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final buttonPadding = isMobile
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    final spacing = isMobile ? 6.0 : 10.0;
    final iconSize = isMobile ? 18.0 : 24.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Tooltip(
          message: 'uložit a přišel',
          child: ElevatedButton.icon(
            key: const Key('IntakeForm_saveAndArrived_button'),
            onPressed: () => handleSave(context, true),
            icon: Icon(Icons.check_circle, color: Colors.white, size: iconSize),
            label: isMobile ? const SizedBox.shrink() : const Text('uložit a přišel'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(width: spacing),
        Tooltip(
          message: 'uložit',
          child: ElevatedButton.icon(
            key: const Key('IntakeBottomRow_save_button'),
            onPressed: () => handleSave(context, false),
            icon: Icon(Icons.save, color: Colors.white, size: iconSize),
            label: isMobile ? const SizedBox.shrink() : const Text('uložit'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(width: spacing),
        Tooltip(
          message: 'neukládat',
          child: ElevatedButton.icon(
            key: const Key('IntakeForm_cancel_button'),
            onPressed: onCancel,
            icon: Icon(Icons.cancel, color: Colors.white, size: iconSize),
            label: isMobile ? const SizedBox.shrink() : const Text('neukládat'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
              padding: buttonPadding,
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
