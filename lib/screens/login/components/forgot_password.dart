import 'package:denik_zza/screens/login/forgot_password_page.dart';
import 'package:flutter/material.dart';

/// Widget representing a "Forgot Password" link.
class ForgotPassword extends StatelessWidget {
  /// Constructor for the ForgotPassword widget.
  const ForgotPassword({Key? key});

  /// Builds the UI for the ForgotPassword widget.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Redirect to another screen (ForgotPasswordScreen)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ForgotPasswordScreen()), 
        );
      },
      child: Text(
        'Zapomenuté heslo',
        style: TextStyle(
          color: Color.fromARGB(103, 0, 0, 0),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}