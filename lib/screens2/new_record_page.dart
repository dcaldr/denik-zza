import 'package:flutter/material.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:denik_zza/screens2/services/record_service.dart';
import 'package:denik_zza/screens2/widgets/record_list_widget.dart';

/// Enhanced new record page that matches the old system functionality
/// but with improved architecture and validation
class NewRecordPage extends StatefulWidget {
  final MemoryOsoba participant;

  const NewRecordPage({super.key, required this.participant});

  @override
  _NewRecordPageState createState() => _NewRecordPageState();
}

class _NewRecordPageState extends State<NewRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _recordService = RecordService();

  bool _isSaving = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _refreshCounter = 0; // For forcing widget refresh

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
        : _selectedTime!.format(context);
    
    return '$datePart, $timePart';
  }

  Future<void> _saveRecord() async {
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
        idPacient: widget.participant.id,
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
        
        // Clear the form
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedDate = null;
          _selectedTime = null;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nový záznam úrazu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: null, // Disabled for now as requested
            tooltip: 'Úpravy (zatím nedostupné)',
          ),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              // Placeholder for info functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Informace o záznamu')),
              );
            },
            tooltip: 'Informace',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Adjust spacing and layout based on available height
          final isCompact = constraints.maxHeight < 600;
          final spacing = isCompact ? 4.0 : 8.0;
          final titleSpacing = isCompact ? 4.0 : 6.0;
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with participant name (enhanced styling)
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.blue.shade50,
                        Colors.blue.shade50.withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.blue.shade200, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.blue.shade700,
                          size: isCompact ? 18 : 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Účastník',
                              style: TextStyle(
                                fontSize: isCompact ? 12 : 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            Text(
                              '${widget.participant.jmeno} ${widget.participant.prijmeni}',
                              style: TextStyle(
                                fontSize: isCompact ? 16 : 18, 
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
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
                  flex: isCompact ? 2 : 3,
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
                          child: RecordListWidget(
                            key: ValueKey(_refreshCounter),
                            participant: widget.participant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: spacing),
                
                // Form for new record (prioritized input area)
                Expanded(
                  flex: isCompact ? 3 : 7,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Optional date and time selection (enhanced professional styling)
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.blue.shade200.withOpacity(0.5), width: 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(
                                  Icons.schedule,
                                  color: Colors.blue.shade700,
                                  size: isCompact ? 14 : 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Čas záznamu',
                                      style: TextStyle(
                                        fontSize: isCompact ? 11 : 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    Text(
                                      _formatSelectedDateTime(),
                                      style: TextStyle(
                                        fontSize: isCompact ? 13 : 14,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.tonal(
                                onPressed: _selectDateTime,
                                style: FilledButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isCompact ? 8 : 12,
                                    vertical: isCompact ? 4 : 6,
                                  ),
                                  minimumSize: Size.zero,
                                  backgroundColor: Colors.blue.shade100,
                                  foregroundColor: Colors.blue.shade700,
                                ),
                                child: Text(
                                  'Změnit',
                                  style: TextStyle(
                                    fontSize: isCompact ? 11 : 12,
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
                            controller: _titleController,
                            maxLines: 1,
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
                              hintText: 'Typ úrazu nebo stížnosti (např. "Odřenina kolena", "Bolest hlavy")',
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
                        
                        // Description field (simplified for better layout)
                        Expanded(
                          child: TextFormField(
                            controller: _descriptionController,
                            maxLines: null,
                            minLines: isCompact ? 3 : 4,
                            maxLength: 1024,
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
                              contentPadding: EdgeInsets.all(isCompact ? 12 : 16),
                              alignLabelWithHint: true,
                              counterStyle: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                              ),
                              errorMaxLines: 1,
                              errorStyle: const TextStyle(fontSize: 11, height: 0.8),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Prosím zadejte popis úrazu';
                              }
                              if (value.length > 1024) {
                                return 'Popis nesmí být delší než 1024 znaků';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: titleSpacing),
                        
                        // Action buttons (enhanced professional styling)
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.grey.shade200, width: 1),
                          ),
                          child: Row(
                            children: [
                              // Save button (primary action)
                              Expanded(
                                flex: 3,
                                child: FilledButton.icon(
                                  onPressed: _isSaving ? null : _saveRecord,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.blue.shade600,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      vertical: isCompact ? 8 : 12,
                                      horizontal: isCompact ? 12 : 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6.0),
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
                              
                              const SizedBox(width: 12),
                              
                              // Cancel button (secondary action)
                              Expanded(
                                flex: 2,
                                child: OutlinedButton.icon(
                                  onPressed: _isSaving ? null : _cancelAndReturn,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.grey.shade700,
                                    side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                    padding: EdgeInsets.symmetric(
                                      vertical: isCompact ? 8 : 12,
                                      horizontal: isCompact ? 8 : 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.close,
                                    size: isCompact ? 16 : 18,
                                  ),
                                  label: Text(
                                    'Zrušit',
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
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

