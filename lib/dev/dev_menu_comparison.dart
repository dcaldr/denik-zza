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
                      child: Column(
                        children: [
                          Text(
                            'A) Současné menu (AppDrawer)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Standardní rozvržení - současná navigace',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
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
          VerticalDivider(width: 1, thickness: 1, color: Colors.grey.shade300),
          
          // Middle: Collapsible sections version
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Container(
                    key: const Key('MenuComparison_middleTitle'),
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.green.shade50,
                    child: const Center(
                      child: Column(
                        children: [
                          Text(
                            'B) Sbalitelné sekce',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Skládací sekce - úspora místa',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
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
          VerticalDivider(width: 1, thickness: 1, color: Colors.grey.shade300),
          
          // Right side: Phase-based hybrid version
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
                    color: Colors.orange.shade50,
                    child: const Center(
                      child: Column(
                        children: [
                          Text(
                            'C) Fázový hybrid',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Podle fází - zaměřeno na workflow',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Expanded(
                    child: _PhaseBasedMenuPreview(),
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
            title: const Text('UDÁLOSTI',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
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
                leading: const Icon(Icons.event_note),
                title: const Text('Seznam akcí'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Seznam akcí')),
                  );
                },
              ),
            ],
          ),

          // ÚČASTNÍCI section - collapsible
          ExpansionTile(
            key: const Key('CollapsibleMenu_ucastniciSection'),
            leading: const Icon(Icons.people),
            title: const Text('ÚČASTNÍCI',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            initiallyExpanded: true,
            children: [
              ListTile(
                key: const Key('CollapsibleMenu_participantsList'),
                leading: Icon(Icons.people, 
                  color: hasEvent ? null : Colors.grey.shade400),
                title: Text('Seznam účastníků',
                  style: TextStyle(
                    fontSize: 15,
                    color: hasEvent ? null : Colors.grey.shade500,
                  ),
                ),
                subtitle: !hasEvent
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber, 
                            size: 16, 
                            color: Colors.orange.shade700),
                          const SizedBox(width: 4),
                          Text(
                            'Vytvořte akci nejdříve',
                            style: TextStyle(fontSize: 11, color: Colors.red.shade700),
                          ),
                        ],
                      )
                    : null,
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
                key: const Key('CollapsibleMenu_newParticipant'),
                leading: Icon(Icons.person_add,
                  color: hasEvent ? null : Colors.grey.shade400),
                title: Text('Registrace účastníka',
                  style: TextStyle(
                    fontSize: 15,
                    color: hasEvent ? null : Colors.grey.shade500,
                  ),
                ),
                subtitle: !hasEvent
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber, 
                            size: 16, 
                            color: Colors.orange.shade700),
                          const SizedBox(width: 4),
                          Text(
                            'Vytvořte akci nejdříve',
                            style: TextStyle(fontSize: 11, color: Colors.red.shade700),
                          ),
                        ],
                      )
                    : null,
                enabled: hasEvent,
                onTap: hasEvent
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Registrace účastníka')),
                        );
                      }
                    : null,
              ),
              ListTile(
                key: const Key('CollapsibleMenu_csvImport'),
                leading: Icon(Icons.upload_file,
                  color: hasEvent ? null : Colors.grey.shade400),
                title: Text('Import CSV',
                  style: TextStyle(
                    fontSize: 15,
                    color: hasEvent ? null : Colors.grey.shade500,
                  ),
                ),
                subtitle: !hasEvent
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber, 
                            size: 16, 
                            color: Colors.orange.shade700),
                          const SizedBox(width: 4),
                          Text(
                            'Vytvořte akci nejdříve',
                            style: TextStyle(fontSize: 11, color: Colors.red.shade700),
                          ),
                        ],
                      )
                    : null,
                enabled: hasEvent,
                onTap: hasEvent
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Import CSV')),
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
            title: const Text('ZÁZNAMY',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            initiallyExpanded: true,
            children: [
              ListTile(
                key: const Key('CollapsibleMenu_newRecord'),
                leading: Icon(Icons.add,
                  color: (hasEvent && hasParticipants) ? null : Colors.grey.shade400),
                title: Text('Nový záznam úrazu',
                  style: TextStyle(
                    fontSize: 15,
                    color: (hasEvent && hasParticipants) ? null : Colors.grey.shade500,
                  ),
                ),
                subtitle: (!hasEvent || !hasParticipants)
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber, 
                            size: 16, 
                            color: Colors.orange.shade700),
                          const SizedBox(width: 4),
                          Text(
                            !hasEvent ? 'Vytvořte akci nejdříve' : 'Přidejte účastníky',
                            style: TextStyle(fontSize: 11, color: Colors.red.shade700),
                          ),
                        ],
                      )
                    : null,
                enabled: hasEvent && hasParticipants,
                onTap: hasEvent && hasParticipants
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Nový záznam úrazu')),
                        );
                      }
                    : null,
              ),
              ListTile(
                key: const Key('CollapsibleMenu_intakeForm'),
                leading: Icon(Icons.assignment,
                  color: (hasEvent && hasParticipants) ? null : Colors.grey.shade400),
                title: Text('Příjímací formulář',
                  style: TextStyle(
                    fontSize: 15,
                    color: (hasEvent && hasParticipants) ? null : Colors.grey.shade500,
                  ),
                ),
                subtitle: (!hasEvent || !hasParticipants)
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber, 
                            size: 16, 
                            color: Colors.orange.shade700),
                          const SizedBox(width: 4),
                          Text(
                            !hasEvent ? 'Vytvořte akci nejdříve' : 'Přidejte účastníky',
                            style: TextStyle(fontSize: 11, color: Colors.red.shade700),
                          ),
                        ],
                      )
                    : null,
                enabled: hasEvent && hasParticipants,
                onTap: hasEvent && hasParticipants
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Příjímací formulář')),
                        );
                      }
                    : null,
              ),
              ListTile(
                key: const Key('CollapsibleMenu_printCenter'),
                leading: Icon(Icons.print,
                  color: hasEvent ? null : Colors.grey.shade400),
                title: Text('Tisk centrum',
                  style: TextStyle(
                    fontSize: 15,
                    color: hasEvent ? null : Colors.grey.shade500,
                  ),
                ),
                subtitle: !hasEvent
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber, 
                            size: 16, 
                            color: Colors.orange.shade700),
                          const SizedBox(width: 4),
                          Text(
                            'Vytvořte akci nejdříve',
                            style: TextStyle(fontSize: 11, color: Colors.red.shade700),
                          ),
                        ],
                      )
                    : null,
                enabled: hasEvent,
                onTap: hasEvent
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tisk centrum')),
                        );
                      }
                    : null,
              ),
            ],
          ),


        ],
      ),
    );
  }
}

