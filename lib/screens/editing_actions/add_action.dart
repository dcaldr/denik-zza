import 'package:denik_zza/database/in_memory_structures_tmp/memory_action.dart';
import 'package:denik_zza/screens/actions/all_actions.dart';
import 'package:denik_zza/screens/actions/profile.dart';
import 'package:denik_zza/screens/editing_actions/action_detail.dart';
import 'package:denik_zza/screens/login/login_page.dart';
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
    var a = DateTime.parse('10.5.2000');
    var b =DateTime.parse('11.5.2000');
    @Deprecated("Remove as soon as possible")
    MemoryAction dummy = MemoryAction(idAkce: 1, nadpis: "Dummy", popis: "popis", odkdy: a, dokdy: b);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Přidat akci',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ActionDetail( action: dummy,)), // Navigate to ActionDetail page
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: Text(
                      'Profil',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Profile()),
                      );
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Akce',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AllActions()),
                      );
                    },
                  ),
                  // Add more menu items as needed
                ],
              ),
            ),
            Divider(), // Divider to separate the main items from logout
            ListTile(
              title: Text(
                'Odhlásit se',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red, // Customize the color as needed
                ),
              ),
              onTap: () {
                Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Login()), // Navigate to Login page
          ); // Replace '/login' with your login page route
              },
            ),
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
