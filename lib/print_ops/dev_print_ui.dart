import 'package:denik_zza/print_ops/printer_ui.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(Tempik());
}

class Tempik extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: PageUI(),
    );
  }
}