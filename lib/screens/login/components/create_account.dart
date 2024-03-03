import 'package:denik_zza/screens/login/register_page.dart';
import 'package:flutter/material.dart';

/// Widget representing a "Create Account" link.
class CreateAccount extends StatelessWidget {
  const CreateAccount({super.key});

//  const CreateAccount({super.key, Key? key});


/// Builds the UI for the CreateAccount widget.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
         // Redirect to another screen (RegisterScreen)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RegisterScreen()), 
        );
      },
      child: const Text(
        'Vytvořit účet',
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}