import 'package:denik_zza/screens/actions/change_profile.dart';
import 'package:denik_zza/screens/editing_actions/edit_action_page.dart';
import 'package:denik_zza/screens/login/components/my_button.dart';
import 'package:denik_zza/screens/participants/add_participantt_page_page.dart';
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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
              SizedBox(height: 20),
              Text(
                'Popis Akce\nZde vložte textový popis akce...',
                style: TextStyle(fontSize: 16),
              ),
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
            ],
          ),
        ),
      ),
    );
  }
}
