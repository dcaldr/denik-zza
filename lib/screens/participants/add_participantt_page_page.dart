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
  TextEditingController medicineController = TextEditingController();
  TextEditingController frequencyController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  TextEditingController nonInfectiousConfirmationController = TextEditingController();
  TextEditingController eligibleConfirmationController = TextEditingController();

  // Dropdown items for gender
  List<String> genderOptions = ['Muž', 'Žena'];
  String selectedGender = 'Muž';

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
                decoration: InputDecoration(labelText: 'Telefonní číslo'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: insuranceCompanyController,
                decoration: InputDecoration(labelText: 'Pojišťovna'),
              ),
              TextField(
                controller: insuranceNumberController,
                decoration: InputDecoration(labelText: 'Číslo pojištění'),
                keyboardType: TextInputType.phone,
              ),
              // Dropdown for Gender
              SizedBox(height: 15),
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
                decoration: InputDecoration(labelText: 'Pohlaví'),
              ),
              // Additional Fields
              SizedBox(height: 15),
              // ... (Other fields)
              // Medicine and Frequency
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: medicineController,
                      decoration: InputDecoration(labelText: 'Léky'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: frequencyController,
                      decoration: InputDecoration(labelText: 'Frekvence užívání'),
                    ),
                  ),
                ],
              ),
              // Notes
              SizedBox(height: 15),
              TextField(
                controller: notesController,
                decoration: InputDecoration(labelText: 'Poznámky'),
                maxLines: 3,
              ),
              // Checkboxes for Confirmations
              SizedBox(height: 15),
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
                  Text('Potvrzení o bezinfekčnosti'),
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
                  Text('Potvrzení o způsobilosti'),
                ],
              ),
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
                      // ... (handle cancel logic)
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