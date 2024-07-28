import 'package:denik_zza/screens2/widgets/app_drawer.dart';
import 'package:denik_zza/screens2/widgets/custom_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import '../database/database_wrapper.dart';
import '../input/input_hold.dart';
import '../input/rodne_cislo.dart';

class ParticipantRegistrationForm extends StatefulWidget {
  final MemoryOsoba? osoba;

  const ParticipantRegistrationForm({super.key, this.osoba});

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
    'jmenoRodice': JmenoHold(columnName: 'jmeno rodiče'),
    'telefonRodice': TelefonHold(),
    'emailRodice': EmailHold(),
    'zdravotniPojistovna': PojistovnaHold(),
    'poznamka': TextHold(),
    'pohlavi': PohlaviHold(),
  };

  @override
  void initState() {
    super.initState();
    if (widget.osoba != null) {
      _populateFields(widget.osoba!);
    }
    _controllers['cisloPojisteni']!.addListener(() {
      setState(() {
        guessAndFillFields(_controllers['cisloPojisteni']!.text);
      });
    });
  }

  void _populateFields(MemoryOsoba osoba) {
    _controllers['jmeno']!.text = osoba.jmeno;
    _controllers['prijmeni']!.text = osoba.prijmeni;
    _controllers['cisloPojisteni']!.text = osoba.cisloPojisteni!;
    if (osoba.datumNarozeni != null) {
      _controllers['datumNarozeni']!.text = DateFormat('dd.MM.yyyy').format(osoba.datumNarozeni!);
    }
    _controllers['pohlavi']!.text = osoba.pohlavi.toString();
    _controllers['zdravotniPojistovna']!.text = osoba.zdravotniPojistovna!;
    _controllers['adresa']!.text = osoba.adresa!;
    _controllers['jmenoRodice']!.text = osoba.jmenoRodice!;
    _controllers['emailRodice']!.text = osoba.emailRodice!;
    _controllers['telefonRodice']!.text = osoba.telefonRodice!;
    _controllers['poznamka']!.text = osoba.poznamka!;
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      MemoryOsoba osoba = _createMemoryOsoba();
      if (widget.osoba == null) {
        bool insertSuccess = await DatabaseWrapper.getDatabase().addOsoba(osoba);
        _showSnackBar(insertSuccess ? 'Insert successful' : 'Insert failed');
        if (insertSuccess) _showPersonDetails(osoba);
      } else {
        int updateResult = await DatabaseWrapper.getDatabase().updateParticipant(osoba.id, osoba);
        _showSnackBar(updateResult > 0 ? 'Update successful' : 'Update failed');
        if (updateResult > 0) _showPersonDetails(osoba);
      }
    }
  }

  MemoryOsoba _createMemoryOsoba() {
    return MemoryOsoba.fullNamed(
      id: widget.osoba?.id,
      jmeno: _controllers['jmeno']!.text,
      prijmeni: _controllers['prijmeni']!.text,
      datumNarozeni: DateFormat('dd.MM.yyyy').parse(_controllers['datumNarozeni']!.text),
      adresa: _controllers['adresa']!.text,
      cisloPojisteni: _controllers['cisloPojisteni']!.text,
      jmenoRodice: _controllers['jmenoRodice']!.text,
      telefonRodice: _controllers['telefonRodice']!.text,
      emailRodice: _controllers['emailRodice']!.text,
      zdravotniPojistovna: _controllers['zdravotniPojistovna']!.text,
      poznamka: _controllers['poznamka']!.text,
      pohlavi: int.parse(_controllers['pohlavi']!.text),
      zpusobilost: false,
      bezinfekcnost: false,
      wasPrinted: false,
      oddil: '',
      prisel: false,
      potvrzeniPath: '',
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void guessAndFillFields(String inText) {
    if (inText.length >= 6) {
      RodneCislo rc = RodneCislo(inText);
      DateTime datumNarozeni = rc.getDatumNarozeni();
      int pohlavi = rc.getPohlavi();
      if (_controllers['datumNarozeni']!.text.isEmpty) {
        _controllers['datumNarozeni']!.text = DateFormat('dd.MM.yyyy').format(datumNarozeni);
      }
      if (_controllers['pohlavi']!.text.isEmpty) {
        _controllers['pohlavi']!.text = pohlavi.toString();
      }
    }
  }

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
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildGridView(),
            _buildTextField('poznamka', 'Poznámka', 'Tento text se nebude tisknout', maxLines: 3),
            ElevatedButton(onPressed: _submitForm, child: Text(widget.osoba == null ? 'Přidat' : 'Aktualizovat')),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
      childAspectRatio: 3 / 1,
      children: [
        _buildTextField('jmeno', 'Jméno', 'Jméno je povinné pole'),
        _buildTextField('prijmeni', 'Příjmení', 'Příjmení je povinné pole'),
        _buildTextField('cisloPojisteni', 'Číslo Pojištěnce', null),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: CustomDatePicker(controller: _controllers['datumNarozeni']!, labelText: 'Datum Narození')),
            const SizedBox(width: 8.0),
            Expanded(child: _buildTextField('pohlavi', 'Pohlaví', null)),
          ],
        ),
        _buildTextField('zdravotniPojistovna', 'Zdravotní Pojišťovna', null),
        _buildTextField('adresa', 'Adresa', 'Adresa je povinné pole'),
        _buildTextField('jmenoRodice', 'Jméno rodiče', null),
        _buildTextField('emailRodice', 'Email rodiče', null),
        _buildTextField('telefonRodice', 'Telefon rodiče', null),
      ],
    );
  }

  Widget _buildTextField(String key, String labelText, String? validatorText, {int maxLines = 1}) {
    return TextFormField(
      controller: _controllers[key],
      decoration: InputDecoration(labelText: labelText, border: maxLines > 1 ? const OutlineInputBorder() : null),
      validator: (value) {
        if (validatorText != null && (value == null || value.isEmpty)) {
          return validatorText;
        }
        return _validators[key]?.validator(value);
      },
      maxLines: maxLines,
    );
  }
}

class ParticipantRegistrationPage extends StatelessWidget {
  const ParticipantRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrace Účastníka')),
      drawer: const AppDrawer(),
      body: const ParticipantRegistrationForm(),
    );
  }
}