/// Preview of phase-based hybrid menu (Option C)
class _PhaseBasedMenuPreview extends StatefulWidget {
  const _PhaseBasedMenuPreview();

  @override
  State<_PhaseBasedMenuPreview> createState() => _PhaseBasedMenuPreviewState();
}

class _PhaseBasedMenuPreviewState extends State<_PhaseBasedMenuPreview> {
  bool hasEvent = false;
  bool hasParticipants = false;

  @override
  void initState() {
    super.initState();
    _checkState();
  }

  Future<void> _checkState() async {
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
            key: const Key('PhaseMenu_header'),
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
                  'Fázový hybrid',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // HLAVNÍ WORKFLOW section - always visible, never collapses
          Container(
            key: const Key('PhaseMenu_hlavniSection'),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade100, Colors.orange.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(
                left: BorderSide(color: Colors.deepOrange, width: 3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.shade200,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.star, color: Colors.deepOrange, size: 18),
                SizedBox(width: 8),
                Text(
                  'HLAVNÍ: BĚHEM AKCE',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepOrange,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            key: const Key('PhaseMenu_newRecord'),
            leading: Icon(Icons.add_circle, 
              color: (hasEvent && hasParticipants) ? Colors.deepOrange : Colors.grey.shade400),
            title: Text(
              'Nový záznam úrazu',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: (hasEvent && hasParticipants) ? null : Colors.grey.shade500,
              ),
            ),
            subtitle: !hasEvent || !hasParticipants
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber, 
                        size: 16, 
                        color: Colors.orange.shade700),
                      const SizedBox(width: 4),
                      Text(
                        !hasEvent 
                          ? 'Vytvořte akci nejdříve' 
                          : 'Přidejte účastníky',
                        style: TextStyle(fontSize: 11, color: Colors.red.shade700),
                      ),
                    ],
                  )
                : null,
            enabled: hasEvent && hasParticipants,
            onTap: hasEvent && hasParticipants
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nový záznam úrazu')),
                    );
                  }
                : null,
          ),
          ListTile(
            key: const Key('PhaseMenu_participantsList'),
            leading: Icon(Icons.people,
              color: hasEvent ? null : Colors.grey.shade400),
            title: Text('Seznam účastníků',
              style: TextStyle(
                fontSize: 15,
                color: hasEvent ? null : Colors.grey.shade500,
              ),
            ),
            subtitle: !hasEvent
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber, 
                        size: 16, 
                        color: Colors.orange.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'Vytvořte akci nejdříve',
                        style: TextStyle(fontSize: 11, color: Colors.red.shade700),
                      ),
                    ],
                  )
                : null,
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
            key: const Key('PhaseMenu_printCenterMain'),
            leading: Icon(Icons.print,
              color: hasEvent ? null : Colors.grey.shade400),
            title: Text('Tisk centrum',
              style: TextStyle(
                fontSize: 15,
                color: hasEvent ? null : Colors.grey.shade500,
              ),
            ),
            subtitle: !hasEvent
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber, 
                        size: 16, 
                        color: Colors.orange.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'Vytvořte akci nejdříve',
                        style: TextStyle(fontSize: 11, color: Colors.red.shade700),
                      ),
                    ],
                  )
                : null,
            enabled: hasEvent,
            onTap: hasEvent
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tisk centrum (hlavní)')),
                    );
                  }
                : null,
          ),

          const SizedBox(height: 8),
          const Divider(height: 1),

          // PŘÍPRAVA AKCE section - collapsible
          ExpansionTile(
            key: const Key('PhaseMenu_priprava'),
            leading: const Icon(Icons.event_available),
            title: const Text('PŘÍPRAVA AKCE',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            initiallyExpanded: false,
            children: [
              ListTile(
                key: const Key('PhaseMenu_newEvent'),
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('Nová akce'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nová akce')),
                  );
                },
              ),
              ListTile(
                key: const Key('PhaseMenu_eventsList'),
                leading: const Icon(Icons.event_note),
                title: const Text('Seznam akcí'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Seznam akcí')),
                  );
                },
              ),
              ListTile(
                key: const Key('PhaseMenu_newParticipant'),
                leading: Icon(Icons.person_add,
                  color: hasEvent ? null : Colors.grey.shade400),
                title: Text('Registrace účastníka',
                  style: TextStyle(
                    fontSize: 15,
                    color: hasEvent ? null : Colors.grey.shade500,
                  ),
                ),
                enabled: hasEvent,
                subtitle: !hasEvent
                    ? const Text('Vyžaduje akci', style: TextStyle(fontSize: 11, color: Colors.grey))
                    : null,
                onTap: hasEvent
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Registrace účastníka')),
                        );
                      }
                    : null,
              ),
              ListTile(
                key: const Key('PhaseMenu_csvImport'),
                leading: Icon(Icons.upload_file,
                  color: hasEvent ? null : Colors.grey.shade400),
                title: Text('Import CSV',
                  style: TextStyle(
                    fontSize: 15,
                    color: hasEvent ? null : Colors.grey.shade500,
                  ),
                ),
                enabled: hasEvent,
                subtitle: !hasEvent
                    ? const Text('Vyžaduje akci', style: TextStyle(fontSize: 11, color: Colors.grey))
                    : null,
                onTap: hasEvent
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Import CSV')),
                        );
                      }
                    : null,
              ),
            ],
          ),

          // ZDRAVOTNICKÝ FILTR section - collapsible
          ExpansionTile(
            key: const Key('PhaseMenu_filtr'),
            leading: const Icon(Icons.medical_services),
            title: const Text('ZDRAVOTNICKÝ FILTR',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            initiallyExpanded: false,
            children: [
              ListTile(
                key: const Key('PhaseMenu_intakeForm'),
                leading: Icon(Icons.assignment_turned_in,
                  color: (hasEvent && hasParticipants) ? null : Colors.grey.shade400),
                title: Text('Příjímací formulář',
                  style: TextStyle(
                    fontSize: 15,
                    color: (hasEvent && hasParticipants) ? null : Colors.grey.shade500,
                  ),
                ),
                enabled: hasEvent && hasParticipants,
                subtitle: !hasEvent || !hasParticipants
                    ? const Text('Vyžaduje akci a účastníky', style: TextStyle(fontSize: 11, color: Colors.grey))
                    : null,
                onTap: hasEvent && hasParticipants
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Příjímací formulář')),
                        );
                      }
                    : null,
              ),
            ],
          ),

          // NÁSTROJE section - collapsible (for demo showing Print in multiple places)
          ExpansionTile(
            key: const Key('PhaseMenu_nastroje'),
            leading: const Icon(Icons.build),
            title: const Text('NÁSTROJE',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            initiallyExpanded: false,
            children: [
              ListTile(
                key: const Key('PhaseMenu_printCenterTools'),
                leading: Icon(Icons.print,
                  color: hasEvent ? null : Colors.grey.shade400),
                title: Text('Tisk centrum',
                  style: TextStyle(
                    fontSize: 15,
                    color: hasEvent ? null : Colors.grey.shade500,
                  ),
                ),
                subtitle: const Text('Duplicated for demo', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                enabled: hasEvent,
                onTap: hasEvent
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tisk centrum (nástroje)')),
                        );
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
