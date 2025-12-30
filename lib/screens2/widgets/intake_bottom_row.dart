import 'package:flutter/material.dart';
import '../../database/in_memory_structures_tmp/memory_osoba.dart';
import '../participant_registration_form.dart';
import '../shared/intake_types.dart';
import 'intake_action_buttons.dart';

class IntakeBottomRow extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final MemoryOsoba? selectedPerson;
  final FileUploadedCallback onFileUploaded;
  final SaveCallback handleSave;
  final ParticipantRegistrationForm participantRegistrationForm;
  final VoidCallback? onCancel;

  const IntakeBottomRow({
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
    return Align(
      alignment: Alignment.bottomRight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IntakeActionButtons(
              formKey: formKey,
              selectedPerson: selectedPerson,
              onFileUploaded: onFileUploaded,
              handleSave: handleSave,
              participantRegistrationForm: participantRegistrationForm,
              onCancel: onCancel,
            ),
          ],
        ),
      ),
    );
  }
}

