import 'package:denik_zza/input/input_parser.dart';
import 'package:denik_zza/input/text_tools.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('basic tests too see how build-in options work', () {
    //test(description, body)
    test('basic string trimming', () {
      expect('     hello    '.trim(), 'hello');
    });
    test('to lowercase', () {
      expect("HeLlO".toLowerCase(), 'hello');
    });
    test('to lowercase harder', () {
      expect('ĚŠČŘŽÝÁÍÉŮĎˇI'.toLowerCase(), 'ěščřžýáíéůďˇi');
    });
  });
  group('advanced text manipulation', () {
    test('my normalizer remove', () {
      expect(TextTools.normText('ěščřžýáíéúůďť'), 'escrzyaieuudt');
      expect(TextTools.normText('ĚŠČŘŽÝÁÍÉÚŮĎŤ'), 'escrzyaieuudt');
    });
    test('my normalizer with spaces', () {
      expect(TextTools.normText(' ěščřžýáíéúůďť '), 'escrzyaieuudt');
      expect(TextTools.normText(' ĚŠČŘŽÝÁÍÉÚŮĎŤ '), 'escrzyaieuudt');
      expect(TextTools.normText(' ĚŠČŘžýáíéÚŮĎŤ '), 'escrzyaieuudt');
    });
  });

  /// TODO: Need? to move elsewhere
  group('comparing statuses', () {
    ParseStatus ok = ParseStatus.ok;
    ParseStatus format = ParseStatus.format;
    ParseStatus warn = ParseStatus.warn;
    ParseStatus bad = ParseStatus.bad;

    test('basic ordering', () {
      expect(ok.index, lessThan(warn.index));
      expect(ok.compareTo(warn), lessThan(0));
    });
    test('overridden operators', () {
      expect(format < bad, true);
      expect(ok > warn, false);
      expect(ok <= warn, true);
      expect(ok >= warn, false);
    });
    test('Implicit operators', () {
      expect(format == format, true);
      expect(format != bad, true);
    });
  });
  group('Date Parsing', () {
    test('basic IT style date parse', () {
      expect(TextTools.myParseDate('2020-01-02'), DateTime(2020, 01, 02));
    });
    test('basic CZ style date parse', () {
      expect(TextTools.myParseDate('10.06.2020'), DateTime(2020, 06, 10));
      expect(TextTools.myParseDate('10/06/2020'), DateTime(2020, 06, 10));
    });

    test('date validation robustness - invalid days', () {
      // Invalid day for any month
      expect(TextTools.myParseDate('32.01.2020'), null);
      expect(TextTools.myParseDate('00.01.2020'), null);

      // Invalid day for specific months
      expect(TextTools.myParseDate('31.04.2020'), null); // April has 30 days
      expect(TextTools.myParseDate('31.06.2020'), null); // June has 30 days
      expect(
          TextTools.myParseDate('31.09.2020'), null); // September has 30 days
      expect(TextTools.myParseDate('31.11.2020'), null); // November has 30 days

      // February edge cases
      expect(
          TextTools.myParseDate('30.02.2020'), null); // Feb never has 30 days
      expect(
          TextTools.myParseDate('29.02.2019'), null); // 2019 is not leap year
    });

    test('date validation robustness - invalid months', () {
      expect(TextTools.myParseDate('15.13.2020'), null); // Month 13
      expect(TextTools.myParseDate('15.00.2020'), null); // Month 0
      expect(TextTools.myParseDate('15.-1.2020'), null); // Negative month
    });

    test('date validation robustness - invalid years', () {
      expect(TextTools.myParseDate('15.06.1899'), null); // Year too old
      expect(
          TextTools.myParseDate('15.06.2101'), null); // Year too far in future
    });

    test('date validation robustness - leap year handling', () {
      // Valid leap year dates
      expect(TextTools.myParseDate('29.02.2020'),
          DateTime(2020, 02, 29)); // 2020 is leap year
      expect(TextTools.myParseDate('29.02.2000'),
          DateTime(2000, 02, 29)); // 2000 is leap year (divisible by 400)

      // Invalid leap year dates
      expect(TextTools.myParseDate('29.02.1900'),
          null); // 1900 is not leap year (divisible by 100, not 400)
      expect(
          TextTools.myParseDate('29.02.2021'), null); // 2021 is not leap year
    });

    test('date validation robustness - valid edge cases', () {
      // Valid dates that should still work
      expect(TextTools.myParseDate('31.01.2020'),
          DateTime(2020, 01, 31)); // January 31st
      expect(TextTools.myParseDate('31.03.2020'),
          DateTime(2020, 03, 31)); // March 31st
      expect(TextTools.myParseDate('30.04.2020'),
          DateTime(2020, 04, 30)); // April 30th (valid)
      expect(TextTools.myParseDate('28.02.2019'),
          DateTime(2019, 02, 28)); // Feb 28 non-leap year

      // Year range boundaries
      expect(TextTools.myParseDate('01.01.1900'),
          DateTime(1900, 01, 01)); // Min year
      expect(TextTools.myParseDate('31.12.2100'),
          DateTime(2100, 12, 31)); // Max year
    });
  });
}
