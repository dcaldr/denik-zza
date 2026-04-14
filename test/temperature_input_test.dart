import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/input/temperature_input.dart';

void main() {
  group('TemperatureInput.validateOptional', () {
    test('accepts empty as optional', () {
      expect(TemperatureInput.validateOptional(''), isNull);
      expect(TemperatureInput.validateOptional('   '), isNull);
      expect(TemperatureInput.validateOptional(null), isNull);
    });

    test('accepts valid values', () {
      expect(TemperatureInput.validateOptional('37'), isNull);
      expect(TemperatureInput.validateOptional('37.0'), isNull);
      expect(TemperatureInput.validateOptional('37.00'), isNull);
      expect(TemperatureInput.validateOptional('36.09'), isNull);
    });

    test('rejects invalid values', () {
      expect(TemperatureInput.validateOptional('3'), isNotNull);
      expect(TemperatureInput.validateOptional('37.222'), isNotNull);
      expect(TemperatureInput.validateOptional('100'), isNotNull);
      expect(TemperatureInput.validateOptional('100.0'), isNotNull);
    });
  });

  group('TemperatureInput.parseOptional', () {
    test('parses valid values', () {
      expect(TemperatureInput.parseOptional('37'), 37.0);
      expect(TemperatureInput.parseOptional('37.0'), 37.0);
      expect(TemperatureInput.parseOptional('37.00'), 37.0);
      expect(TemperatureInput.parseOptional('36.09'), 36.09);
    });

    test('returns null for empty or invalid values', () {
      expect(TemperatureInput.parseOptional(''), isNull);
      expect(TemperatureInput.parseOptional('3'), isNull);
      expect(TemperatureInput.parseOptional('100.0'), isNull);
      expect(TemperatureInput.parseOptional('abc'), isNull);
    });
  });
}
