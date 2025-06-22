import 'package:flutter/material.dart';
import '../../database/in_memory_structures_tmp/memory_osoba.dart';
import '../participant_registration_form.dart';
import 'intake_action_buttons.dart';

class IntakeBottomRow extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final MemoryOsoba? selectedPerson;
  final Function(String) onFileUploaded;
  final Function(BuildContext, bool) handleSave;
  final ParticipantRegistrationForm participantRegistrationForm;

  const IntakeBottomRow({
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
            IntakeActionButtons(
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
