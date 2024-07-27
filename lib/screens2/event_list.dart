import 'package:denik_zza/screens2/event_registration_form.dart';
import 'package:denik_zza/screens2/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:denik_zza/screens2/event_detail.dart';
import 'package:intl/intl.dart';
import '../../database/database_interface.dart';
import '../../database/database_wrapper.dart';
import '../../database/in_memory_structures_tmp/memory_akce.dart';

class EventList extends StatelessWidget {
  final DatabaseInterface database = DatabaseWrapper.getDatabase();

  EventList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: const AppDrawer(),
      body: _buildActionList(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Všechny akce', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EventRegistrationForm())), //TODO: implement real add action page
        ),
        const IconButton(icon: Icon(Icons.search), onPressed: null), // Placeholder for future search functionality
      ],
    );
  }

  Widget _buildActionList() {
    return FutureBuilder<List<MemoryAction>>(
      future: database.getAllZzaActions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => _buildActionItem(context, snapshot.data![index]),
          );
        }
      },
    );
  }



Widget _buildActionItem(BuildContext context, MemoryAction action) {
  final dateFormat = DateFormat('dd.MM.yyyy', 'cs_CZ');
  return FutureBuilder<int>(
    future: database.getParticipantCountInAction(action.idAkce ?? -1),
    builder: (context, participantSnapshot) {
      if (participantSnapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      } else if (participantSnapshot.hasError) {
        return Text('Error: ${participantSnapshot.error}');
      } else {
        return ListTile(
          title: Text(action.nadpis),
          subtitle: Text('${dateFormat.format(action.odkdy)} - ${dateFormat.format(action.dokdy)}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(participantSnapshot.data.toString()),
              const Icon(Icons.people),
            ],
          ),
          onTap: () => _navigateToActionDetail(context, action),
        );
      }
    },
  );
}

  void _navigateToActionDetail(BuildContext context, MemoryAction action) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ActionDetail(action: action)),
    );
  }
}