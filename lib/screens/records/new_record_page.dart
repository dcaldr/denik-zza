import 'package:denik_zza/screens/records/record_detail_page.dart';
import 'package:flutter/material.dart';

import '../participants/paticipant_detail_page.dart';

class NewRecordPage extends StatefulWidget {
  @override
  _NewRecordPageState createState() => _NewRecordPageState();
}

class _NewRecordPageState extends State<NewRecordPage> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController treatmentController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

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
        title: Text(
          'Nový záznam',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Add navigation to the edit action page
              // Navigator.push(context, MaterialPageRoute(builder: (context) => EditActionPage()));
            },
          ),
          IconButton(
            icon: Icon(Icons.info),
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
                'Jan Novotný',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
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
              SizedBox(height: 10),
              // Description TextField
              TextField(
                controller: descriptionController,
                maxLines: 5,
                maxLength: 1024,
                decoration: InputDecoration(
                  labelText: 'Popis',
                  hintText: 'Maximálně 1024 znaků',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(height: 10),
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
              SizedBox(height: 15),
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
                      padding: EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 60,
                      ),
                    ),
                    child: Text(
                      'Uložit',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  // Zrušit Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ParticipantDetailPage())
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 255, 251, 245),
                      onPrimary: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 50,
                      ),
                    ),
                    child: Text(
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
