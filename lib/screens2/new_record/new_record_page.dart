import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_lek.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_omezeni.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:denik_zza/design_system/tokens/app_breakpoints.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_new_record_layout.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/print_ops2/print_center.dart';
import 'package:denik_zza/print_ops2/print_center_controller.dart';
import 'package:denik_zza/print_ops2/print_center_service.dart';
import 'package:denik_zza/screens2/new_record/widgets/new_record_action_buttons.dart';
import 'package:denik_zza/screens2/new_record/widgets/new_record_body_layout.dart';
import 'package:denik_zza/screens2/new_record/new_record_scroll_strategy.dart';
import 'package:denik_zza/screens2/services/record_service.dart';
import 'package:denik_zza/screens2/widgets/app_drawer.dart';
import 'package:denik_zza/screens2/new_record/new_record_date_time.dart';
import 'package:denik_zza/screens2/new_record/new_record_page_dialogs.dart';
import 'package:denik_zza/utils/app_logger.dart';

/// Enhanced new record page that matches the old system functionality
/// but with improved architecture and validation
///
/// ## TODO: Features pending implementation
///
/// ### Printing (print_ops2/ integration)
/// **Status:** ✅ IMPLEMENTED
/// - [x] Print buttons enabled when participant selected
/// - [x] Navigate to PersonAndModeFlowPage with pre-selected participant
/// - [x] Support both full print and append print modes
/// - [x] PrintCenter handles all PDF generation and printing logic
///
/// ### File Viewer (způsobilost documents)
/// **Status:** ✅ IMPLEMENTED
/// - [x] Wired to FileViewerScreen
/// - [x] Uses potvrzeniPath field from MemoryOsoba
/// - [x] Opens JPG/PDF viewer for způsobilost documents
/// - [x] Handles missing file paths gracefully
///
/// ### Health Data Entry (real data workflow)
/// **Status:** Larger scope feature - requires new UI
/// - Current: Health data DISPLAY works (loads from database correctly)
/// - Missing: UI forms for adding/editing omezení, alergie, léky
/// - Note: DevMockDataBadge shown because dev environment uses mock data, not because UI uses mocks
/// - Requires: New screens/dialogs for health data CRUD operations
class NewRecordPage extends StatefulWidget {
  final MemoryOsoba? participant;

  const NewRecordPage({super.key, this.participant});

  @override
  NewRecordPageState createState() => NewRecordPageState();
}

