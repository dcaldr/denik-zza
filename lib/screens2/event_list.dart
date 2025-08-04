import 'package:denik_zza/screens2/event_registration_form.dart';
import 'package:denik_zza/screens2/widgets/app_drawer.dart';
import 'package:denik_zza/screens2/widgets/event_list_constants.dart';
import 'package:flutter/material.dart';
import 'package:denik_zza/screens2/event_detail.dart';
import 'package:intl/intl.dart';
import '../../database/database_interface.dart';
import '../../database/database_wrapper.dart';
import '../../database/in_memory_structures_tmp/memory_akce.dart';

class EventList extends StatefulWidget {
  final DatabaseInterface database = DatabaseWrapper.getDatabase();

  EventList({super.key});

  @override
  _EventListState createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  int? _currentEventID;

  @override
  void initState() {
    super.initState();
    _fetchCurrentEventID();
  }

  void _fetchCurrentEventID() async {
    _currentEventID = await widget.database.getCurrentEventID();
    setState(() {});
  }

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
      title: const Text(
        EventListConstants.title, 
        style: EventListConstants.titleStyle
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _navigateToEventRegistration(context),
        ),
        const IconButton(
          icon: Icon(Icons.search), 
          onPressed: null
        ), // Placeholder for future search functionality
      ],
    );
  }

  Widget _buildActionList() {
    return FutureBuilder<List<MemoryAction>>(
      future: widget.database.getAllZzaActions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();        } else if (snapshot.hasError) {
          return Text('${EventListConstants.errorPrefix}${snapshot.error}');
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => _buildActionItem(context, snapshot.data![index]),
          );
        }
      },
    );
  }

  void _handlePinnedChanged(MemoryAction event) {
    setState(() {
      if(event.idAkce == _currentEventID) {
        widget.database.updateCurrentEvent(null);
      }
      else {
        widget.database.updateCurrentEvent(event.idAkce);
      }

      _fetchCurrentEventID();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(EventListConstants.pinChangedMessage),
        )
      );
    });
  }

  Widget _buildActionItem(BuildContext context, MemoryAction action) {
    final dateFormat = DateFormat('dd.MM.yyyy', 'cs_CZ');
    return FutureBuilder<int>(
      future: widget.database.getParticipantCountInAction(action.idAkce ?? -1),
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
                IconButton(
                  icon: Icon(action.idAkce == _currentEventID ? Icons.push_pin : Icons.push_pin_outlined),
                  onPressed: () => _handlePinnedChanged(action),
                ),
              ],
            ),
            onTap: () => _navigateToActionDetail(context, action),
          );
        }
      },
    );
  }

  void _navigateToEventRegistration(BuildContext context) {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const EventRegistrationForm())
    );
  }

  void _navigateToActionDetail(BuildContext context, MemoryAction action) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ActionDetail(action: action)),
    );
  }
}