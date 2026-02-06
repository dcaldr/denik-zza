// First Print Wizard
//
// Flow:
// 1) Explain what append print is and what it needs from user
// 2) Ask user to load 2 sheets of paper into the printer
// 3) Print the two papers with bottom page number
// 4) Ask user to confirm which page is on top (1 or 2)
// 5) After confirms ask user to put the same papers in same order
// 6) Append print two new records to each page
// 7) Ask user to confirm correctness with confirm window

import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/services/system/system_interface.dart';
import 'package:denik_zza/print_ops2/print_center_service.dart';
import 'widgets/step_badge.dart';
import 'widgets/print_confirm_dialog.dart';
import 'calibration_pdf_generator.dart';
import 'widgets/append_instruction_dialog.dart';
import 'widgets/append_instructions_view.dart';
import 'widgets/instruction_step_row.dart';
import 'widgets/first_print/step_explanation.dart';
import 'widgets/first_print/step_prepare_paper.dart';
import 'widgets/first_print/step_test_print.dart';
import 'widgets/first_print/step_evaluation.dart';
import 'widgets/first_print/step_reinsert_paper.dart';
import 'widgets/first_print/step_append_test.dart';
import 'widgets/first_print/step_confirmation.dart';

// FIRST PRINT WIZARD

class FirstPrint extends StatefulWidget {
  const FirstPrint({super.key});

  @override
  State<FirstPrint> createState() => _FirstPrintState();
}

class _FirstPrintState extends State<FirstPrint> {
  int _currentStep = 0;
  final PrintCenterService _service = PrintCenterService();

  // Step labels for the wizard (7 steps total)
  static const _stepLabels = [
    'Vysvětlení',
    'Příprava papírů',
    'Testovací tisk',
    'Vyhodnocení',
    'Druhý tisk',
    'Dostisk test',
    'Potvrzení',
  ];

  // Calibration result: true = page 1 on top, false = page 2 on top
  bool? _page1OnTop;

