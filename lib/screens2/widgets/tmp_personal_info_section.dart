import 'package:flutter/material.dart';
import '../widgets/custom_date_picker.dart';

/// Extracted widget for personal information section
/// This demonstrates how to break down large forms into smaller, reusable components
class PersonalInfoSection extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final Map<String, dynamic> validators;

  const PersonalInfoSection({
    super.key,
    required this.controllers,
    required this.validators,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Osobní údaje',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          childAspectRatio: 3 / 1,
          children: [
            _buildTextField('jmeno', 'Jméno', 'Jméno je povinné pole'),
            _buildTextField('prijmeni', 'Příjmení', 'Příjmení je povinné pole'),
            _buildTextField('cisloPojisteni', 'Číslo Pojištěnce', null),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomDatePicker(
                    controller: controllers['datumNarozeni']!, 
                    labelText: 'Datum Narození'
                  )
                ),
                const SizedBox(width: 8.0),
                Expanded(child: _buildTextField('pohlavi', 'Pohlaví', null)),
              ],
            ),
            _buildTextField('zdravotniPojistovna', 'Zdravotní Pojišťovna', null),
            _buildTextField('adresa', 'Adresa', null),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(String key, String labelText, String? validatorText, {int maxLines = 1, String? hintText}) {
    return TextFormField(
      controller: controllers[key],
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: maxLines > 1 ? const OutlineInputBorder() : null,
      ),
      validator: (value) {
        if (validatorText != null && (value == null || value.isEmpty)) {
          return validatorText;
        }
        return validators[key]?.validator(value);
      },
      maxLines: maxLines,
    );
  }
}
