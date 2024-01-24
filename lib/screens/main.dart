import 'package:denik_zza/screens/login/login_page.dart';
import 'package:denik_zza/screens/login/register_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // for deleting the debug text
      home: Login(),
      routes: {
        '/register_screen':(context) => RegisterScreen(),
        //'/profile_screen':(context) => Profile(),
      },
    );
  }
}
