import 'package:denik_zza/screens/actions/profile.dart';
import 'package:denik_zza/screens/editing_actions/action_detail.dart';
import 'package:denik_zza/screens/editing_actions/add_action.dart';
import 'package:flutter/material.dart';
import 'package:denik_zza/screens/login/login_page.dart';

import '../../database/database_interface.dart';
import '../../database/database_wrapper.dart';
import '../../database/in_memory_structures_tmp/memory_action.dart';

/// A widget representing the screen that displays all actions.
class AllActions extends StatelessWidget {
  /// The database interface used for accessing actions.
  final DatabaseInterface database = DatabaseWrapper.getDatabase();

  /// Constructor for initializing the AllActions widget.
  AllActions({super.key});

  @override
  Widget build(BuildContext context) {
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
          const IconButton(
            icon: Icon(Icons.search),
            onPressed: null,
            // onPressed: () {
            //   showSearch(context: context, delegate: CustomSearchDelegate());
            // },
          ),
        ],
      ),
      // Drawer widget for displaying navigation options.
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  // Menu items for navigating to the profile and all actions.
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
                  )
                  // Add more menu items as needed
                ],
              ),
            ),
            const Divider(), // Divider to separate the main items from logout

            // Menu item for logging out.
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
                  MaterialPageRoute(
                      builder: (context) => Login()), // Navigate to Login page
                ); // Replace '/login' with your login page route
              },
            ),
          ],
        ),
      ),
      // ... (rest of the build method)
    );
  }
}

/// A widget representing an individual action item in the list.
class ActionItem extends StatelessWidget {
  /// The number of participants in the action.
  final int participants;

  /// The memory representation of the action.
  final MemoryAction action;

  /// Constructor for initializing the ActionItem widget.
  const ActionItem({super.key, required this.action, required this.participants});

  @override
  Widget build(BuildContext context) {
    // Access the database interface.
    DatabaseInterface db = DatabaseWrapper.getDatabase();

    // ListTile displaying action information.
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(action.nadpis), // Title
          ),
          Expanded(
            child: Text(
              '${action.odkdy?.day.toString().padLeft(2, '0')}.${action.odkdy?.month.toString().padLeft(2, '0')}.${action.odkdy?.year} - ${action.dokdy?.day.toString().padLeft(2, '0')}.${action.dokdy?.month.toString().padLeft(2, '0')}.${action.dokdy?.year}'), // Date
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(participants.toString().padLeft(3, ' ')),
                const Icon(Icons.people),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Update the current event in the database.
              db.updateCurrentEvent(action.idAkce);
              // Navigate to the ActionDetail page for the selected action.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActionDetail(
                    action: action,
                  ),
                ),
              );
              print('Here');
            },
            child: const Text('Detail'),
          ),
        ],
      ),
    );
  }
}

/// A search delegate for handling search actions.
class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    // Build search actions, such as clearing the query.
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
    // Build leading icon, such as the back button.
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
