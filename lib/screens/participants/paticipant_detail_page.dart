import 'package:denik_zza/screens/records/new_record_page.dart';
import 'package:denik_zza/screens/records/record_detail_page.dart';
import 'package:flutter/material.dart';

class ParticipantDetailPage extends StatelessWidget {
  // Placeholder participant data
  final String participantName = "Jan Novotný";
  final String birthDate = "1990-01-01";
  final String gender = "Muž";
  final String insuranceCompany = "Pojišťovna XYZ";
  final String phoneNumber = "123456789";
  final String location = "Praha";
  final String nonInfectiousConfirmation = "Ano";
  final String eligibleConfirmation = "Ano";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Účastníka'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigate to another screen for editing participant details
              // Replace `EditParticipantPage` with your actual edit page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditParticipantPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 0),
            Text(
              participantName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Divider(),
            // Bubbles with participant information
            Expanded(
              child: ListView(
                children: [
                  InfoBubble(label: 'Datum Narození', value: birthDate),
                  InfoBubble(label: 'Pohlaví', value: gender),
                  InfoBubble(label: 'Pojišťovna', value: insuranceCompany),
                  InfoBubble(label: 'Číslo pojištění', value: phoneNumber),
                  InfoBubble(label: 'Lokace', value: location),
                  InfoBubble(label: 'Bezinfekčnost', value: nonInfectiousConfirmation),
                  InfoBubble(label: 'Způsobilost', value: eligibleConfirmation),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Záznam o nemoci section
            Text(
              'Záznam o Nemoci/Ošetření',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                // Buttons for new záznam and printing
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NewRecordPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 25,
                    ),
                  ),
                  child: Text(
                    'Nový Záznam',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Implement logic for printing the záznam
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 255, 251, 245),
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 25,
                    ),
                  ),
                  child: Text(
                    'Tisk Záznamu',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            // List of previous záznamy
            // Replace `PreviousZaznam` with your actual záznam widget
            PreviousZaznam(title: 'Zranění 1', date: '2022-01-01'),
            PreviousZaznam(title: 'Zranění 2', date: '2022-02-01'),
            // Add more PreviousZaznam widgets as needed
          ],
        ),
      ),
    );
  }
}

// Placeholder widget for the bubbles
class InfoBubble extends StatelessWidget {
  final String label;
  final String value;

  InfoBubble({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 226, 226, 226),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      margin: EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.black),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

// Placeholder widget for previous záznamy
class PreviousZaznam extends StatelessWidget {
  final String title;
  final String date;

  PreviousZaznam({required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 226, 226, 226),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      margin: EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 1.0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(date),
            ElevatedButton(
              onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RecordDetailPage()),
              );
              },
              child: Text('Detail'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditParticipantPage extends StatelessWidget {
  // Placeholder widget for editing participant details
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upravit'),
      ),
      body: Center(
        child: Text('Prostě to musím dodělat chcípám z toho'),
      ),
    );
  }
}
