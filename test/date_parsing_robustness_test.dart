import 'package:denik_zza/input/input_hold.dart';
import 'package:denik_zza/input/input_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Date Parsing Robustness - WARN Policy', () {
    test('Invalid dates should result in WARN status, not hard fail', () {
      // Test various invalid date scenarios
      final testCases = [
        '32.01.2020', // Invalid day
        '31.04.2020', // April only has 30 days
        '30.02.2020', // February never has 30 days
        '29.02.2019', // 2019 is not a leap year
        '15.13.2020', // Invalid month
        '15.06.1899', // Year too old
        '15.06.2101', // Year too far in future
      ];
      
      for (final invalidDate in testCases) {
        final datumHold = DatumNarozeniHold.full(invalidDate);
        
        // Should result in WARN status (not hard fail)
        expect(datumHold.status, ParseStatus.warn, 
               reason: 'Invalid date $invalidDate should result in WARN status');
        
        // Output should be null (no silent normalization)
        expect(datumHold.getOutput(), null,
               reason: 'Invalid date $invalidDate should result in null output');
      }
    });
    
    test('Valid dates should result in OK status', () {
      final validTestCases = [
        ('10.06.2020', DateTime(2020, 06, 10)),
        ('29.02.2020', DateTime(2020, 02, 29)), // 2020 is leap year
        ('28.02.2019', DateTime(2019, 02, 28)), // Valid non-leap year
        ('31.01.2020', DateTime(2020, 01, 31)), // January 31st
        ('30.04.2020', DateTime(2020, 04, 30)), // April 30th (valid)
        ('01.01.1900', DateTime(1900, 01, 01)), // Min year boundary
        ('31.12.2100', DateTime(2100, 12, 31)), // Max year boundary
      ];
      
      for (final testCase in validTestCases) {
        final validDate = testCase.$1;
        final expectedDateTime = testCase.$2;
        
        final datumHold = DatumNarozeniHold.full(validDate);
        
        // Should result in OK status
        expect(datumHold.status, ParseStatus.ok,
               reason: 'Valid date $validDate should result in OK status');
        
        // Output should match expected DateTime
        expect(datumHold.getOutput(), expectedDateTime,
               reason: 'Valid date $validDate should parse to correct DateTime');
      }
    });
    
    test('Date validation prevents silent DateTime normalization', () {
      // These dates would be silently normalized by Dart's DateTime constructor
      // but our validation should catch them and return WARN instead
      
      // DateTime(2020, 13, 1) would become DateTime(2021, 1, 1) in Dart
      final invalidMonth = DatumNarozeniHold.full('01.13.2020');
      expect(invalidMonth.status, ParseStatus.warn);
      expect(invalidMonth.getOutput(), null);
      
      // DateTime(2020, 4, 31) would become DateTime(2020, 5, 1) in Dart  
      final invalidDay = DatumNarozeniHold.full('31.04.2020');
      expect(invalidDay.status, ParseStatus.warn);
      expect(invalidDay.getOutput(), null);
    });
  });
}
