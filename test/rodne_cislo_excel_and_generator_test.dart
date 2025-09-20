import 'package:flutter_test/flutter_test.dart';
import '../lib/input/rodne_cislo.dart';

void main() {
  group('RodneCislo Excel Leading Zero Fix Tests', () {
    test('should fix Excel leading zero stripping for various cases', () {
      // Test cases where Excel might strip leading zeros (using safe, non-personal examples)
      final testCases = [
        {'input': '123/4567', 'expected': '0001234567'},
        {'input': '123456/789', 'expected': '0123456789'}, // Pad to 10 digits
        {'input': '1234567890', 'expected': '1234567890'}, // Already 10 digits - no padding
        {'input': '12345/67890', 'expected': '1234567890'}, // Remove slash, no padding (already 10 digits) 
        {'input': '90815123', 'expected': '0090815123'}, // Pad to 10 digits (8 digits -> 10)
        {'input': '908151234', 'expected': '0908151234'}, // Pad to 10 digits (9 digits -> 10)
      ];

      for (final testCase in testCases) {
        final rc = RodneCislo(testCase['input']!);
        expect(rc.getRawRc(), equals(testCase['expected']), 
               reason: 'Failed for input: ${testCase['input']}');
      }
    });

    test('should not pad non-numeric strings', () {
      // Test that non-numeric strings aren't padded
      final rc1 = RodneCislo('abc123def');
      expect(rc1.getRawRc(), equals('abc123def'));
      
      final rc2 = RodneCislo('12a3b4c5d6');
      expect(rc2.getRawRc(), equals('12a3b4c5d6'));
    });

    test('should not pad strings that are too short or too long', () {
      // Too short (less than 6 digits)
      final rc1 = RodneCislo('12345');
      expect(rc1.getRawRc(), equals('12345'));
      
      // Too long (more than 10 digits) 
      final rc2 = RodneCislo('12345678901');
      expect(rc2.getRawRc(), equals('12345678901'));
    });
  });

  group('RodneCislo Generator Tests', () {
    test('generateForYear should create valid RCs for specified year', () {
      final rc1 = RodneCislo.generateForYear(1990);
      final rc2 = RodneCislo.generateForYear(2000);
      
      expect(rc1.hasValidFormat, isTrue);
      expect(rc1.hasValidSum, isTrue);
      expect(rc2.hasValidFormat, isTrue);
      expect(rc2.hasValidSum, isTrue);
      
      // Check that the year is correct
      expect(rc1.getDatumNarozeni().year, equals(1990));
      expect(rc2.getDatumNarozeni().year, equals(2000));
    });

    test('generateForYear should respect gender parameter', () {
      final maleRc = RodneCislo.generateForYear(1985, isFemale: false);
      final femaleRc = RodneCislo.generateForYear(1985, isFemale: true);
      
      expect(maleRc.getPohlavi(), equals(1)); // Male
      expect(femaleRc.getPohlavi(), equals(2)); // Female
    });

    test('generateForDate should create valid RC for specific date', () {
      final testDate = DateTime(1995, 6, 15);
      final rc = RodneCislo.generateForDate(testDate);
      
      expect(rc.hasValidFormat, isTrue);
      expect(rc.hasValidSum, isTrue);
      expect(rc.getDatumNarozeni(), equals(testDate));
    });

    test('generateForDate should respect gender parameter', () {
      final testDate = DateTime(1980, 3, 10);
      final maleRc = RodneCislo.generateForDate(testDate, isFemale: false);
      final femaleRc = RodneCislo.generateForDate(testDate, isFemale: true);
      
      expect(maleRc.getPohlavi(), equals(1)); // Male
      expect(femaleRc.getPohlavi(), equals(2)); // Female
      expect(maleRc.getDatumNarozeni(), equals(testDate));
      expect(femaleRc.getDatumNarozeni(), equals(testDate));
    });

    test('generateRandom should create valid RCs', () {
      for (int i = 0; i < 10; i++) {
        final rc = RodneCislo.generateRandom();
        expect(rc.hasValidFormat, isTrue, reason: 'Generated RC $i has invalid format: ${rc.getRc()}');
        expect(rc.hasValidSum, isTrue, reason: 'Generated RC $i has invalid checksum: ${rc.getRc()}');
      }
    });

    test('should generate different RCs on multiple calls', () {
      final generatedRcs = <String>{};
      
      // Generate multiple RCs and check for diversity
      for (int i = 0; i < 20; i++) {
        final rc = RodneCislo.generateRandom();
        generatedRcs.add(rc.getRc());
      }
      
      // Should have generated at least some different RCs
      expect(generatedRcs.length, greaterThan(5), 
             reason: 'Should generate varied RCs, but got only ${generatedRcs.length} unique values');
    });

    test('generated RCs should pass all validation checks', () {
      // Use safe test dates (non-personal information)
      final testDates = [
        DateTime(1975, 1, 1),
        DateTime(1988, 12, 31), 
        DateTime(2000, 6, 15),
        DateTime(2010, 2, 29), // Leap year
        DateTime(1955, 8, 20),
        DateTime(1963, 4, 12),
      ];
      
      for (final date in testDates) {
        final maleRc = RodneCislo.generateForDate(date, isFemale: false);
        final femaleRc = RodneCislo.generateForDate(date, isFemale: true);
        
        // Test male RC
        expect(maleRc.hasValidFormat, isTrue, 
               reason: 'Male RC for $date has invalid format: ${maleRc.getRc()}');
        expect(maleRc.hasValidSum, isTrue,
               reason: 'Male RC for $date has invalid checksum: ${maleRc.getRc()}');
        expect(maleRc.getDatumNarozeni(), equals(date));
        expect(maleRc.getPohlavi(), equals(1));
        
        // Test female RC  
        expect(femaleRc.hasValidFormat, isTrue,
               reason: 'Female RC for $date has invalid format: ${femaleRc.getRc()}');
        expect(femaleRc.hasValidSum, isTrue,
               reason: 'Female RC for $date has invalid checksum: ${femaleRc.getRc()}');
        expect(femaleRc.getDatumNarozeni(), equals(date));
        expect(femaleRc.getPohlavi(), equals(2));
      }
    });

    test('generators should be callable from anywhere (static methods)', () {
      // Test that generators can be called without instance
      final rc1 = RodneCislo.generateRandom();
      final rc2 = RodneCislo.generateForYear(1990);
      final rc3 = RodneCislo.generateForDate(DateTime(1985, 5, 15));
      
      expect(rc1.hasValidSum, isTrue);
      expect(rc2.hasValidSum, isTrue);
      expect(rc3.hasValidSum, isTrue);
    });
  });
}
