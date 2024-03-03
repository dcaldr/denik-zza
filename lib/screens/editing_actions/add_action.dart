/// Importing necessary packages and modules for the 'AddActionPage' Dart file.
library;
import 'package:denik_zza/database/database_interface.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_action.dart';
import 'package:denik_zza/screens/actions/all_actions.dart';
import 'package:denik_zza/screens/our_widgets/our_drawer.dart';
import 'package:flutter/material.dart';
import 'package:denik_zza/screens/login/components/my_button.dart';


/// StatefulWidget for the 'AddActionPage', used for creating new actions
/// TODO: Edit action page component
///
/// needs hevy cleaning in the future
class AddActionPage extends StatefulWidget {
   const AddActionPage({super.key});

  @override
  AddActionPageState createState() => AddActionPageState();
}

//TODO: simplify using Forms and FormFields (https://flutter.dev/docs/cookbook/forms/validation)
class AddActionPageState extends State<AddActionPage> {
  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController startDateController;
  late TextEditingController endDateController;
  late TextEditingController descriptionController;

/// Initializes the state of the 'AddActionPage'.
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    addressController = TextEditingController();
    startDateController = TextEditingController();
    endDateController = TextEditingController();
    descriptionController = TextEditingController();
  }

 /// Disposes of resources when the 'AddActionPage' is no longer needed.
  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

 /// Displays a date picker dialog and updates the selected date.
  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        controller.text =
            '${pickedDate.day.toString().padLeft(2, '0')}.${pickedDate.month.toString().padLeft(2, '0')}.${pickedDate.year}'; //todo: ref //DT1
      });
    }
  }

  /// Builds a standard text field.
  Widget buildTextField(TextEditingController controller, String labelText,
      Future<void> Function(TextEditingController)? onTap) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black),
      ),
      readOnly: onTap != null,
      onTap: onTap != null ? () => onTap(controller) : null,
    );
  }

/// Builds a text field with a character counter.
  Widget buildTextFieldWithCounter(
      TextEditingController controller,
      String labelText,
      int maxLength,
      Future<void> Function(TextEditingController)? onTap) {
    return TextField(
      controller: controller,
      maxLines: 3,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: 'Maximálně 130 znaků',
        border:
        // ignore: prefer_const_constructors
            OutlineInputBorder(), //cannot be const or the numbers wont move when you type
        //labelStyle: const TextStyle(color: Colors.black),
      ),
      readOnly: onTap != null,
      onTap: onTap != null ? () => onTap(controller) : null,
    );
  }


/// Builds the UI for the 'AddActionPage'.
  @override
  Widget build(BuildContext context) {
    // TODO: remove
    // var a = DateTime(2020,7,15);
    // var b =DateTime(2020,7,16);
    // @Deprecated("Remove as soon as possible")
    // MemoryAction dummy = MemoryAction(idAkce: 1, nadpis: "Dummy", popis: "popis", odkdy: a, dokdy: b);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Přidat akci',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: const [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: null,
            // onPressed: () { // TODO: consult existence  of edit action reference in create action
            //
            //   // TODO: Add navigation to the edit action page
            //   // Navigator.push(context, MaterialPageRoute(builder: (context) => EditActionPage()));
            // },
          ),
          IconButton(
            icon: Icon(Icons.info),
            onPressed: null,
            // onPressed: () { // TODO : consult
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => ActionDetail( action: dummy,)), // Navigate to ActionDetail page
            //   );
            // },
          ),
        ],
      ),
      drawer: const OurDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildTextField(nameController, 'Název akce', null),
              const SizedBox(height: 10),
              buildTextField(addressController, 'Adresa', null),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: buildTextField(
                        startDateController, 'Datum začátku', _selectDate),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: buildTextField(
                        endDateController, 'Datum ukončení', _selectDate),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              buildTextFieldWithCounter(
                  descriptionController, 'Popis', 130, null),
              const SizedBox(height: 20),
              // TODO: Add more content here as needed
              //FIXME: this button name shadows the material one
              Button(
                // TODO:  improve no error handeling -> do with forms + user input handler
                onPressed: () {
                  // Get the values from the TextEditingControllers
                  String nadpis = nameController.text;
                  String popis = descriptionController.text;
                  String adresa = addressController.text;
                  String startDateString = startDateController.text;
                  String endDateString = endDateController.text;

                  // Check if any of the values are null or empty
                  if (nadpis.isEmpty /*|| popis.isEmpty*/ || startDateString.isEmpty || endDateString.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Neúspěch: nebyly zadány všechny hodnoty"),
                      ),
                    );
                    // Navigate to the AllActions page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AllActions()),
                    );
                  } else {
                    // Convert the date strings to DateTime objects
                    DateTime? odkdy = convertToDate(startDateString);
                    DateTime? dokdy = convertToDate(endDateString);
                   // print('Odkdy: $odkdy');
                   // print('Dokdy: $dokdy');

                    // Create a new MemoryAction object
                    MemoryAction newAction = MemoryAction(
                        idAkce: null,
                        nadpis: nadpis,
                        popis: "$adresa $popis",
                        odkdy: odkdy,
                        dokdy: dokdy
                    );

                    // Get the database interface
                    DatabaseInterface db = DatabaseWrapper.getDatabase();

                    // Add the new action to the database
                    db.addEvent(newAction);
                  }
                  // Navigate to the AllActions page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AllActions()),
                  );
                },
                buttonText: "Přidat",
                verticalPadding: 10,
                horizontalPadding: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

DateTime convertToDate(String date) {

    var parts = date.split('.');
    if (parts.length != 3) {
      return DateTime(0,0,0);
    } else {
      var day = int.parse(parts[0]);
      var month = int.parse(parts[1]);
      var year = int.parse(parts[2]);
      return DateTime(year, month, day);
    }



}
