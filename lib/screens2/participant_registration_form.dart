import 'package:denik_zza/screens2/widgets/app_drawer.dart';
import 'package:denik_zza/screens2/widgets/custom_date_picker.dart';
import 'package:denik_zza/screens2/widgets/restrictions_widget.dart';
import 'package:denik_zza/screens2/services/participant_registration_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import '../input/input_hold.dart';
import '../input/rodne_cislo.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/screens2/widgets/memory_restriction_widget.dart';

class ParticipantRegistrationForm extends StatefulWidget {
  final MemoryOsoba? osoba;
  final Function(bool Function())? onValidate;
  final Function(MemoryOsoba)? onOsobaEdited;
  final VoidCallback? onRefresh;

  const ParticipantRegistrationForm(
      {super.key,
      this.osoba,
      this.onValidate,
      this.onOsobaEdited,
      this.onRefresh});

  @override
  State<ParticipantRegistrationForm> createState() =>
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
    'jmenoRodice': JmenoHold(columnName: 'jmeno rodiče'),
    'telefonRodice': TelefonHold(),
    'emailRodice': EmailHold(),
    'zdravotniPojistovna': PojistovnaHold(),
    'poznamka': TextHold(),
    'pohlavi': PohlaviHold(),
  };

  // State variables for checkboxes
  bool _zpusobilost = false;
  bool _bezinfekcnost = false;

  // Restrictions and medications logic
  final MemoryOmezeniLogic _omezeniLogic = MemoryOmezeniLogic();
  final MemoryLekLogic _lekLogic = MemoryLekLogic();
  final ParticipantRegistrationService _participantService =
      ParticipantRegistrationService();

  @override
  void initState() {
    super.initState();
    if (widget.osoba == null ||
        (widget.osoba!.id == -1 &&
            widget.osoba!.jmeno.isEmpty &&
            widget.osoba!.prijmeni.isEmpty)) {
      // Start with clear fields for new person
      clearFields();
    } else {
      // Populate fields for existing person
      _populateFields(widget.osoba!);
      _loadRestrictionsForExistingPerson();
    }
    _controllers['cisloPojisteni']!.addListener(() {
      setState(() {
        guessAndFillFields(_controllers['cisloPojisteni']!.text);
      });
    });
    widget.onValidate?.call(validateForm);
  }

  void clearFields() {
    _controllers.forEach((key, controller) {
      controller.clear();
    });

    // Reset checkbox values
    _zpusobilost = false;
    _bezinfekcnost = false;

    // Reset restrictions
    _participantService.resetRestrictions(
      omezeniLogic: _omezeniLogic,
      lekLogic: _lekLogic,
    );
  }

  /// Load restrictions for an existing person
  Future<void> _loadRestrictionsForExistingPerson() async {
    if (widget.osoba != null && widget.osoba!.id > 0) {
      await _participantService.loadRestrictionsForParticipant(
        participantId: widget.osoba!.id,
        omezeniLogic: _omezeniLogic,
        lekLogic: _lekLogic,
      );
      setState(() {}); // Refresh UI after loading restrictions
    }
  }

  @override
  void didUpdateWidget(covariant ParticipantRegistrationForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.osoba != oldWidget.osoba) {
      if (widget.osoba == null ||
          (widget.osoba!.id == -1 &&
              widget.osoba!.jmeno.isEmpty &&
              widget.osoba!.prijmeni.isEmpty)) {
        // Clear fields for new person
        clearFields();
      } else {
        // Populate fields for existing person
        _populateFields(widget.osoba!);
        _loadRestrictionsForExistingPerson();
      }
    }
  }

  bool validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  void _populateFields(MemoryOsoba osoba) {
    _controllers['jmeno']!.text = osoba.jmeno;
    _controllers['prijmeni']!.text = osoba.prijmeni;
    _controllers['cisloPojisteni']!.text = osoba.cisloPojisteni ?? '';
    if (osoba.datumNarozeni != null) {
      _controllers['datumNarozeni']!.text =
          DateFormat('dd.MM.yyyy').format(osoba.datumNarozeni!);
    }
    _controllers['pohlavi']!.text = osoba.pohlavi?.toString() ?? '';
    _controllers['zdravotniPojistovna']!.text = osoba.zdravotniPojistovna ?? '';
    _controllers['adresa']!.text = osoba.adresa ?? '';
    _controllers['jmenoRodice']!.text = osoba.jmenoRodice ?? '';
    _controllers['emailRodice']!.text = osoba.emailRodice ?? '';
    _controllers['telefonRodice']!.text = osoba.telefonRodice ?? '';
    _controllers['poznamka']!.text = osoba.poznamka ?? '';

    // Initialize checkbox values
    _zpusobilost = osoba.zpusobilost ?? false;
    _bezinfekcnost = osoba.bezinfekcnost ?? false;
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  // This method should only be called for standalone usage (not from intake form)
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      MemoryOsoba osoba = createMemoryOsoba();
      widget.onOsobaEdited?.call(osoba); // Ensure callback is called

      // Use the service to save participant with restrictions
      final participantId =
          await _participantService.saveParticipantWithRestrictions(
        osoba: osoba,
        omezeniLogic: _omezeniLogic,
        lekLogic: _lekLogic,
      );

      if (participantId != null) {
        _showSnackBar(widget.osoba == null
            ? 'Účastník úspěšně přidán'
            : 'Účastník aktualizován');
        // Update the osoba with the new ID if it was a new participant
        if (osoba.id == -1) {
          osoba.id = participantId;
          widget.onOsobaEdited?.call(osoba);
        }
      } else {
        _showSnackBar('Chyba při ukládání účastníka');
      }
    }
  }

  MemoryOsoba createMemoryOsoba() {
    // Use DatumNarozeniHold validator for consistent date parsing (same as CSV import)
    // This prevents crashes on invalid dates and provides proper validation
    DateTime? parsedDate;
    if (_controllers['datumNarozeni']!.text.isNotEmpty) {
      final validator = _validators['datumNarozeni'] as DatumNarozeniHold;
      validator.addInput(_controllers['datumNarozeni']!.text);
      parsedDate = validator.getOutput();
    }

    return MemoryOsoba.fullNamed(
      id: widget.osoba?.id,
      jmeno: _controllers['jmeno']!.text,
      prijmeni: _controllers['prijmeni']!.text,
      datumNarozeni: parsedDate ?? widget.osoba?.datumNarozeni,
      adresa: _controllers['adresa']!.text.isNotEmpty
          ? _controllers['adresa']!.text
          : widget.osoba?.adresa,
      cisloPojisteni: _controllers['cisloPojisteni']!.text.isNotEmpty
          ? _controllers['cisloPojisteni']!.text
          : widget.osoba?.cisloPojisteni,
      jmenoRodice: _controllers['jmenoRodice']!.text.isNotEmpty
          ? _controllers['jmenoRodice']!.text
          : widget.osoba?.jmenoRodice,
      telefonRodice: _controllers['telefonRodice']!.text.isNotEmpty
          ? _controllers['telefonRodice']!.text
          : widget.osoba?.telefonRodice,
      emailRodice: _controllers['emailRodice']!.text.isNotEmpty
          ? _controllers['emailRodice']!.text
          : widget.osoba?.emailRodice,
      zdravotniPojistovna: _controllers['zdravotniPojistovna']!.text.isNotEmpty
          ? _controllers['zdravotniPojistovna']!.text
          : widget.osoba?.zdravotniPojistovna,
      poznamka: _controllers['poznamka']!.text.isNotEmpty
          ? _controllers['poznamka']!.text
          : widget.osoba?.poznamka,
      pohlavi: _controllers['pohlavi']!.text.isNotEmpty
          ? int.parse(_controllers['pohlavi']!.text)
          : widget.osoba?.pohlavi,
      zpusobilost: _zpusobilost,
      bezinfekcnost: _bezinfekcnost,
      wasPrinted: widget.osoba?.wasPrinted ?? false,
      oddil: widget.osoba?.oddil ?? '',
      prisel: widget.osoba?.prisel ?? false,
      potvrzeniPath: widget.osoba?.potvrzeniPath,
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void guessAndFillFields(String inText) {
    if (inText.length >= 6) {
      RodneCislo rc = RodneCislo(inText);
      DateTime datumNarozeni = rc.getDatumNarozeni();
      int pohlavi = rc.getPohlavi();
      if (_controllers['datumNarozeni']!.text.isEmpty) {
        _controllers['datumNarozeni']!.text =
            DateFormat('dd.MM.yyyy').format(datumNarozeni);
      }
      if (_controllers['pohlavi']!.text.isEmpty) {
        _controllers['pohlavi']!.text = pohlavi.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGridView(),
              const SizedBox(height: 16),
              _buildTextField('poznamka', 'Poznámka', null, maxLines: 3),
              const SizedBox(height: 16),
              _buildCheckboxSection(),
              const SizedBox(height: 24),
              _buildRestrictionsSection(),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(
                      widget.osoba == null ? 'Registrovat' : 'Uložit změny'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return Column(
      children: [
        // Row 1: Basic identification
        _buildFormRow([
          _buildTextField('jmeno', 'Jméno', 'Jméno je povinné pole'),
          _buildTextField('prijmeni', 'Příjmení', 'Příjmení je povinné pole'),
          _buildTextField('cisloPojisteni', 'Číslo Pojištěnce', null),
        ]),
        const SizedBox(height: 4),
        // Row 2: Birth details and insurance
        _buildFormRow([
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: CustomDatePicker(
                      controller: _controllers['datumNarozeni']!,
                      labelText: 'Datum Narození')),
              const SizedBox(width: 8.0),
              Expanded(child: _buildTextField('pohlavi', 'Pohlaví', null)),
            ],
          ),
          _buildTextField('zdravotniPojistovna', 'Zdravotní Pojišťovna', null),
          _buildTextField('adresa', 'Adresa', null),
        ]),
        const SizedBox(height: 4),
        // Row 3: Guardian contact info
        _buildFormRow([
          _buildTextField('jmenoRodice', 'Jméno rodiče', null),
          _buildTextField('emailRodice', 'Email rodiče', null),
          _buildTextField('telefonRodice', 'Telefon rodiče', null),
        ]),
      ],
    );
  }

  Widget _buildFormRow(List<Widget> fields) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fields
          .map((field) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: field,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildTextField(String key, String labelText, String? validatorText,
      {int maxLines = 1, String? hintText}) {
    return TextFormField(
      controller: _controllers[key],
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: maxLines > 1 ? const OutlineInputBorder() : null,
      ),
      validator: (value) {
        if (key == 'poznamka' && (value == null || value.isEmpty)) {
          return null; // Make 'poznamka' optional
        }
        if (validatorText != null && (value == null || value.isEmpty)) {
          return validatorText;
        }
        return _validators[key]?.validator(value);
      },
      maxLines: maxLines,
    );
  }

  Widget _buildCheckboxSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Potvrzení',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: const Text('Má bezinfekčnost'),
                value: _bezinfekcnost,
                onChanged: (bool? value) {
                  setState(() {
                    _bezinfekcnost = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: const Text('Má potvrzení o způsobilosti'),
                value: _zpusobilost,
                onChanged: (bool? value) {
                  setState(() {
                    _zpusobilost = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build the restrictions and medications section
  Widget _buildRestrictionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Omezení a léky',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: RestrictionsWidget(
                logic: _omezeniLogic,
                participantId: widget.osoba?.id,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: RestrictionsWidget(
                logic: _lekLogic,
                participantId: widget.osoba?.id,
              ),
            ),
          ],
        ),
      ],
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
