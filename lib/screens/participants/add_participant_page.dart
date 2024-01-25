import 'package:flutter/material.dart';


/// Widget representing a custom button.
class MyButton extends StatelessWidget { //todo why?
  final VoidCallback onPressed;
  final String buttonText;
  final double verticalPadding;
  final double horizontalPadding;

 /// Constructor for initializing the MyButton widget.
  MyButton({
    required this.onPressed,
    required this.buttonText,
    required this.verticalPadding,
    required this.horizontalPadding,
  });

//Designing the button
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Colors.black,
        onPrimary: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: EdgeInsets.symmetric(
          vertical: verticalPadding,
          horizontal: horizontalPadding,
        ),
      ),
      child: Text(
        buttonText,
        style: const TextStyle(fontSize: 10),
      ),
    );
  }
}

/// Stateful widget for the 'Add Participant' page.
class AddParticipantPage extends StatefulWidget {
  /// Constructor for initializing the AddParticipantPage widget.
  const AddParticipantPage({super.key});

  @override
  AddParticipantPageState createState() => AddParticipantPageState();
}
//todo: use forms in future
class AddParticipantPageState extends State<AddParticipantPage> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController birthDateController = TextEditingController();
  DateTime? selectedBirthDate;
  TextEditingController locationController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController insuranceCompanyController = TextEditingController();
  TextEditingController insuranceNumberController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController medicineController = TextEditingController();
  TextEditingController frequencyController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  TextEditingController nonInfectiousConfirmationController = TextEditingController();
  TextEditingController eligibleConfirmationController = TextEditingController();

  /// Handles the logic for CSV import action.
  void _handleCsvImport() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('CSV Import'),
          content: const Text('Zatím dávám místo logiky CSV'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  List<String> genderOptions = ['Muž', 'Žena'];
  String selectedGender = 'Muž';

/// Displays a date picker and updates the selected date.
  Future<void> _selectDate(BuildContext context, DateTime? selectedDate, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color.fromARGB(255, 0, 0, 0), // Change this to your preferred color
            colorScheme: const ColorScheme.light(primary: Colors.blue),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = pickedDate.toLocal().toString().split(' ')[0];
        selectedBirthDate = pickedDate;
      });
    }
  }

/// Formats a date into a string with the format 'yyyy-MM-dd'.
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Přidat Účastníka'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'Jméno'),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Příjmení'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _selectDate(context, selectedBirthDate, birthDateController),
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(255, 0, 0, 0), // Change this to your preferred color
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 24.0,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Vybrat Datum Narození',
                      style: TextStyle(color: Colors.white),
                    ),
                    Icon(Icons.calendar_today, color: Colors.white),
                  ],
                ),
              ),
              Text('Vybrané Datum: ${selectedBirthDate != null ? _formatDate(selectedBirthDate!) : ""}'),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Adresa'),
              ),
              TextField(
                controller: phoneNumberController,
                decoration: const InputDecoration(labelText: 'Telefonní číslo'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: insuranceCompanyController,
                decoration: const InputDecoration(labelText: 'Pojišťovna'),
              ),
              TextField(
                controller: insuranceNumberController,
                decoration: const InputDecoration(labelText: 'rodné číslo (Číslo pojištění)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField(
                value: selectedGender,
                onChanged: (value) {
                  setState(() {
                    selectedGender = value.toString();
                  });
                },
                items: genderOptions.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Pohlaví'),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      enabled: false, //notime
                      controller: medicineController,
                      decoration: const InputDecoration(labelText: 'Léky'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      enabled: false, //notime
                      controller: frequencyController,
                      decoration: const InputDecoration(labelText: 'Frekvence užívání'),
                    ),
                  ),
                ],
              ),
              // Notes
              const SizedBox(height: 15),
              TextField(
                enabled: false,
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Poznámky'),
                maxLines: 3,
              ),
              // Checkboxes for Confirmations
              const SizedBox(height: 15),
              Row(
                children: [
                  Checkbox(
                    value: nonInfectiousConfirmationController.text.toLowerCase() == 'true',
                    onChanged: (value) {
                      setState(() {
                        nonInfectiousConfirmationController.text = value.toString();
                      });
                    },
                  ),
                  const Text('Potvrzení o bezinfekčnosti'),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: eligibleConfirmationController.text.toLowerCase() == 'true',
                    onChanged: (value) {
                      setState(() {
                        eligibleConfirmationController.text = value.toString();
                      });
                    },
                  ),
                  const Text('Potvrzení o způsobilosti'),
                ],
              ),
              const SizedBox(height: 5),
              ElevatedButton(

                onPressed: null /*_handleCsvImport*/,
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(255, 0, 0, 0),
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.file_upload),
                    SizedBox(width: 10),
                    Text(
                      'CSV Import',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
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
                  ElevatedButton(
                    onPressed: () {
                      // ... (handle cancel logic)
                    },
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
