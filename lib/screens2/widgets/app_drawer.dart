import 'package:denik_zza/screens2/event_list.dart';
import 'package:denik_zza/screens2/event_registration_form.dart';
import 'package:denik_zza/screens2/participant_registration_form.dart';
import 'package:flutter/material.dart';

import '../../screens/actions/all_actions.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: const Text('Seznam akcí'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EventList()),
              );
            },
          ),
          ListTile(
            title: const Text('Přidat akci'),
            onTap:(){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EventRegistrationForm()),
              );
            },
          ),
          ListTile(
            title: const Text('Nový Účastník'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ParticipantRegistrationForm()),
              );
            },
          ),

        ],
      ),
    );
  }
}