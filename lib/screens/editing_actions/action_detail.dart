import 'package:denik_zza/screens/login/components/my_button.dart';
import 'package:flutter/material.dart';


class ActionDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Akce'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ikona pro "lidé"
              Row(
                children: [
                  Icon(Icons.people, size: 50),
                  Text('150'),
                ],
              ),

              // Ikona pro "kalendář" a zobrazení data
              Row(
                children: [
                  Icon(Icons.calendar_month, size: 50),
                  Text('Datum: 1.5. - 15.9.'),
                ],
              ),

              // Ikona pro "lokace" a název lokace
              Row(
                children: [
                  Icon(Icons.location_city, size: 50),
                  Text('Velká Chmelistná'),
                ],
              ),

              // Popis akce
              SizedBox(height: 20),
              Text(
                'Popis Akce\nZde vložte textový popis akce...',
                style: TextStyle(fontSize: 16),
              ),

              // Sekce pro účastníky
              SizedBox(height: 20),
              Text(
                'Účastníci',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              // Search bar pro hledání účastníků
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  // Corrected syntax for displaying text
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Hledat účastníka"),
                        // Add your search functionality here
                        content: Text("Custom search functionality"),
                      );
                    },
                  );
                },
              ),

              SizedBox(height: 10),
              // Tlačítko pro přidání účastníka
            Button(
                onPressed: () {
                  //
                },
                buttonText: "Pridat",
                verticalPadding: 20,
                horizontalPadding: 160,
              ),

              // Zde se budou zobrazovat účastníci
              // (Můžete použít ListView nebo GridView podle potřeby)
            ],
          ),
        ),
      ),
    );
  }
}