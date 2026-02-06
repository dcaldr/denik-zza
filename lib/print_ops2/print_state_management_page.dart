import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/print_ops2/print_state_controller.dart';
import 'package:denik_zza/print_ops2/widgets/person_print_state_card.dart';

/// Page for manual print state management.
///
/// Shows all participants with their print status, allowing manual toggles
/// of wasPrinted/isPrinted flags as a fallback for automatic tracking.
/// Reached from the "Správa stavu" FeatureCard in PrintCenterPage.
class PrintStateManagementPage extends StatefulWidget {
  final PrintStateController controller;

  const PrintStateManagementPage({
    super.key,
    required this.controller,
  });

  @override
  State<PrintStateManagementPage> createState() =>
      _PrintStateManagementPageState();
}

class _PrintStateManagementPageState extends State<PrintStateManagementPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    widget.controller.loadParticipants();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        key: const Key('PrintStateManagement_appBar'),
        title: const Text('Správa stavu tisku'),
        actions: [
          IconButton(
            key: const Key('PrintStateManagement_refresh'),
            icon: const Icon(Icons.refresh),
            tooltip: 'Obnovit',
            onPressed: widget.controller.loadParticipants,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final ctrl = widget.controller;

    if (ctrl.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (ctrl.error != null) {
      return _ErrorView(
        message: ctrl.error!,
        onRetry: ctrl.loadParticipants,
      );
    }

    if (ctrl.personStates.isEmpty) {
      return _EmptyView();
    }

    return Column(
      children: [
        // Info banner
        _InfoBanner(),
        // Participant list
        Expanded(
          child: ListView.builder(
            key: const Key('PrintStateManagement_list'),
            padding: const EdgeInsets.only(
              top: AppSpacing.xs,
              bottom: AppSpacing.xl,
            ),
            itemCount: ctrl.personStates.length,
            itemBuilder: (context, index) {
              final state = ctrl.personStates[index];
              return PersonPrintStateCard(
                state: state,
                onTogglePersonPrinted: (id) => ctrl.togglePersonPrinted(id),
                onToggleRecordPrinted: (personId, recordId) =>
                    ctrl.toggleRecordPrinted(personId, recordId),
                onPreviewImpact: ctrl.previewToggleImpact,
                onMarkAllPrinted: (id) => ctrl.markAllPrintedForPerson(id),
                onResetAll: (id) => ctrl.resetAllForPerson(id),
              );
            },
          ),
        ),
      ],
    );
  }
}

// --- Small helper widgets ---

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppSpacing.s),
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.blueBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.blueBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: AppColors.blueText),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              'Ruční úprava stavu tisku. Změny se projeví okamžitě v databázi.',
              style: TextStyle(fontSize: 12, color: AppColors.blueText),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, size: 48, color: AppColors.greyTextLight),
          const SizedBox(height: AppSpacing.m),
          Text(
            'Žádní účastníci',
            style: TextStyle(color: AppColors.greyText, fontSize: 16),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Nejsou registrováni žádní účastníci pro aktuální akci.',
            style: TextStyle(color: AppColors.greyTextLight, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.orangeText),
            const SizedBox(height: AppSpacing.m),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.orangeText),
            ),
            const SizedBox(height: AppSpacing.l),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Zkusit znovu'),
            ),
          ],
        ),
      ),
    );
  }
}
