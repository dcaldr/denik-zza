import 'package:denik_zza/input/file_manager.dart';
import 'package:denik_zza/screens2/widgets/app_drawer.dart';
import 'package:denik_zza/screens2/widgets/custom_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../database/database_wrapper.dart';
import '../database/in_memory_structures_tmp/memory_akce.dart';
import 'event_list.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';

class EventRegistrationForm extends StatefulWidget {
  final MemoryAction? action;

  const EventRegistrationForm({super.key, this.action});

  @override
  _EventRegistrationFormState createState() => _EventRegistrationFormState();
}

class _EventRegistrationFormState extends State<EventRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'nadpis': TextEditingController(),
    'popis': TextEditingController(),
    'odkdy': TextEditingController(),
    'dokdy': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    if (widget.action != null) {
      _controllers['nadpis']!.text = widget.action!.nadpis;
      _controllers['popis']!.text = widget.action!.popis!;
      _controllers['odkdy']!.text =
          DateFormat('dd.MM.yyyy').format(widget.action!.odkdy);
      _controllers['dokdy']!.text =
          DateFormat('dd.MM.yyyy').format(widget.action!.dokdy);
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final dateFormat = DateFormat('dd.MM.yyyy');
      final directory = await FileManager()
          .createNewEventDataDir(_controllers['nadpis']!.text);
      final newAction = MemoryAction(
        idAkce: widget.action?.idAkce,
        nadpis: _controllers['nadpis']!.text,
        popis: _controllers['popis']!.text,
        odkdy: dateFormat.parseStrict(_controllers['odkdy']!.text),
        dokdy: dateFormat.parseStrict(_controllers['dokdy']!.text),
        domovskyAdresarPath: directory?.path,
      );

      if (widget.action == null) {
        DatabaseWrapper.getDatabase().addEvent(newAction).then((success) {
          final message =
              success ? 'Akce úspěšně přidána' : 'Přidání Akce se nezdařilo';
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));

          if (success) {
            //mark as selected event
            //DatabaseWrapper.getDatabase().updateCurrentEvent(newAction.idAkce!);
            //workaround
            DatabaseWrapper.getDatabase().getAllZzaActions().then((actions) {
              final lastAction = actions.last;
              if (lastAction.nadpis == _controllers['nadpis']!.text &&
                  DateFormat('dd.MM.yyyy').format(lastAction.odkdy) ==
                      _controllers['odkdy']!.text &&
                  DateFormat('dd.MM.yyyy').format(lastAction.dokdy) ==
                      _controllers['dokdy']!.text) {
                DatabaseWrapper.getDatabase()
                    .updateCurrentEvent(lastAction.idAkce!);
              } else {
                Logger().e(
                    'Sanity check failed: Last action details do not match the form input.');
              }
            });
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => EventList()));
          }
        });
      } else {
        DatabaseWrapper.getDatabase()
            .updateEvent(action: newAction)
            .then((updateResult) {
          final message = updateResult > 0
              ? 'Akce úspěšně aktualizována'
              : 'Aktualizace Akce se nezdařila';
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));

          if (updateResult > 0) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => EventList()));
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Založit akci')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextFormField('nadpis', 'Nadpis', 'Prosím zadejte nadpis'),
              AppSpacing.smallGap,
              _buildTextFieldWithCounter('popis', 'Popis', 130),
              AppSpacing.smallGap,
              Row(
                children: [
                  Expanded(
                      child: CustomDatePicker(
                          controller: _controllers['odkdy']!,
                          labelText: 'Od kdy',
                          validatorText: 'Prosím zadejte datum začátku')),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                      child: CustomDatePicker(
                          controller: _controllers['dokdy']!,
                          labelText: 'Do kdy',
                          validatorText: 'Prosím zadejte datum konce')),
                ],
              ),
              AppSpacing.largeGap,
              FilledButton(
                  onPressed: _submitForm,
                  child:
                      Text(widget.action == null ? 'Odeslat' : 'Aktualizovat')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
      String key, String labelText, String validatorText) {
    return TextFormField(
      controller: _controllers[key],
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? validatorText : null,
    );
  }

  Widget _buildTextFieldWithCounter(
      String key, String labelText, int maxLength) {
    return TextField(
      controller: _controllers[key],
      maxLines: 3,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: 'Maximálně $maxLength znaků',
        border: const OutlineInputBorder(),
      ),
    );
  }
}
