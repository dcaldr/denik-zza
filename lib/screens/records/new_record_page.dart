import 'package:denik_zza/database/database_interface.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:flutter/material.dart';

import '../participants/participant_detail_page.dart';

/// Widget for creating a new record associated with a participant.
class NewRecordPage extends StatefulWidget {
  final MemoryOsoba osoba;

  /// Constructor for [NewRecordPage].
  const NewRecordPage({super.key, required this.osoba});

  @override
  NewRecordPageState createState() => NewRecordPageState();
}

/// State class for handling the state of [NewRecordPage].
class NewRecordPageState extends State<NewRecordPage> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController treatmentController = TextEditingController();
  final TextEditingController titleController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  DatabaseInterface db = DatabaseWrapper.getDatabase();

  /// Function to show the date picker and update the selected date.
  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        dateController.text = pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  /// Function to show the time picker and update the selected time.
  Future<void> _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
        timeController.text = pickedTime.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nový záznam',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Add navigation to the edit action page
              // Navigator.push(context, MaterialPageRoute(builder: (context) => EditActionPage()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              // Navigate to ActionDetail page
              // Navigator.push(context, MaterialPageRoute(builder: (context) => ActionDetail()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with participant name
              Text(
                '${widget.osoba.jmeno} ${widget.osoba.prijmeni}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 350,
                child: FullZraneniList(databaze: db, osoba: widget.osoba),
              ),

              // Date TextField
              const SizedBox(height: 10),
              TextField(
                controller: titleController,
                maxLines: 1,
                decoration: const InputDecoration(
                  labelText: 'Nadpis',
                  hintText: 'pár slovný popis',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 10,),
              // Description TextField
              TextField(
                controller: descriptionController,
                maxLines: 5,
                maxLength: 1024,
                decoration: const InputDecoration(
                  labelText: 'Rozsáhlejší popis',
                  hintText: 'Maximálně 1024 znaků',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 10),
              // Treatment TextField
              const SizedBox(height: 15),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Uložit Button
                  ElevatedButton(
                    onPressed: () {
                      String mTitle = titleController.text;
                      String mPopis = descriptionController.text;
                      if (mTitle.isNotEmpty || mPopis.isNotEmpty) {
                        MemoryZaznam zaznamIn = MemoryZaznam.named(
                          nazev: mTitle,
                          popis: mPopis,
                          idPacient: widget.osoba.id,
                          idZaznamu: -1,
                          casZaznamu: DateTime.now(),
                          isPrinted: false,
                          idAuthor: 1,
                        );
                        db.addZaznam(zaznamIn);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Uloženo'),
                          ),
                        );
                      } else{
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('nepovedlo se uložit'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 60,
                      ),
                    ),
                    child: const Text(
                      'Uložit',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  // Zrušit Button
                  ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black, backgroundColor: const Color.fromARGB(255, 255, 251, 245),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 50,
                      ),
                    ),
                    child: const Text(
                      'Zrušit',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
