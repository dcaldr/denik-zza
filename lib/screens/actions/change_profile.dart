import 'package:denik_zza/screens/actions/profile.dart';
import 'package:denik_zza/screens/login/components/my_button.dart';
import 'package:denik_zza/screens/login/components/my_textfield.dart';
import 'package:flutter/material.dart';

class ChangeProfile extends StatelessWidget {
  ChangeProfile({Key? key});
  
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // name 
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Jmeno'),
              ),
              SizedBox(height: 10),

              //
              TextFormField(
                controller: lastnameController,
                decoration: InputDecoration(labelText: 'Prijmeni'),
              ),
              SizedBox(height: 10),

              //
              TextFormField(
                controller: loginNameController,
                decoration: InputDecoration(labelText: 'Prihlasovaci jmeno'),
              ),
              SizedBox(height: 10),
              //

              TextFormField(
                controller: phoneNumberController,
                decoration: InputDecoration(labelText: 'Telefonni cislo'),
              ),
              SizedBox(height: 20),

              //
              TextFormField(
                controller: newPasswordController,
                decoration: InputDecoration(labelText: 'Nove heslo'),
              ),
              SizedBox(height: 10),

              //
              TextFormField(
                controller: newPasswordAgainController,
                decoration: InputDecoration(labelText: 'Heslo znovu'),
              ),
              SizedBox(height: 10),


              // button logic
              Button(
                onPressed: () {
                   Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile()), // profile for now, pop up
                );
                },
                buttonText: "Potvrdit",
                verticalPadding: 20,
                horizontalPadding: 140,
              ),
            ],
          ),
        ),
      ),
    );
  }
}