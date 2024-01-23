import 'package:denik_zza/screens/actions/change_profile.dart';
import 'package:denik_zza/screens/editing_actions/edit_action_page.dart';
import 'package:denik_zza/screens/login/components/my_button.dart';
import 'package:denik_zza/screens/participants/add_participantt_page_page.dart';
import 'package:denik_zza/screens/participants/paticipant_detail_page.dart';
import 'package:flutter/material.dart';

class ActionDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Akce'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigate to another screen for editing the profile
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditActionPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 0),
              Text(
                'Tábor Jurský Park',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Divider(),
              Row(
                children: [
                  Icon(Icons.people, size: 50),
                  Text('150'),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.calendar_month, size: 50),
                  Text('Datum: 1.5. - 15.9.'),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.location_city, size: 50),
                  Text('Velká Chmelistná'),
                ],
              ),
              Divider(),
              SizedBox(height: 20),
              Text(
                'Popis Akce\nZde vložte textový popis akce...',
                style: TextStyle(fontSize: 16),
              ),
              Divider(),
              SizedBox(height: 20),
              Text(
                'Účastníci',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  // Search bar for participants
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Hledat účastníka...',
                        suffixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.person_add),
                    onPressed: () {
                      // Navigate to another screen for adding a participant
                      // You need to create the AddParticipantPage
                      // and handle the logic for adding participants.
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddParticipantPage()),
                      );
                    },
                  ),
                ],
              ),
              Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
          ),
              // List of actions
              ParticipantItem(title: 'Jan Novotný', date: '2022-01-01'),
              ParticipantItem(title: 'Jan Novotný', date: '2022-01-01'),
              ParticipantItem(title: 'Jan Novotný', date: '2022-01-01')
              // Add more ActionItem widgets as needed
            ],
          ),
        ),
      ),
    );
  }
}

class ParticipantItem extends StatelessWidget {
  final String title;
  final String date;

  ParticipantItem({required this.title, required this.date});

  @override
Widget build(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      color: Color.fromARGB(255, 226, 226, 226), // Change the color as needed
      borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
    ),
    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0), // Adjust vertical padding
    margin: EdgeInsets.only(bottom: 10.0),
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
                MaterialPageRoute(builder: (context) => ParticipantDetailPage()),
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