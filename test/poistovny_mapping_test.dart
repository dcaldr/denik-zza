import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/input/poistovny.dart';

/// Unit tests for insurer canonicalization helper.
///
/// These tests verify that known synonyms map to canonical short codes and
/// that unknown insurer names are returned as-is (so they can be stored in DB).
void main() {
  group('poistovny canonicalization', () {
    test('known synonyms map to canonical codes', () {
      // VZP variants
      expect(canonicalizeInsurance('vzp'), equals('vzp'));
      expect(canonicalizeInsurance('Všeobecná zdravotní pojišťovna'), equals('vzp'));
      expect(canonicalizeInsurance('111'), equals('vzp'));

      // OZP
      expect(canonicalizeInsurance('ozp'), equals('ozp'));
      expect(canonicalizeInsurance('Oborová zdravotní pojišťovna'), equals('ozp'));

      // CPZP
      expect(canonicalizeInsurance('česká průmyslová zdravotní pojišťovna'), equals('cpzp'));
    });

    test('unknown insurer returns original trimmed string', () {
      final unknown = 'Můj Lokální poskytovatel';
      expect(canonicalizeInsurance(unknown), equals(unknown));
      // Leading/trailing whitespace should be trimmed but preserved otherwise
      expect(canonicalizeInsurance('  MyInsurer  '), equals('MyInsurer'));
    });

    test('null or empty input returns null', () {
      expect(canonicalizeInsurance(null), isNull);
      expect(canonicalizeInsurance(''), isNull);
      expect(canonicalizeInsurance('   '), isNull);
    });
  });
}
