/// Tools for manipulating strings mainly for matching purposes
/// Should extend existing options for input validation and normalization
library;

import 'package:diacritic/diacritic.dart';
import 'package:logger/logger.dart';

/// Utility class for text manipulation and date parsing operations
class TextTools {
  static final Logger _logger = Logger();

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
  /// [date] - date string to parse
  /// Returns DateTime object or null if parsing fails
  static DateTime? myParseDate(String date) {
    DateTime? parsedDate;
    
    // Split text by common separators
    List<String> splitted = date.split(RegExp(r'[-/.\s]'));
    if (splitted.length != 3) {
      _logger.w('Date parsing failed - invalid format: $date');
      return null;
    }
    
    try {
      // Try parsing different formats
      if (splitted[0].length == 4) {
        // Format: yyyy.mm.dd
        parsedDate = DateTime(
          int.parse(splitted[0]), 
          int.parse(splitted[1]), 
          int.parse(splitted[2])
        );
      } else {
        // Format: dd.mm.yyyy
        parsedDate = DateTime(
          int.parse(splitted[2]), 
          int.parse(splitted[1]), 
          int.parse(splitted[0])
        );
      }
    } catch (e) {
      _logger.w('Date parsing failed for: $date, error: $e');
      parsedDate = null;
    }
    
    return parsedDate;
  }
}