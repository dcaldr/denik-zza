// ignore_for_file: prefer_const_constructors

import 'package:denik_zza/screens/login/components/my_textfield.dart';
import 'package:flutter/material.dart';

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
                    "Registrace",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                      height:
                          10), 
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
                  SizedBox(height: 10), 
                  MyTextField(
                    controller: passwordController,
                    hintText: 'Heslo',
                    obscureText: true,
                  ),
                  SizedBox(height: 10), 
                  MyTextField(
                    controller: passwordAgain,
                    hintText: 'Heslo znovu',
                    obscureText: true,
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

            // button
            ElevatedButton(
              onPressed: () {
                // Implement your button functionality here
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8.0), // Adjust the radius as needed
                ),
                padding: EdgeInsets.symmetric(
                    vertical: 20, horizontal: 140), // Adjust padding for size
              ),
              child: Text("Potvrdit",
                  style: TextStyle(fontSize: 16)), // Adjust font size
            ),
          ],
        ),
      ),
      // Additional parts of your code...
    );
  }
}
