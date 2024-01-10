import 'package:denik_zza/screens/actions/profile.dart';
import 'package:denik_zza/screens/editing_actions/add_action.dart';
import 'package:flutter/material.dart';

class AllActions extends StatelessWidget {
  AllActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Všechny akce',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddActionPage()),
                );
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: CustomSearchDelegate());
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text(
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
              title: Text(
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
            // Add more menu items as needed
          ],
        ),
      ),
      body: ListView(
        children: [
          // Search bar and add action button

          // Table headers
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nazev akce'),
                Text('Datum konani'),
                Row(
                  children: [
                    Text('Pocet ucastniku'),
                    Icon(Icons.people),
                  ],
                ),
              ],
            ),
          ),
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
              Icon(Icons.people),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              // Handle detail button press
              // You can navigate to the detailed view for the selected action
            },
            child: Text('Detail'),
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
        icon: Icon(Icons.close),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
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