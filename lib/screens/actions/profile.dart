import 'package:denik_zza/screens/actions/change_profile.dart';
import 'package:denik_zza/screens/login/components/my_textfield.dart';
import 'package:flutter/material.dart';

import '../our_widgets/our_drawer.dart';

/// Widget for displaying user profile information.
class Profile extends StatelessWidget {
  /// Constructor for initializing the Profile widget.
  Profile({super.key, Key? key});

  final usernameController = TextEditingController();
  final lastnameController = TextEditingController();
  final loginName = TextEditingController();
  final phoneNumber = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar for the profile screen.
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        // Action button for navigating to the ChangeProfile screen.
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to another screen for editing the profile
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangeProfile()),
              );
            },
          ),
        ],
      ),

      // Drawer widget for displaying navigation options.
      drawer: const OurDrawer(),

      // Body of the profile screen wrapped in a SingleChildScrollView.
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // Profile welcome message.
            const Text(
              'Vítejte na svém profilu!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            // Change avatar section.
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/doc.jpg'), // Set your image asset path
            ),
            const SizedBox(height: 10),

            // Username text field.
            const SizedBox(height: 10),
            MyTextField(
              controller: usernameController,
              hintText: 'Jmeno',
              obscureText: false,
            ),

            // Last name text field.
            const SizedBox(height: 10),
            MyTextField(
              controller: lastnameController,
              hintText: 'Prijmeni',
              obscureText: false,
            ),

            // Login name text field.
            const SizedBox(height: 10),
            MyTextField(
              controller: loginName,
              hintText: 'Prihlasovaci jmeno',
              obscureText: false,
            ),

            // Phone number text field.
            const SizedBox(height: 10),
            MyTextField(
              controller: phoneNumber,
              hintText: 'Telefonni cislo',
              obscureText: false,
            ),
          ],
        ),
      ),
    );
  }
}


