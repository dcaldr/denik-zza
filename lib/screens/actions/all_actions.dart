
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
              MaterialPageRoute(builder: (context) =>  AddActionPage()),
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
                MaterialPageRoute(
                    builder: (context) => Login()), // Navigate to Login page
              ); // Replace '/login' with your login page route
            },
          ),
        ],
      ),
    ),
    body: FutureBuilder<List<MemoryAction>>(
  future: database.getAllZzaActions(),
  builder: (BuildContext context, AsyncSnapshot<List<MemoryAction>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    } else if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      return ListView.builder(
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          MemoryAction action = snapshot.data![index];
          return FutureBuilder<int>(
            future: database.getParticipantCountInAction(action.idAkce ?? -1),
            builder: (BuildContext context, AsyncSnapshot<int> participantSnapshot) {
              if (participantSnapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (participantSnapshot.hasError) {
                return Text('Error: ${participantSnapshot.error}');
              } else {
                return ActionItem(
                  action: action,
                  participants: participantSnapshot.data!,
                );
              }
            },
          );
        },
      );
    }
  },
),
  );
}
}

class ActionItem extends StatelessWidget {
  // final String title;
  // final String date;
  final int participants;
  final MemoryAction action;

  const ActionItem({super.key, required this.action, required this.participants});

  @override
  Widget build(BuildContext context) {
    DatabaseInterface db = DatabaseWrapper.getDatabase();
    return ListTile(
  title: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(action.nadpis), //title
      ),
      Expanded(
        child: Text(

          '${action.odkdy?.day.toString().padLeft(2, '0')}.${action.odkdy?.month.toString().padLeft(2, '0')}.${action.odkdy?.year} - ${action.dokdy?.day.toString().padLeft(2, '0')}.${action.dokdy?.month.toString().padLeft(2, '0')}.${action.dokdy?.year}'), // date //TODO: improve as mentioned in pdf.dart //DT1 //DT2
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
        onPressed: ()  {
          //FIXME
          db.updateCurrentEvent(action.idAkce);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ActionDetail(
                      action: action,
                    )),
          );
          print('Here');
        },
        //    onPressed: null,
        child: const Text('Detail'),
      ),
    ],
  ),
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
    // TODO: Implement your search results UI here
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: Implement your search suggestions UI here
    return Container();
  }
}
