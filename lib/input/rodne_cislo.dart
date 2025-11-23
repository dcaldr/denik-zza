import 'dart:math';

/// Czech national identification number (rodné číslo) validation and parsing class
///
/// Handles validation of Czech national ID format and checksum calculation
/// according to Czech Republic regulations
class RodneCislo {
  /// Tested national ID number
  String _rc;
  bool hasValidFormat = false;
  bool hasValidSum = false;

  /// Creates a new RodneCislo instance and validates the provided number
  ///
  /// [_rc] - the national ID number to validate
  RodneCislo(this._rc) {
    _rc = formatRc(_rc);
    if (!_isValidFormat(_rc)) {
      hasValidFormat = false;
    } else {
      hasValidFormat = true;
    }
    hasValidSum = isValidSum();
  }

  /// Formats the national ID number by removing separators and fixing Excel zero stripping
  ///
  /// Removes dashes, slashes, spaces, and all whitespace characters.
  /// Fixes Excel's leading zero stripping by padding to current format length (10 digits).
  String formatRc(String rcCandidate) {
    // Remove all separators (dash, forward/back slash, whitespace)
    String cleaned = rcCandidate.replaceAll(RegExp(r'[-/\\\s]'), '');

    // Fix Excel leading zero stripping issue
    // Smart padding logic:
    // 1. If length is 6, assume it's a date prefix (YYMMDD) -> DO NOT PAD
    // 2. If length > 6 and < 10:
    //    a. If starts with '0', user explicitly typed it -> DO NOT PAD
    //    b. If doesn't start with '0', assume Excel stripped zeros -> PAD

    if (cleaned.length == 6) {
      return cleaned;
    }

    if (cleaned.length > 6 && cleaned.length < 10) {
      if (!cleaned.startsWith('0')) {
        // Only pad if it doesn't start with 0 (likely Excel stripped)
        // And ensure it's all digits
        if (RegExp(r'^\d+$').hasMatch(cleaned)) {
          cleaned = cleaned.padLeft(10, '0');
        }
      }
    }

    return cleaned;
  }

  /// Validates the format of the national ID number
  ///
  /// Checks length and ensures it contains only digits
  bool _isValidFormat(String rc) {
    // Check length and that it contains only digits (except possible slash)
    if (rc.length == 10 || (rc.length == 11 && rc[6] == '/')) {
      return RegExp(r'^\d{9,10}$').hasMatch(rc);
    }
    return false;
  }

  /// Validates checksum using modulo 11 algorithm
  ///
  /// Returns true if the checksum is valid according to Czech national ID rules
  bool isValidSum() {
    if (!_isValidFormat(_rc)) {
      return false;
    }

    int sum = int.parse(_rc);
    int modulo = sum % 11;

    return (modulo == 0) || (modulo == 1 && _rc.endsWith('0'));
  }

  /// Determines gender from the national ID number
  ///
  /// Returns 1 for male, 2 for female based on month field
  int getPohlavi() {
    if (getHrubyMesic() < 50) {
      return 1; // Male
    } else {
      return 2; // Female
    }
  }

  /// Extracts birth date from the national ID number
  ///
  /// Handles century determination and month adjustments for gender
  DateTime getDatumNarozeni() {
    int rok = getRok();
    int mesic = getHrubyMesic();
    int den = getDen();

    // Month adjustment for women and alternative numbers
    if (mesic > 50) {
      mesic -= 50;
    }
    if (mesic > 20) {
      mesic -= 20;
    }

    // Century determination
    if (rok < 54) {
      rok += 2000;
    } else {
      rok += 1900;
    }

    return DateTime(rok, mesic, den);
  }

  /// Extracts day from national ID number
  int getDen() {
    int den = int.parse(_rc.substring(4, 6));
    return den;
  }

  /// Extracts raw month value from national ID number (before gender adjustment)
  int getHrubyMesic() {
    int mesic = int.parse(_rc.substring(2, 4));
    return mesic;
  }

  /// Extracts year from national ID number
  int getRok() {
    int rok = int.parse(_rc.substring(0, 2));
    return rok;
  }

