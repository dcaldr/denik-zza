// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_const

import 'package:denik_zza/screens/login/components/create_account.dart';
import 'package:denik_zza/screens/login/components/my_button.dart';
import 'package:denik_zza/screens/login/components/my_textfield.dart';
import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  //sign user method
  void signUserIn() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            children:  [
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
              MyTextField(
                controller: passwordController,
                hintText: 'Heslo',
                obscureText: true,
              ),

              SizedBox(height: 10),

              // login button
              Button(buttonText: "Zaregistrovat se"),

              const SizedBox(height: 10,),

              // forgotten password text
              CreateAccount(),

              

              

              
              
            ],
          ),
        ),
      ),
    );
  }
}
