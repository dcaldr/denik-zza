import 'package:denik_zza/print_ops/printer_woodoo.dart';
import 'package:flutter/material.dart';

class PageUI extends StatelessWidget {
   PageUI({super.key});
  PrinterWoodoo printer = PrinterWoodoo();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tisknutí',
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                  onPressed: () {
            printer.printAll();
                   },
                child: Text('tisk všecho'),
),
              SizedBox(height: 10), // Add space between buttons
              ElevatedButton(
                onPressed: () {},
                child: Text('dotisk'),
              ),
              SizedBox(height: 10), // Add space between buttons
              ElevatedButton(
                onPressed: null, // Make this button non-clickable
                child: Text('neimplementováno'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}