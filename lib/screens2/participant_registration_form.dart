import 'package:denik_zza/screens2/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/screens2/widgets/custom_date_picker.dart';
import 'package:intl/intl.dart';

class ParticipantRegistrationForm extends StatefulWidget {
  const ParticipantRegistrationForm({Key? key}) : super(key: key);

  @override
  _ParticipantRegistrationFormState createState() => _ParticipantRegistrationFormState();
}

class _ParticipantRegistrationFormState extends State<ParticipantRegistrationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'jmeno': TextEditingController(),
    'prijmeni': TextEditingController(),
    'datumNarozeni': TextEditingController(),
    'adresa': TextEditingController(),
    'cisloPojisteni': TextEditingController(),
    'telefonRodice': TextEditingController(),
    'emailRodice': TextEditingController(),
    'zdravotniPojistovna': TextEditingController(),
    'poznamka': TextEditingController(),
  };

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Logic to handle form submission
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Registrace Účastníka')),
    drawer: const AppDrawer(),
    body: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            GridView.count(
  crossAxisCount: 3,
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  mainAxisSpacing: 4.0, // Adjustable
  crossAxisSpacing: 4.0, // Adjustable
  childAspectRatio: 3 / 1, // Adjustable
  children: [
    TextFormField(controller: _controllers['jmeno'], decoration: const InputDecoration(labelText: 'Jméno')),
    TextFormField(controller: _controllers['prijmeni'], decoration: const InputDecoration(labelText: 'Příjmení')),
    TextFormField(controller: _controllers['cisloPojisteni'], decoration: const InputDecoration(labelText: 'Číslo Pojištěnce')),
    CustomDatePicker(controller: _controllers['datumNarozeni']!, labelText: 'Datum Narození'),
    TextFormField(controller: _controllers['pohlavi'], decoration: const InputDecoration(labelText: 'Pohlaví')),
    TextFormField(controller: _controllers['zdravotniPojistovna'], decoration: const InputDecoration(labelText: 'Zdravotní Pojišťovna')),
    TextFormField(controller: _controllers['jmenoRodice'], decoration: const InputDecoration(labelText: 'Jméno Rodiče')),
    TextFormField(controller: _controllers['telefonRodice'], decoration: const InputDecoration(labelText: 'Telefon Rodiče')),
    TextFormField(controller: _controllers['emailRodice'], decoration: const InputDecoration(labelText: 'Email Rodiče')),
  ],
),
            // Additional fields or buttons can be added here
          ],
        ),
      ),
    ),
  );
}
}