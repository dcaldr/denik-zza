// ignore_for_file: prefer_const_constructors

import 'package:denik_zza/screens/login/login_page.dart';
import 'package:denik_zza/screens/login/components/my_button.dart';
import 'package:denik_zza/screens/login/components/my_textfield.dart';
import 'package:flutter/material.dart';

//Class for creating new account with needed textfields
class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final usernameController = TextEditingController();
  final lastnameController = TextEditingController();
  final passwordController = TextEditingController();
  final loginName = TextEditingController();
  final passwordAgain = TextEditingController();
  final phoneNumber = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // Current AppBar code
          //Adding needed textfields
          ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    "Registrace",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  MyTextField(
                    controller: usernameController,
                    hintText: 'Jmeno',
                    obscureText: false,
                  ),
                  SizedBox(height: 10),
                  MyTextField(
                    controller: lastnameController,
                    hintText: 'Prijmeni',
                    obscureText: false,
                  ),
                  SizedBox(height: 10),
                  MyTextField(
                    controller: loginName,
                    hintText: 'Prihlasovaci jmeno',
                    obscureText: false,
                  ),
                  //SizedBox(height: 10),
                  //MyTextField(
                    //controller: passwordController,
                    //hintText: 'Heslo',
                    //obscureText: true,
                  //),
                  //SizedBox(height: 10),
                  //MyTextField(
                    //controller: passwordAgain,
                    //hintText: 'Heslo znovu',
                    //obscureText: true,
                  //),
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
                _showSuccessDialog(context);
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
  Future<void> _showSuccessDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Úspěch'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Registrace proběhla úspěšně!'),
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
