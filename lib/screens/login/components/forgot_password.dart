import 'package:denik_zza/screens/login/forgot_password_page.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({Key? key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Přesměrování na jinou obrazovku
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
