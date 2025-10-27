import 'package:denik_zza/screens2/csv/import_screen.dart';
import 'package:denik_zza/screens2/event_list.dart';
import 'package:denik_zza/screens2/event_registration_form.dart';
import 'package:denik_zza/screens2/intake_form.dart';
import 'package:denik_zza/screens2/intake_form_improved.dart';
import 'package:denik_zza/screens2/participant_registration_form.dart';
import 'package:denik_zza/print_ops2/print_center.dart';
import 'package:flutter/material.dart';


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
                MaterialPageRoute(builder: (context) => const ParticipantRegistrationPage()),
              );
            },
          ),
          ListTile(
            key: const Key('AppDrawer_csv_import'),
            title: const Text('Import CSV'),
            subtitle: const Text('Hromadný import účastníků'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CsvImportScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Příjmací formulář'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const IntakeForm()),
              );
            },
          ),
          ListTile(
            title: const Text('Příjmací formulář (Vylepšený)'),
            subtitle: const Text('Test verze s kontrolérem'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TmpIntakeFormImproved()),
              );
            },
          )
          ,
          const Divider(),
          ListTile(
            title: const Text('Tisk Centrum (Nové)'),
            subtitle: const Text('UI náhled'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrintCenterPage()),
              );
            },
          ),

        ],
      ),
    );
  }
}