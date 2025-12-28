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
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_typography.dart';
import 'package:denik_zza/design_system/tokens/app_breakpoints.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';
import 'package:denik_zza/screens2/widgets/memory_restriction_widget.dart';
import 'package:denik_zza/screens2/widgets/zza_scrollable.dart';

class ParticipantRegistrationForm extends StatefulWidget {
  final bool enableStickyFooter;
  final bool bypassLayoutBuilder;
  final MemoryOsoba? osoba;
  final Function(bool Function())? onValidate;
  final Function(MemoryOsoba)? onOsobaEdited;
  final VoidCallback? onRefresh;

  const ParticipantRegistrationForm({
    super.key,
    this.osoba,
    this.onValidate,
    this.onOsobaEdited,
    this.onRefresh,
    this.enableStickyFooter = false,
    this.bypassLayoutBuilder = false,
  });

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

  String? _lastAddedName;

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
        if (widget.osoba == null) {
          // Success for NEW participant -> Inline Message
          final addedName = "${osoba.jmeno} ${osoba.prijmeni}";
          // Update the osoba with the new ID if it was a new participant
          if (osoba.id == -1) {
            osoba.id = participantId;
            widget.onOsobaEdited?.call(osoba);
          }
          clearFields();
          setState(() {
            _lastAddedName = addedName;
          });
        } else {
          // Success for EDIT -> SnackBar (keep existing behavior for edits)
          _showSnackBar('Účastník aktualizován');
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
    // Phase 7: Clean Split Architecture
    // 1. Calculate layout variables ONCE at the top level
    //    We need width to determine column count.
    //    We check constraints if available (LayoutBuilder parent), else MediaQuery.

    // Use LayoutBuilder at ROOT ONLY to get width for grid columns
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        // 2. Determine Column Count (Responsive Grid)
        final columnCount = AppBreakpoints.getColumnCount(width);

        // 3. Determine Layout Mode (Mobile vs Desktop)
        //    We use width for this decision, consistent with AppBreakpoints
        final isMobile = AppBreakpoints.isMobile(width);

        // 4. Build Content
        return Padding(
          padding: AppSpacing.containerPadding,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: constraints.hasBoundedHeight
                  ? MainAxisSize.max
                  : MainAxisSize.min, // Shrink wrap content if unbounded
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_lastAddedName != null) _buildSuccessMessage(),
                _buildGridView(columnCount),
                const SizedBox(height: AppSpacing.s),
                _buildTextField('poznamka', 'Poznámka', null,
                    minLines: 2, maxLines: 7),
                const SizedBox(height: AppSpacing.s),
                _buildCheckboxSection(),
                const SizedBox(height: AppSpacing.xs),

                // RESTRICTIONS SECTION
                // In clean architecture, we simply render them.
                // The PARENT determines if this stretches (SliverFillRemaining) or flows.
                // But RestrictionsWidget needs to know if it should be 'bounded' (Expanded) or 'unbounded'.
                // If we are in "Footer Mode" (Desktop/SliverFillRemaining), the parent passes bounded constraints.
                // If we are in "Mobile Mode" (SliverToBoxAdapter), the parent passes unbounded constraints.
                // However, RestrictionsWidget logic relies on `isBounded` flag.
                // We can infer this from constraints.hasBoundedHeight.
                if (constraints.hasBoundedHeight)
                  Expanded(
                    child: _buildRestrictionsSection(
                      isNarrow: isMobile,
                      isBounded: true,
                    ),
                  )
                else
                  _buildRestrictionsSection(
                    isNarrow: isMobile,
                    isBounded: false,
                  ),

                // STICKY FOOTER LOGIC
                // The Button is handled by the Page via SliverFillRemaining.
                // We ONLY render the button here if sticky footer is DISABLED (legacy/embedded mode).
                if (!widget.enableStickyFooter) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Center(
                    child: FilledButton(
                      key: const Key(
                          'ParticipantRegistrationForm_submit_button'),
                      onPressed: _submitForm,
                      child: Text(widget.osoba == null
                          ? 'Registrovat'
                          : 'Uložit změny'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m), // Corrected token
      padding: const EdgeInsets.all(AppSpacing.s), // Corrected token
      decoration: BoxDecoration(
        color: AppColors.greenBackground,
        borderRadius: BorderRadius.circular(AppRadii.small), // Corrected token
        border: Border.all(
            color: AppColors.greenIcon.withOpacity(0.3)), // Compatibility fix
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 20, color: AppColors.greenIcon),
          const SizedBox(width: AppSpacing.s), // Corrected token
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Text(
                '$_lastAddedName byl úspěšně přidán',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.greenText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: AppColors.greenIcon),
            onPressed: () => setState(() => _lastAddedName = null),
            tooltip: 'Zavřít',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  // Deprecated _buildFormContent removed - logic moved to build()

  Widget _buildGridView(int columnCount) {
    return Column(
      children: [
        // Row 1: Basic identification
        _buildFormRow([
          _buildTextField('jmeno', 'Jméno', 'Jméno je povinné pole'),
          _buildTextField('prijmeni', 'Příjmení', 'Příjmení je povinné pole'),
          _buildTextField('cisloPojisteni', 'Číslo Pojištěnce', null),
        ], columnCount),
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
        ], columnCount),
        const SizedBox(height: 4),
        // Row 3: Guardian contact info
        _buildFormRow([
          _buildTextField('jmenoRodice', 'Jméno rodiče', null),
          _buildTextField('emailRodice', 'Email rodiče', null),
          _buildTextField('telefonRodice', 'Telefon rodiče', null),
        ], columnCount),
      ],
    );
  }

  /// Builds a responsive form row: 3 columns on desktop, 2 on tablet, 1 on mobile.
  Widget _buildFormRow(List<Widget> fields, int columns) {
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
  /// [isNarrow] and [isBounded] are calculated once at root LayoutBuilder level.
  Widget _buildRestrictionsSection({
    required bool isNarrow,
    required bool isBounded,
  }) {
    final widgets = [
      RestrictionsWidget(
        logic: _omezeniLogic,
        participantId: widget.osoba?.id,
        isBounded: isBounded,
      ),
      RestrictionsWidget(
        logic: _lekLogic,
        participantId: widget.osoba?.id,
        isBounded: isBounded,
      ),
    ];

    if (isNarrow) {
      // Mobile: Stack vertically
      // In bounded mode, wrap in Expanded for each widget to share space
      if (isBounded) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: widgets[0]),
            SizedBox(height: AppSpacing.s),
            Expanded(child: widgets[1]),
          ],
        );
      }
      // In scroll mode: min sizing
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widgets[0],
          SizedBox(height: AppSpacing.s),
          widgets[1],
        ],
      );
    }

    // Desktop/Tablet: Side by side
    // In bounded mode: stretch to fill height
    // In scroll mode: align to start
    return Row(
      crossAxisAlignment:
          isBounded ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
      children: [
        Expanded(child: widgets[0]),
        AppSpacing.buttonGap,
        Expanded(child: widgets[1]),
      ],
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
  final ScrollController _scrollController =
      ScrollController(); // Added for ZzaScrollable

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
      // Phase 8: Scroll Signaling (ZzaScrollable Wrapper)
      // Wraps the main CustomScrollView to provide "more content" hints
      body: ZzaScrollable(
        controller: _scrollController,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // 1. The Form Content (Scrolls naturally)
            SliverToBoxAdapter(
              child: ParticipantRegistrationForm(
                key: _formKey,
                enableStickyFooter:
                    true, // Signal to not render internal button
                bypassLayoutBuilder:
                    true, // Signal to rely on parent constraints
              ),
            ),

            // 2. The Sticky Footer (Fills remaining space or sits at bottom)
            SliverFillRemaining(
              hasScrollBody: false, // It's just a button container, not a list
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FilledButton(
                    key: const Key('ParticipantRegistrationPage_submit_button'),
                    // Call submit on the form state via GlobalKey
                    onPressed: () => _formKey.currentState?._submitForm(),
                    child: const Text('Registrovat'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
