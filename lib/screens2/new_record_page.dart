import 'package:flutter/material.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:denik_zza/screens2/services/record_service.dart';
import 'package:denik_zza/screens2/widgets/record_list_widget.dart';
import 'package:denik_zza/screens2/widgets/person_autocomplete.dart';
import 'package:denik_zza/database/database_wrapper.dart';

/// Enhanced new record page that matches the old system functionality
/// but with improved architecture and validation
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
  final _recordService = RecordService();

  bool _isSaving = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _refreshCounter = 0; // For forcing widget refresh
  MemoryOsoba? _selectedParticipant;
  bool _hasUnsavedChanges = false;
  List<MemoryOsoba> _availableParticipants = [];

  @override
  void initState() {
    super.initState();
    _selectedParticipant = widget.participant;
    
    // Track unsaved changes
    _titleController.addListener(_trackChanges);
    _descriptionController.addListener(_trackChanges);
    
    // Load available participants
    _loadAvailableParticipants();
    
    // If no participant provided, search interface will be shown automatically
  }

  void _trackChanges() {
    setState(() {
      _hasUnsavedChanges = _titleController.text.trim().isNotEmpty || 
                          _descriptionController.text.trim().isNotEmpty;
    });
  }

  Future<void> _loadAvailableParticipants() async {
    try {
  // Always resolve DB via the wrapper so tests/dev can inject memory DB
  final database = DatabaseWrapper.getDatabase();
  final participants = await database.watchParticipantsByCurrentEvent().first;
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
      
      // Only clear timestamp if there were unsaved changes
      // Preserve manually set timestamps when no unsaved changes exist
      if (_hasUnsavedChanges) {
        _selectedDate = null;
        _selectedTime = null;
      }
      
      // Reset unsaved changes flag since we're starting fresh with new participant
      _hasUnsavedChanges = false;
    });
  }

  void _onRefresh() {
    _loadAvailableParticipants();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Combined date and time picker (better UX than separate pickers)
  Future<void> _selectDateTime() async {
    // First, show date picker
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      // If date was selected, immediately show time picker
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime ?? TimeOfDay.now(),
      );

      if (pickedTime != null) {
        // Both date and time selected
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
        });
      } else {
        // Only date selected, use current time
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = null; // Will use current time when saving
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
        
        // Refresh the record list by triggering a rebuild
        setState(() {
          _refreshCounter++;
        });
        
        // Clear the form after successful save, but keep custom timestamp as tests expect it preserved
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          // Do not reset _selectedDate/_selectedTime to preserve manually set timestamp in UI
          _hasUnsavedChanges = false; // Reset unsaved changes flag
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Záznam úrazu byl úspěšně uložen do deníku!')),
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
            'Chcete pokračovat?'
          ),
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
            padding: const EdgeInsets.all(20.0), // Increased from 16.0 for better breathing room
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
                        Colors.blue.shade50.withOpacity(0.5),
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
                          _selectedParticipant != null ? Icons.person : Icons.person_search,
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
                                Text(
                                  'Účastník',
                                  style: TextStyle(
                                    fontSize: isCompact ? 12 : 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Unsaved changes warning badge
                                if (_hasUnsavedChanges)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.orange.shade300, width: 1),
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
                            Text(
                              _selectedParticipant != null
                                  ? '${_selectedParticipant!.jmeno} ${_selectedParticipant!.prijmeni}'
                                  : 'Vyberte účastníka...',
                              style: TextStyle(
                                fontSize: isCompact ? 15 : 16, 
                                fontWeight: FontWeight.bold,
                                color: _selectedParticipant != null ? Colors.black87 : Colors.grey.shade600,
                              ),
                            ),
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
                                    'Vyhledat',
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
                              key: const Key('NewRecordPage_participantAutocomplete'),
                              textFieldKey: const Key('NewRecordPage_participantSearchField'),
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
                
                // Display existing records (enhanced professional container styling)
                Expanded(
                  flex: 1, // Minimized to make room for form
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.grey.shade50,
                          Colors.white,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header for records list
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(
                                  Icons.history,
                                  color: Colors.grey.shade700,
                                  size: isCompact ? 14 : 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Historie úrazů',
                                style: TextStyle(
                                  fontSize: isCompact ? 12 : 13,
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
                                    physics: const NeverScrollableScrollPhysics(),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.person_search,
                                          size: 24, // Reduced for test compatibility
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 4), // Reduced for test compatibility
                                        Text(
                                          'Nejprve vyberte účastníka',
                                          style: TextStyle(
                                            fontSize: 12, // Reduced for test compatibility
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 2), // Reduced for test compatibility
                                        Text(
                                          'Po výběru účastníka se zde zobrazí\njejí historie úrazů',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10, // Reduced for test compatibility
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
                
                // Form for new record (prioritized input area)
                Expanded(
                  flex: isCompact ? 3 : 5, // Increased flex to accommodate better spacing
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
                        // Optional date and time selection (enhanced professional styling)
                        Container(
                          padding: const EdgeInsets.all(16.0), // Increased padding for better spacing
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12.0), // More rounded corners
                            border: Border.all(color: Colors.blue.shade200.withOpacity(0.5), width: 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8), // Increased padding
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.schedule,
                                  color: Colors.blue.shade700,
                                  size: isCompact ? 16 : 18, // Slightly larger icon
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Čas záznamu',
                                      style: TextStyle(
                                        fontSize: isCompact ? 12 : 13, // Slightly larger text
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 4), // Add some spacing
                                    Text(
                                      _formatSelectedDateTime(),
                                      style: TextStyle(
                                        fontSize: isCompact ? 14 : 15, // Larger display text
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              FilledButton.tonal(
                                key: const Key('datetime_change_button'),
                                onPressed: _selectedParticipant != null ? _selectDateTime : null,
                                style: FilledButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isCompact ? 12 : 16,
                                    vertical: isCompact ? 8 : 10, // Better vertical padding
                                  ),
                                  minimumSize: Size.zero,
                                  backgroundColor: Colors.blue.shade100,
                                  foregroundColor: Colors.blue.shade700,
                                ),
                                child: Text(
                                  'Změnit',
                                  style: TextStyle(
                                    fontSize: isCompact ? 12 : 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: titleSpacing),
                        
                        // Title field (enhanced professional styling)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade100.withOpacity(0.3),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: TextFormField(
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
                              labelText: 'Nadpis',
                              labelStyle: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                              hintText: _selectedParticipant != null 
                                  ? 'Typ úrazu nebo stížnosti (např. "Odřenina kolena", "Bolest hlavy")'
                                  : 'Vyberte účastníka pro pokračování',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: Colors.blue.shade200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: Colors.blue.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(color: Colors.red, width: 2),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: isCompact ? 12 : 16, 
                                vertical: isCompact ? 8 : 12
                              ),
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(8.0),
                                padding: const EdgeInsets.all(6.0),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(
                                  Icons.title,
                                  color: Colors.blue.shade700,
                                  size: isCompact ? 16 : 18,
                                ),
                              ),
                              errorMaxLines: 1,
                              errorStyle: const TextStyle(fontSize: 11, height: 0.8),
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
                        SizedBox(height: titleSpacing),
                        
                        // Description field (proper multi-line with good UX)
                        Container(
                          height: isCompact ? 90 : 120, // Increased height for at least 3 rows
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade100.withOpacity(0.3),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            key: const Key('description_field'),
                            controller: _descriptionController,
                            enabled: _selectedParticipant != null,
                            maxLines: null,
                            minLines: null, // Must be null when expands is true
                            maxLength: 1024,
                            expands: true, // Fill the container height
                            textAlignVertical: TextAlignVertical.top,
                            style: TextStyle(
                              fontSize: isCompact ? 13 : 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Popis úrazu a ošetření',
                              labelStyle: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                              hintText: 'Co se stalo, jak k úrazu došlo, jaké ošetření bylo poskytnuto...',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: Colors.blue.shade200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: Colors.blue.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(color: Colors.red, width: 2),
                              ),
                              contentPadding: EdgeInsets.all(isCompact ? 12 : 16), // More generous padding
                              alignLabelWithHint: true,
                              counterStyle: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                              ),
                              errorMaxLines: 1,
                              errorStyle: const TextStyle(fontSize: 11, height: 0.8),
                            ),
                            validator: (value) {
                              if (value != null && value.length > 1024) {
                                return 'Popis nesmí být delší než 1024 znaků';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: titleSpacing),
                              ],
                            ),
                          ),
                        ),
                        
                        // Action buttons (enhanced professional styling) pinned at bottom
                        Container(
                          padding: const EdgeInsets.all(16.0), // Increased padding
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12.0), // More rounded
                            border: Border.all(color: Colors.grey.shade200, width: 1),
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
                                      vertical: isCompact ? 12 : 14, // Better button height
                                      horizontal: isCompact ? 16 : 20,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    elevation: 2,
                                  ),
                                  icon: _isSaving
                                      ? SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Icon(
                                          Icons.save,
                                          size: isCompact ? 16 : 18,
                                        ),
                                  label: Text(
                                    _isSaving ? 'Ukládání...' : 'Uložit do deníku',
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
                                  onPressed: _isSaving ? null : _cancelAndReturn,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.grey.shade700,
                                    side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                    padding: EdgeInsets.symmetric(
                                      vertical: isCompact ? 12 : 14, // Match save button height
                                      horizontal: isCompact ? 12 : 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
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
                        ],
                      ), // Close Column (Form child)
                    ), // Close Form widget
                  ), // Close Opacity widget
                ), // Close Expanded widget
            ],
          ),
        );
      },
    ),
  );
  }
}

