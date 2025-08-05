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
            const SnackBar(content: Text('Záznam byl úspěšně uložen!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Nepodařilo se uložit záznam: $e')),
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
        title: const Text('Nový záznam'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with participant name (like old system)
              Text(
                '${widget.participant.jmeno} ${widget.participant.prijmeni}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // Display existing records (full width and scrollable)
              Container(
                height: 350,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: RecordListWidget(
                  key: ValueKey(_refreshCounter),
                  participant: widget.participant,
                  height: 350,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Form for new record
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Optional date and time selection (combined picker)
                    Row(
                      children: [
                        Text(
                          'Změnit čas záznamu (volitelné):',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const Spacer(),
                        IconButton.outlined(
                          onPressed: _selectDateTime,
                          icon: const Icon(Icons.schedule, size: 18),
                          tooltip: _formatSelectedDateTime(),
                          iconSize: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Title field (matching old system terminology)
                    TextFormField(
                      controller: _titleController,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        labelText: 'Nadpis',
                        hintText: 'pár slovný popis',
                        border: OutlineInputBorder(),
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
                    const SizedBox(height: 16),
                    
                    // Description field with character limit (like old system)
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      maxLength: 1024, // Character limit from old system
                      decoration: const InputDecoration(
                        labelText: 'Rozsáhlejší popis',
                        hintText: 'Maximálně 1024 znaků',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Prosím zadejte popis';
                        }
                        if (value.length > 1024) {
                          return 'Popis nesmí být delší než 1024 znaků';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Action buttons (matching old system layout)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Save button (styled like old system)
                        ElevatedButton(
                          onPressed: _isSaving ? null : _saveRecord,
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Uložit'),
                        ),
                        
                        // Cancel button (restored from old system)
                        ElevatedButton(
                          onPressed: _isSaving ? null : _cancelAndReturn,
                          child: const Text('Zrušit'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

