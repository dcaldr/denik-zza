import 'package:denik_zza/screens2/widgets/person_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/screens2/participant_registration_form.dart';

class IntakeForm extends StatelessWidget {
  const IntakeForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intake Form'),
      ),
      body: const Center(
        child: SizedBox(
          height: double.infinity,
          child: LayoutStyle(),
        ),
      ),
    );
  }
}

class LayoutStyle extends StatelessWidget {
  const LayoutStyle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            FirstRow(),
            TwoColumnRow(),
          ],
        ),
        SecondRow(),
      ],
    );
  }
}

class FirstRow extends StatelessWidget {
  const FirstRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('First Row'),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(8),
            child: PersonAutocomplete(onPersonSelected: (MemoryOsoba person) {
              // Dummy function
            }),
          ),
        ),
      ],
    );
  }
}

class TwoColumnRow extends StatelessWidget {
  const TwoColumnRow({super.key});

  @override
  Widget build(BuildContext context) {
    return  Row(
      children: [
        Flexible(
          flex: 1,
          child: Column(
            children: [
              const Text('First Column'),
              Transform.scale(
                scale: 0.85,
                child: const ParticipantRegistrationForm(),
              ),
            ],
          ),
        ),
        const Flexible(
          flex: 1,
          child: Column(
            children: [
              Text('Second Column'),
            ],
          ),
        ),
      ],
    );
  }
}

class SecondRow extends StatelessWidget {
  const SecondRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Text('Second Row'),
      ],
    );
  }
}