// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;

   MyTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText,
      });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,// to acces input
         obscureText: obscureText, // hides the text
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
