/// Tools for manipulating strings mainly for matching purposes
/// Should extend existing options for input validation and normalization
library;

import 'package:diacritic/diacritic.dart';
import 'package:logger/logger.dart';
import 'package:denik_zza/utils/app_logger.dart';

/// Utility class for text manipulation and date parsing operations
class TextTools {
  static final Logger _logger = AppLogger.l;

  /// Creates "normalized" version of text by removing diacritics and converting to lowercase
  /// 
  /// [inText] - input text to normalize
  /// Returns normalized text for comparison purposes
  static String normText(String inText) {
    inText = inText.toLowerCase().trim(); // TODO: consider removing all whitespace
    inText = removeDiacritics(inText);
    return inText;
  }
  /// Returns true if two strings are similar after normalization
  /// 
  /// [a] - first string to compare
  /// [b] - second string to compare
  static bool looseCmp(String a, String b) {
    a = normText(a);
    b = normText(b);
    return a == b;
  }

  /// Returns true if string matches any item in the provided list
  /// 
  /// [a] - string to compare
  /// [bList] - list of strings to compare against
  static bool looseCmpWithList(String a, List<String> bList) {
    a = normText(a);
    for (String b in bList) {
      b = normText(b);
      if (a == b) {
        return true;
      }
    }
    return false;
  }
  /// Parses date string in various formats
  /// 
  /// Attempts standard DateTime.parse first, then falls back to custom parsing
  /// [date] - date string to parse
  /// Returns DateTime object or null if parsing fails
  static DateTime? parseDate(String date) {
    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(date);
    } catch (e) {
      _logger.d('Standard DateTime.parse failed for: $date, trying custom parser');
      parsedDate = null;
    }
    
    if (parsedDate == null) {
      return myParseDate(date);
    }
    
    return parsedDate;
  }
  /// Custom date parser for various European date formats
  /// 
  /// Supports formats: dd.mm.yyyy, yyyy.mm.dd with various separators
  /// Validates date components before constructing DateTime to prevent silent normalization
  /// [date] - date string to parse
  /// Returns DateTime object or null if parsing fails or components are invalid
  static DateTime? myParseDate(String date) {
    // Split text by common separators
    List<String> splitted = date.split(RegExp(r'[-/.\s]'));
    if (splitted.length != 3) {
      _logger.w('Date parsing failed - invalid format (expected 3 components): $date');
      return null;
    }
    
    try {
      int year, month, day;
      
      // Parse components based on format detection
      if (splitted[0].length == 4) {
        // Format: yyyy.mm.dd
        year = int.parse(splitted[0]);
        month = int.parse(splitted[1]);
        day = int.parse(splitted[2]);
      } else {
        // Format: dd.mm.yyyy
        day = int.parse(splitted[0]);
        month = int.parse(splitted[1]);
        year = int.parse(splitted[2]);
      }
      
      // Validate date components before creating DateTime
      if (!_isValidDate(day, month, year)) {
        _logger.w('Date parsing failed - invalid date components: day=$day, month=$month, year=$year for input: $date');
        return null;
      }
      
      return DateTime(year, month, day);
      
    } catch (e) {
      _logger.w('Date parsing failed for: $date, error: $e');
      return null;
    }
  }

  /// Validates date components to prevent silent DateTime normalization
  /// 
  /// [day] - day component (1-31, month-specific)
  /// [month] - month component (1-12)
  /// [year] - year component (reasonable range 1900-2100)
  /// Returns true if all components are valid for the given date
  static bool _isValidDate(int day, int month, int year) {
    // Basic range checks
    if (month < 1 || month > 12) return false;
    if (year < 1900 || year > 2100) return false;
    if (day < 1 || day > 31) return false;
    
    // Month-specific day validation
    final daysInMonth = _getDaysInMonth(month, year);
    return day <= daysInMonth;
  }

  /// Gets the number of days in a specific month/year combination
  /// 
  /// [month] - month (1-12)
  /// [year] - year (for leap year calculation)
  /// Returns number of days in the month
  static int _getDaysInMonth(int month, int year) {
    switch (month) {
      case 2: // February
        return _isLeapYear(year) ? 29 : 28;
      case 4: // April
      case 6: // June
      case 9: // September
      case 11: // November
        return 30;
      default:
        return 31;
    }
  }

  /// Determines if a year is a leap year
  /// 
  /// [year] - year to check
  /// Returns true if year is a leap year
  static bool _isLeapYear(int year) {
    return (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0);
  }
}