import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_omezeni.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_lek.dart';
import 'package:denik_zza/screens2/services/record_service.dart';
import 'package:denik_zza/screens2/widgets/record_list_widget.dart';
import 'package:denik_zza/screens2/widgets/person_autocomplete.dart';
import 'package:denik_zza/screens2/widgets/dev_mock_data_badge.dart';
import 'package:denik_zza/screens2/widgets/file_viewer_screen_widget.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/print_ops2/print_center.dart';
import 'package:denik_zza/print_ops2/print_center_controller.dart';
import 'package:denik_zza/print_ops2/print_center_service.dart';
import 'package:intl/intl.dart';

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

  bool _isSaving = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _refreshCounter = 0; // For forcing widget refresh
  MemoryOsoba? _selectedParticipant;
  bool _hasUnsavedChanges = false;
  List<MemoryOsoba> _availableParticipants = [];

  // Health info loaded separately
  List<MemoryOmezeni> _omezeniList = [];
  List<MemoryLek> _lekyList = [];
  bool _healthInfoExpanded = false; // Controls whether to show all health items

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
      setState(() {
        _availableParticipants = participants;
      });
    } catch (e) {
      // Handle error silently or show a message
      print('Error loading participants: $e');
    }
  }

  void _onParticipantSelected(MemoryOsoba participant) async {
    // Guard against accidental data override
    if (_selectedParticipant != null && _hasUnsavedChanges) {
      final confirmed = await _confirmParticipantChange();
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

      setState(() {
        _omezeniList = omezeni;
        _lekyList = leky;
      });
    } catch (e) {
      // Silent fail - health info is optional
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

  /// Builds health info row with responsive collapse logic
  Widget _buildHealthInfoRow() {
    // Filter omezeni by type: 1=omezeni, 2=alergie
    final alergieList = _omezeniList.where((o) => o.typOmezeni == 2).toList();
    final omezeniList = _omezeniList.where((o) => o.typOmezeni == 1).toList();

    if (alergieList.isEmpty && omezeniList.isEmpty && _lekyList.isEmpty) {
      return const SizedBox.shrink(); // No health info to show
    }

    // Build all health chip widgets
    final allHealthChips = <Widget>[
      // Alergie
      for (var alergie in alergieList)
        _buildHealthChip(
          icon: Icons.warning_amber,
          iconColor: Colors.red,
          backgroundColor: Colors.red.shade50,
          text: alergie.omezeni,
          maxChars: 30,
        ),
      // Omezení
      for (var omezeni in omezeniList)
        _buildHealthChip(
          icon: Icons.block,
          iconColor: Colors.orange,
          backgroundColor: Colors.orange.shade50,
          text: omezeni.omezeni,
          maxChars: 30,
        ),
      // Léky
      for (var lek in _lekyList)
        _buildHealthChip(
          icon: Icons.medication,
          iconColor: Colors.blue,
          backgroundColor: Colors.blue.shade50,
          text: lek.nazev,
          maxChars: 30,
        ),
    ];

    // Responsive collapse: adapt threshold to screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final maxCollapsedItems =
        screenWidth < 600 ? 4 : (screenWidth < 900 ? 6 : 8);
    final totalItems = allHealthChips.length;
    final shouldShowCollapseButton = totalItems > maxCollapsedItems;
    final visibleChips = (_healthInfoExpanded || !shouldShowCollapseButton)
        ? allHealthChips
        : allHealthChips.take(maxCollapsedItems).toList();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        ...visibleChips,
        // Compact collapse button (only if more than 6 items)
        if (shouldShowCollapseButton)
          _buildCompactCollapseButton(
            hiddenCount: totalItems - maxCollapsedItems,
          ),
      ],
    );
  }

  /// Builds compact collapse/expand button for health info
  Widget _buildCompactCollapseButton({required int hiddenCount}) {
    return InkWell(
      key: const Key('NewRecordPage_health_info_toggle'),
      onTap: () {
        setState(() {
          _healthInfoExpanded = !_healthInfoExpanded;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _healthInfoExpanded ? Icons.expand_less : Icons.more_horiz,
              size: 14,
              color: Colors.grey.shade700,
            ),
            if (!_healthInfoExpanded) ...[
              const SizedBox(width: 2),
              Text(
                '+$hiddenCount',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds a health info chip with truncation
  Widget _buildHealthChip({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String text,
    required int maxChars,
  }) {
    final truncated = text.length > maxChars;
    final displayText = truncated ? '${text.substring(0, maxChars)}...' : text;

    return InkWell(
      onTap: truncated
          ? () => _showHealthDetailOverlay(text, icon, iconColor)
          : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                displayText,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows overlay with full health info text
  void _showHealthDetailOverlay(
      String fullText, IconData icon, Color iconColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                fullText,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zavřít'),
          ),
        ],
      ),
    );
  }

  /// Shows full birthdate information in a dialog
  void _showBirthdateInfo() {
    if (_selectedParticipant?.datumNarozeni == null) return;

    final birthDate = _selectedParticipant!.datumNarozeni!;
    final formatted = DateFormat('d. MMMM yyyy', 'cs_CZ').format(birthDate);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Datum narození'),
        content: Text(
          formatted,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            key: const Key('NewRecordPage_birthdate_dialog_close'),
            onPressed: () => Navigator.pop(context),
            child: const Text('Zavřít'),
          ),
        ],
      ),
    );
  }

  /// Opens file viewer for způsobilost document
  void _showZpusobilostDocument() {
    if (_selectedParticipant?.potvrzeniPath == null ||
        _selectedParticipant!.potvrzeniPath!.isEmpty) {
      // Show error if no document path
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Chybí dokument'),
          content: const Text(
              'Pro tohoto účastníka není k dispozici dokument způsobilosti.'),
          actions: [
            TextButton(
              key: const Key('NewRecordPage_zpusobilost_missing_close'),
              onPressed: () => Navigator.pop(context),
              child: const Text('Zavřít'),
            ),
          ],
        ),
      );
      return;
    }

    // Navigate to file viewer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FileViewerScreen(
          initialFilePath: _selectedParticipant!.potvrzeniPath!,
        ),
      ),
    );
  }

  /// Builds a print icon button with consistent styling
  Widget _buildPrintIconButton({
    required Key key,
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        key: key,
        icon: Icon(icon),
        iconSize: 20,
        onPressed: onPressed,
        color: onPressed != null ? Colors.blue.shade700 : Colors.grey.shade400,
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(8),
          minimumSize: const Size(36, 36),
          backgroundColor:
              onPressed != null ? Colors.blue.shade50 : Colors.grey.shade100,
        ),
      ),
    );
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
        onPressed: hasDocument ? _showZpusobilostDocument : null,
        color: hasDocument ? Colors.green.shade700 : Colors.grey.shade400,
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(8),
          minimumSize: const Size(36, 36),
          backgroundColor:
              hasDocument ? Colors.green.shade50 : Colors.grey.shade100,
        ),
      ),
    );
  }

  /// Check if printing is available (participant must be selected)
  bool _canPrint() {
    return _selectedParticipant != null;
  }

  /// Print full record (navigate to PrintCenter with full mode)
  Future<void> _printFullRecord() async {
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
            initialMode: PrintMode.full,
          ),
        ),
      ),
    );
  }

  /// Print append mode (navigate to PrintCenter with append mode)
  Future<void> _printAppendRecord() async {
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
            initialMode: PrintMode.append,
          ),
        ),
      ),
    );
  }

  /// Combined date and time picker (better UX than separate pickers)
  Future<void> _selectDateTime() async {
    // First, show TIME picker (more important for injury records)
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      // If time was selected, then show date picker
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (pickedDate != null) {
        // Both time and date selected
        setState(() {
          _selectedTime = pickedTime;
          _selectedDate = pickedDate;
        });
      } else {
        // Only time selected, use current date
        setState(() {
          _selectedTime = pickedTime;
          _selectedDate = null; // Will use current date when saving
        });
      }
    }
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

  /// Get the final DateTime for the record
  DateTime _getFinalDateTime() {
    if (_selectedDate != null && _selectedTime != null) {
      return DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    } else if (_selectedDate != null) {
      return _selectedDate!;
    } else {
      return DateTime.now();
    }
  }

  /// Format selected date and time for display in combined picker
  String _formatSelectedDateTime() {
    if (_selectedDate == null && _selectedTime == null) {
      return 'Datum a čas (aktuální)';
    }

    String datePart = _selectedDate == null
        ? 'Dnes'
        : '${_selectedDate!.day.toString().padLeft(2, '0')}.${_selectedDate!.month.toString().padLeft(2, '0')}.${_selectedDate!.year}';

    String timePart = _selectedTime == null
        ? 'aktuální čas'
        : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

    return '$datePart, $timePart';
  }

  Future<void> _saveRecord() async {
    if (_selectedParticipant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nejprve vyberte účastníka'),
          backgroundColor: Colors.orange,
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

      final newRecord = MemoryZaznam.oldUI(
        nazev: _titleController.text.trim(),
        popis: _descriptionController.text.trim(),
        idPacient: _selectedParticipant!.id,
        idZaznamu: -1, // DB will assign ID
        casZaznamu: _getFinalDateTime(),
        isPrinted: false,
        idAuthor: 1, // Assuming a logged-in user with ID 1
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

  Future<bool?> _confirmParticipantChange() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Změnit účastníka?'),
          content: const Text(
              'Změnou účastníka se ztratí neuložené změny v formuláři. '
              'Chcete pokračovat?'),
          actions: [
            TextButton(
              key: const Key('dialog_cancel_button'),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Zrušit'),
            ),
            FilledButton(
              key: const Key('dialog_confirm_button'),
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('Změnit účastníka'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nový záznam úrazu'),
        // Removed disabled edit button and placeholder info button for cleaner interface
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Adjust spacing and layout based on available height
          final isCompact = constraints.maxHeight <= 600;
          final spacing = isCompact ? 8.0 : 12.0; // Increased spacing
          final titleSpacing = isCompact ? 8.0 : 12.0; // Increased spacing

          return Padding(
            padding: const EdgeInsets.all(
                20.0), // Increased from 16.0 for better breathing room
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Compact horizontal participant selection with inline search
                Container(
                  padding: const EdgeInsets.all(16.0), // Increased padding
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.blue.shade50,
                        Colors.blue.shade50.withValues(alpha: 0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12.0), // More rounded
                    border: Border.all(color: Colors.blue.shade200, width: 1),
                  ),
                  child: Row(
                    children: [
                      // Participant icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          _selectedParticipant != null
                              ? Icons.person
                              : Icons.person_search,
                          color: Colors.blue.shade700,
                          size: isCompact ? 18 : 20,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Participant info (takes most space)
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Účastník',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: isCompact ? 12 : 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Dev warning: Mock data badge (reusable widget)
                                const DevMockDataBadge(),
                                const SizedBox(width: 8),
                                // Unsaved changes warning badge
                                if (_hasUnsavedChanges)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.orange.shade300,
                                          width: 1),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.warning_amber,
                                          size: 10,
                                          color: Colors.orange.shade600,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          'Neuloženo',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.orange.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    _selectedParticipant != null
                                        ? '${_selectedParticipant!.jmeno} ${_selectedParticipant!.prijmeni}${_formatAge()}'
                                        : 'Vyberte účastníka...',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: isCompact
                                          ? 14
                                          : 15, // Reduced from 15-16 for compactness
                                      fontWeight: FontWeight.bold,
                                      color: _selectedParticipant != null
                                          ? Colors.black87
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                // Info icon to show full birthdate on tap
                                if (_selectedParticipant?.datumNarozeni !=
                                    null) ...[
                                  const SizedBox(width: 4),
                                  InkWell(
                                    key: const Key(
                                        'NewRecordPage_birthdate_info_icon'),
                                    onTap: _showBirthdateInfo,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: Icon(
                                        Icons.info_outline,
                                        size: 14,
                                        color: Colors.blue.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            // Health info (alergie, omezení, léky) - shows first 6 items by default, expandable
                            if (_selectedParticipant != null) ...[
                              const SizedBox(height: 4),
                              _buildHealthInfoRow(),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Inline search (compact on the right)
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colors.blue.shade600,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Vyhledat osobu',
                                    style: TextStyle(
                                      fontSize: isCompact ? 11 : 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            PersonAutocomplete(
                              key: const Key(
                                  'NewRecordPage_participantAutocomplete'),
                              onPersonSelected: _onParticipantSelected,
                              onRefresh: _onRefresh,
                              availablePersons: _availableParticipants,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: spacing),

                // Display existing records (compact)
                Expanded(
                  flex:
                      isCompact ? 1 : 2, // Reduced to take less vertical space
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: Column(
                      children: [
                        // Header for records list (compact)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(7.0),
                              topRight: Radius.circular(7.0),
                            ),
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.history,
                                color: Colors.grey.shade600,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Historie úrazů',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Records list content
                        Expanded(
                          child: _selectedParticipant != null
                              ? RecordListWidget(
                                  key: ValueKey(_refreshCounter),
                                  participant: _selectedParticipant!,
                                )
                              : Container(
                                  alignment: Alignment.center,
                                  child: SingleChildScrollView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.person_search,
                                          size:
                                              24, // Reduced for test compatibility
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(
                                            height:
                                                4), // Reduced for test compatibility
                                        Text(
                                          'Nejprve vyberte účastníka',
                                          style: TextStyle(
                                            fontSize:
                                                12, // Reduced for test compatibility
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(
                                            height:
                                                2), // Reduced for test compatibility
                                        Text(
                                          'Po výběru účastníka se zde zobrazí\njejí historie úrazů',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize:
                                                10, // Reduced for test compatibility
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: spacing),

                // Form for new record (main focus)
                Expanded(
                  flex: isCompact ? 5 : 7, // More space for form (main focus)
                  child: Opacity(
                    opacity: _selectedParticipant != null ? 1.0 : 0.4,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Make form fields scrollable but keep action buttons pinned
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Date/time section with action buttons - datetime in blue box, buttons at far right
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Blue box wraps ONLY the datetime section (tight fit)
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.all(16.0),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50
                                                .withValues(alpha: 0.3),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            border: Border.all(
                                                color: Colors.blue.shade200
                                                    .withValues(alpha: 0.5),
                                                width: 1),
                                          ),
                                          child: InkWell(
                                            key: const Key(
                                                'datetime_change_button'),
                                            onTap: _selectedParticipant != null
                                                ? _selectDateTime
                                                : null,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  child: Icon(
                                                    Icons.schedule,
                                                    color: Colors.blue.shade700,
                                                    size: isCompact ? 16 : 18,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Flexible(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Čas záznamu',
                                                        style: TextStyle(
                                                          fontSize: isCompact
                                                              ? 12
                                                              : 13,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors
                                                              .blue.shade700,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Flexible(
                                                            child: Text(
                                                              _formatSelectedDateTime(),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                fontSize:
                                                                    isCompact
                                                                        ? 14
                                                                        : 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                height:
                                                                    1.2, // Prevent text clipping
                                                                color: _selectedParticipant !=
                                                                        null
                                                                    ? Colors
                                                                        .black87
                                                                    : Colors
                                                                        .grey
                                                                        .shade400,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          Icon(
                                                            Icons.edit_outlined,
                                                            size: 16,
                                                            color: _selectedParticipant !=
                                                                    null
                                                                ? Colors.blue
                                                                    .shade700
                                                                : Colors.grey
                                                                    .shade400,
                                                          ),
                                                          // Only show reset button if datetime was modified
                                                          if (_selectedDate !=
                                                                  null ||
                                                              _selectedTime !=
                                                                  null) ...[
                                                            const SizedBox(
                                                                width: 6),
                                                            InkWell(
                                                              key: const Key(
                                                                  'datetime_reset_button'),
                                                              onTap:
                                                                  _selectedParticipant !=
                                                                          null
                                                                      ? () {
                                                                          setState(
                                                                              () {
                                                                            _selectedDate =
                                                                                null;
                                                                            _selectedTime =
                                                                                null;
                                                                          });
                                                                        }
                                                                      : null,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                              child: Tooltip(
                                                                message:
                                                                    'Reset na aktuální čas',
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          2),
                                                                  child: Icon(
                                                                    Icons
                                                                        .refresh,
                                                                    size: 16,
                                                                    color: _selectedParticipant !=
                                                                            null
                                                                        ? Colors
                                                                            .blue
                                                                            .shade700
                                                                        : Colors
                                                                            .grey
                                                                            .shade400,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Group all action buttons together on the right
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _buildPrintIconButton(
                                            key: const Key(
                                                'NewRecordPage_print_full_button'),
                                            icon: Icons.print,
                                            tooltip: 'Tisknout záznam',
                                            onPressed: _canPrint()
                                                ? _printFullRecord
                                                : null,
                                          ),
                                          const SizedBox(width: 4),
                                          _buildPrintIconButton(
                                            key: const Key(
                                                'NewRecordPage_print_append_button'),
                                            icon: Icons.add_to_photos,
                                            tooltip:
                                                'Přitisknout k existujícímu',
                                            onPressed: _canPrint()
                                                ? _printAppendRecord
                                                : null,
                                          ),
                                          // Způsobilost document button (far right)
                                          if (_selectedParticipant != null) ...[
                                            const SizedBox(width: 4),
                                            _buildZpusobilostButton(),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: titleSpacing),

                                  // Title field
                                  TextFormField(
                                    key: const Key('title_field'),
                                    controller: _titleController,
                                    enabled: _selectedParticipant != null,
                                    maxLines: 1,
                                    maxLength: 200,
                                    style: TextStyle(
                                      fontSize: isCompact ? 14 : 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Nadpis * (povinné)',
                                      labelStyle: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      hintText: _selectedParticipant != null
                                          ? 'Povinné - typ úrazu nebo stížnosti (např. "Odřenina kolena", "Bolest hlavy")'
                                          : 'Vyberte účastníka pro pokračování',
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: BorderSide(
                                            color: Colors.blue.shade200),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: BorderSide(
                                            color: Colors.blue.shade200),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: BorderSide(
                                            color: Colors.blue.shade600,
                                            width: 2),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: const BorderSide(
                                            color: Colors.red, width: 2),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: isCompact ? 12 : 16,
                                          vertical: isCompact ? 8 : 12),
                                      prefixIcon: Container(
                                        margin: const EdgeInsets.all(8.0),
                                        padding: const EdgeInsets.all(6.0),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Icon(
                                          Icons.title,
                                          color: Colors.blue.shade700,
                                          size: isCompact ? 16 : 18,
                                        ),
                                      ),
                                      errorMaxLines: 1,
                                      errorStyle: const TextStyle(
                                          fontSize: 11, height: 0.8),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Prosím zadejte nadpis';
                                      }
                                      if (value.length > 200) {
                                        return 'Nadpis nesmí být delší než 200 znaků';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: titleSpacing),

                                  // Description and Note side-by-side
                                  SizedBox(
                                    height: isCompact ? 90 : 120,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Description field (main focus - wider)
                                        Expanded(
                                          flex: 4,
                                          child: TextFormField(
                                            key: const Key('description_field'),
                                            controller: _descriptionController,
                                            enabled:
                                                _selectedParticipant != null,
                                            maxLines: null,
                                            minLines: null,
                                            maxLength: 1024,
                                            expands: true,
                                            textAlignVertical:
                                                TextAlignVertical.top,
                                            style: TextStyle(
                                              fontSize: isCompact ? 13 : 14,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black87,
                                              height: 1.4,
                                            ),
                                            decoration: InputDecoration(
                                              labelText:
                                                  'Popis úrazu a ošetření',
                                              labelStyle: TextStyle(
                                                color: Colors.blue.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              hintText:
                                                  'Co se stalo, jak k úrazu došlo, jaké ošetření bylo poskytnuto...',
                                              hintStyle: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontStyle: FontStyle.italic,
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.blue.shade200),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.blue.shade200),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                borderSide: BorderSide(
                                                    color: Colors.blue.shade600,
                                                    width: 2),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                borderSide: const BorderSide(
                                                    color: Colors.red,
                                                    width: 2),
                                              ),
                                              contentPadding: EdgeInsets.all(
                                                  isCompact ? 12 : 16),
                                              alignLabelWithHint: true,
                                              counterStyle: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 11,
                                              ),
                                              errorMaxLines: 1,
                                              errorStyle: const TextStyle(
                                                  fontSize: 11, height: 0.8),
                                            ),
                                            validator: (value) {
                                              if (value != null &&
                                                  value.length > 1024) {
                                                return 'Popis nesmí být delší než 1024 znaků';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),

                                        const SizedBox(width: 12),

                                        // Poznámka field (side note - narrower, sticky note style)
                                        Expanded(
                                          flex: 1,
                                          child: TextFormField(
                                            key: const Key('poznamka_field'),
                                            controller: _poznamkaController,
                                            enabled:
                                                _selectedParticipant != null,
                                            maxLines: null,
                                            minLines: null,
                                            expands: true,
                                            textAlignVertical:
                                                TextAlignVertical.top,
                                            style: TextStyle(
                                              fontSize: isCompact ? 11 : 12,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black87,
                                              height: 1.3,
                                            ),
                                            decoration: InputDecoration(
                                              labelText: 'Poznámka',
                                              labelStyle: TextStyle(
                                                color: Colors.amber.shade800,
                                                fontWeight: FontWeight.w600,
                                                fontSize: isCompact ? 11 : 12,
                                              ),
                                              hintText: 'Alergie, léky...',
                                              hintStyle: TextStyle(
                                                color: Colors.amber.shade700,
                                                fontStyle: FontStyle.italic,
                                                fontSize: 11,
                                              ),
                                              filled: true,
                                              fillColor: Colors.yellow.shade50,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6.0),
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.amber.shade300,
                                                    width: 1.5),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6.0),
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.amber.shade300,
                                                    width: 1.5),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6.0),
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.amber.shade600,
                                                    width: 2),
                                              ),
                                              contentPadding: EdgeInsets.all(
                                                  isCompact ? 8 : 10),
                                              alignLabelWithHint: true,
                                              helperText: 'Netiskne se',
                                              helperStyle: TextStyle(
                                                color: Colors.amber.shade700,
                                                fontSize: 9,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Action buttons (enhanced professional styling) pinned at bottom
                          Container(
                            padding:
                                const EdgeInsets.all(16.0), // Increased padding
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius:
                                  BorderRadius.circular(12.0), // More rounded
                              border: Border.all(
                                  color: Colors.grey.shade200, width: 1),
                            ),
                            child: Row(
                              children: [
                                // Save button (primary action)
                                Expanded(
                                  flex: 3,
                                  child: FilledButton.icon(
                                    key: const Key('save_button'),
                                    onPressed: _isSaving ? null : _saveRecord,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.blue.shade600,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        vertical: isCompact
                                            ? 12
                                            : 14, // Better button height
                                        horizontal: isCompact ? 16 : 20,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      elevation: 2,
                                    ),
                                    icon: _isSaving
                                        ? SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )
                                        : Icon(
                                            Icons.save,
                                            size: isCompact ? 16 : 18,
                                          ),
                                    label: Text(
                                      _isSaving
                                          ? 'Ukládání...'
                                          : 'Uložit do deníku',
                                      style: TextStyle(
                                        fontSize: isCompact ? 13 : 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 16), // Increased spacing

                                // Cancel button (secondary action)
                                Expanded(
                                  flex: 2,
                                  child: OutlinedButton.icon(
                                    key: const Key('cancel_button'),
                                    onPressed:
                                        _isSaving ? null : _cancelAndReturn,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.grey.shade700,
                                      side: BorderSide(
                                          color: Colors.grey.shade400,
                                          width: 1.5),
                                      padding: EdgeInsets.symmetric(
                                        vertical: isCompact
                                            ? 12
                                            : 14, // Match save button height
                                        horizontal: isCompact ? 12 : 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    icon: Icon(
                                      Icons.close,
                                      size: isCompact ? 16 : 18,
                                    ),
                                    label: Text(
                                      'Zavřít',
                                      style: TextStyle(
                                        fontSize: isCompact ? 13 : 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ], // Close Column (Form child)
                      ), // Close Form Column widget
                    ), // Close Form widget
                  ), // Close Opacity widget
                ), // Close Expanded widget (form section)
              ],
            ), // Close outer Column
          ); // Close Padding and return
        },
      ), // Close LayoutBuilder
    ); // Close Scaffold
  }
}
