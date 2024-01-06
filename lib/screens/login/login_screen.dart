// ignore_for_file: prefer_const_constructors

import 'package:denik_zza/screens/second_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("1st Page")),
      body: Center(
        child: ElevatedButton(
          child: Text("Go to second page"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SecondPage(),
              ),
            );
          },
        ),
      ),
    );
  }
}
