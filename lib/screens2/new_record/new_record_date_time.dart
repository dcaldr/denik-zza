import 'package:flutter/material.dart';

class NewRecordDateTimeHelper {
  static Future<DateTimeSelection?> pickDateTime({
    required BuildContext context,
    DateTime? initialDate,
    TimeOfDay? initialTime,
  }) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );

    if (pickedTime == null) return null;
    if (!context.mounted) return null;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    return DateTimeSelection(
      date: pickedDate,
      time: pickedTime,
    );
  }

  static DateTime getFinalDateTime({
    required DateTime? selectedDate,
    required TimeOfDay? selectedTime,
  }) {
    if (selectedDate != null && selectedTime != null) {
      return DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
    }
    if (selectedDate != null) {
      return selectedDate;
    }
    return DateTime.now();
  }

  static String formatSelectedDateTime({
    required DateTime? selectedDate,
    required TimeOfDay? selectedTime,
  }) {
    if (selectedDate == null && selectedTime == null) {
      return 'Datum a čas (aktuální)';
    }

    final datePart = selectedDate == null
        ? 'Dnes'
        : '${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}';

    final timePart = selectedTime == null
        ? 'aktuální čas'
        : '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';

    return '$datePart, $timePart';
  }
}

class DateTimeSelection {
  final DateTime? date;
  final TimeOfDay time;

  const DateTimeSelection({
    required this.date,
    required this.time,
  });
}