  // Loading state for print operations
  bool _isPrinting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nastavení prvního tisku')),
      body: Column(
        children: [
          // Step badges row
          StepBadgeRow(
            key: const Key('FirstPrint_stepBadges'),
            stepLabels: _stepLabels,
            currentStep: _currentStep,
          ),
          const Divider(height: 1),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _buildCurrentStep(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return FirstPrintStepExplanation(
          navigation: _buildNavigationButtons(),
        );
      case 1:
        return FirstPrintStepPreparePaper(
          navigation: _buildNavigationButtons(),
        );
      case 2:
        return FirstPrintStepTestPrint(
          isPrinting: _isPrinting,
          onPrint: _runInitialCalibrationPrint,
          navigation: _buildNavigationButtons(),
        );
      case 3:
        return FirstPrintStepEvaluation(
          page1OnTop: _page1OnTop,
          onPage1OnTopChanged: (value) => setState(() => _page1OnTop = value),
          navigation: _buildNavigationButtons(),
        );
      case 4:
        return FirstPrintStepReinsertPaper(
          isNormalOrder: _page1OnTop ?? true,
          navigation: _buildNavigationButtons(),
        );
      case 5:
        return FirstPrintStepAppendTest(
          isPrinting: _isPrinting,
          onPrint: _runAppendTestPrint,
          navigation: _buildNavigationButtons(),
        );
      case 6:
        return FirstPrintStepConfirmation(
          onComplete: _completeWizard,
          onBack: _previousStep,
        );
      default:
        return Center(
          key: ValueKey(_currentStep),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction, size: 48, color: AppColors.greyIcon),
              const SizedBox(height: AppSpacing.l),
              Text('Krok ${_currentStep + 1} - ${_stepLabels[_currentStep]}'),
              const SizedBox(height: AppSpacing.s),
              Text('Zatím neimplementováno',
                  style: TextStyle(color: AppColors.greyText)),
              const SizedBox(height: AppSpacing.xxl),
              _buildNavigationButtons(),
            ],
          ),
        );
    }
  }

  Future<void> _completeWizard() async {
    await _service.completeCalibration(_page1OnTop);

    if (!mounted) return;
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kalibrace dokončena!'),
        backgroundColor: AppColors.actionGreen,
      ),
    );
  }

  // PRINT METHODS

  Future<void> _runInitialCalibrationPrint() async {
    setState(() => _isPrinting = true);

    try {
      final pdfBytes =
          await CalibrationPdfGenerator.generateInitialCalibration();

      if (!mounted) return;

      await SystemInterface.instance.printPdf(
        onLayout: (_) async => pdfBytes,
        name: 'Kalibrace_tisk_1',
      );

      if (mounted) {
        // Don't show confirmation dialog here - it hasn't been introduced yet
        // Just proceed to step 4 (Evaluation) where user checks the printed pages
        _nextStep();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba tisku: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  Future<void> _runAppendTestPrint() async {
    // 1. Show Instruction Dialog (Static Mode)
    final isNormalOrder = _page1OnTop ?? true;

    // Prepare steps View for the Dialog
    final instructionsView = AppendInstructionsView(
      steps: [
        InstructionStepRow(
          text: isNormalOrder ? 'Nahoře stránka 1' : 'Nahoře stránka 2',
          isStrong: true,
        ),
        InstructionStepRow(
          text: isNormalOrder ? 'Pod ní stránka 2' : 'Pod ní stránka 1',
          isStrong: true,
        ),
      ],
      infoWidget: Container(
        padding: const EdgeInsets.all(AppSpacing.s),
        decoration: BoxDecoration(
          color: AppColors.blueBackground,
          borderRadius: BorderRadius.circular(AppRadii.small),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: AppColors.blueText),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Text(
                isNormalOrder
                    ? 'Vložte podle čísel vzestupně (1 nahoře).'
                    : 'Vložte podle čísel sestupně (2 nahoře).',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.blueText,
                    ),
              ),
            ),
          ],
        ),
      ),
    );

    final shouldPrint = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AppendInstructionDialog(
        customContent: instructionsView,
      ),
    );

    if (shouldPrint != true) return;

    // 2. Proceed to Print
    setState(() => _isPrinting = true);

    try {
      final pdfBytes = await CalibrationPdfGenerator.generateAppendTest();

      if (!mounted) return;

      await SystemInterface.instance.printPdf(
        onLayout: (_) async => pdfBytes,
        name: 'Kalibrace_dostisk',
      );

      if (mounted) {
        // 3. Show Confirmation Dialog
        await _showCalibrationConfirmDialog(
          onSuccess: _nextStep,
          onRetry: _runAppendTestPrint,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba tisku: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  /// Shows the shared print confirmation dialog.
  ///
  /// Adds a calibration-specific info banner to the standard dialog.
  Future<void> _showCalibrationConfirmDialog({
    required VoidCallback onSuccess,
    required VoidCallback onRetry,
  }) async {
    final result = await showPrintConfirmDialog(
      context: context,
      showTip: false,
      extraContent: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.blueBackground,
          borderRadius: AppRadii.buttonRadius,
          border: Border.all(color: AppColors.blueBorder),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.blueText),
            const SizedBox(width: AppSpacing.m),
            const Expanded(
              child: Text(
                'Toto je dialog, který uvidíte při každém tisku. '
                'Pro kalibraci stačí "Vše OK" nebo "Zopakovat".',
              ),
            ),
          ],
        ),
      ),
    );

    switch (result) {
      case PrintSimulationResult.success:
      case PrintSimulationResult.noChange:
      case PrintSimulationResult.reset:
        onSuccess();
        break;
      case PrintSimulationResult.repeat:
      case PrintSimulationResult.resetAndReprint:
        onRetry();
        break;
      case null:
        // Dialog dismissed without selection
        break;
    }
  }

  // NAVIGATION HELPERS

  /// Standard back/next navigation buttons for wizard steps
  Widget _buildNavigationButtons() {
    final isFirst = _currentStep == 0;
    final isLast = _currentStep == _stepLabels.length - 1;

    // Step 4 (index 3) requires a selection before proceeding
    final canProceed = _currentStep != 3 || _page1OnTop != null;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.l,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button (hidden on first step)
          isFirst
              ? const SizedBox(width: 100)
              : OutlinedButton.icon(
                  key: const Key('FirstPrint_back'),
                  onPressed: _previousStep,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Zpět'),
                ),
          // Next button - disabled on step 4 without selection
          FilledButton.icon(
            key: const Key('FirstPrint_next'),
            onPressed: (isLast || !canProceed) ? null : _nextStep,
            icon: Icon(isLast ? Icons.check : Icons.arrow_forward),
            label: Text(isLast ? 'Dokončit' : 'Další'),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < _stepLabels.length - 1) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }
}
