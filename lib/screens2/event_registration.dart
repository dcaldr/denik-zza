import 'package:denik_zza/screens2/widgets/custom_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_wrapper.dart';
import '../database/in_memory_structures_tmp/memory_akce.dart';
import 'event_list.dart';

class EventRegistrationForm extends StatefulWidget {
  const EventRegistrationForm({super.key});

  @override
  _EventRegistrationFormState createState() => _EventRegistrationFormState();
}

class _EventRegistrationFormState extends State<EventRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nadpisController = TextEditingController();
  final _popisController = TextEditingController();
  final _odkdyController = TextEditingController();
  final _dokdyController = TextEditingController();

  @override
  void dispose() {
    _nadpisController.dispose();
    _popisController.dispose();
    _odkdyController.dispose();
    _dokdyController.dispose();
    super.dispose();
  }

void _submitForm() {
  if (_formKey.currentState!.validate()) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final newAction = MemoryAction(
      idAkce: null,
      nadpis: _nadpisController.text,
      popis: _popisController.text,
      odkdy: dateFormat.parseStrict(_odkdyController.text),
      dokdy: dateFormat.parseStrict(_dokdyController.text),
      domovskyAdresarPath: null,
    );

    DatabaseWrapper.getDatabase().addEvent(newAction).then((success) {
      final message = success
          ? 'MemoryAction úspěšně přidána'
          : 'Přidání MemoryAction se nezdařilo';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

      if (success) {
        // Navigate to EventList screen upon successful addition
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EventList()),
        );
      }
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrace události')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextFormField(_nadpisController, 'Nadpis', 'Prosím zadejte nadpis'),
              const SizedBox(height: 10),
              _buildTextFieldWithCounter(_popisController, 'Popis', 130),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CustomDatePicker(
                      controller: _odkdyController,
                      labelText: 'Od kdy',
                      validatorText: 'Prosím zadejte datum začátku',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomDatePicker(
                      controller: _dokdyController,
                      labelText: 'Do kdy',
                      validatorText: 'Prosím zadejte datum konce',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Odeslat'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String labelText, String validatorText) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorText;
        }
        return null;
      },
    );
  }

  Widget _buildTextFieldWithCounter(TextEditingController controller, String labelText, int maxLength) {
    return TextField(
      controller: controller,
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