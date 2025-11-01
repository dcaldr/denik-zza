///FIXME: Right now it "just works"  but needs to be heavily refactored
import 'package:denik_zza/database/database_interface.dart';
import 'package:denik_zza/screens/participants/add_participant_page.dart';
import 'package:denik_zza/screens2/widgets/participant_list_item.dart';
import 'package:flutter/material.dart';

import '../../database/database_wrapper.dart';
import '../../database/in_memory_structures_tmp/memory_akce.dart';
import '../../database/in_memory_structures_tmp/memory_osoba.dart';

/// Widget of class ActionDetail.
class ActionDetail extends StatefulWidget {
  final MemoryAction action;

  const ActionDetail({super.key, required this.action});

  @override
  State<ActionDetail> createState() => _ActionDetailState();
}

class _ActionDetailState extends State<ActionDetail> {
  /// Database instance for interacting with the data.
  final DatabaseInterface database = DatabaseWrapper.getDatabase();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filters participants based on search query
  List<MemoryOsoba> _filterParticipants(List<MemoryOsoba> participants) {
    if (_searchQuery.isEmpty) return participants;
    
    final query = _searchQuery.toLowerCase();
    return participants.where((person) {
      return person.jmeno.toLowerCase().contains(query) ||
             person.prijmeni.toLowerCase().contains(query) ||
             (person.cisloPojisteni?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Akce: ${widget.action.nadpis}'),
        actions: const [
          IconButton(
            //TODO: could  be rewritten to prefill new action
            icon: Icon(Icons.edit),
            onPressed: null,
            // onPressed: () {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => const EditActionPage()),
            //   );
            // },
          ),
        ],
      ),

      // Using FutureBuilder to asynchronously fetch and display a list of participants
      body: FutureBuilder<List<MemoryOsoba>>(
        future: database.getParticipantsByEvent(widget.action.idAkce!),
        builder:
            (BuildContext context, AsyncSnapshot<List<MemoryOsoba>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 0),
                    Text(
                      widget.action.nadpis,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    Row(
                      children: [
                        const Icon(Icons.people, size: 50),
                        Text('Počet účastníků: ${snapshot.data!.length}'),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, size: 50),
                        Text(
                            'Datum: ${widget.action.odkdy.day.toString().padLeft(2, '0')}.${widget.action.odkdy.month.toString().padLeft(2, '0')}.${widget.action.odkdy.year} - ${widget.action.dokdy.day.toString().padLeft(2, '0')}.${widget.action.dokdy.month.toString().padLeft(2, '0')}.${widget.action.dokdy.year}'), //TODO: improve as mentioned in pdf.dart //DT1 //DT2
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 20),
                    Text(
                      'Popis Akce\n${widget.action.popis}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Divider(),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        // Search bar for participants
                        Expanded(
                          child: TextField(
                            key: const Key('EventDetail_searchField'),
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Hledat účastníka...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          key: const Key('EventDetail_addButton'),
                          icon: const Icon(Icons.person_add),
                          onPressed: () {
                            // Navigate to another screen for adding a participant
                            // You need to create the AddParticipantPage
                            // and handle the logic for adding participants.
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AddParticipantPage()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Účastníci',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    // Apply search filter
                    ..._filterParticipants(snapshot.data!)
                        .asMap()
                        .entries
                        .map((entry) => ParticipantListItem(
                              osoba: entry.value,
                              index: entry.key,
                            )),
                    // Show message if no results
                    if (_searchQuery.isNotEmpty && _filterParticipants(snapshot.data!).isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              const Icon(Icons.search_off, size: 48, color: Colors.grey),
                              const SizedBox(height: 10),
                              Text(
                                'Žádné výsledky pro "$_searchQuery"',
                                style: const TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
