import 'package:denik_zza/screens/actions/all_actions.dart';
import 'package:denik_zza/screens/actions/profile.dart';
import 'package:denik_zza/screens/login/components/my_button.dart';
import 'package:flutter/material.dart';
import 'package:denik_zza/screens/login/components/my_textfield.dart';

/// Widget for changing user profile information.
class ChangeProfile extends StatelessWidget {
  /// Constructor for initializing the ChangeProfile widget.
  ChangeProfile({Key? key});

  // Controllers for various text fields.
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController loginNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController newPasswordAgainController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upravit profil',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      // Drawer widget for displaying navigation options.
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text('Profil', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile()),
                );
              },
            ),
            ListTile(
              title: Text('Akce', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AllActions()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Column(
                children: [
                  SizedBox(height: 10),
                  MyTextField(
                    controller: usernameController,
                    hintText: 'Jméno',
                    obscureText: false,
                  ),
                  SizedBox(height: 10),
                  MyTextField(
                    controller: lastnameController,
                    hintText: 'Příjmení',
                    obscureText: false,
                  ),
                  SizedBox(height: 10),
                  MyTextField(
                    controller: loginNameController,
                    hintText: 'Přihlašovací jméno',
                    obscureText: false,
                  ),
                  SizedBox(height: 10),
                  MyTextField(
                    controller: phoneNumberController,
                    hintText: 'Telefonní číslo',
                    obscureText: true,
                  ),
                  SizedBox(height: 10),
                  MyTextField(
                    controller: newPasswordController,
                    hintText: 'Nové heslo',
                    obscureText: true,
                  ),
                  SizedBox(height: 10),
                  MyTextField(
                    controller: newPasswordAgainController,
                    hintText: 'Heslo znovu',
                    obscureText: false,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            // Button - temporarily navigates to the profile screen.
            Button(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile()),
                );
              },
              buttonText: "Potvrdit",
              verticalPadding: 20,
              horizontalPadding: 142,
            ),
          ],
        ),
      ),
    );
  }
}
