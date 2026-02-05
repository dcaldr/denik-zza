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
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';
import 'package:denik_zza/services/system/system_interface.dart';
import 'widgets/step_badge.dart';
import 'widgets/print_confirm_dialog.dart';
import 'calibration_pdf_generator.dart';


// Step helpers imported from shared widgets
import 'widgets/step_helpers.dart';


// FIRST PRINT WIZARD

class FirstPrint extends StatefulWidget {
  const FirstPrint({super.key});

  @override
  State<FirstPrint> createState() => _FirstPrintState();
}

class _FirstPrintState extends State<FirstPrint> {
  int _currentStep = 0;

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
        return _buildStep1Explanation();
      case 1:
        return _buildStep2PreparePaper();
      case 2:
        return _buildStep3TestPrint();
      case 3:
        return _buildStep4Evaluation();
      case 4:
        return _buildStep6ReinsertPaper();
      case 5:
        return _buildStep7AppendTest();
      case 6:
        return _buildStep8Confirmation();
      default:
        return Center(
          key: ValueKey(_currentStep),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction, size: 48, color: AppColors.greyIcon),
              const SizedBox(height: 16),
              Text('Krok ${_currentStep + 1} - ${_stepLabels[_currentStep]}'),
              const SizedBox(height: 8),
              Text('Zatím neimplementováno', style: TextStyle(color: AppColors.greyText)),
              const SizedBox(height: 24),
              _buildNavigationButtons(),
            ],
          ),
        );
    }
  }

  // ===========================================================================
  // STEP 1: Explain what this wizard does
  // ===========================================================================
  Widget _buildStep1Explanation() {
    return StepContent(
      stepIndex: 0,
      children: [
        const StepHeader(
          icon: Icons.info_outline,
          title: 'Proč tento průvodce?',
        ),
        const StepSpacing.large(),
        
        Text(
          'Na téma divně fungujících tiskáren existuje spousta vtipů vzniklých na základě reálných zkušeností, '
          'nicméně pravidelný výpis na papír je pro tuto aplikaci '
          'velmi důležitý. S počítačem se ve špatné chvíli může něco stát, naopak papír lze předat dál a lze do něj něco vepsat. '
          'Vzhledem k tomu, že by bylo nepraktické aby každý záznam byl na vlastní stránce, vzniká funkce '
          'Dostisk (append print), která vám umožní přidat nové '
          'záznamy na již vytištěný papír – bez nutnosti tisknout celý '
          'dokument znovu. '
          'Protože ale tiskárny, narozdíl od psacích strojů, neumí pokračovat v tisku tam, kde skončily, musíme jim trochu pomoci. A aby nevznikaly zbytečné nové vtipy, je tu tento průvodce.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const StepSpacing.medium(),
        
        const InfoBox(
          icon: Icons.lightbulb_outline,
          title: 'Proč je pravidelný (do)tisk užitečný?',
          content:
            '• Již vytištěný papír je k dispozici okamžitě bez ohledu na to, jestli běží elektřina, počítač, tiskárna, nebo aplikace\n'
            '• Lze kopírovat, nebo do něj přidat poznámky\n'
            '• S dotiskem lze průběžně tisknout záznamy a nemusí se odkládat „až se jich sejde více"\n'
            '• Stačí vložit už vytištěný list zpět do tiskárny\n'
            '• Aplikace si pamatuje, které záznamy byly vytištěny',
        ),
        const StepSpacing.large(),
        
        const SectionTitle('Co tento průvodce nastaví?'),
        const StepSpacing.small(),
        const Text(
          'Každá tiskárna se chová trochu jinak – například některé dávají '
          'první stránku navrch, jiné na spodek. Tento průvodce zjistí, '
          'jak funguje vaše tiskárna, aby dostisk fungoval správně a zároveň předvede jak a proč se má postupovat při tisku.',
        ),
        const StepSpacing.xlarge(),
        
        _buildNavigationButtons(),
      ],
    );
  }

  // STEP 2: Ask user to prepare 2 sheets of paper
  Widget _buildStep2PreparePaper() {
    return StepContent(
      stepIndex: 1,
      children: [
        const StepHeader(
          icon: Icons.description_outlined,
          title: 'Příprava testovacích papírů',
        ),
        const StepSpacing.large(),

        const InfoBox(
          icon: Icons.checklist,
          title: 'Co budete potřebovat:',
          content:
            '• 2 listy čistého papíru (A4)\n'
            '• Tiskárnu připravenou k tisku'
            
        ),
        const StepSpacing.medium(),
        
        const SectionTitle('Postup:'),
        const StepSpacing.small(),
        const Text(
          '1. Vložte 2 listy papíru do tiskárny\n'
          '2. V dalším kroku vytiskneme testovací stránky\n'
          '3. Poté zjistíme, která stránka skončila navrchu',
        ),
        const StepSpacing.medium(),
        
        const InfoBox(
          icon: Icons.visibility_outlined,
          title: 'Na co se zaměřit po tisku:',
          content:
            'Po tisku si všimněte, která stránka leží navrchu:\n'
            '• Stránka s číslem 1? Nebo stránka s číslem 2\n'
            '• Papíry ponechte v tiskárně tak jak jsou (bez otáčení, převracení, měnění pořadí)'
            ,
        ),
        const StepSpacing.medium(),
        
        _buildNavigationButtons(),
      ],
    );
  }

  // STEP 3: Test print (2 pages, pass 1)
  Widget _buildStep3TestPrint() {
    return StepContent(
      stepIndex: 2,
      children: [
        const StepHeader(
          icon: Icons.print,
          title: 'Testovací tisk',
        ),
        const StepSpacing.medium(),
        
        const Text(
          'Nyní vytiskneme 2 testovací stránky. Je potřeba zvolit skutečnou tiskárnu, která bude na akci používána (i když nejspíše se nabídne tisk do PDF). Pro zvládnutí samotného tisku se spustí nové okno operačního systému nikoli této aplikace.\n'
          '• Stránka 1 – s nadpisem "TESTOVACÍ STRÁNKA 1"\n'
          '• Stránka 2 – s nadpisem "TESTOVACÍ STRÁNKA 2"\n'
          'Obě stránky budou mít ukázkové záznamy podobné skutečným.',
        ),
        const StepSpacing.large(),
        
        // Print button with loading state
        Center(
          child: _isPrinting
              ? const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Tisknu...'),
                  ],
                )
              : FilledButton.icon(
                  onPressed: _runInitialCalibrationPrint,
                  icon: const Icon(Icons.print, size: 28),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  label: const Text('Spustit testovací tisk', style: TextStyle(fontSize: 18)),
                ),
        ),
        const StepSpacing.large(),
        
        const InfoBox(
          icon: Icons.warning_amber,
          title: 'Po vytištění:',
          content:
            'Neodebírejte papíry z výstupního zásobníku!\n'
            'Budeme je potřebovat pro další kroky.',
        ),
        const StepSpacing.medium(),
        
        _buildNavigationButtons(),
      ],
    );
  }

  // STEP 4: Evaluate which page is on top

  Widget _buildStep4Evaluation() {
    return StepContent(
      stepIndex: 3,
      children: [
        const StepHeader(
          icon: Icons.question_answer,
          title: 'Která stránka je navrchu?',
        ),
        const StepSpacing.medium(),
        
        const Text(
          'Podívejte se na vytištěné papíry ve výstupním zásobníku tiskárny. '
          'Která stránka leží nahoře?',
        ),
        const StepSpacing.medium(),
        
        // Selection cards
        Row(
          children: [
            Expanded(
              child: _buildSelectionCard(
                title: 'Stránka 1',
                icon: Icons.looks_one,
                isSelected: _page1OnTop == true,
                onTap: () => setState(() => _page1OnTop = true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSelectionCard(
                title: 'Stránka 2',
                icon: Icons.looks_two,
                isSelected: _page1OnTop == false,
                onTap: () => setState(() => _page1OnTop = false),
              ),
            ),
          ],
        ),
        const StepSpacing.medium(),
        
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.cardRadius,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                icon,
                size: 48,
                color: isSelected ? colorScheme.primary : AppColors.greyIcon,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 8),
              // Always reserve space for checkmark to prevent layout shift
              Opacity(
                opacity: isSelected ? 1.0 : 0.0,
                child: Icon(Icons.check_circle, color: colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // STEP 6: Reinsert paper for append test
  Widget _buildStep6ReinsertPaper() {
    return StepContent(
      stepIndex: 4,
      children: [
        const StepHeader(
          icon: Icons.replay,
          title: 'Vložení papírů zpět',
        ),
        const StepSpacing.medium(),
        
        const Text(
          'Vezměte vytištěné papíry a vložte je zpět do tiskárny.',
        ),
        const StepSpacing.medium(),
        
        const InfoBox(
          icon: Icons.warning_amber,
          title: 'DŮLEŽITÉ:',
          content:
            '• Zachovejte stejné pořadí\n'
            '• NEOTÁČEJTE papíry\n'
            '• NEPŘEVRACEJTE papíry',
        ),
        const StepSpacing.medium(),
        
        _buildNavigationButtons(),
      ],
    );
  }

  // STEP 7: Append test print (pass 2)
  Widget _buildStep7AppendTest() {
    return StepContent(
      stepIndex: 5,
      children: [
        const StepHeader(
          icon: Icons.add_to_photos,
          title: 'Test dotisku',
        ),
        const StepSpacing.medium(),
        
        const Text(
          'Nyní vytiskneme nové záznamy na již vytištěné papíry. '
          'Nové záznamy by se měly objevit pod těmi stávajícími.',
        ),
        const StepSpacing.medium(),
        
        // Print button with loading state
        Center(
          child: _isPrinting
              ? const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Tisknu...'),
                  ],
                )
              : FilledButton.icon(
                  onPressed: _runAppendTestPrint,
                  icon: const Icon(Icons.print, size: 28),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  label: const Text('Spustit dostisk', style: TextStyle(fontSize: 18)),
                ),
        ),
        const StepSpacing.medium(),
        const InfoBox(
          icon: Icons.info_outline,
          title: 'potvrzení tisku',
          content: 'Po tomto tisku se objeví dialog s potvrzením stavu tisku, ten se bude objevovat po každém tisku aby se záznamy správně označily.\n '
          'Označí se tam co se povedlo a nepovedlo vytisknout, popř. nějaké chyby (chybějící papír apd) lze opakovat tisk, pokud došlo k velké chybě (otočení papíru apd.) lze vše označit, že je třeba začít od začátku'
          ,
        ),
        
        _buildNavigationButtons(),
      ],
    );
  }

  // STEP 8: Final confirmation
  Widget _buildStep8Confirmation() {
    return StepContent(
      stepIndex: 6,
      children: [
        const StepHeader(
          icon: Icons.check_circle,
          title: 'Potvrzení',
        ),
        const StepSpacing.medium(),
        
        const Text(
          'Zkontrolujte vytištěné papíry. Na každé stránce by měly být '
          'záznamy z obou průchodů.',
        ),
        const StepSpacing.medium(),
        
        const InfoBox(
          icon: Icons.help_outline,
          title: 'Je vše v pořádku?',
          content:
            'Pokud se nové záznamy vytiskly správně pod těmi původními, '
            'je kalibrace dokončena.',
        ),
        const StepSpacing.large(),
        
        // Explanation of the confirmation dialog
/*         const InfoBox(
          icon: Icons.info_outline,
          title: 'O potvrzovacím dialogu',
          content:
            'Po každém tisku uvidíte dialog "Jak dopadl tisk?" s těmito možnostmi:\\n\\n'
            '• Vše OK – označí záznamy jako vytištěné\\n'
            '• Zopakovat – tisk se opakuje (např. při zaseklé tiskárně)\\n'
            '• Neměnit – nic neoznačí (testování)\\n'
            '• Reset – zruší označení (při chybě)\\n\\n'
            'Tento dialog je klíčový pro správné sledování stavu tisku!',
        ),
        const StepSpacing.large(), */
        
        // Completion button
        Center(
          child: FilledButton.icon(
            onPressed: _completeWizard,
            icon: const Icon(Icons.done_all, size: 28),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              backgroundColor: AppColors.greenIcon,
            ),
            label: const Text('Dokončit nastavení', style: TextStyle(fontSize: 18)),
          ),
        ),
        const StepSpacing.medium(),
        
        // Only show back button on final step (completion is handled by the green button above)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Zpět'),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _completeWizard() async {
    // Save calibration result to database
    final db = DatabaseWrapper.getDatabase();
    await db.setPrinterPage1OnTop(_page1OnTop);
    
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
      final pdfBytes = await CalibrationPdfGenerator.generateInitialCalibration();
      
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
    setState(() => _isPrinting = true);
    
    try {
      final pdfBytes = await CalibrationPdfGenerator.generateAppendTest();
      
      if (!mounted) return;
      
      await SystemInterface.instance.printPdf(
        onLayout: (_) async => pdfBytes,
        name: 'Kalibrace_dostisk',
      );
      
      if (mounted) {
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
      extraContent: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.blueBackground,
          borderRadius: AppRadii.buttonRadius,
          border: Border.all(color: AppColors.blueBorder),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.blueText),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Toto je dialog, který uvidíte při každém tisku. '
                'Pro kalibraci stačí "Vše OK" nebo "Zopakovat".',
                style: TextStyle(fontSize: 13),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button (hidden on first step)
          isFirst
              ? const SizedBox(width: 100)
              : OutlinedButton.icon(
                  onPressed: _previousStep,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Zpět'),
                ),
          // Next button - disabled on step 4 without selection
          FilledButton.icon(
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