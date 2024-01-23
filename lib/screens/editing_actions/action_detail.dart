import 'package:denik_zza/database/database_interface.dart';
import 'package:denik_zza/screens/actions/change_profile.dart';
import 'package:denik_zza/screens/editing_actions/edit_action_page.dart';
import 'package:denik_zza/screens/login/components/my_button.dart';
import 'package:denik_zza/screens/participants/add_participantt_page_page.dart';
import 'package:denik_zza/screens/participants/paticipant_detail_page.dart';
import 'package:flutter/material.dart';

import '../../database/database_wrapper.dart';
import '../../database/in_memory_structures_tmp/memory_action.dart';

class ActionDetail extends StatelessWidget {
  final MemoryAction action;
  // DatabaseInterface db = DatabaseWrapper.getDatabase();

  const ActionDetail({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Akce: ${action.nadpis}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to another screen for editing the profile
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditActionPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 0),
              Text(
                action.nadpis,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              const Row(
                children: [
                  Icon(Icons.people, size: 50),
                  Text('Počet účastníků: -150'),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_month, size: 50),
                  Text('Datum: ''${action.odkdy?.day.toString().padLeft(2, '0')}.${action.odkdy?.month.toString().padLeft(2, '0')}.${action.odkdy?.year}'),
                ],
              ),
              const Divider(),
              const SizedBox(height: 20),
              Text(
                'Popis Akce\n${action.popis}',
                style: const TextStyle(fontSize: 16),
              ),
              const Divider(),
              const SizedBox(height: 20),
              const Text(
                'Účastníci',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  // Search bar for participants
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Hledat účastníka...',
                        suffixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_add),
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
              const Padding(
                padding: EdgeInsets.all(8.0),
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

  ParticipantItem({super.key, required this.title, required this.date});

  @override
Widget build(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 226, 226, 226), // Change the color as needed
      borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
    ),
    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0), // Adjust vertical padding
    margin: const EdgeInsets.only(bottom: 10.0),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 1.0),
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
            child: const Text('Detail'),
          ),
        ],
      ),
    ),
  );
}
}