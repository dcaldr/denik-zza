class TemperatureInput {
  TemperatureInput._();

  // Accepts exactly two-digit integers with optional 1-2 decimal digits.
  // Valid examples: 37, 37.0, 37.00, 36.09
  static final RegExp _format = RegExp(r'^[1-9]\d(?:\.\d{1,2})?$');

  static String? validateOptional(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) {
      return null;
    }

    if (!_format.hasMatch(value)) {
      return 'Zadejte teplotu ve formatu nn, nn.n nebo nn.nn';
    }

    return null;
  }

  static double? parseOptional(String? raw) {
    final error = validateOptional(raw);
    if (error != null) {
      return null;
    }

    final value = raw?.trim() ?? '';
    if (value.isEmpty) {
      return null;
    }

    return double.parse(value);
  }
}
