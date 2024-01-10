import 'package:flutter/material.dart';
import 'package:denik_zza/screens/login/components/my_button.dart';

class AddActionPage extends StatefulWidget {
  @override
  _AddActionPageState createState() => _AddActionPageState();
}

class _AddActionPageState extends State<AddActionPage> {
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
          'Přidat akci',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text(
                'Profil',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                // Implement navigation to the profile page
              },
            ),
            ListTile(
              title: Text(
                'Akce',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                // Implement navigation to the AllActions page
              },
            ),
            // Add more menu items as needed
          ],
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
                      decoration: InputDecoration(
                        labelText: 'Datum začátku',
                        labelStyle: TextStyle(color: Colors.black),
                        cursorColor: Colors.black, // Set cursor color here
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(startDateController),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: endDateController,
                      decoration: InputDecoration(
                        labelText: 'Datum ukončení',
                        labelStyle: TextStyle(color: Colors.black),
                        cursorColor: Colors.black, // Set cursor color here
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
              Button(
                onPressed: () {
                  // add action
                },
                buttonText: "Pridat",
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