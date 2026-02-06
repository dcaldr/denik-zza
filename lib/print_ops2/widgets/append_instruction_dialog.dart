import 'package:flutter/material.dart';
import 'package:denik_zza/print_ops2/widgets/append_instructions_view.dart';
import 'package:denik_zza/print_ops2/widgets/instruction_step_row.dart';

import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/print_ops2/models/append_analysis.dart';
import 'package:denik_zza/print_ops2/print_center_controller.dart';

/// Scenarios detected from analysis
enum _AppendScenario {
  firstPrint, // baseline=0
  fitsOnLast, // reused=true, final==baseline
  overflowsNewPages, // reused=true, final>baseline
  allNewPages, // reused=false (full page + new)
}

class AppendInstructionDialog extends StatefulWidget {
  final PrintCenterController? controller;
  final Widget? customContent;

  const AppendInstructionDialog({
    super.key,
    this.controller,
    this.customContent,
  }) : assert(controller != null || customContent != null,
            'Either controller or customContent must be provided');

  @override
  State<AppendInstructionDialog> createState() =>
      _AppendInstructionDialogState();
}

class _AppendInstructionDialogState extends State<AppendInstructionDialog> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.customContent != null) {
      _loading = false;
    } else {
      _runAnalysis();
    }
  }

  Future<void> _runAnalysis() async {
    final controller = widget.controller;
    if (controller == null) return;

    await controller.analyzeAppendScenario();

    if (mounted) {
      setState(() {
        _loading = false;
        _error = controller.analysisError;
      });
    }
  }

  _AppendScenario _detectScenario(AppendAnalysis a) {
    if (a.baselinePages == 0) return _AppendScenario.firstPrint;
    if (a.reusedLastPage && a.finalPages == a.baselinePages) {
      return _AppendScenario.fitsOnLast;
    }
    if (a.reusedLastPage && a.finalPages > a.baselinePages) {
      return _AppendScenario.overflowsNewPages;
    }
    return _AppendScenario.allNewPages;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.s,
      ),
      title: Row(
        children: [
          Icon(Icons.print, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: AppSpacing.s),
          const Text('Instrukce pro tisk'),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: SingleChildScrollView(child: _buildContent()),
      ),
      actions: _buildActions(),
    );
  }

  Widget _buildContent() {
    if (widget.customContent != null) {
      return widget.customContent!;
    }

    if (_loading) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: AppSpacing.l),
              Text('Analyzuji dokument...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Text('Chyba analýzy: $_error',
          style: TextStyle(color: Theme.of(context).colorScheme.error));
    }

    final analysis = widget.controller?.appendAnalysis;
    if (analysis == null) return const Text('Žádná data k analýze.');

    return _buildInstructions(analysis);
  }

  Widget _buildInstructions(AppendAnalysis analysis) {
    final controller = widget.controller;
    if (controller == null) return const SizedBox();

    final scenario = _detectScenario(analysis);
    final page1Callback = controller.printerPage1OnTop;

    // Warning if not calibrated
    Widget? calibrationWarning;
    if (page1Callback == null) {
      calibrationWarning = Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.m),
        padding: const EdgeInsets.all(AppSpacing.s),
        decoration: BoxDecoration(
          color: AppColors.orangeBackground,
          borderRadius: AppRadii.buttonRadius,
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: AppColors.orangeText, size: 20),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Text(
                'Tiskárna není kalibrována! Pořadí stránek nemusí odpovídat.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      );
    }

    final stepStrings = _getStepsForScenario(scenario, analysis, page1Callback);

    return AppendInstructionsView(
      steps: stepStrings.map((s) => InstructionStepRow(text: s)).toList(),
      warningWidget: calibrationWarning,
      infoWidget: Container(
        padding: const EdgeInsets.all(AppSpacing.s),
        decoration: BoxDecoration(
          color: AppColors.greyBackground,
          borderRadius: AppRadii.buttonRadius,
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: AppColors.greyText),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Text(
                'Stránky s * obsahují pouze transparentní obsah - můžete použít existující výtisk nebo prázdný papír.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.greyText,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getStepsForScenario(
      _AppendScenario scenario, AppendAnalysis a, bool? page1OnTop) {
    final steps = <String>[];

    // Determine loading order based on printer type
    // If page1OnTop=true (normal), we load in page order (1, 2, 3...)
    // If page1OnTop=false (reverse), we load in reverse order (3, 2, 1...)
    // Default to normal if unknown
    final isNormalOrder = page1OnTop ?? true;

    switch (scenario) {
      case _AppendScenario.firstPrint:
        steps.add('Vložte ${a.finalPages} prázdných listů.');
        break;

      case _AppendScenario.fitsOnLast:
        // Just the reused page
        steps.add('Stránka ${a.baselinePages} (existující)*');
        break;

      case _AppendScenario.overflowsNewPages:
      case _AppendScenario.allNewPages:
        // We print all pages involved
        // E.g. reused page + new pages OR new pages only
        final pagesToLoad = <String>[];

        // If we reuse last page (Scenario 3, 5, 6)
        if (a.reusedLastPage && a.baselinePages > 0) {
          pagesToLoad.add('Stránka ${a.baselinePages} (existující)*');
        }

        // Add additional blank pages needed
        final newPagesCount = a.finalPages -
            (a.reusedLastPage ? a.baselinePages : a.baselinePages);
        if (newPagesCount > 0) {
          pagesToLoad.add('$newPagesCount x prázdný list');
        } else {
          // Should not happen in overflow scenario
          // If we fall here, newPagesCount is <= 0 which implies no new pages needed
          // or logic error. Safest is to add nothing or show error.
          // For now, we assume if reusedLastPage=false (allNewPages), newPagesCount is finalPages
          if (scenario == _AppendScenario.allNewPages) {
            pagesToLoad.add('${a.finalPages} x prázdný list');
          }
        }

        // Apply order
        if (!isNormalOrder) {
          pagesToLoad.reversed.forEach(steps.add);
        } else {
          pagesToLoad.forEach(steps.add);
        }
        break;
    }

    return steps;
  }

  List<Widget> _buildActions() {
    if (_loading) return [];

    return [
      TextButton(
        key: const Key('AppendInstruction_cancel'),
        onPressed: () => Navigator.of(context).pop(false),
        child: const Text('Zrušit'),
      ),
      FilledButton(
        key: const Key('AppendInstruction_continue'),
        onPressed:
            _error != null ? null : () => Navigator.of(context).pop(true),
        child: const Text('Pokračovat k tisku'),
      ),
    ];
  }
}
