import 'package:denik_zza/print_ops/printer_ui.dart';
import 'package:flutter/material.dart';

/// The main method of class.
void main() {
  runApp(const Tempik());
}

/// The root widget of the application, responsible for setting up the MaterialApp.
class Tempik extends StatelessWidget {
  const Tempik({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: PageUI(),
    );
  }
}