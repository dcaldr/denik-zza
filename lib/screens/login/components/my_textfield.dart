// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';


/// Custom text field widget with customizable controller, hintText, and obscureText.
class MyTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;

/// Constructor for the MyTextField widget.
   MyTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText,
      });

/// Builds the UI for the MyTextField widget.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
         obscureText: obscureText,
        decoration: InputDecoration(
          enabledBorder:  OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 82, 81, 81)),
          ),
          fillColor: Colors.white,
          filled: true,
          hintText: hintText, 
          hintStyle: TextStyle(color: Colors.grey[500],)
        ),
      ),
    );
  }
}
