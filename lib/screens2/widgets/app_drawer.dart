import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/screens2/csv/import_screen.dart';
import 'package:denik_zza/screens2/event_list.dart';
import 'package:denik_zza/screens2/event_registration_form.dart';
import 'package:denik_zza/screens2/intake_form_improved.dart';
import 'package:denik_zza/screens2/new_record_page.dart';
import 'package:denik_zza/screens2/participant_list_screen.dart';
import 'package:denik_zza/screens2/participant_registration_form.dart';
import 'package:denik_zza/print_ops2/print_center.dart';
import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';

/// Phase-based hybrid menu drawer with workflow-focused design
/// Option C: Main workflow items always visible, supporting sections collapsible
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

              // HLAVNÍ: BĚHEM AKCE - Always visible main workflow section
              _buildMainWorkflowHeader(),
              _buildNewRecord(context, hasEvent, hasParticipants),
              _buildParticipantList(context, hasEvent),
              _buildPrintCenter(context, hasEvent),

              const SizedBox(height: 8),
              const Divider(height: 1),

              // PŘÍPRAVA AKCE - Collapsible pre-event setup section
              _buildPrepSection(context, hasEvent),

              // ZDRAVOTNICKÝ FILTR - Collapsible medical screening section
              _buildMedicalSection(context, hasEvent, hasParticipants),
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

  /// Build highlighted main workflow section header with rounded corners
  Widget _buildMainWorkflowHeader() {
    return Container(
      key: const Key('AppDrawer_hlavniSection'),
      padding: AppSpacing.formFieldPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.orangeBackground,
            AppColors.orangeBackground.withOpacity(0.5)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          left: BorderSide(color: AppColors.orangeText, width: 3),
        ),
        borderRadius: AppRadii.buttonRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.orangeBorder,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.star, color: AppColors.orangeText, size: 18),
          const SizedBox(width: 8),
          Text(
            'HLAVNÍ: BĚHEM AKCE',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.orangeText,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Build collapsible pre-event preparation section
  Widget _buildPrepSection(BuildContext context, bool hasEvent) {
    return ExpansionTile(
      key: const Key('AppDrawer_priprava'),
      leading: const Icon(Icons.event_available),
      title: const Text(
        'PŘÍPRAVA AKCE',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      initiallyExpanded: false,
      children: [
        _buildAddEvent(context),
        _buildEventList(context),
        _buildNewParticipant(context, hasEvent),
        _buildCsvImport(context, hasEvent),
      ],
    );
  }

  /// Build collapsible medical screening section
  Widget _buildMedicalSection(
      BuildContext context, bool hasEvent, bool hasParticipants) {
    return ExpansionTile(
      key: const Key('AppDrawer_filtr'),
      leading: const Icon(Icons.medical_services),
      title: const Text(
        'ZDRAVOTNICKÝ FILTR',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      initiallyExpanded: false,
      children: [
        _buildIntakeForm(context, hasEvent, hasParticipants),
      ],
    );
  }

  // PŘÍPRAVA AKCE section items
  Widget _buildAddEvent(BuildContext context) {
    return ListTile(
      key: const Key('AppDrawer_add_event'),
      leading: const Icon(Icons.add_circle_outline),
      title: const Text('Nová akce', style: TextStyle(fontSize: 15)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const EventRegistrationForm()),
        );
      },
    );
  }

  Widget _buildEventList(BuildContext context) {
    return ListTile(
      key: const Key('AppDrawer_event_list'),
      leading: const Icon(Icons.event_note),
      title: const Text('Seznam akcí', style: TextStyle(fontSize: 15)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EventList()),
        );
      },
    );
  }

  // HLAVNÍ section: Participant list (main workflow item)
  Widget _buildParticipantList(BuildContext context, bool hasEvent) {
    return ListTile(
      key: const Key('AppDrawer_participant_list'),
      leading:
          Icon(Icons.people, color: hasEvent ? null : AppColors.greyTextLight),
      title: Text(
        'Seznam účastníků',
        style: TextStyle(
          fontSize: 15,
          color: hasEvent ? null : AppColors.greyText,
        ),
      ),
      subtitle: !hasEvent
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber,
                    size: 16, color: AppColors.orangeText),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Vytvořte akci nejdříve',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.lightColorScheme.error),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          : null,
      enabled: hasEvent,
      onTap: hasEvent
          ? () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ParticipantListScreen(),
                ),
              );
            }
          : null,
    );
  }

  // PŘÍPRAVA section: Registration (requires event)
  Widget _buildNewParticipant(BuildContext context, bool hasEvent) {
    return ListTile(
      key: const Key('AppDrawer_new_participant'),
      leading: Icon(Icons.person_add,
          color: hasEvent ? null : AppColors.greyTextLight),
      title: Text(
        'Registrace účastníka',
        style: TextStyle(
          fontSize: 15,
          color: hasEvent ? null : AppColors.greyText,
        ),
      ),
      subtitle: hasEvent
          ? null
          : Text('Vyžaduje akci',
              style: TextStyle(fontSize: 11, color: AppColors.greyText)),
      enabled: hasEvent,
      onTap: hasEvent
          ? () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ParticipantRegistrationPage()),
              );
            }
          : null,
    );
  }

  Widget _buildCsvImport(BuildContext context, bool hasEvent) {
    return ListTile(
      key: const Key('AppDrawer_csv_import'),
      leading: Icon(Icons.upload_file,
          color: hasEvent ? null : AppColors.greyTextLight),
      title: Text(
        'Import CSV',
        style: TextStyle(
          fontSize: 15,
          color: hasEvent ? null : AppColors.greyText,
        ),
      ),
      subtitle: hasEvent
          ? null
          : Text('Vyžaduje akci',
              style: TextStyle(fontSize: 11, color: AppColors.greyText)),
      enabled: hasEvent,
      onTap: hasEvent
          ? () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CsvImportScreen()),
              );
            }
          : null,
    );
  }

  // HLAVNÍ section: New injury record (primary workflow action)
  Widget _buildNewRecord(
      BuildContext context, bool hasEvent, bool hasParticipants) {
    final enabled = hasEvent && hasParticipants;
    return ListTile(
      key: const Key('AppDrawer_new_record'),
      leading: Icon(
        Icons.add_circle,
        color: enabled ? AppColors.orangeText : AppColors.greyTextLight,
      ),
      title: Text(
        'Nový záznam úrazu',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: enabled ? null : AppColors.greyText,
        ),
      ),
      subtitle: !enabled
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber,
                    size: 16, color: AppColors.orangeText),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    !hasEvent ? 'Vytvořte akci nejdříve' : 'Přidejte účastníky',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.lightColorScheme.error),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
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

  // ZDRAVOTNICKÝ FILTR section: Intake form
  Widget _buildIntakeForm(
      BuildContext context, bool hasEvent, bool hasParticipants) {
    final enabled = hasEvent && hasParticipants;
    return ListTile(
      key: const Key('AppDrawer_intake_form'),
      leading: Icon(
        Icons.assignment_turned_in,
        color: enabled ? null : AppColors.greyTextLight,
      ),
      title: Text(
        'Příjímací formulář',
        style: TextStyle(
          fontSize: 15,
          color: enabled ? null : AppColors.greyText,
        ),
      ),
      subtitle: !enabled
          ? Text('Vyžaduje akci a účastníky',
              style: TextStyle(fontSize: 11, color: AppColors.greyText))
          : null,
      enabled: enabled,
      onTap: enabled
          ? () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NewIntakeFormImproved()),
              );
            }
          : null,
    );
  }

  // HLAVNÍ section: Print center
  Widget _buildPrintCenter(BuildContext context, bool hasEvent) {
    return ListTile(
      key: const Key('AppDrawer_print_center'),
      leading:
          Icon(Icons.print, color: hasEvent ? null : AppColors.greyTextLight),
      title: Text(
        'Tisk centrum',
        style: TextStyle(
          fontSize: 15,
          color: hasEvent ? null : AppColors.greyText,
        ),
      ),
      subtitle: hasEvent
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber,
                    size: 16, color: AppColors.orangeText),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Vytvořte akci nejdříve',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.lightColorScheme.error),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
      enabled: hasEvent,
      onTap: hasEvent
          ? () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PrintCenterPage()),
              );
            }
          : null,
    );
  }
}
