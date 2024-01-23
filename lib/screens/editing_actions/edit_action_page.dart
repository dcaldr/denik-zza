import 'package:flutter/material.dart';
import 'package:denik_zza/screens/login/components/my_button.dart';

class EditActionPage extends StatefulWidget {
  const EditActionPage({super.key});

  @override
  _EditActionPageState createState() => _EditActionPageState();
}

class _EditActionPageState extends State<EditActionPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != controller.text) {
      setState(() {
        controller.text = pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upravit akci',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Název akce',
                  labelStyle: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Adresa',
                  labelStyle: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startDateController,
                      decoration: const InputDecoration(
                        labelText: 'Datum začátku',
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(startDateController),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: endDateController,
                      decoration: const InputDecoration(
                        labelText: 'Datum ukončení',
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(endDateController),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                maxLines: 5,
                maxLength: 130,
                decoration: InputDecoration(
                  labelText: 'Popis',
                  hintText: 'Maximálně 130 znaků',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.person),
                  SizedBox(width: 8),
                  Text('Osob: 150', style: TextStyle(fontSize: 16)),
                ],
              ),
              SizedBox(height: 20),
              // Add more content here as needed
              Button(
                onPressed: () {
                  // update action logic
                },
                buttonText: "Upravit",
                verticalPadding: 20,
                horizontalPadding: 130,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
