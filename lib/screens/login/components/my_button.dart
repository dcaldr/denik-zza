import 'package:flutter/material.dart';


class Button extends StatelessWidget {
  final String buttonText;
  final double verticalPadding;
  final double horizontalPadding;
  final VoidCallback onPressed;

  Button({
    Key? key,
    required this.buttonText,
    required this.verticalPadding,
    required this.horizontalPadding,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
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