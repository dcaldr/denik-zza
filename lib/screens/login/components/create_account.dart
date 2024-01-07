import 'package:denik_zza/screens/login/register_page.dart';
import 'package:flutter/material.dart';

class CreateAccount extends StatelessWidget {
  const CreateAccount({Key? key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Přesměrování na jinou obrazovku
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RegisterScreen()), 
        );
      },
      child: Text(
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