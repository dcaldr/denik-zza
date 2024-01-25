

import 'package:flutter/material.dart';

import '../actions/all_actions.dart';
import '../actions/profile.dart';

class OurDrawer extends StatelessWidget {
  const OurDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: const Text(
              'Profil',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
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
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AllActions()),
              );
            },
          ),
        ],
      ),
    );
  }
}