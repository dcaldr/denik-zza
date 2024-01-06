import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

void main() {
  runApp(const MyApp());
}

/*
 https://www.youtube.com/watch?v=HQ_ytw58tC4&t=20s&ab_channel=MitchKoko
 https://www.figma.com/file/UFtYbWaZOjjyK0OkjN1eHL/Den%C3%ADk-ZZA?type=design&node-id=0-1&mode=design&t=ljxD6YfuybVZWLmH-0
 */

/* 

REFORMATING IN VISUAL CODE -> SHIFT + ALT + F

1) PADDING 
padding: EdgeInsets.only(left: 100,bottom: 50),
EdgeInsets.all(60),
EdgeInsets.symmetric(horizontal: 25,vertical: 30),


2) TEXT
Text(
            "Přihlášení",
            style: TextStyle(
              color: Colors.green, // changing color of the text
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          )
  
3) ICONS
Icon(
            Icons.favorite,
            color: Colors.red,
            size: 50,
          )
 */
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // for deleting the debug text
      home: Scaffold(
        // phone main screen
        appBar: AppBar(

          
        ),
        backgroundColor: Color.fromARGB(255, 219, 141, 167),
        body: Center(
            // container
            child: Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20), // rounded fields
          ),
          padding: EdgeInsets.all(30),
          child: Icon(
            Icons.favorite,
            color: Colors.red,
            size: 50,
          ),
        )),
      ),
    );
  }
}
