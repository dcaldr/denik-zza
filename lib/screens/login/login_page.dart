// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_const

import 'package:denik_zza/screens/actions/profile.dart';
import 'package:denik_zza/screens/login/components/create_account.dart';
import 'package:denik_zza/screens/login/components/my_button.dart';
import 'package:denik_zza/screens/login/components/my_textfield.dart';
import 'package:flutter/material.dart';
import 'package:denik_zza/screens/actions/all_actions.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Profile()), // Use the Profile class
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 25),

              // logo
              Icon(
                Icons.book,
                size: 100,
              ),

              SizedBox(height: 20),

              //greeting message
              Text(
                'Vítejte!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 25),

              //username
              MyTextField(
                controller: usernameController,
                hintText: 'Uživatelské jméno',
                obscureText: false,
              ),

              SizedBox(height: 10),

              // password textfield
             //MyTextField(
                //controller: passwordController,
                //hintText: 'Heslo',
                //obscureText: true,
             // ),

              SizedBox(height: 10),

              // login button
              Button(
                onPressed: () {
                  if (usernameController.text == 'ester') {
                  // If the username and password are valid, navigate to the AllActions page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AllActions()),
                  );
                } else {
                  print('Invalid username');
                }
              },
                buttonText: "Přihlásit se",
                verticalPadding: 20,
                horizontalPadding: 130,
              ),

              //const SizedBox(
                //height: 10,
              //),

              // Row for "Create Account" and "Forgot Password"
            //Row(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjust as needed
             // children: [
                // forgot password
                //ForgotPassword(),

                // create new account
                CreateAccount(),
              ],
            ),
         // ],
        ),
      ),
   // ),
  );
}
}
