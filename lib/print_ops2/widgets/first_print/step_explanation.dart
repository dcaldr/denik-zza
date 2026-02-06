import 'package:flutter/material.dart';
import 'package:denik_zza/print_ops2/widgets/step_helpers.dart';

class FirstPrintStepExplanation extends StatelessWidget {
  final Widget navigation;

  const FirstPrintStepExplanation({
    super.key,
    required this.navigation,
  });

  @override
  Widget build(BuildContext context) {
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
        navigation,
      ],
    );
  }
}