  /// Returns the national ID number in human-readable format (123456/7890)
  ///
  /// Adds slash separator if not already present
  String getRc() {
    // Handle invalid/short RCs gracefully
    if (_rc.length < 6) {
      return _rc; // Return as-is if too short
    }

    String outRc = _rc;
    if (!_rc.contains('/')) {
      outRc = '${_rc.substring(0, 6)}/${_rc.substring(6)}';
    }
    return outRc;
  }

  /// Returns the raw formatted national ID number without slash (for testing)
  ///
  /// Used primarily for testing the formatRc method
  String getRawRc() {
    return _rc;
  }

  @override
  String toString() {
    return getRc();
  }

  // =====================================================
  // Generator Methods for Testing
  // =====================================================

  /// Generates a valid rodné číslo for a specific year.
  ///
  /// [year] - Birth year (1950-2030)
  /// [isFemale] - Optional gender specification (random if null)
  /// Returns a valid [RodneCislo] instance.
  ///
  /// This helper underpins test fixture creation. See
  /// `docs/testing-database-setup.md` (section *Rodné číslo generators*) for
  /// guidance on consistent usage within test setups.
  static RodneCislo generateForYear(int year, {bool? isFemale}) {
    final random = Random();

    // Generate random month and day
    final month = 1 + random.nextInt(12);
    final maxDay = DateTime(year, month + 1, 0).day;
    final day = 1 + random.nextInt(maxDay);

    return generateForDate(DateTime(year, month, day), isFemale: isFemale);
  }

  /// Generates a valid rodné číslo for a specific date.
  ///
  /// [birthDate] - Exact birth date
  /// [isFemale] - Optional gender specification (random if null)
  /// Returns a valid [RodneCislo] instance.
  ///
  /// Refer to `docs/testing-database-setup.md` for fixture patterns that call
  /// this helper when constructing deterministic test data.
  static RodneCislo generateForDate(DateTime birthDate, {bool? isFemale}) {
    final random = Random();

    // Determine gender
    final isActuallyFemale = isFemale ?? random.nextBool();

    // Convert year to 2-digit format
    int yy = birthDate.year % 100;

    // Month with gender encoding
    int month = birthDate.month;
    if (isActuallyFemale) {
      month += 50;
    }

    // Format date part: YYMMDD
    String datePart = '${yy.toString().padLeft(2, '0')}'
        '${month.toString().padLeft(2, '0')}'
        '${birthDate.day.toString().padLeft(2, '0')}';

    // Generate sequence number (100-999 for new format)
    int sequence = 100 + random.nextInt(899);

    // Calculate checksum digit that satisfies existing validation
    String nineDigits = datePart + sequence.toString();
    int checksum = _calculateChecksum(nineDigits);

    // Create full 10-digit RC
    String fullRc = nineDigits + checksum.toString();

    return RodneCislo(fullRc);
  }

  /// Generates a completely random valid rodné číslo
  ///
  /// [isFemale] - Optional gender specification (random if null)
  /// Returns a valid RodneCislo instance
  static RodneCislo generateRandom({bool? isFemale}) {
    final random = Random();

    // Generate random year between 1950-2030
    final year = 1950 + random.nextInt(81);

    return generateForYear(year, isFemale: isFemale);
  }

  /// Calculates the checksum digit for Czech rodné číslo
  ///
  /// Uses the same algorithm as the existing validation (modulo 11)
  static int _calculateChecksum(String nineDigits) {
    if (nineDigits.length != 9) {
      throw ArgumentError('Expected exactly 9 digits for checksum calculation');
    }

    // Find a checksum digit (0-9) that makes the whole 10-digit number
    // satisfy the existing validation: (whole_number % 11 == 0) or (whole_number % 11 == 1 and ends with 0)
    for (int checksum = 0; checksum <= 9; checksum++) {
      String fullNumber = nineDigits + checksum.toString();
      int fullAsInt = int.parse(fullNumber);
      int modulo = fullAsInt % 11;

      if (modulo == 0 || (modulo == 1 && fullNumber.endsWith('0'))) {
        return checksum;
      }
    }

    // If no valid checksum found, return 0 as fallback
    return 0;
  }
}
