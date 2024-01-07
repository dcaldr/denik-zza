import 'package:flutter/material.dart';


class Button extends StatelessWidget {
  final String buttonText;
  final double verticalPadding; // New parameter for vertical padding
  final double horizontalPadding; // New parameter for horizontal padding

  Button({
    super.key,
    required this.buttonText,
    required this.verticalPadding,
    required this.horizontalPadding,
  });

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
          vertical: verticalPadding,
          horizontal: horizontalPadding,
        ),
      ),
      child: Text(
        buttonText,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}