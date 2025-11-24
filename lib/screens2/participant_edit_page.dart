import 'package:flutter/material.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/screens2/participant_registration_form.dart';
import 'package:denik_zza/database/database_wrapper.dart';

class ParticipantEditPage extends StatefulWidget {
  final MemoryOsoba participant;

  const ParticipantEditPage({
    super.key,
    required this.participant,
  });

  @override
  State<ParticipantEditPage> createState() => _ParticipantEditPageState();
}

class _ParticipantEditPageState extends State<ParticipantEditPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ParticipantRegistrationForm? _participantRegistrationForm;
  bool Function()? _validateFunction;
  MemoryOsoba? _editedParticipant;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _participantRegistrationForm = ParticipantRegistrationForm(
      osoba: widget.participant,
      onValidate: (validate) => _validateFunction = validate,
      onOsobaEdited: (osoba) => _editedParticipant = osoba,
      onRefresh: null, // Not needed for edit mode
    );
  }

  Future<void> _handleSave() async {
    if (_validateFunction?.call() ?? false) {
      if (_editedParticipant != null) {
        try {
          final updateResult = await DatabaseWrapper.getDatabase()
              .updateParticipant(osoba: _editedParticipant!);

          if (mounted) {
            if (updateResult > 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Účastník byl úspěšně upraven')),
              );
              // Return true to indicate success
              Navigator.of(context).pop(true);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chyba při ukládání změn')),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Chyba: $e')),
            );
          }
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prosím, opravte chyby ve formuláři')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Upravit účastníka: ${widget.participant.jmeno} ${widget.participant.prijmeni}'),
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: const Text(
              'Uložit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: _participantRegistrationForm ?? const SizedBox(),
                    ),
                  ),
                ),
                AppSpacing.mediumGap,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Zrušit'),
                    ),
                    FilledButton(
                      onPressed: _handleSave,
                      child: const Text('Uložit změny'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
