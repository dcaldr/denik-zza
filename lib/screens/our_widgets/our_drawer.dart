

import 'package:denik_zza/print_ops/printer_ui.dart';
import 'package:flutter/material.dart';

import '../actions/all_actions.dart';
import '../actions/profile.dart';
///One place for Drawer if necerssary
///
/// Our version of drawer //TODO: add icons or something
class OurDrawer extends StatelessWidget {
  const OurDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile( //todo:  extract widget -> prevent repeating code
            title: const Text(
              'Profil',
             // style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profile()),
              );
            },
          ),
          ListTile(
            title: const Text(
              'Akce',
           //   style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AllActions()),
              );
            },
          ),
          ListTile(
            title: const Text('Tisk'),
            onTap:(){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PageUI())
              );
            },
          )
        ],
      ),
    );
  }
}