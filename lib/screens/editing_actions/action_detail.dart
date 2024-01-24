import 'package:denik_zza/database/database_interface.dart';
import 'package:denik_zza/screens/actions/change_profile.dart';
import 'package:denik_zza/screens/editing_actions/edit_action_page.dart';
import 'package:denik_zza/screens/login/components/my_button.dart';
import 'package:denik_zza/screens/participants/add_participantt_page_page.dart';
import 'package:denik_zza/screens/participants/paticipant_detail_page.dart';
import 'package:flutter/material.dart';

import '../../database/database_wrapper.dart';
import '../../database/in_memory_structures_tmp/memory_action.dart';
import '../../database/in_memory_structures_tmp/memory_osoba.dart';
class ActionDetail extends StatelessWidget {
  final MemoryAction action;
  final DatabaseInterface database = DatabaseWrapper.getDatabase();

  ActionDetail({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Akce: ${action.nadpis}'),
        actions: const [
          IconButton(   //TODO: could  be rewritten to prefill new action
            icon: Icon(Icons.edit),
            onPressed: null,
            // onPressed: () {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => const EditActionPage()),
            //   );
            // },
          ),
        ],
      ),
      body: FutureBuilder<List<MemoryOsoba>>(
        future: database.getParticipantsByCurrentEvent(),
        builder: (BuildContext context, AsyncSnapshot<List<MemoryOsoba>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return SingleChildScrollView(
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
                    Row(
                      children: [
                        const Icon(Icons.people, size: 50),
                        Text('Počet účastníků: ${snapshot.data!.length}'),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, size: 50),
                        Text('Datum: ${action.odkdy?.day.toString().padLeft(2, '0')}.${action.odkdy?.month.toString().padLeft(2, '0')}.${action.odkdy?.year} - ${action.dokdy?.day.toString().padLeft(2, '0')}.${action.dokdy?.month.toString().padLeft(2, '0')}.${action.dokdy?.year}'), //TODO: improve as mentioned in pdf.dart //DT1 //DT2
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
                    Row(
                      children: [
                        // Search bar for participants
                        const Expanded(
                          child: TextField(
                            enabled: false,
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
                    const Text(
                      'Účastníci',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ...snapshot.data!.map((osoba) => ParticipantItem(osoba: osoba)),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class ParticipantItem extends StatelessWidget {
  final MemoryOsoba osoba;

  ParticipantItem({super.key,required this.osoba});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 226, 226, 226),
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      margin: const EdgeInsets.only(bottom: 10.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 1.0),
        title: Row(
          children: [
            Expanded(
              child: Text('${osoba.jmeno} ${osoba.prijmeni}'), // jméno
            ),
            Expanded(
              child: Text('${osoba.datumNarozeni?.day.toString().padLeft(2, '0')}.${osoba.datumNarozeni?.month.toString().padLeft(2, '0')}.${osoba.datumNarozeni?.year}'), // date //TODO: improve as mentioned in pdf.dart //DT1)
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ParticipantDetailPage( ucastnik: osoba,)),
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