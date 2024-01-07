import 'package:flutter/material.dart';


class Button extends StatelessWidget {

  final String buttonText;
    Button({super.key, required this.buttonText});

 
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Your onPressed logic here
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.black,
        onPrimary: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 110,
        ),
      ),
      child: Text(
        buttonText, 
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}