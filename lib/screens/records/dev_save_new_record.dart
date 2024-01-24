import 'package:flutter/material.dart';
import 'new_record_page.dart';

/// State class for handling the state of the [NewRecordPage].
class NewRecordPageState extends State<NewRecordPage> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController treatmentController = TextEditingController();
  final TextEditingController titleController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

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
              const Text(
                'Jan Novotný',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Date TextField
              //TextField(
              //  controller: dateController,
              //  decoration: const InputDecoration(
              //   labelText: 'Datum',
              //    labelStyle: TextStyle(color: Colors.black),
              //  ),
              //  readOnly: true,
              //  onTap: _selectDate,
              //),
              //SizedBox(height: 10),
              // Time TextField
              //TextField(
              //  controller: timeController,
              //  decoration: const InputDecoration(
              //    labelText: 'Čas',
              //    labelStyle: TextStyle(color: Colors.black),
              //  ),
              //  readOnly: true,
              //  onTap: _selectTime,
              //),
              const SizedBox(height: 10),
              TextField(
                controller: titleController,
              ),
              // Description TextField
              TextField(
                controller: descriptionController,
                maxLines: 5,
                maxLength: 1024,
                decoration: const InputDecoration(
                  labelText: 'Popis',
                  hintText: 'Maximálně 1024 znaků',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 10),
              // Treatment TextField
              //TextField(
              // controller: treatmentController,
              //  maxLines: 5,
              //  maxLength: 130,
              //  decoration: InputDecoration(
              //    labelText: 'Ošetření',
              //    hintText: 'Maximálně 130 znaků',
              //    border: OutlineInputBorder(),
              //    labelStyle: TextStyle(color: Colors.black),
              //  ),
              //),
              const SizedBox(height: 15),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Uložit Button
                  ElevatedButton(
                    onPressed: () {
                      // ... (handle save logic)
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      onPrimary: Colors.white,
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
                  ElevatedButton( //TODO Fix
                    onPressed: null,
                    // onPressed: () {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(builder: (context) => const ParticipantDetailPage(ucastnik: null,))
                    //   );
                    // },
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromARGB(255, 255, 251, 245),
                      onPrimary: Colors.black,
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
