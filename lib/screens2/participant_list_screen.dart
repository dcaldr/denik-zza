import 'package:flutter/material.dart';
import 'package:denik_zza/database/database_interface.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_akce.dart';
import 'package:denik_zza/screens2/widgets/app_drawer.dart';
import 'package:denik_zza/screens2/widgets/participant_list_item.dart';
import 'package:denik_zza/screens2/widgets/person_autocomplete.dart';
import 'package:denik_zza/screens2/participant_registration_form.dart';
import 'package:denik_zza/screens2/event_detail.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';

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
  List<MemoryOsoba> _allParticipants = [];
  List<MemoryOsoba> _displayedParticipants = [];
  MemoryAction? _currentAction;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
    _loadCurrentAction();
  }

  Future<void> _loadCurrentAction() async {
    final action = await _database.getCurrentAction();
    if (!mounted) return;
    setState(() {
      _currentAction = action;
    });
  }

  Future<void> _loadParticipants() async {
    final participants = await _database.getParticipantsByCurrentEvent();
    if (!mounted) return;
    setState(() {
      _allParticipants = participants;
      _displayedParticipants = participants;
    });
  }

  void _handlePersonSelected(MemoryOsoba person) {
    // When person selected from dropdown, show only that person
    setState(() {
      _displayedParticipants = [person];
    });
  }

  Widget _buildParticipantsList() {
    if (_allParticipants.isEmpty) {
      final hasEvent = _currentAction != null;
      return Center(
        key: const Key('ParticipantList_empty'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              hasEvent ? 'Žádní účastníci' : 'Nejprve vytvořte akci',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            if (hasEvent) ...[
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _navigateToAddParticipant(context),
                icon: const Icon(Icons.person_add),
                label: const Text('Přidat účastníka'),
              ),
            ],
          ],
        ),
      );
    }

    if (_displayedParticipants.isEmpty) {
      return const Center(
        key: Key('ParticipantList_noResults'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Žádné výsledky',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      key: const Key('ParticipantList_listView'),
      padding: AppSpacing.screenPadding,
      itemCount: _displayedParticipants.length,
      itemBuilder: (context, index) {
        return ParticipantListItem(
          osoba: _displayedParticipants[index],
          index: index,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('ParticipantList_scaffold'),
      appBar: AppBar(
        key: const Key('ParticipantList_appBar'),
        title: const Text('Seznam účastníků'),
        actions: [
          // Navigate to current action/event detail
          if (_currentAction != null)
            IconButton(
              key: const Key('ParticipantList_eventDetailButton'),
              icon: const Icon(Icons.event),
              tooltip: 'Detail akce',
              onPressed: () => _navigateToActionDetail(context),
            ),
          if (_currentAction != null)
            IconButton(
              key: const Key('ParticipantList_addButton'),
              icon: const Icon(Icons.person_add),
              tooltip: 'Přidat účastníka',
              onPressed: () => _navigateToAddParticipant(context),
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Search field using PersonAutocomplete widget (stable focus management)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PersonAutocomplete(
              key: const Key('ParticipantList_autocomplete'),
              textFieldKey: const Key('ParticipantList_searchField'),
              availablePersons: _allParticipants,
              onPersonSelected: _handlePersonSelected,
              onRefresh: _loadParticipants,
            ),
          ),
          // Participants list
          Expanded(
            child: _buildParticipantsList(),
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

  void _navigateToActionDetail(BuildContext context) {
    if (_currentAction == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActionDetail(action: _currentAction!),
      ),
    );
  }
}
