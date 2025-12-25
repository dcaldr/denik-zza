import 'package:denik_zza/screens2/widgets/app_drawer.dart';
import 'package:denik_zza/screens2/widgets/custom_date_picker.dart';
import 'package:denik_zza/screens2/widgets/restrictions_widget.dart';
import 'package:denik_zza/screens2/services/participant_registration_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import '../input/input_hold.dart';
import '../input/rodne_cislo.dart';
import '../input/text_tools.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/design_system/tokens/app_breakpoints.dart';
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
        // Clear form for next entry: ONLY for NEW participants on standalone page.
        // IntakeForm is NOT affected - it uses controller-based saves, not this button.
        // Edit mode (widget.osoba != null) does NOT clear to preserve context.
        if (widget.osoba == null) {
          clearFields();
          setState(() {}); // Refresh UI to show cleared form
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
          ? (PohlaviHold.full(_controllers['pohlavi']!.text).output as int?)
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
        _controllers['pohlavi']!.text =
            TextTools.formatGenderLabel(pohlavi.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Compact padding to give more space to list
      padding: AppSpacing.containerPadding,
      child: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            print('');
            print('=== FORM LayoutBuilder ===');
            print('  maxHeight: ${constraints.maxHeight}');
            print('  maxWidth: ${constraints.maxWidth}');
            print('  isBounded: ${constraints.maxHeight.isFinite}');
            print('');

            // FIX: No SingleChildScrollView - use Column(max) + Flexible
            // This passes BOUNDED constraints to restrictions section
            return Column(
              mainAxisSize: MainAxisSize.max, // FILL available space
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGridView(),
                SizedBox(height: AppSpacing.s), // Compact gap (8px)
                _buildTextField('poznamka', 'Poznámka', null,
                    minLines: 2, maxLines: 7), // Shows 2 lines, scrolls up to 7
                SizedBox(height: AppSpacing.s), // Compact gap (8px)
                _buildCheckboxSection(),
                SizedBox(height: AppSpacing.xs), // Minimal gap (4px)
                // Flexible: takes REMAINING bounded space
                Flexible(child: _buildRestrictionsSection()),
                SizedBox(height: AppSpacing.xs), // Minimal gap (4px)
                Center(
                  child: FilledButton(
                    key: const Key('ParticipantRegistrationForm_submit_button'),
                    onPressed: _submitForm,
                    child: Text(
                        widget.osoba == null ? 'Registrovat' : 'Uložit změny'),
                  ),
                ),
              ],
            );
          },
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
                  flex: 2,
                  child: CustomDatePicker(
                      key: const Key(
                          'ParticipantRegistrationForm_datumNarozeni_input'),
                      controller: _controllers['datumNarozeni']!,
                      labelText: 'Datum Narození')),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                  flex: 1, child: _buildTextField('pohlavi', 'Pohlaví', null)),
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

  /// Builds a responsive form row: 3 columns on desktop, 2 on tablet, 1 on mobile.
  Widget _buildFormRow(List<Widget> fields) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = AppBreakpoints.getColumnCount(constraints.maxWidth);

        if (columns == 1) {
          // Mobile: Stack vertically with spacing
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: fields
                .map((field) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: field,
                    ))
                .toList(),
          );
        }

        // Tablet/Desktop: Chunk into rows with column count
        final rows = <Widget>[];
        for (var i = 0; i < fields.length; i += columns) {
          final chunk = fields.skip(i).take(columns).toList();
          rows.add(Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: chunk
                .map((field) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: field,
                      ),
                    ))
                .toList(),
          ));
          if (i + columns < fields.length) {
            rows.add(const SizedBox(height: 4));
          }
        }
        return Column(children: rows);
      },
    );
  }

  Widget _buildTextField(String key, String labelText, String? validatorText,
      {int? maxLines = 1, int? minLines, String? hintText}) {
    return TextFormField(
      key: Key('ParticipantRegistrationForm_${key}_input'),
      controller: _controllers[key],
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: (maxLines != null && maxLines > 1) || minLines != null
            ? const OutlineInputBorder()
            : null,
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
      minLines: minLines,
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
                key: const Key(
                    'ParticipantRegistrationForm_bezinfekcnost_checkbox'),
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
                key: const Key(
                    'ParticipantRegistrationForm_zpusobilost_checkbox'),
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

  /// Build the restrictions and medications section with responsive layout.
  Widget _buildRestrictionsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        print('=== _buildRestrictionsSection ===');
        print('  maxWidth: ${constraints.maxWidth}');
        print('  maxHeight: ${constraints.maxHeight}');
        print('  isBounded: ${constraints.maxHeight.isFinite}');
        print('');

        final isNarrow = AppBreakpoints.isMobile(constraints.maxWidth);

        final widgets = [
          RestrictionsWidget(
            logic: _omezeniLogic,
            participantId: widget.osoba?.id,
          ),
          RestrictionsWidget(
            logic: _lekLogic,
            participantId: widget.osoba?.id,
          ),
        ];

        if (isNarrow) {
          // Mobile: Stack vertically
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              widgets[0],
              const SizedBox(height: 16),
              widgets[1],
            ],
          );
        }

        // Desktop/Tablet: Side by side - stretch to fill bounded height
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: widgets[0]),
            AppSpacing.buttonGap,
            Expanded(child: widgets[1]),
          ],
        );
      },
    );
  }
}

class ParticipantRegistrationPage extends StatefulWidget {
  const ParticipantRegistrationPage({super.key});

  @override
  State<ParticipantRegistrationPage> createState() =>
      _ParticipantRegistrationPageState();
}

class _ParticipantRegistrationPageState
    extends State<ParticipantRegistrationPage> {
  final GlobalKey<_ParticipantRegistrationFormState> _formKey =
      GlobalKey<_ParticipantRegistrationFormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrace Účastníka'),
        actions: [
          IconButton(
            key: const Key('ParticipantRegistrationPage_refresh_button'),
            icon: const Icon(Icons.refresh),
            tooltip: 'Vymazat formulář',
            onPressed: () {
              _formKey.currentState?.clearFields();
              _formKey.currentState?.setState(() {});
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: ParticipantRegistrationForm(key: _formKey),
    );
  }
}
