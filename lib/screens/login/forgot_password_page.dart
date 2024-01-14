import 'package:flutter/material.dart';
import 'package:denik_zza/screens/login/login_page.dart';
import 'package:denik_zza/screens/login/components/my_button.dart';
import 'package:denik_zza/screens/login/components/my_textfield.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen ({super.key});

  final phoneNumber = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // Your current AppBar code
          ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    "Obnovení hesla",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Zadejte tel. číslo pro zaslání nového hesla",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: 10),
                  MyTextField(
                    controller: phoneNumber,
                    hintText: 'Telefonni cislo',
                    obscureText: false,
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),

            // Button - shows the success pop-up
            Button(
              onPressed: () {
                // Show the success pop-up
                _showSuccessFullySendDialog(context);
              },
              buttonText: "Potvrdit",
              verticalPadding: 20,
              horizontalPadding: 142,
            ),
          ],
        ),
      ),
    );
  }

  // Function to show the success dialog
  Future<void> _showSuccessFullySendDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Zkontrolujte sms'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Na vaše telefoní číslo bylo zasláno nové heslo'),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Close the dialog and navigate to the profile screen
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }
}