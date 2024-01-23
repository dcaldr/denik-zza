import 'package:denik_zza/screens/actions/profile.dart';
import 'package:denik_zza/screens/editing_actions/action_detail.dart';
import 'package:denik_zza/screens/editing_actions/add_action.dart';
import 'package:flutter/material.dart';
import 'package:denik_zza/screens/login/login_page.dart';

import '../../database/database_interface.dart';
import '../../database/database_wrapper.dart';
import '../../database/in_memory_structures_tmp/memory_action.dart';
class AllActions extends StatelessWidget {
  AllActions({super.key});
  final DatabaseInterface database = DatabaseWrapper.getDatabase();


  @override
  Widget build(BuildContext context) {
    List<MemoryAction> allActions = await database.getAllZzaActions();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Všechny akce',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddActionPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: CustomSearchDelegate());
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: const Text(
                      'Profil',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
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
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AllActions()),
                      );
                    },
                  ),
                  // Add more menu items as needed
                ],
              ),
            ),
            const Divider(), // Divider to separate the main items from logout
            ListTile(
              title: const Text(
                'Odhlásit se',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red, // Customize the color as needed
                ),
              ),
              onTap: () {
                Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Login()), // Navigate to Login page
          ); // Replace '/login' with your login page route
              },
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          // Search bar and add action button

          // Table headers
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nazev akce'),
                Text('Datum konani'),
                Row(
                  children: [
                    Text('Pocet ucastniku'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          // List of actions
          ActionItem(title: 'Akce 1', date: '2022-01-01', participants: 20),
          ActionItem(title: 'Akce 2', date: '2022-02-15', participants: 15),
          ActionItem(title: 'Akce 3', date: '2022-03-20', participants: 30),
          // Add more ActionItem widgets as needed
        ],
      ),
    );
  }
}

class ActionItem extends StatelessWidget {
  final String title;
  final String date;
  final int participants;

  ActionItem({required this.title, required this.date, required this.participants});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(date),
          Row(
            children: [
              Text(participants.toString()),
              const Icon(Icons.people),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ActionDetail()),
                );
            },
            child: const Text('Detail'),
          ),
        ],
      ),
      // Customize the ListTile as needed
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Implement your search results UI here
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Implement your search suggestions UI here
    return Container();
  }
}