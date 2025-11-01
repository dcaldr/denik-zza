import 'package:flutter/material.dart';
import 'package:denik_zza/dev/dev_environment.dart';
import 'package:denik_zza/dev/ui/dev_app_builder.dart';
import 'package:denik_zza/screens2/widgets/app_drawer.dart';
import 'package:denik_zza/database/database_wrapper.dart';

/// Dev screen showing side-by-side menu layout comparison:
/// - Left: Current AppDrawer implementation
/// - Right: Collapsible sections with ExpansionTile
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DevEnvironment.initialize();
  runApp(buildDevAppWithBanner(
    title: 'Menu Comparison',
    home: const MenuComparisonScreen(),
    bannerMessage: 'DEV - Menu Comparison',
  ));
}

class MenuComparisonScreen extends StatelessWidget {
  const MenuComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Layout Comparison'),
        centerTitle: true,
      ),
      body: Row(
        children: [
          // Left side: Current Drawer implementation
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Container(
                    key: const Key('MenuComparison_leftTitle'),
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.blue.shade50,
                    child: const Center(
                      child: Text(
                        'Současné menu (AppDrawer)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: _DrawerPreview(),
                  ),
                ],
              ),
            ),
          ),
          
          // Right side: Collapsible sections version
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Container(
                    key: const Key('MenuComparison_rightTitle'),
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.green.shade50,
                    child: const Center(
                      child: Text(
                        'Sbalitelné sekce (ExpansionTile)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: _CollapsibleMenuPreview(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Preview of current AppDrawer implementation
class _DrawerPreview extends StatelessWidget {
  const _DrawerPreview();

  @override
  Widget build(BuildContext context) {
    // Show the drawer content directly without the Drawer wrapper
    return Material(
      child: Container(
        color: Colors.white,
        child: const AppDrawer(),
      ),
    );
  }
}

/// Preview of collapsible sections menu using ExpansionTile
class _CollapsibleMenuPreview extends StatefulWidget {
  const _CollapsibleMenuPreview();

  @override
  State<_CollapsibleMenuPreview> createState() => _CollapsibleMenuPreviewState();
}

class _CollapsibleMenuPreviewState extends State<_CollapsibleMenuPreview> {
  bool hasEvent = false;
  bool hasParticipants = false;

  @override
  void initState() {
    super.initState();
    _checkState();
  }

  Future<void> _checkState() async {
    // Check state using DatabaseWrapper
    final db = DatabaseWrapper.getDatabase();
    final event = await db.getCurrentAction();
    final participants = await db.getParticipantsByCurrentEvent();
    
    if (!mounted) return;
    setState(() {
      hasEvent = event != null;
      hasParticipants = participants.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          DrawerHeader(
            key: const Key('CollapsibleMenu_header'),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
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
                SizedBox(height: 8),
                Text(
                  'Sbalitelné sekce',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // UDÁLOSTI section - collapsible
          ExpansionTile(
            key: const Key('CollapsibleMenu_udalostiSection'),
            leading: const Icon(Icons.event),
            title: const Text('UDÁLOSTI'),
            initiallyExpanded: true,
            children: [
              ListTile(
                key: const Key('CollapsibleMenu_createEvent'),
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('Nová akce'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nová akce')),
                  );
                },
              ),
              ListTile(
                key: const Key('CollapsibleMenu_eventsList'),
                leading: const Icon(Icons.list),
                title: const Text('Seznam akcí'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Seznam akcí')),
                  );
                },
              ),
              ListTile(
                key: const Key('CollapsibleMenu_eventDetail'),
                leading: const Icon(Icons.info_outline),
                title: const Text('Detail akce'),
                enabled: hasEvent,
                onTap: hasEvent
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Detail akce')),
                        );
                      }
                    : null,
              ),
            ],
          ),

          // ÚČASTNÍCI section - collapsible
          ExpansionTile(
            key: const Key('CollapsibleMenu_ucastniciSection'),
            leading: const Icon(Icons.people),
            title: const Text('ÚČASTNÍCI'),
            initiallyExpanded: true,
            children: [
              ListTile(
                key: const Key('CollapsibleMenu_participantsList'),
                leading: const Icon(Icons.list),
                title: const Text('Seznam účastníků'),
                enabled: hasEvent,
                onTap: hasEvent
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Seznam účastníků')),
                        );
                      }
                    : null,
              ),
              ListTile(
                key: const Key('CollapsibleMenu_participantDetail'),
                leading: const Icon(Icons.person),
                title: const Text('Detail účastníka'),
                enabled: hasParticipants,
                onTap: hasParticipants
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Detail účastníka')),
                        );
                      }
                    : null,
              ),
              ListTile(
                key: const Key('CollapsibleMenu_editParticipant'),
                leading: const Icon(Icons.edit),
                title: const Text('Úprava účastníka'),
                enabled: hasParticipants,
                onTap: hasParticipants
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Úprava účastníka')),
                        );
                      }
                    : null,
              ),
              ListTile(
                key: const Key('CollapsibleMenu_searchParticipants'),
                leading: const Icon(Icons.search),
                title: const Text('Vyhledávání účastníků'),
                enabled: hasParticipants,
                onTap: hasParticipants
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vyhledávání účastníků')),
                        );
                      }
                    : null,
              ),
            ],
          ),

          // ZÁZNAMY section - collapsible
          ExpansionTile(
            key: const Key('CollapsibleMenu_zaznamySection'),
            leading: const Icon(Icons.medical_services),
            title: const Text('ZÁZNAMY'),
            initiallyExpanded: true,
            children: [
              ListTile(
                key: const Key('CollapsibleMenu_newRecord'),
                leading: const Icon(Icons.add),
                title: const Text('Nový záznam'),
                enabled: hasEvent,
                onTap: hasEvent
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Nový záznam')),
                        );
                      }
                    : null,
              ),
              ListTile(
                key: const Key('CollapsibleMenu_recordsList'),
                leading: const Icon(Icons.list_alt),
                title: const Text('Seznam záznamů úrazů'),
                enabled: hasEvent,
                onTap: hasEvent
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Seznam záznamů úrazů')),
                        );
                      }
                    : null,
              ),
            ],
          ),

          // NÁSTROJE section - collapsible
          ExpansionTile(
            key: const Key('CollapsibleMenu_nastroje'),
            leading: const Icon(Icons.build),
            title: const Text('NÁSTROJE'),
            initiallyExpanded: false,
            children: [
              ListTile(
                key: const Key('CollapsibleMenu_csvImport'),
                leading: const Icon(Icons.upload_file),
                title: const Text('Import CSV'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Import CSV')),
                  );
                },
              ),
              ListTile(
                key: const Key('CollapsibleMenu_fileManager'),
                leading: const Icon(Icons.folder_open),
                title: const Text('Správce souborů'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Správce souborů')),
                  );
                },
              ),
              ListTile(
                key: const Key('CollapsibleMenu_printTest'),
                leading: const Icon(Icons.print),
                title: const Text('Test tisku'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Test tisku')),
                  );
                },
              ),
            ],
          ),

          // PŘIPRAVUJEME section - collapsible, initially collapsed
          ExpansionTile(
            key: const Key('CollapsibleMenu_pripravujemeSection'),
            leading: const Icon(Icons.construction),
            title: const Text('PŘIPRAVUJEME'),
            initiallyExpanded: false,
            children: [
              _buildPlaceholderItem(
                key: 'CollapsibleMenu_placeholderDetailEvent',
                icon: Icons.event_note,
                title: 'Detail akce (připravujeme)',
              ),
              _buildPlaceholderItem(
                key: 'CollapsibleMenu_placeholderDetailParticipant',
                icon: Icons.person_outline,
                title: 'Detail účastníka (připravujeme)',
              ),
              _buildPlaceholderItem(
                key: 'CollapsibleMenu_placeholderEditParticipant',
                icon: Icons.edit_note,
                title: 'Úprava účastníka (připravujeme)',
              ),
              _buildPlaceholderItem(
                key: 'CollapsibleMenu_placeholderSearchParticipants',
                icon: Icons.person_search,
                title: 'Vyhledávání účastníků (připravujeme)',
              ),
              _buildPlaceholderItem(
                key: 'CollapsibleMenu_placeholderRecordsList',
                icon: Icons.medical_information,
                title: 'Seznam záznamů úrazů (připravujeme)',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderItem({
    required String key,
    required IconData icon,
    required String title,
  }) {
    return ListTile(
      key: Key(key),
      leading: Icon(icon, color: Colors.grey),
      title: Text(
        title,
        style: const TextStyle(color: Colors.grey),
      ),
      enabled: false,
    );
  }
}
