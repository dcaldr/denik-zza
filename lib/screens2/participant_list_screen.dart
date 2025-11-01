import 'package:flutter/material.dart';
import 'package:denik_zza/database/database_interface.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/screens2/widgets/app_drawer.dart';
import 'package:denik_zza/screens2/widgets/participant_list_item.dart';
import 'package:denik_zza/screens2/participant_registration_form.dart';

/// Screen displaying list of participants for the current event with search functionality
/// 
/// Features:
/// - Search by name or insurance number
/// - List of participants from current event
/// - Navigation to participant registration
/// - Reuses familiar UI patterns from EventList and EventDetail
class ParticipantListScreen extends StatefulWidget {
  const ParticipantListScreen({super.key});

  @override
  State<ParticipantListScreen> createState() => _ParticipantListScreenState();
}

class _ParticipantListScreenState extends State<ParticipantListScreen> {
  final DatabaseInterface _database = DatabaseWrapper.getDatabase();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filter participants based on search query
  List<MemoryOsoba> _filterParticipants(List<MemoryOsoba> participants) {
    if (_searchQuery.isEmpty) {
      return participants;
    }

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
      key: const Key('ParticipantList_scaffold'),
      appBar: AppBar(
        key: const Key('ParticipantList_appBar'),
        title: const Text('Seznam účastníků'),
        actions: [
          IconButton(
            key: const Key('ParticipantList_addButton'),
            icon: const Icon(Icons.person_add),
            onPressed: () => _navigateToAddParticipant(context),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              key: const Key('ParticipantList_searchField'),
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Hledat účastníka...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // Participants list
          Expanded(
            child: FutureBuilder<List<MemoryOsoba>>(
              future: _database.getParticipantsByCurrentEvent(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    key: Key('ParticipantList_loading'),
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    key: const Key('ParticipantList_error'),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Chyba: ${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final allParticipants = snapshot.data ?? [];
                
                if (allParticipants.isEmpty) {
                  return Center(
                    key: const Key('ParticipantList_empty'),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people_outline, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Žádní účastníci',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _navigateToAddParticipant(context),
                          icon: const Icon(Icons.person_add),
                          label: const Text('Přidat účastníka'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredParticipants = _filterParticipants(allParticipants);

                if (filteredParticipants.isEmpty && _searchQuery.isNotEmpty) {
                  return Center(
                    key: const Key('ParticipantList_noResults'),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'Žádné výsledky pro "$_searchQuery"',
                          style: const TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  key: const Key('ParticipantList_listView'),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: filteredParticipants.length,
                  itemBuilder: (context, index) {
                    return ParticipantListItem(
                      osoba: filteredParticipants[index],
                      index: index,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddParticipant(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ParticipantRegistrationPage(),
      ),
    );
  }
}
