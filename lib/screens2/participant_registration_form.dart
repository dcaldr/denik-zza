import 'package:denik_zza/screens2/widgets/app_drawer.dart';
import 'package:denik_zza/screens2/widgets/custom_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';

import '../input/input_hold.dart';
import '../input/rodne_cislo.dart';

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
    'jmenoRodice': JmenoHold( columnName: 'jmeno rodiče'),
    'telefonRodice': TelefonHold(),
    'emailRodice': EmailHold(),
    'zdravotniPojistovna': PojistovnaHold(),
    'poznamka': TextHold(),
    'pohlavi': PohlaviHold(),
  };

  @override
  void initState() {
    super.initState();
    _controllers['cisloPojisteni']!.addListener(() {
      setState(() {
        guessAndFillFields(_controllers['cisloPojisteni']!.text);
      });
    });
  }

  void guessAndFillFields(String inText) {
    if (inText.length >= 6) {
      RodneCislo rc = RodneCislo(inText);
      DateTime datumNarozeni = rc.getDatumNarozeni();
      int pohlavi = rc.getPohlavi();

      if (_controllers['datumNarozeni'] != null &&
          _controllers['datumNarozeni']!.text.isEmpty) {
        _controllers['datumNarozeni']!.text =
            DateFormat('dd.MM.yyyy').format(datumNarozeni);
      }

      if (_controllers['pohlavi'] != null &&
          _controllers['pohlavi']!.text.isEmpty) {
        _controllers['pohlavi']!.text = pohlavi.toString();
      }
    }
  }
/// for debug purposes
  void _showPersonDetails(MemoryOsoba osoba) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Person Details'),
          content: Text(
              'Name: ${osoba.jmeno} ${osoba.prijmeni}\nDate of Birth: ${osoba.datumNarozeni}\nGender: ${osoba.pohlavi}\nAddress: ${osoba.adresa}\nInsurance Number: ${osoba.cisloPojisteni}\nParent Name: ${osoba.jmenoRodice}\nParent Phone: ${osoba.telefonRodice}\nParent Email: ${osoba.emailRodice}\nHealth Insurance: ${osoba.zdravotniPojistovna}\nNote: ${osoba.poznamka}'),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                    final validator = _validators['jmeno']?.validator(value);
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
                    return _validators['prijmeni']?.validator(value);
                  },
                ),
                TextFormField(
                  controller: _controllers['cisloPojisteni'],
                  decoration:
                      const InputDecoration(labelText: 'Číslo Pojištěnce'),
                  validator: (value) =>
                      _validators['cisloPojisteni']?.validator(value),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomDatePicker(
                        controller: _controllers['datumNarozeni']!,
                        labelText: 'Datum Narození',
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: TextFormField(
                        controller: _controllers['pohlavi'],
                        decoration: const InputDecoration(labelText: 'Pohlaví'),
                        validator: (value) =>
                            _validators['pohlavi']?.validator(value),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: _controllers['zdravotniPojistovna'],
                  decoration: const InputDecoration(
                      labelText: 'Zdravotní Pojišťovna'),
                  validator: (value) =>
                      _validators['zdravotniPojistovna']?.validator(value),
                ),
                TextFormField(
                  controller: _controllers['adresa'],
                  decoration: const InputDecoration(labelText: 'Adresa'),
                  validator: (value) {

                    return _validators['adresa']?.validator(value);
                  },
                ),
                TextFormField(
                  controller: _controllers['jmenoRodice'],
                  decoration:
                      const InputDecoration(labelText: 'Jméno rodiče'),
                  validator: (value) =>
                      _validators['jmenoRodice']?.validator(value),
                ),
                TextFormField(
                  controller: _controllers['emailRodice'],
                  decoration:
                      const InputDecoration(labelText: 'Email rodiče'),
                  validator: (value) =>
                      _validators['emailRodice']?.validator(value),
                ),
                TextFormField(
                  controller: _controllers['telefonRodice'],
                  decoration:
                      const InputDecoration(labelText: 'Telefon rodiče'),
                  validator: (value) =>
                      _validators['telefonRodice']?.validator(value),
                ),
              ],
            ),
            TextFormField(
              controller: _controllers['poznamka'],
              decoration: const InputDecoration(
                  labelText: 'Poznámka',
                  border: OutlineInputBorder(),
                  hintText: 'Tento text se nebude tisknout'),
              maxLines: 3,
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  MemoryOsoba osoba = MemoryOsoba.fullNamed(
                    id: null,
                    jmeno: _controllers['jmeno']!.text,
                    prijmeni: _controllers['prijmeni']!.text,
                    datumNarozeni: DateFormat('dd.MM.yyyy')
                        .parse(_controllers['datumNarozeni']!.text),
                    adresa: _controllers['adresa']!.text,
                    cisloPojisteni: _controllers['cisloPojisteni']!.text,
                    jmenoRodice: _controllers['jmenoRodice']!.text,
                    telefonRodice: _controllers['telefonRodice']!.text,
                    emailRodice: _controllers['emailRodice']!.text,
                    zdravotniPojistovna:
                        _controllers['zdravotniPojistovna']!.text,
                    poznamka: _controllers['poznamka']!.text,
                    pohlavi: int.parse(_controllers['pohlavi']!.text),
                    zpusobilost: false,
                    bezinfekcnost: false,
                    wasPrinted: false,
                    oddil: '',
                    prisel: false,
                    potvrzeniPath: '',
                  );
                  _showPersonDetails(osoba);
                }
              },
              child: const Text('Odeslat'),
            ),
          ],
        ),
      ),
    ),
  );
}
}