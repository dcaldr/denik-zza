import 'package:flutter/material.dart';

/// Extracted widget for parent/guardian information section
/// This demonstrates separation of concerns and widget reusability
class ParentInfoSection extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final Map<String, dynamic> validators;

  const ParentInfoSection({
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
          'Údaje rodiče/zákonného zástupce',
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
            _buildTextField('jmenoRodice', 'Jméno rodiče', null),
            _buildTextField('emailRodice', 'Email rodiče', null),
            _buildTextField('telefonRodice', 'Telefon rodiče', null),
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
