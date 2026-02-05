/// attach to print_center.dart, use similar ui to steps flow in print sector
/// flow:1) screen explain what append print is (useful) what it needs from user to do - and that this will contain some text and getting use to
///  2) ask user to load 2 sheets of paper into the printer + then to see what paper is on top when both printed
///  3) Print the two papers with bottom page number; header should be simple this is page N , two mock records marking page number and print pass
///  4) ask user to confirm which page is on top (1 or 2) and then explain why is it needed to know that (to determine if we can reuse the last page or need to insert a new one)
///  5) make new db field(s) for that so we remember the user choice for future prints (and also to use it in the append algorithm)
///  6) after confirms ask user to put the same papers in same order (top one on top ) SIgnify that no rotating and no flipping - just simple put in
///  7) append print two new records to each page (again with page number and pass numeber
///  8) ask user to confirm corectness with (two step? popup) first asking for any unforseen error+ explaining confirm widnow that will be later used , then the confirm widow we use in project,
///

import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/services/system/system_interface.dart';
import 'widgets/step_badge.dart';
import 'calibration_pdf_generator.dart';


// REUSABLE STEP CONTENT HELPERS


/// Standard step page wrapper with scrolling and padding
class StepContent extends StatelessWidget {
  final int stepIndex;
  final List<Widget> children;
  
  const StepContent({
    super.key,
    required this.stepIndex,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        key: ValueKey(stepIndex),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

/// Step header with icon and title
class StepHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  
  const StepHeader({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ],
    );
  }
}

/// Highlighted info box with icon and title
class InfoBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  
  const InfoBox({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content),
        ],
      ),
    );
  }
}

/// Section title (bold medium text)
class SectionTitle extends StatelessWidget {
  final String text;
  
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// Standard vertical spacing between sections
class StepSpacing extends StatelessWidget {
  final double size;
  
  const StepSpacing.small({super.key}) : size = 8;
  const StepSpacing.medium({super.key}) : size = 16;
  const StepSpacing.large({super.key}) : size = 24;
  const StepSpacing.xlarge({super.key}) : size = 32;

  @override
  Widget build(BuildContext context) => SizedBox(height: size);
}


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
    'Vložení zpět',
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
        borderRadius: BorderRadius.circular(12),
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

  // STEP 5: Save to database
  Widget _buildStep5SaveToDB() {
    final resultText = _page1OnTop == true
        ? 'Stránka 1 navrchu'
        : _page1OnTop == false
            ? 'Stránka 2 navrchu'
            : 'Nebylo vybráno';
    
    return StepContent(
      stepIndex: 4,
      children: [
        const StepHeader(
          icon: Icons.save,
          title: 'Uložení nastavení',
        ),
        const StepSpacing.medium(),
        
        InfoBox(
          icon: Icons.check_circle,
          title: 'Vaše volba:',
          content: resultText,
        ),
        const StepSpacing.medium(),
        
        const Text(
          'Toto nastavení bude uloženo a aplikace ho použije při každém dotisku.',
        ),
        const StepSpacing.medium(),
        
        _buildNavigationButtons(),
      ],
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
        const InfoBox(
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
        const StepSpacing.large(),
        
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
        
        _buildNavigationButtons(),
      ],
    );
  }

  void _completeWizard() {
    // TODO: Save calibration result to database
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kalibrace dokončena!'),
        backgroundColor: Colors.green,
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
        await _showCalibrationConfirmDialog(
          onSuccess: _nextStep,
          onRetry: _runInitialCalibrationPrint,
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

  /// Simplified confirmation dialog for calibration prints.
  /// 
  /// This is a preview of the confirmation dialog used in real printing workflow.
  Future<void> _showCalibrationConfirmDialog({
    required VoidCallback onSuccess,
    required VoidCallback onRetry,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        title: const Text('Jak dopadl tisk?'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Zvolte hlavní výsledek. Sekce níže obsahuje méně časté případy.',
              ),
              const SizedBox(height: 16),
              
              // Primary options explanation
              Text('Hlavní volby',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              
              _buildOptionDescription(
                icon: Icons.check_circle_outline,
                title: 'Vše OK (úspěšný tisk)',
                body: 'Označí nové záznamy/strany jako vytištěné. '
                    'Pokud běží režim Dostisk, označí jen ty nové.',
              ),
              _buildOptionDescription(
                icon: Icons.replay_circle_filled_outlined,
                title: 'Zopakovat tisk',
                body: 'Nic neoznačí – můžete hned zkusit znovu '
                    '(např. zaseklá tiskárna).',
              ),
              
              const SizedBox(height: 16),
              Text('Vedlejší & speciální',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              
              _buildOptionDescription(
                icon: Icons.remove_done,
                title: 'Neměnit označení',
                body: 'Nechá vše tak, jak bylo před tiskem. '
                    'Vhodné pokud jen testujete náhled.',
              ),
              _buildOptionDescription(
                icon: Icons.error_outline,
                title: 'Rozbitý tisk (reset)',
                body: 'Zruší označení vytištěného stavu. '
                    'Po výběru Reset si ještě zvolíte zda spustit nový tisk.',
              ),
              
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Toto je dialog, který uvidíte při každém tisku. '
                        'Pro kalibraci stačí "Vše OK" nebo "Zopakovat".',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(c).pop();
              // For calibration, "no change" just continues
              onSuccess();
            },
            icon: const Icon(Icons.remove_done),
            label: const Text('Neměnit'),
          ),
          TextButton.icon(
            onPressed: () async {
              Navigator.of(c).pop();
              await showDialog<void>(
                context: context,
                builder: (sc) => AlertDialog(
                  title: const Text('Reset tisku'),
                  content: const Text(
                      'Chcete pouze resetovat stav, nebo resetovat a ihned spustit nový tisk?'),
                  actions: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(sc).pop();
                        // For calibration, reset just continues
                        onSuccess();
                      },
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Jen reset'),
                    ),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(sc).pop();
                        onRetry();
                      },
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Reset + znovu'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reset'),
          ),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(c).pop();
              onRetry();
            },
            icon: const Icon(Icons.replay_circle_filled_outlined),
            label: const Text('Zopakovat'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(c).pop();
              onSuccess();
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Vše OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionDescription({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.greyIcon),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(body, style: TextStyle(fontSize: 12, color: AppColors.greyText)),
              ],
            ),
          ),
        ],
      ),
    );
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