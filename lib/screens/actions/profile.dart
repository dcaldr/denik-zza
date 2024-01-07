import 'package:denik_zza/screens/login/components/my_textfield.dart';
import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  Profile({Key? key});

  final usernameController = TextEditingController();
  final lastnameController = TextEditingController();
  final loginName = TextEditingController();
  final phoneNumber = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bar
      appBar: AppBar(
        title: Text(
          'Profil',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigate to another screen for editing the profile
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
         

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

        const SizedBox(height: 40),

            // profile message

            const Text(
              'Vítejte na svém profilu!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            // change avatar
            const CircleAvatar(
              radius: 50,
              //child: Image.asset('doctor.jpg'), // check
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                // For example, show a dialog or navigate to a screen for image selection/upload
              },
              icon: const Icon(
                Icons.camera_alt,
                color: Colors.black,
              ),
              label: const Text(
                'Změnit profilový obrázek',
                style: TextStyle(color: Colors.black),
              ),
            ),

            // username
            const SizedBox(height: 10),
            MyTextField(
              controller: usernameController,
              hintText: 'Jmeno',
              obscureText: false,
            ),

            // last name
            const SizedBox(height: 10),
            MyTextField(
              controller: lastnameController,
              hintText: 'Prijmeni',
              obscureText: false,
            ),

            // login name
            const SizedBox(height: 10),
                  MyTextField(
                    controller: loginName,
                    hintText: 'Prihlasovaci jmeno',
                    obscureText: false,
                  ),

            //phone number
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
