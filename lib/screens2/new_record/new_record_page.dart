import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_lek.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_omezeni.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:denik_zza/design_system/tokens/app_breakpoints.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_layout.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/print_ops2/print_center.dart';
import 'package:denik_zza/print_ops2/print_center_controller.dart';
import 'package:denik_zza/print_ops2/print_center_service.dart';
import 'package:denik_zza/screens2/new_record/widgets/new_record_action_buttons.dart';
import 'package:denik_zza/screens2/new_record/widgets/new_record_history_section.dart';
import 'package:denik_zza/screens2/services/record_service.dart';
import 'package:denik_zza/screens2/widgets/app_drawer.dart';
import 'package:denik_zza/screens2/widgets/file_viewer_screen_widget.dart';
import 'package:denik_zza/screens2/widgets/person_autocomplete.dart';
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
  bool _healthInfoExpanded = false; // Controls whether to show all health items
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
  /// Shows compact badges on mobile/compact, full chips on desktop
  Widget _buildHealthInfoRow({required bool isCompact}) {
    // Filter omezeni by type: 1=omezeni, 2=alergie
    final alergieList = _omezeniList.where((o) => o.typOmezeni == 2).toList();
    final omezeniList = _omezeniList.where((o) => o.typOmezeni == 1).toList();

    if (alergieList.isEmpty && omezeniList.isEmpty && _lekyList.isEmpty) {
      // All clear indicator
      return _buildHealthAllClearIndicator();
    }

    // Use compact badges on mobile or compact height mode
    final screenWidth = MediaQuery.of(context).size.width;
    final useCompactBadges = isCompact || AppBreakpoints.isMobile(screenWidth);

    if (useCompactBadges) {
      return _buildCompactHealthBadges(
        criticalCount: alergieList.length + omezeniList.length,
        medCount: _lekyList.length,
      );
    }

    // Build all health chip widgets (desktop view)
    final allHealthChips = <Widget>[
      // Alergie
      for (var alergie in alergieList)
        _buildHealthChip(
          icon: Icons.warning_amber,
          iconColor: Theme.of(context).colorScheme.error,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          text: alergie.omezeni,
          maxChars: 30,
        ),
      // Omezení
      for (var omezeni in omezeniList)
        _buildHealthChip(
          icon: Icons.block,
          iconColor: Theme.of(context).colorScheme.secondary,
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          text: omezeni.omezeni,
          maxChars: 30,
        ),
      // Léky
      for (var lek in _lekyList)
        _buildHealthChip(
          icon: Icons.medication,
          iconColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          text: lek.nazev,
          maxChars: 30,
        ),
    ];

    // Responsive collapse: adapt threshold to screen size
    final maxCollapsedItems = screenWidth < 900 ? 6 : 8;
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
        // Compact collapse button (only if more than threshold items)
        if (shouldShowCollapseButton)
          _buildCompactCollapseButton(
            hiddenCount: totalItems - maxCollapsedItems,
          ),
      ],
    );
  }

  /// Green checkmark indicator when participant has no health restrictions
  Widget _buildHealthAllClearIndicator() {
    return Container(
      key: const Key('NewRecordPage_health_all_clear'),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.greenBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.greenBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14, color: AppColors.greenIcon),
          const SizedBox(width: 4),
          Text(
            'Bez omezení',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.greenText,
            ),
          ),
        ],
      ),
    );
  }

  /// Compact dual-zone badges for mobile view
  Widget _buildCompactHealthBadges({
    required int criticalCount,
    required int medCount,
  }) {
    return GestureDetector(
      key: const Key('NewRecordPage_health_badges'),
      onTap: () => _showHealthDetailsBottomSheet(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Critical items badge (allergies + restrictions)
          if (criticalCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber,
                    size: 12,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '$criticalCount',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          if (criticalCount > 0 && medCount > 0) const SizedBox(width: 4),
          // Medications badge
          if (medCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.medication,
                    size: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '$medCount',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 4),
          // Chevron to indicate tappable
          Icon(
            Icons.chevron_right,
            size: 16,
            color: AppColors.greyText,
          ),
        ],
      ),
    );
  }

  /// Shows full health details in a bottom sheet (mobile-friendly)
  void _showHealthDetailsBottomSheet() {
    final alergieList = _omezeniList.where((o) => o.typOmezeni == 2).toList();
    final omezeniList = _omezeniList.where((o) => o.typOmezeni == 1).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Zdravotní údaje',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greyIcon,
                ),
              ),
              const SizedBox(height: 16),
              // Allergies section
              if (alergieList.isNotEmpty) ...[
                _buildHealthSectionHeader(
                  icon: Icons.warning_amber,
                  iconColor: Theme.of(context).colorScheme.error,
                  label: 'Alergie',
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: alergieList.map((a) => _buildHealthChip(
                    icon: Icons.warning_amber,
                    iconColor: Theme.of(context).colorScheme.error,
                    backgroundColor: Theme.of(context).colorScheme.errorContainer,
                    text: a.omezeni,
                    maxChars: 50,
                  )).toList(),
                ),
                const SizedBox(height: 12),
              ],
              // Restrictions section
              if (omezeniList.isNotEmpty) ...[
                _buildHealthSectionHeader(
                  icon: Icons.block,
                  iconColor: Theme.of(context).colorScheme.secondary,
                  label: 'Omezení',
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: omezeniList.map((o) => _buildHealthChip(
                    icon: Icons.block,
                    iconColor: Theme.of(context).colorScheme.secondary,
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    text: o.omezeni,
                    maxChars: 50,
                  )).toList(),
                ),
                const SizedBox(height: 12),
              ],
              // Medications section
              if (_lekyList.isNotEmpty) ...[
                _buildHealthSectionHeader(
                  icon: Icons.medication,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: 'Léky',
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _lekyList.map((l) => _buildHealthChip(
                    icon: Icons.medication,
                    iconColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    text: l.nazev,
                    maxChars: 50,
                  )).toList(),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Section header for BottomSheet health categories
  Widget _buildHealthSectionHeader({
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.greyIcon,
          ),
        ),
      ],
    );
  }

  /// Shows poznámka (note) editing bottom sheet for mobile layout
  void _showPoznamkaBottomSheet() {
    // Create a temporary controller to allow cancel functionality
    final tempController = TextEditingController(text: _poznamkaController.text);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.yellow.shade50,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title with sticky note style
            Row(
              children: [
                Icon(Icons.sticky_note_2, size: 20, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                Text(
                  'Poznámka',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Interní poznámka - netiskne se na výstup',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: Colors.amber.shade600,
              ),
            ),
            const SizedBox(height: 12),
            // Text input
            TextField(
              key: const Key('NewRecordPage_poznamka_bottomsheet_input'),
              controller: tempController,
              autofocus: true,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Alergie, léky, interní poznámky...',
                hintStyle: TextStyle(
                  color: Colors.amber.shade400,
                  fontStyle: FontStyle.italic,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.amber.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.amber.shade600, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Zrušit',
                    style: TextStyle(color: Colors.amber.shade700),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    _poznamkaController.text = tempController.text;
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.amber.shade600,
                  ),
                  child: const Text('Uložit'),
                ),
              ],
            ),
          ],
        ),
      ),
    ).then((_) => tempController.dispose());
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
          color: AppColors.greyBackgroundMedium,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _healthInfoExpanded ? Icons.expand_less : Icons.more_horiz,
              size: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            if (!_healthInfoExpanded) ...[
              const SizedBox(width: 2),
              Text(
                '+$hiddenCount',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
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
        color: onPressed != null
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).disabledColor,
        // Removed styleFrom override to use theme styling
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
      // Guard against async gap before second picker
      if (!mounted) return;

      // If time was selected, then show date picker
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (!mounted) return; // Guard against async gap
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
        casZaznamu: _getFinalDateTime(),
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
                backgroundColor: AppColors.orangeBackground,
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
          final spacing = isCompact ? 12.0 : 24.0; // Increased spacing for better separation
          final titleSpacing = isCompact ? 12.0 : 16.0; // Increased spacing between form fields

          final estimatedHistoryHeaderHeight = isCompact
              ? (AppSpacing.m + AppSpacing.s)
              : (AppSpacing.l + AppSpacing.s);
          final historyHeaderHeight =
              _historyHeaderHeight ?? estimatedHistoryHeaderHeight;

          final minHistoryListHeight = AppBreakpoints.getListHeight(
            context,
            itemCount: 1,
            peekRatio: 0.35,
            dense: true,
          );
          final minHistoryHeight = historyHeaderHeight + minHistoryListHeight;

          final recordCountForHeight = math.max(_recordCount, 1);
          final fullListHeight = AppBreakpoints.getListHeight(
            context,
            itemCount: recordCountForHeight,
            peekRatio: 0.0,
            dense: true,
          );
          final fullHistoryHeight = historyHeaderHeight + fullListHeight;

          final maxItemsWhenScroll = constraints.maxHeight <=
                  AppBreakpoints.compactHeight * 0.6
              ? 2
              : constraints.maxHeight <= AppBreakpoints.compactHeight * 0.8
                  ? 3
                  : 5;
          final maxListHeightWhenScroll = AppBreakpoints.getListHeight(
            context,
            itemCount: maxItemsWhenScroll,
            peekRatio: 0.0,
            dense: true,
          );
          final maxHistoryHeightWhenScroll =
              historyHeaderHeight + maxListHeightWhenScroll;

          final availableHeightForHistory = constraints.maxHeight -
              (_headerHeight ?? 0) -
              (_formHeight ?? 0) -
              (spacing * 2);

          final hasMeasuredHeights =
              _headerHeight != null && _formHeight != null;

          final effectiveAvailableHeight = hasMeasuredHeights
              ? (availableHeightForHistory.isFinite
                  ? availableHeightForHistory
                  : fullListHeight)
              : maxListHeightWhenScroll;

          final fitsWithoutPageScroll =
              fullHistoryHeight <= effectiveAvailableHeight;

          final targetHistoryMaxHeight = fitsWithoutPageScroll
              ? fullHistoryHeight
              : maxHistoryHeightWhenScroll;

          final cappedMaxHeight = effectiveAvailableHeight.isFinite
              ? math.min(targetHistoryMaxHeight, effectiveAvailableHeight)
              : targetHistoryMaxHeight;

          final historyMaxHeight =
              math.max(minHistoryHeight, cappedMaxHeight);

          final requiredMinHeight = (_headerHeight ?? 0) +
              (_formHeight ?? 0) +
              minHistoryHeight +
              (spacing * 2);

          final shouldUsePageScroll =
              hasMeasuredHeights && requiredMinHeight > constraints.maxHeight;

          final historyHeightForScroll = math.max(
            minHistoryHeight,
            math.min(fullHistoryHeight, maxHistoryHeightWhenScroll),
          );

          Widget formFields = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title field with DateTime and action buttons - responsive layout
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title field takes remaining space using AppLayout flex
                  Expanded(
                    flex: AppLayout.inputFlex,
                    child: TextFormField(
                      key: const Key('NewRecordPage_title_input'),
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
                          color: AppColors.blueDark,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: _selectedParticipant != null
                            ? 'Povinné - typ úrazu nebo stížnosti (např. "Odřenina kolena", "Bolest hlavy")'
                            : 'Vyberte účastníka pro pokračování',
                        hintStyle: TextStyle(
                          color: AppColors.greyText,
                          fontStyle: FontStyle.italic,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: AppColors.blueBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: AppColors.blueBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              BorderSide(color: AppColors.blueText, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 12 : 16,
                            vertical: isCompact ? 8 : 12),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(8.0),
                          padding: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: AppColors.blueBackground,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.title,
                            color: AppColors.blueDark,
                            size: isCompact ? 16 : 18,
                          ),
                        ),
                        errorMaxLines: 1,
                        errorStyle:
                            const TextStyle(fontSize: 11, height: 0.8),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Prosím zadejte nadpis';
                        }
                        if (value.length > 200) {
                          return 'Nadpis nesmí být delší než 200 znaků';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: AppSpacing.s),
                  // DateTime Chip (merged into title row, after title)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: _buildDateTimeChip(isCompact: isCompact),
                  ),
                  SizedBox(width: AppSpacing.s),
                  // Action buttons - wrap when narrow (~33% width)
                  // Action buttons - min width to let title expand
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildPrintIconButton(
                          key: const Key('NewRecordPage_print_full_button'),
                          icon: Icons.print,
                          tooltip: 'Tisknout záznam',
                          onPressed: _canPrint() ? _printFullRecord : null,
                        ),
                        _buildPrintIconButton(
                          key: const Key('NewRecordPage_print_append_button'),
                          icon: Icons.add_to_photos,
                          tooltip: 'Přitisknout k existujícímu',
                          onPressed: _canPrint() ? _printAppendRecord : null,
                        ),
                        // Způsobilost document button
                        if (_selectedParticipant != null)
                          _buildZpusobilostButton(),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: titleSpacing),

              // Description and Note - responsive layout
              // Mobile: full-width description with floating poznámka icon
              // Desktop: side-by-side layout
              if (isCompact)
                // Mobile: Stack with description + floating note icon
                SizedBox(
                  height: 100,
                  child: Stack(
                    children: [
                      // Full-width description field
                      TextFormField(
                        key: const Key('NewRecordPage_description_input'),
                        controller: _descriptionController,
                        enabled: _selectedParticipant != null,
                        maxLines: null,
                        minLines: null,
                        maxLength: 1024,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Popis úrazu a ošetření',
                          labelStyle: TextStyle(
                            color: AppColors.blueDark,
                            fontWeight: FontWeight.w500,
                          ),
                          hintText: 'Co se stalo, jak k úrazu došlo...',
                          hintStyle: TextStyle(
                            color: AppColors.greyText,
                            fontStyle: FontStyle.italic,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: AppColors.blueBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: AppColors.blueBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide:
                                BorderSide(color: AppColors.blueText, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 2),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                          alignLabelWithHint: true,
                          counterStyle: TextStyle(
                            color: AppColors.greyText,
                            fontSize: 11,
                          ),
                          errorMaxLines: 1,
                          errorStyle:
                              const TextStyle(fontSize: 11, height: 0.8),
                        ),
                        validator: (value) {
                          if (value != null && value.length > 1024) {
                            return 'Popis nesmí být delší než 1024 znaků';
                          }
                          return null;
                        },
                      ),
                      // Floating poznámka icon (top-right)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Material(
                          color: Colors.yellow.shade100,
                          borderRadius: BorderRadius.circular(6),
                          child: InkWell(
                            key: const Key('NewRecordPage_poznamka_icon'),
                            onTap: _selectedParticipant != null
                                ? _showPoznamkaBottomSheet
                                : null,
                            borderRadius: BorderRadius.circular(6),
                            child: Tooltip(
                              message: _poznamkaController.text.isNotEmpty
                                  ? 'Poznámka: ${_poznamkaController.text}'
                                  : 'Přidat poznámku',
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.sticky_note_2,
                                      size: 16,
                                      color: Colors.amber.shade700,
                                    ),
                                    if (_poznamkaController.text.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.only(left: 4),
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: Colors.amber.shade600,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                // Desktop: side-by-side layout
                SizedBox(
                  height: 120,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description field (main focus - wider)
                      Expanded(
                        flex: 4,
                        child: TextFormField(
                          key: const Key('NewRecordPage_description_input'),
                          controller: _descriptionController,
                          enabled: _selectedParticipant != null,
                          maxLines: null,
                          minLines: null,
                          maxLength: 1024,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Popis úrazu a ošetření',
                            labelStyle: TextStyle(
                              color: AppColors.blueDark,
                              fontWeight: FontWeight.w500,
                            ),
                            hintText:
                                'Co se stalo, jak k úrazu došlo, jaké ošetření bylo poskytnuto...',
                            hintStyle: TextStyle(
                              color: AppColors.greyText,
                              fontStyle: FontStyle.italic,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide:
                                  BorderSide(color: AppColors.blueBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide:
                                  BorderSide(color: AppColors.blueBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide:
                                  BorderSide(color: AppColors.blueText, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide:
                                  const BorderSide(color: Colors.red, width: 2),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                            alignLabelWithHint: true,
                            counterStyle: TextStyle(
                              color: AppColors.greyText,
                              fontSize: 11,
                            ),
                            errorMaxLines: 1,
                            errorStyle:
                                const TextStyle(fontSize: 11, height: 0.8),
                          ),
                          validator: (value) {
                            if (value != null && value.length > 1024) {
                              return 'Popis nesmí být delší než 1024 znaků';
                            }
                            return null;
                          },
                        ),
                      ),

                      SizedBox(width: AppSpacing.m),

                      // Poznámka field (side note - narrower, sticky note style)
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          key: const Key('NewRecordPage_poznamka_input'),
                          controller: _poznamkaController,
                          enabled: _selectedParticipant != null,
                          maxLines: null,
                          minLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Poznámka',
                            labelStyle: TextStyle(
                              color: Colors.amber.shade800,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
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
                              borderRadius: BorderRadius.circular(6.0),
                              borderSide:
                                  BorderSide(color: Colors.amber.shade300, width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                              borderSide:
                                  BorderSide(color: Colors.amber.shade300, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                              borderSide:
                                  BorderSide(color: Colors.amber.shade600, width: 2),
                            ),
                            contentPadding: const EdgeInsets.all(10),
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
          );

          Widget formContent = shouldUsePageScroll
              ? formFields
              : SingleChildScrollView(child: formFields);

          Widget headerSection = Container(
            key: _headerKey,
            padding: AppSpacing.containerPadding, // 16px padding
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.5),
                ],
              ),
              borderRadius: AppRadii.containerRadius, // 12px rounded
              border: Border.all(
                  color: Theme.of(context).colorScheme.primary, width: 1),
            ),
            child: Row(
              children: [
                // Participant icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    _selectedParticipant != null
                        ? Icons.person
                        : Icons.person_search,
                    color: Theme.of(context).colorScheme.primary,
                    size: isCompact ? 18 : 20,
                  ),
                ),

                SizedBox(width: AppSpacing.m),

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
                                color: AppColors.blueText,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          const SizedBox(width: 8),
                          // Unsaved changes warning badge
                          if (_hasUnsavedChanges)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.orangeBackground,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: AppColors.orangeBorder, width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.warning_amber,
                                    size: 10,
                                    color: AppColors.orangeText,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Neuloženo',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.orangeText,
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
                                fontSize: isCompact ? 14 : 15,
                                fontWeight: FontWeight.bold,
                                color: _selectedParticipant != null
                                    ? AppColors.greyIcon
                                    : AppColors.greyText,
                              ),
                            ),
                          ),
                          // Info icon to show full birthdate on tap
                          if (_selectedParticipant?.datumNarozeni != null) ...[
                            const SizedBox(width: 4),
                            InkWell(
                              key: const Key(
                                  'NewRecordPage_birthdate_info_icon'),
                              onTap: _showBirthdateInfo,
                              borderRadius: AppRadii.containerRadius,
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Icon(
                                  Icons.info_outline,
                                  size: 14,
                                  color: AppColors.blueText,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      // Health info (alergie, omezení, léky) - adaptive display
                      if (_selectedParticipant != null) ...[
                        const SizedBox(height: 4),
                        _buildHealthInfoRow(isCompact: isCompact),
                      ],
                    ],
                  ),
                ),

                SizedBox(width: AppSpacing.m),

                // Inline search (compact on the right)
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 0),
                      SizedBox(height: isCompact ? 2 : 4),
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
          );

          Widget historySection = NewRecordHistorySection(
            isCompact: isCompact,
            recordCount: _recordCount,
            historyHeaderKey: _historyHeaderKey,
            selectedParticipant: _selectedParticipant,
            refreshCounter: _refreshCounter,
            onRecordsLoaded: (count) {
              if (mounted && _recordCount != count) {
                setState(() => _recordCount = count);
              }
            },
          );

          Widget historyBlock = shouldUsePageScroll
              ? SizedBox(
                  height: historyHeightForScroll,
                  child: historySection,
                )
              : Flexible(
                  fit: FlexFit.loose,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: minHistoryHeight,
                      maxHeight: historyMaxHeight,
                    ),
                    child: historySection,
                  ),
                );

          Widget formSection = SizedBox(
            key: _formContainerKey,
            child: Opacity(
              opacity: _selectedParticipant != null ? 1.0 : 0.4,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    formContent,
                  ],
                ),
              ),
            ),
          );

          Widget bodyContent = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              headerSection,
              SizedBox(height: spacing),
              historyBlock,
              SizedBox(height: spacing),
              formSection,
            ],
          );

          return Padding(
            padding: AppSpacing.screenPadding,
            child: shouldUsePageScroll
                ? SingleChildScrollView(child: bodyContent)
                : bodyContent,
          );
        },
      ), // Close LayoutBuilder
    ); // Close Scaffold
  }

  Widget _buildDateTimeChip({required bool isCompact}) {
    return Tooltip(
      message: 'Čas záznamu',
      child: InkWell(
        key: const Key('datetime_change_button'),
        onTap: _selectedParticipant != null ? _selectDateTime : null,
        borderRadius: AppRadii.containerRadius,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 8 : 10,
            vertical: isCompact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.blueBackground.withValues(alpha: 0.3),
            borderRadius: AppRadii.containerRadius,
            border: Border.all(
              color: AppColors.blueBorder.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule,
                color: AppColors.blueDark,
                size: isCompact ? 16 : 18,
              ),
              SizedBox(width: isCompact ? 4 : 6),
              Flexible(
                child: Text(
                  _formatSelectedDateTime(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isCompact ? 13 : 14,
                    fontWeight: FontWeight.w500,
                    color: _selectedParticipant != null
                        ? Colors.black87
                        : Colors.grey.shade400,
                  ),
                ),
              ),
              if (_selectedDate != null || _selectedTime != null) ...[
                const SizedBox(width: 4),
                InkWell(
                  key: const Key('datetime_reset_button'),
                  onTap: _selectedParticipant != null
                      ? () {
                          setState(() {
                            _selectedDate = null;
                            _selectedTime = null;
                          });
                        }
                      : null,
                  child: Icon(
                    Icons.refresh,
                    size: isCompact ? 14 : 16,
                    color: AppColors.blueDark,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
