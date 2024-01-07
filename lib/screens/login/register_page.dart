// ignore_for_file: prefer_const_constructors

import 'package:denik_zza/screens/login/components/my_button.dart';
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
            //Button(buttonText: "Potvrdit")
           
          ],
        ),
      ),
      
    );
  }
}
