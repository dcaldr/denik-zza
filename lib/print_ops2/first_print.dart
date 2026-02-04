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
import 'widgets/step_badge.dart';
// StepBadgeRow is imported from widgets/step_badge.dart
// =============================================================================
// FIRST PRINT WIZARD
// =============================================================================

/// 8-step wizard for printer calibration (append-print setup).
/// Determines how the user's printer stacks pages so append printing works correctly.
class FirstPrint extends StatefulWidget {
  const FirstPrint({super.key});

  @override
  State<FirstPrint> createState() => _FirstPrintState();
}

class _FirstPrintState extends State<FirstPrint> {
  int _currentStep = 0;

  // Step labels for the wizard
  static const _stepLabels = [
    'Vysvětlení',
    'Příprava papírů',
    'Testovací tisk',
    'Vyhodnocení',
    'Uložení',
    'Vložení zpět',
    'Dostisk test',
    'Potvrzení',
  ];

  // TODO: Step 5 - store result here (or in DB later)
  // bool? _topPageIsFirst; // true = page 1 on top, false = page 2 on top

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
      // case 2: return _buildStep3TestPrint();
      // case 3: return _buildStep4Evaluation();
      // case 4: return _buildStep5SaveToDB();
      // case 5: return _buildStep6ReinsertPaper();
      // case 6: return _buildStep7AppendTest();
      // case 7: return _buildStep8Confirmation();
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
    return SingleChildScrollView(
      key: const ValueKey(0),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, 
                  size: 32, 
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Proč tento průvodce?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Text(
            'Na téma divně fungujících tiskáren existuje spousta vtipů vzniklých na základě reálných zkušeností, '
             'nicméně pravidelný výpis  na papír je pro tuto apliakci '
             'velmi důležitý. S počítačem se ve špatné chvíli může něco stát, naopak papír lze předat dál a lze do něj něco vepsat.'
             'Vzhledem k tomu, že by bylo nepraktické aby každý záznam byl na vlastní stránce, vznika funkce '

            'Dostisk (append print), která vám umožní přidat nové '
            'záznamy na již vytištěný papír – bez nutnosti tisknout celý '
            'dokument znovu. '
            'Protože ale tiskárny, narozdíl od psacích strojů, neumí pokračovat v tisku tam, kde skončily, musíme jim trochu pomoci. A aby nevznikaly zbytečné nové vtipy, je tu tento průvodce. '
            ,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          
          // Why it's useful
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, 
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Proč je pravidelný (do)tisk užitečný?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Již vytištěný papír je k dispozici okamžitě  bez ohledu na to, jestli běží elektřina, počítač, tiskárna, nebo aplikace\n'
                  '• Lze kopírovat, nebo do něj přidat poznámky \n'
                  '• S dotiskem lze průběžně tisknout záznamy a nemusí se odkládat ,,až se jich sejde více" \n'
                  '• Stačí vložit už vytištěný list zpět do tiskárny\n'
                  '• Aplikace si pamatuje, ketré záznamy byly vytištěny',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // What this wizard does
          Text(
            'Co tento průvodce nastaví?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Každá tiskárna se chová trochu jinak  napříkald některé dávají '
            'první stránku navrch, jiné na spodek. Tento průvodce spojí, '
             'jak funguje vaše tiskárna, aby dostisk fungoval správně a zároveň předvede jak a proč se má postupovat  při tisku. ',
          ),
          const SizedBox(height: 32),
          
          // Navigation
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  // ===========================================================================
  // STEP 2: Ask user to prepare 2 sheets of paper
  // ===========================================================================
  Widget _buildStep2PreparePaper() {
    // TODO: Your task! Implement this step.
    // Hints:
    //   - Similar structure to step 1
    //   - Add an icon like Icons.description or Icons.print_outlined
    //   - Instruct user to load 2 sheets of blank paper
    //   - Tell them to watch which page ends up on top after printing
    //   - Use _buildNavigationButtons() for back/next

    

    return Placeholder(key: const ValueKey(1)); // <-- Replace this!
  }

  // ===========================================================================
  // NAVIGATION HELPERS
  // ===========================================================================
  
  /// Standard back/next navigation buttons for wizard steps
  Widget _buildNavigationButtons() {
    final isFirst = _currentStep == 0;
    final isLast = _currentStep == _stepLabels.length - 1;

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
          // Next button
          FilledButton.icon(
            onPressed: isLast ? null : _nextStep, // TODO: handle last step differently
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