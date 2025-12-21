import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDatePicker extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? validatorText;

  const CustomDatePicker({
    super.key,
    required this.controller,
    required this.labelText,
    this.validatorText,
  });

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
      //  locale: const Locale('cs', 'CZ'),
    );

    if (pickedDate != null) {
      controller.text = DateFormat('dd.MM.yyyy').format(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key:
          key, // Pass widget's key to inner TextFormField for robot testability
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => _selectDate(context),
        ),
      ),
      keyboardType: TextInputType.datetime,
      validator: validatorText != null
          ? (value) {
              if (value == null || value.isEmpty) {
                return validatorText;
              }
              // Validate date format
              try {
                DateFormat('dd.MM.yyyy').parseStrict(value);
              } catch (e) {
                return 'Invalid date format';
              }
              return null;
            }
          : null,
      readOnly: false, // Allow manual entry
    );
  }
}
