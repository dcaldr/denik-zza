import 'package:flutter/material.dart';


class Button extends StatelessWidget {
    Button({super.key,required this.onTap});

   Function()? onTap;
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap:  onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(color: Colors.black,
        borderRadius: BorderRadius.circular(8),),
        child: const Center(child: Text("Přihlásit se",
        style: TextStyle(color: Colors.white,
         fontWeight: FontWeight.bold,
         fontSize: 16,
         ),
       
        ),
        ),
      ),
    );
  } 
  
  }