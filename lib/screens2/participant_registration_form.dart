import 'package:denik_zza/screens2/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/screens2/widgets/custom_date_picker.dart';
import 'package:intl/intl.dart';
import '../input/input_hold.dart';
import '../input/rodne_cislo.dart'; // Corrected import

class ParticipantRegistrationForm extends StatefulWidget {
  const ParticipantRegistrationForm({Key? key}) : super(key: key);

  @override
  _ParticipantRegistrationFormState createState() =>
      _ParticipantRegistrationFormState();
}

class _ParticipantRegistrationFormState
    extends State<ParticipantRegistrationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'jmeno': TextEditingController(),
    'prijmeni': TextEditingController(),
    'datumNarozeni': TextEditingController(),
    'adresa': TextEditingController(),
    'cisloPojisteni': TextEditingController(),
    'jmenoRodice': TextEditingController(),
    'telefonRodice': TextEditingController(),
    'emailRodice': TextEditingController(),
    'zdravotniPojistovna': TextEditingController(),
    'poznamka': TextEditingController(),
    'pohlavi': TextEditingController(),
  };

  final Map<String, InputHold> _validators = {
    'jmeno': JmenoHold(),
    'prijmeni': JmenoHold(),
    'datumNarozeni': DatumNarozeniHold(),
    'adresa': AdresaHold(),
    'cisloPojisteni': CisloPojisteniHold(),
    'jmenoRodice': JmenoHold(),
    'telefonRodice': TelefonHold(),
    'emailRodice': EmailHold(),
    'zdravotniPojistovna': PojistovnaHold(),
    'poznamka': TextHold(),
    'pohlavi': PohlaviHold(),
  };
  ///Adds a listener to the controller of the birth number
  @override
  void initState() {
    super.initState();
    _controllers['cisloPojisteni']!.addListener(() {
      guessAndFillFields(_controllers['cisloPojisteni']!.text);
    });
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
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
                childAspectRatio: 3 / 1,
                children: [
                  TextFormField(
                    controller: _controllers['jmeno'],
                    decoration: const InputDecoration(labelText: 'Jméno'),
                    validator: (value) {
                      final validator = _validators['jmeno']?.validator();
                      if (value == null || value.isEmpty) {
                        return 'Jméno je povinné pole';
                      }
                      return validator;
                    },
                  ),

                  TextFormField(
                    controller: _controllers['prijmeni'],
                    decoration: const InputDecoration(labelText: 'Příjmení'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Příjmení je povinné pole';
                      }
                      return _validators['prijmeni']?.validator();
                    },
                  ),
                  TextFormField(
                    controller: _controllers['cisloPojisteni'],
                    decoration:
                        const InputDecoration(labelText: 'Číslo Pojištěnce'),
                    validator: (value) =>
                        _validators['cisloPojisteni']?.validator(),
                  ),
                  CustomDatePicker(
                    controller: _controllers['datumNarozeni']!,
                    labelText: 'Datum Narození',
                  ),
                  TextFormField(
                    controller: _controllers['pohlavi'],
                    decoration: const InputDecoration(labelText: 'Pohlaví'),
                    validator: (value) => _validators['pohlavi']?.validator(),
                  ),
                  TextFormField(
                    controller: _controllers['zdravotniPojistovna'],
                    decoration: const InputDecoration(
                        labelText: 'Zdravotní Pojišťovna'),
                    validator: (value) =>
                        _validators['zdravotniPojistovna']?.validator(),
                  ),
                  // Continue for other fields...

                  TextFormField(
                    controller: _controllers['jmenoRodice'],
                    decoration:
                        const InputDecoration(labelText: 'Jméno rodiče'),
                    validator: (value) =>
                        _validators['jmenoRodice']?.validator(),
                  ),
                  TextFormField(
                    controller: _controllers['emailRodice'],
                    decoration:
                        const InputDecoration(labelText: 'Email rodiče'),
                    validator: (value) =>
                        _validators['emailRodice']?.validator(),
                  ),
                  TextFormField(
                    controller: _controllers['telefonRodice'],
                    decoration:
                        const InputDecoration(labelText: 'Telefon rodiče'),
                    validator: (value) =>
                        _validators['telefonRodice']?.validator(),
                  ),
                  TextFormField(
                    controller: _controllers['poznamka'],
                    decoration: const InputDecoration(
                        labelText: 'Poznámka',
                        border: OutlineInputBorder(),
                        hintText: 'Tento text se nebude tisknout'),
                    maxLines: 3,
                  ),
                ],
              ),
              // Additional fields or buttons can be added here
            ],
          ),
        ),
      ),
    );
  }


/// From part of rč. guess and fill fields
  ///
  /// fills in the fields that can be guessed from the birth number
  /// so  datumNarozeni and pohlavi
void guessAndFillFields(String inText) {
  if (inText.length >= 6) {
    RodneCislo rc = RodneCislo(inText);
    DateTime datumNarozeni = rc.getDatumNarozeni();
    int pohlavi = rc.getPohlavi();

    if (_controllers['datumNarozeni'] != null && _controllers['datumNarozeni']!.text.isEmpty) {
      _controllers['datumNarozeni']!.text = DateFormat('dd.MM.yyyy').format(datumNarozeni);
    }

    if (_controllers['pohlavi'] != null && _controllers['pohlavi']!.text.isEmpty) {
      _controllers['pohlavi']!.text = pohlavi.toString();
    }
  }
}
}
