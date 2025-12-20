///FIXME: Right now it "just works"  but needs to be heavily refactored
import 'package:denik_zza/database/database_interface.dart';
import 'package:denik_zza/screens/participants/add_participant_page.dart';
import 'package:denik_zza/screens2/widgets/participant_list_item.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

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
  final Logger _logger = AppLogger.l;

  /// Database instance for interacting with the data.
  final DatabaseInterface database = DatabaseWrapper.getDatabase();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); // Stable focus node
  String _searchQuery = '';

  // Data state management - load once in initState, filter in memory
  List<MemoryOsoba> _allParticipants = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose(); // Dispose focus node
    super.dispose();
  }

  /// Load participants once in initState, not in build()
  /// This prevents TextField from being recreated on setState
  Future<void> _loadParticipants() async {
    try {
      final participants =
          await database.getParticipantsByEvent(widget.action.idAkce!);
      if (!mounted) return;
      setState(() {
        _allParticipants = participants;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      _logger.e('Chyba při načítání účastníků akce', error: e);
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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

      // Load data in initState, not FutureBuilder - prevents TextField recreation
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Chyba: $_error'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: AppSpacing.screenPadding,
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
                            Text('Počet účastníků: ${_allParticipants.length}'),
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
                        AppSpacing.largeGap,
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
                                focusNode:
                                    _searchFocusNode, // Use stable focus node
                                decoration: const InputDecoration(
                                  hintText: 'Hledat účastníka...',
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: AppRadii.inputRadius,
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: AppSpacing.s),
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
                        AppSpacing.smallGap,
                        const Text(
                          'Účastníci',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        // Apply search filter
                        ..._filterParticipants(_allParticipants)
                            .asMap()
                            .entries
                            .map((entry) => ParticipantListItem(
                                  osoba: entry.value,
                                  index: entry.key,
                                )),
                        // Show message if no results
                        if (_searchQuery.isNotEmpty &&
                            _filterParticipants(_allParticipants).isEmpty)
                          Center(
                            child: Padding(
                              padding: AppSpacing.screenPadding,
                              child: Column(
                                children: [
                                  const Icon(Icons.search_off,
                                      size: 48, color: Colors.grey),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Žádné výsledky pro "$_searchQuery"',
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