class NewRecordPageState extends State<NewRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _poznamkaController = TextEditingController();
  final _recordService = RecordService();
  final _headerKey = GlobalKey();
  final _historyHeaderKey = GlobalKey();
  final _formContainerKey = GlobalKey();

  bool _isSaving = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _refreshCounter = 0; // For forcing widget refresh
  MemoryOsoba? _selectedParticipant;
  bool _hasUnsavedChanges = false;
  List<MemoryOsoba> _availableParticipants = [];
  double? _headerHeight;
  double? _historyHeaderHeight;
  double? _formHeight;

  // Health info loaded separately
  List<MemoryOmezeni> _omezeniList = [];
  List<MemoryLek> _lekyList = [];
  int _recordCount = 0; // Count of participant's records for header badge

  @override
  void initState() {
    super.initState();
    _selectedParticipant = widget.participant;

    // Load participant's health data if participant was provided
    if (_selectedParticipant != null) {
      _poznamkaController.text = _selectedParticipant!.poznamka ?? '';
      _loadParticipantHealthData(_selectedParticipant!.id);
    }

    // Track unsaved changes
    _titleController.addListener(_trackChanges);
    _descriptionController.addListener(_trackChanges);
    _poznamkaController.addListener(_trackChanges);

    // Load available participants
    _loadAvailableParticipants();

    // If no participant provided, search interface will be shown automatically
  }

  void _trackChanges() {
    setState(() {
      _hasUnsavedChanges = _titleController.text.trim().isNotEmpty ||
          _descriptionController.text.trim().isNotEmpty ||
          _poznamkaController.text.trim().isNotEmpty;
    });
  }

  Future<void> _loadAvailableParticipants() async {
    try {
      // Always resolve DB via the wrapper so tests/dev can inject memory DB
      final database = DatabaseWrapper.getDatabase();
      final participants =
          await database.watchParticipantsByCurrentEvent().first;
      if (!mounted) return;
      setState(() {
        _availableParticipants = participants;
      });
    } catch (e) {
      // Handle error silently or show a message
      AppLogger.l.e('Error loading participants: $e');
    }
  }

  void _onParticipantSelected(MemoryOsoba participant) async {
    // Guard against accidental data override
    if (_selectedParticipant != null && _hasUnsavedChanges) {
      final confirmed =
          await NewRecordPageDialogs.confirmParticipantChange(context);
      if (confirmed != true) return; // User cancelled the change
    }

    setState(() {
      _selectedParticipant = participant;
      _refreshCounter++;

      // Clear form when switching participants
      _titleController.clear();
      _descriptionController.clear();

      // Load participant's poznámka into the field
      _poznamkaController.text = participant.poznamka ?? '';

      // Only clear timestamp if there were unsaved changes
      // Preserve manually set timestamps when no unsaved changes exist
      if (_hasUnsavedChanges) {
        _selectedDate = null;
        _selectedTime = null;
      }

      // Reset unsaved changes flag since we're starting fresh with new participant
      _hasUnsavedChanges = false;
    });

    // Load health data for new participant
    _loadParticipantHealthData(participant.id);
  }

  void _onRefresh() {
    _loadAvailableParticipants();
  }

  void _updateMeasuredHeights() {
    final headerBox =
        _headerKey.currentContext?.findRenderObject() as RenderBox?;
    final historyHeaderBox =
        _historyHeaderKey.currentContext?.findRenderObject() as RenderBox?;
    final formBox =
        _formContainerKey.currentContext?.findRenderObject() as RenderBox?;

    final nextHeaderHeight = headerBox?.size.height;
    final nextHistoryHeaderHeight = historyHeaderBox?.size.height;
    final nextFormHeight = formBox?.size.height;

    if (nextHeaderHeight != _headerHeight ||
        nextHistoryHeaderHeight != _historyHeaderHeight ||
        nextFormHeight != _formHeight) {
      setState(() {
        _headerHeight = nextHeaderHeight;
        _historyHeaderHeight = nextHistoryHeaderHeight;
        _formHeight = nextFormHeight;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _poznamkaController.dispose();
    super.dispose();
  }

  /// Loads health data for selected participant
  Future<void> _loadParticipantHealthData(int participantId) async {
    try {
      final database = DatabaseWrapper.getDatabase();
      final omezeni = await database.getOmezeniByParticipantID(participantId);
      final leky = await database.getLekyByParticipantID(participantId);
      if (!mounted) return;

      setState(() {
        _omezeniList = omezeni;
        _lekyList = leky;
      });
    } catch (e) {
      AppLogger.l.w(
        'Failed to load health data for participant $participantId: $e',
      );
    }
  }

  /// Formats age display with hover/click for full birthdate
  String _formatAge() {
    if (_selectedParticipant?.datumNarozeni == null) return '';

    final birthDate = _selectedParticipant!.datumNarozeni!;
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    // Adjust if birthday hasn't occurred yet this year
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return ', $age let';
  }


  /// Check if způsobilost document is available
  bool _hasZpusobilostDocument() {
    return _selectedParticipant?.potvrzeniPath != null &&
        _selectedParticipant!.potvrzeniPath!.isNotEmpty;
  }

  /// Builds způsobilost document button
  Widget _buildZpusobilostButton() {
    final hasDocument = _hasZpusobilostDocument();
    final tooltip = hasDocument
        ? 'Zobrazit dokument způsobilosti'
        : 'Dokument způsobilosti nebyl nahrán';

    return Tooltip(
      message: tooltip,
      child: IconButton(
        key: const Key('NewRecordPage_zpusobilost_button'),
        icon: const Icon(Icons.description_outlined),
        iconSize: 20,
        onPressed: hasDocument
            ? () => NewRecordPageDialogs.showZpusobilostDocument(
                  context: context,
                  filePath: _selectedParticipant?.potvrzeniPath,
                )
            : null,
        color: hasDocument
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).disabledColor,
        // Removed styleFrom override to use theme styling
      ),
    );
  }

  /// Check if printing is available (participant must be selected)
  bool _canPrint() {
    return _selectedParticipant != null;
  }

  /// Print full record (navigate to PrintCenter with full mode)
  Future<void> _printFullRecord() async {
    _openPrintFlow(PrintMode.full);
  }

  /// Print append mode (navigate to PrintCenter with append mode)
  Future<void> _printAppendRecord() async {
    _openPrintFlow(PrintMode.append);
  }

  void _openPrintFlow(PrintMode mode) {
    if (_selectedParticipant == null || !mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) {
            final ctrl = PrintCenterController(PrintCenterService());
            ctrl.init();
            return ctrl;
          },
          child: PersonAndModeFlowPage(
            initialParticipant: _selectedParticipant,
            initialMode: mode,
          ),
        ),
      ),
    );
  }

  /// Combined date and time picker (better UX than separate pickers)
  Future<void> _selectDateTime() async {
    final selection = await NewRecordDateTimeHelper.pickDateTime(
      context: context,
      initialDate: _selectedDate,
      initialTime: _selectedTime,
    );

    if (!mounted || selection == null) return;

    setState(() {
      _selectedTime = selection.time;
      _selectedDate = selection.date;
    });
  }

  /// Test-friendly method for setting date and time directly
  /// This should only be used in test environments
  void setCustomDateTimeForTesting(DateTime dateTime) {
    if (mounted) {
      setState(() {
        _selectedDate = dateTime;
        _selectedTime = TimeOfDay.fromDateTime(dateTime);
      });
    }
  }


  Future<void> _saveRecord() async {
    if (_selectedParticipant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Nejprve vyberte účastníka'),
          backgroundColor: AppColors.orangeBackground,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      // Use validation from service
      final validationError = RecordService.validateRecord(
        title: _titleController.text,
        description: _descriptionController.text,
      );

      if (validationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(validationError)),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      final newRecord = MemoryZaznam.fullNamed(
        nazev: _titleController.text.trim(),
        popis: _descriptionController.text.trim(),
        idPacient: _selectedParticipant!.id,
        idZaznamu: -1, // DB will assign ID
        casZaznamu: NewRecordDateTimeHelper.getFinalDateTime(
          selectedDate: _selectedDate,
          selectedTime: _selectedTime,
        ),
        isPrinted: false,
        idAuthor: 1, // Assuming a logged-in user with ID 1
        poznamka: null,
        teplota: null,
        obrazekPath: null,
      );

      try {
        await _recordService.addRecord(newRecord);

        // Update participant's poznámka if it changed
        if (_selectedParticipant!.poznamka != _poznamkaController.text.trim()) {
          _selectedParticipant!.poznamka = _poznamkaController.text.trim();
          final db = DatabaseWrapper.getDatabase();
          await db.updateParticipant(osoba: _selectedParticipant!);
        }

        // Refresh the record list by triggering a rebuild
        setState(() {
          _refreshCounter++;
        });

        // Clear the form after successful save, but keep custom timestamp as tests expect it preserved
        _titleController.clear();
        _descriptionController.clear();
        // Don't clear poznámka - it stays with the participant
        setState(() {
          // Do not reset _selectedDate/_selectedTime to preserve manually set timestamp in UI
          _hasUnsavedChanges = false; // Reset unsaved changes flag
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Záznam úrazu byl úspěšně uložen do deníku!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Nepodařilo se uložit záznam úrazu: $e')),
          );
        }
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _cancelAndReturn() {
    Navigator.of(context).pop(false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nový záznam úrazu'),
        // Removed disabled edit button and placeholder info button for cleaner interface
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            bottom: AppSpacing.xl,
          ),
          child: NewRecordActionButtons(
            isCompact: AppBreakpoints.isCompactHeight(
              MediaQuery.sizeOf(context).height,
            ),
            isNarrow:
                AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width),
            isSaving: _isSaving,
            onSave: _saveRecord,
            onCancel: _cancelAndReturn,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _updateMeasuredHeights());

          // Use centralized breakpoint instead of magic number.
          // See AppBreakpoints for all responsive thresholds.
          final isCompact =
              AppBreakpoints.isCompactHeight(constraints.maxHeight);
          final isNarrow = AppBreakpoints.isMobile(constraints.maxWidth);
          final spacing = isCompact
              ? NewRecordLayoutConfig.spacingCompact
              : NewRecordLayoutConfig.spacingRegular;

          final estimatedHistoryHeaderHeight = isCompact
              ? (AppSpacing.m + AppSpacing.s)
              : (AppSpacing.l + AppSpacing.s);
          final historyHeaderHeight =
              _historyHeaderHeight ?? estimatedHistoryHeaderHeight;

          final scrollMetrics = NewRecordScrollStrategy.compute(
            context: context,
            constraints: constraints,
            spacing: spacing,
            historyHeaderHeight: historyHeaderHeight,
            recordCount: _recordCount,
            headerHeight: _headerHeight,
            formHeight: _formHeight,
            isNarrow: isNarrow,
            isCompactHeight: isCompact,
          );

          if (NewRecordLayoutConfig.enableLayoutDiagnostics) {
            AppLogger.l.i(
              'NewRecord layout: maxH=${constraints.maxHeight.toStringAsFixed(1)} '
              'header=${_headerHeight?.toStringAsFixed(1)} '
              'form=${_formHeight?.toStringAsFixed(1)} '
              'minHistory=${scrollMetrics.minHistoryHeight.toStringAsFixed(1)} '
              'maxHistory=${scrollMetrics.maxHistoryHeight.toStringAsFixed(1)} '
              'usePageScroll=${scrollMetrics.shouldUsePageScroll}',
            );
          }

          final participantSubtitle = _selectedParticipant != null
              ? '${_selectedParticipant!.jmeno} ${_selectedParticipant!.prijmeni}${_formatAge()}'
              : 'Vyberte účastníka...';
          return NewRecordBodyLayout(
            isCompact: isCompact,
            isNarrow: isNarrow,
            spacing: spacing,
            scrollMetrics: scrollMetrics,
            participantSubtitle: participantSubtitle,
            hasParticipant: _selectedParticipant != null,
            hasUnsavedChanges: _hasUnsavedChanges,
            showBirthdateInfo: _selectedParticipant?.datumNarozeni != null,
            isParticipantSelected: _selectedParticipant != null,
            availableParticipants: _availableParticipants,
            omezeniList: _omezeniList,
            lekyList: _lekyList,
            selectedParticipant: _selectedParticipant,
            recordCount: _recordCount,
            refreshCounter: _refreshCounter,
            headerKey: _headerKey,
            historyHeaderKey: _historyHeaderKey,
            formContainerKey: _formContainerKey,
            formKey: _formKey,
            titleController: _titleController,
            descriptionController: _descriptionController,
            poznamkaController: _poznamkaController,
            dateTimeLabel: NewRecordDateTimeHelper.formatSelectedDateTime(
              selectedDate: _selectedDate,
              selectedTime: _selectedTime,
            ),
            onSelectDateTime:
                _selectedParticipant != null ? _selectDateTime : null,
            showDateTimeReset: _selectedDate != null || _selectedTime != null,
            onResetDateTime: () {
              setState(() {
                _selectedDate = null;
                _selectedTime = null;
              });
            },
            onPrintFull: _canPrint() ? _printFullRecord : null,
            onPrintAppend: _canPrint() ? _printAppendRecord : null,
            zpusobilostButton:
                _selectedParticipant != null ? _buildZpusobilostButton() : null,
            onShowPoznamka: () => NewRecordPageDialogs.showPoznamkaBottomSheet(
              context: context,
              poznamkaController: _poznamkaController,
            ),
            titleValidator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Prosím zadejte nadpis';
              }
              if (value.length > 200) {
                return 'Nadpis nesmí být delší než 200 znaků';
              }
              return null;
            },
            descriptionValidator: (value) {
              if (value != null && value.length > 1024) {
                return 'Popis nesmí být delší než 1024 znaků';
              }
              return null;
            },
            onRefresh: _onRefresh,
            onParticipantSelected: _onParticipantSelected,
            onBirthdateInfo: () {
              final birthDate = _selectedParticipant?.datumNarozeni;
              if (birthDate == null) return;
              NewRecordPageDialogs.showBirthdateInfo(
                context: context,
                birthDate: birthDate,
              );
            },
            onRecordsLoaded: (count) {
              if (mounted && _recordCount != count) {
                setState(() => _recordCount = count);
              }
            },
          );
        },
      ), // Close LayoutBuilder
    ); // Close Scaffold
  }

}
