import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/screens2/csv/import_screen.dart';
import 'package:denik_zza/screens2/event_list.dart';
import 'package:denik_zza/screens2/event_registration_form.dart';
import 'package:denik_zza/screens2/intake_form_improved.dart';
import 'package:denik_zza/screens2/new_record_page.dart';
import 'package:denik_zza/screens2/participant_registration_form.dart';
import 'package:denik_zza/print_ops2/print_center.dart';
import 'package:flutter/material.dart';

/// Simplified menu drawer with state-based item enabling
/// MVP approach: StatelessWidget + FutureBuilder for clean async state checking
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  /// Check if current event is selected
  Future<bool> _hasCurrentEvent() async {
    final db = DatabaseWrapper.getDatabase();
    final currentAction = await db.getCurrentAction();
    return currentAction != null;
  }

  /// Check if current event has participants
  Future<bool> _hasParticipants() async {
    final db = DatabaseWrapper.getDatabase();
    try {
      final participants = await db.getParticipantsByCurrentEvent();
      return participants.isNotEmpty;
    } catch (e) {
      return false; // If no event or error, no participants
    }
  }

  /// Check state for menu enabling logic
  Future<Map<String, bool>> _checkState() async {
    final hasEvent = await _hasCurrentEvent();
    if (!hasEvent) {
      return {'hasEvent': false, 'hasParticipants': false};
    }
    final hasParticipants = await _hasParticipants();
    return {'hasEvent': true, 'hasParticipants': hasParticipants};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, bool>>(
      future: _checkState(),
      builder: (context, snapshot) {
        // Show simple loading state while checking
        if (!snapshot.hasData) {
          return const Drawer(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final state = snapshot.data!;
        final hasEvent = state['hasEvent']!;
        final hasParticipants = state['hasParticipants']!;

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildHeader(context),
              _buildSectionHeader('UDÁLOSTI'),
              _buildEventList(context),
              _buildAddEvent(context),
              const Divider(key: Key('AppDrawer_divider_1')),
              
              _buildSectionHeader('ÚČASTNÍCI'),
              _buildParticipantList(context, hasEvent),
              _buildNewParticipant(context, hasEvent),
              _buildCsvImport(context, hasEvent),
              const Divider(key: Key('AppDrawer_divider_2')),
              
              _buildSectionHeader('ZÁZNAMY'),
              _buildNewRecord(context, hasEvent, hasParticipants),
              _buildIntakeForm(context, hasEvent, hasParticipants),
              const Divider(key: Key('AppDrawer_divider_3')),
              
              _buildSectionHeader('NÁSTROJE'),
              _buildPrintCenter(context, hasEvent),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Deník ZZA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // UDÁLOSTI section
  Widget _buildEventList(BuildContext context) {
    return ListTile(
      key: const Key('AppDrawer_event_list'),
      leading: const Icon(Icons.event_note),
      title: const Text('Seznam akcí'),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EventList()),
        );
      },
    );
  }

  Widget _buildAddEvent(BuildContext context) {
    return ListTile(
      key: const Key('AppDrawer_add_event'),
      leading: const Icon(Icons.add_circle),
      title: const Text('Přidat akci'),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EventRegistrationForm()),
        );
      },
    );
  }

  // ÚČASTNÍCI section
  Widget _buildParticipantList(BuildContext context, bool hasEvent) {
    return ListTile(
      key: const Key('AppDrawer_participant_list'),
      leading: const Icon(Icons.people),
      title: const Text('Seznam účastníků'),
      subtitle: const Text('Připravujeme', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
      enabled: false, // Screen doesn't exist yet
      onTap: null,
    );
  }

  Widget _buildNewParticipant(BuildContext context, bool hasEvent) {
    return ListTile(
      key: const Key('AppDrawer_new_participant'),
      leading: const Icon(Icons.person_add),
      title: const Text('Nový Účastník'),
      subtitle: hasEvent 
          ? null 
          : const Text('Vyžaduje vybranou akci', style: TextStyle(fontSize: 11, color: Colors.grey)),
      enabled: hasEvent,
      onTap: hasEvent
          ? () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ParticipantRegistrationPage()),
              );
            }
          : null,
    );
  }

  Widget _buildCsvImport(BuildContext context, bool hasEvent) {
    return ListTile(
      key: const Key('AppDrawer_csv_import'),
      leading: const Icon(Icons.table_chart),
      title: const Text('Import CSV'),
      subtitle: hasEvent
          ? const Text('Hromadný import účastníků', style: TextStyle(fontSize: 11))
          : const Text('Vyžaduje vybranou akci', style: TextStyle(fontSize: 11, color: Colors.grey)),
      enabled: hasEvent,
      onTap: hasEvent
          ? () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CsvImportScreen()),
              );
            }
          : null,
    );
  }

  // ZÁZNAMY section
  Widget _buildNewRecord(BuildContext context, bool hasEvent, bool hasParticipants) {
    final enabled = hasEvent && hasParticipants;
    return ListTile(
      key: const Key('AppDrawer_new_record'),
      leading: const Icon(Icons.local_hospital),
      title: const Text('Nový záznam úrazu'),
      subtitle: !enabled
          ? const Text('Vyžaduje akci a účastníky', style: TextStyle(fontSize: 11, color: Colors.grey))
          : null,
      enabled: enabled,
      onTap: enabled
          ? () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewRecordPage()),
              );
            }
          : null,
    );
  }

  Widget _buildIntakeForm(BuildContext context, bool hasEvent, bool hasParticipants) {
    final enabled = hasEvent && hasParticipants;
    return ListTile(
      key: const Key('AppDrawer_intake_form'),
      leading: const Icon(Icons.assignment),
      title: const Text('Přijímací formulář'),
      subtitle: !enabled
          ? const Text('Vyžaduje akci a účastníky', style: TextStyle(fontSize: 11, color: Colors.grey))
          : null,
      enabled: enabled,
      onTap: enabled
          ? () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewIntakeFormImproved()),
              );
            }
          : null,
    );
  }

  // NÁSTROJE section
  Widget _buildPrintCenter(BuildContext context, bool hasEvent) {
    return ListTile(
      key: const Key('AppDrawer_print_center'),
      leading: const Icon(Icons.print),
      title: const Text('Tisk Centrum'),
      subtitle: hasEvent
          ? null
          : const Text('Vyžaduje vybranou akci', style: TextStyle(fontSize: 11, color: Colors.grey)),
      enabled: hasEvent,
      onTap: hasEvent
          ? () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrintCenterPage()),
              );
            }
          : null,
    );
  }
}