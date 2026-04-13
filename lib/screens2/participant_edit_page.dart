import 'package:flutter/material.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/screens2/participant_registration_form.dart';
import 'package:denik_zza/screens2/services/participant_registration_service.dart';
import 'package:denik_zza/screens2/widgets/memory_restriction_widget.dart';
import 'package:denik_zza/design_system/tokens/app_breakpoints.dart';

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
  final GlobalKey<ParticipantRegistrationFormState> _formStateKey =
      GlobalKey<ParticipantRegistrationFormState>();
  ParticipantRegistrationForm? _participantRegistrationForm;
  bool Function()? _validateFunction;

  // Owned logic instances — injected into the form so that edits made in
  // RestrictionsWidget are available here when _handleSave is called.
  final MemoryOmezeniLogic _omezeniLogic = MemoryOmezeniLogic();
  final MemoryLekLogic _lekLogic = MemoryLekLogic();
  final ParticipantRegistrationService _participantService =
      ParticipantRegistrationService();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _participantRegistrationForm = ParticipantRegistrationForm(
      key: _formStateKey,
      osoba: widget.participant,
      onValidate: (validate) => _validateFunction = validate,
      onRefresh: null, // Not needed for edit mode
      enableStickyFooter: true,
      // Inject shared instances so RestrictionsWidget edits reach _handleSave.
      omezeniLogic: _omezeniLogic,
      lekLogic: _lekLogic,
    );
  }

  Future<void> _handleSave() async {
    if (_validateFunction?.call() ?? false) {
      try {
        final participantToSave =
            _formStateKey.currentState?.createMemoryOsoba() ??
                widget.participant;

        // Delegate to service so restrictions/meds are saved alongside
        // basic participant data — fixes the silent-drop bug.
        final result =
            await _participantService.saveParticipantWithRestrictions(
          osoba: participantToSave,
          omezeniLogic: _omezeniLogic,
          lekLogic: _lekLogic,
        );

        if (mounted) {
          if (result != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Účastník byl úspěšně upraven')),
            );
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
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = MediaQuery.sizeOf(context).height;
          final isTouch = AppBreakpoints.useTouchMode(context);
          final useCompactDensity = !isTouch && screenHeight < 750;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBreakpoints.formMaxWidth,
              ),
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Theme(
                          data: useCompactDensity
                              ? Theme.of(context).copyWith(
                                  visualDensity: VisualDensity.compact,
                                  inputDecorationTheme: Theme.of(context)
                                      .inputDecorationTheme
                                      .copyWith(
                                        isDense: useCompactDensity,
                                        contentPadding: useCompactDensity
                                            ? const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 10,
                                              )
                                            : null,
                                      ),
                                )
                              : Theme.of(context),
                          child: _participantRegistrationForm ??
                              const SizedBox(),
                        ),
                      ),
                    ),
                    AppSpacing.mediumGap,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Zrušit'),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        FilledButton(
                          key: const Key('ParticipantEditPage_submit_button'),
                          onPressed: _handleSave,
                          child: const Text('Uložit změny'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
