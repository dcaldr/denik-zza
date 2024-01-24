import 'package:denik_zza/screens/actions/change_profile.dart';
import 'package:denik_zza/screens/login/components/my_textfield.dart';
import 'package:flutter/material.dart';
import 'package:denik_zza/screens/actions/all_actions.dart';

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
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangeProfile()),
                );

            },
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text(
                'Profil',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile()),
                );
              },
            ),
            ListTile(
              title: Text(
                'Akce',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
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

        const SizedBox(height: 40),

            // profile message

            const Text(
              'Vítejte na svém profilu!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            // change avatar
             CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/doc.jpg'), // Set your image asset path
            ),
            const SizedBox(height: 10),
           

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
