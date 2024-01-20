import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final double verticalPadding;
  final double horizontalPadding;

  MyButton({
    required this.onPressed,
    required this.buttonText,
    required this.verticalPadding,
    required this.horizontalPadding,
  });

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
        style: TextStyle(fontSize: 10),
      ),
    );
  }
}

class AddParticipantPage extends StatefulWidget {
  @override
  _AddParticipantPageState createState() => _AddParticipantPageState();
}

class _AddParticipantPageState extends State<AddParticipantPage> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController birthDateController = TextEditingController();
  DateTime? selectedBirthDate;
  TextEditingController locationController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController insuranceCompanyController = TextEditingController();
  TextEditingController insuranceNumberController = TextEditingController();
  TextEditingController genderController = TextEditingController();

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
            colorScheme: ColorScheme.light(primary: Colors.blue),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
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

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Přidat Účastníka'),
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(labelText: 'Jméno'),
            ),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: 'Příjmení'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectDate(context, selectedBirthDate, birthDateController),
              style: ElevatedButton.styleFrom(
                primary: const Color.fromARGB(255, 0, 0, 0), // Change this to your preferred color
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 24.0,
                ),
              ),
              child: Row(
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
              decoration: InputDecoration(labelText: 'Lokace'),
            ),
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Telefonní číslo',
              ),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: insuranceCompanyController,
              decoration: InputDecoration(labelText: 'Pojišťovna'),
            ),
            TextField(
              controller: insuranceNumberController,
              decoration: InputDecoration(
                labelText: 'Číslo pojištění',
              ),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: genderController,
              decoration: InputDecoration(labelText: 'Pohlaví (1 - muž, 2 - žena)'),
            ),SizedBox(height: 15),
            // Adjusted styling for "Přidat Účastníka" button
            ElevatedButton(
              onPressed: () {
                // Get values from controllers
                String formattedBirthDate = _formatDate(selectedBirthDate!);
                String firstName = firstNameController.text;
                String lastName = lastNameController.text;
                // ... (other fields)

                // Print or use the participant data
                print('First Name: $firstName');
                print('Last Name: $lastName');
                print('Birth Date: $formattedBirthDate');
                // ... (other prints)

                // Reset the form if needed
                // firstNameController.clear();
                // lastNameController.clear();
                // ... (clear other controllers)

                // Optionally, navigate back to the previous screen
                // Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 100,
                ),
              ),
              child: Text(
                'Přidat Účastníka',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}