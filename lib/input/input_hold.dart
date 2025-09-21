import 'package:denik_zza/input/rodne_cislo.dart';
import 'package:logger/logger.dart';
import 'package:denik_zza/utils/app_logger.dart';

import 'input_parser.dart';
import 'text_tools.dart';

/// This class parses one data item and validates input according to specific rules
abstract class InputHold {
  final Logger _logger = AppLogger.l;
  late dynamic pureInput;
  String input = "";
  dynamic output;
  ParseStatus? status;
  String columnName;

  InputHold(this.columnName);

/// Constructor, takes [pureInput] and [columnName] as arguments
  InputHold.full(this.pureInput, this.columnName) {
    if (pureInput == null) {
      status = ParseStatus.empty;
      output = null;
      return;
    }

    if (pureInput is int || pureInput is double) {
      input = pureInput.toString();
    } else {
      input = pureInput.trim();
    }

    if (input.isEmpty) {
      status = ParseStatus.bad;
      output = null;
    } else {
      output = _converter();
    }
    // Some converter didn't assign status
    status ??= ParseStatus.empty;
  }
  InputHold.empty(this.columnName) {
    status = ParseStatus.empty;
  }

  /// Returns a new empty instance of the same concrete type, preserving columnName
  /// Implemented by each subclass to allow cloning the definition list per parsed line
  InputHold fresh();

  dynamic getOutput() {
    return output;
  }

  /// Abstract method to be implemented by subclasses for specific conversion logic
  dynamic _converter();

  /// Adds input and processes it through the converter
  dynamic addInput(dynamic intake) {
    pureInput = intake;

    if (pureInput == null) {
      status = ParseStatus.empty;
      output = null;
      return output;
    }

    if (pureInput is int || pureInput is double) {
      input = pureInput.toString();
    } else {
      input = pureInput.trim();
    }

    if (input.isEmpty) {
      status = ParseStatus.bad;
      output = null;
    } else {
      try {
        output = _converter();
      } catch (e) {
        _logger.e('Error in converter for $columnName: $e');
        status = ParseStatus.bad;
        output = null;
      }
    }
    // Some converter didn't assign status
    status ??= ParseStatus.empty;
    return output;
  }

  bool isEmpty() {
    return input.isEmpty;
  }

  /// For validating FormFields in Flutter
  /// Returns null if validation passes, error message if validation fails
  String? validator(String? input) {
    addInput(input);
    _converter();
    if (status == ParseStatus.ok) {
      return null;
    } else if (status == ParseStatus.bad) {
      return "$columnName má nesprávná data"; // Generic error message
    } else if (status == ParseStatus.warn) {
      return "Warning: Please check the input"; // Warning message
    }
    return "Unknown error"; // Fallback error message
  }
}
/// For parsing Jméno and Příjmení (First name and Last name)
class JmenoHold extends InputHold {
  JmenoHold({String columnName = "jméno"}) : super(columnName);
  JmenoHold.full(dynamic pureInput, {String columnName = "jméno"}) : super.full(pureInput, columnName);
  @override
  InputHold fresh() => JmenoHold(columnName: columnName);
  @override
  dynamic _converter() {
    status = ParseStatus.ok;
    return input;
  }
}

/// Validates gender input and converts to numeric format (1=male, 2=female)
class PohlaviHold extends InputHold {
  List<String> possibleMuz = ["m", "1", "muž", "chlapec", "kluk"];
  List<String> possibleZena = ["ž", "2", "žena", "dívka", "holka","f"];

  PohlaviHold({String columnName = "pohlaví"}) : super(columnName);
  PohlaviHold.full(dynamic pureInput, {String columnName = "pohlaví"}) : super.full(pureInput, columnName);
  @override
  InputHold fresh() => PohlaviHold(columnName: columnName);

  @override
  _converter() {
    if (input.isEmpty) {
      status = ParseStatus.ok;
      return null;
    }
    if (TextTools.looseCmpWithList(input, possibleMuz)) {
      status = ParseStatus.ok;
      return 1;
    } else if (TextTools.looseCmpWithList(input, possibleZena)) {
      status = ParseStatus.ok;
      return 2;
    } else {
      status = ParseStatus.bad;
      return null;
    }
  }
}

/// Validates and stores address information
class AdresaHold extends InputHold {
  AdresaHold({String columnName = "adresa"}) : super(columnName);
  AdresaHold.full(dynamic pureInput, {String columnName = "adresa"}) : super.full(pureInput, columnName);
  @override
  InputHold fresh() => AdresaHold(columnName: columnName);

  @override
  _converter() {
    status = ParseStatus.ok;
    return input;
  }
}
/// Validates Czech national identification number (rodné číslo)
class CisloPojisteniHold extends InputHold {
  CisloPojisteniHold({String columnName = "rodné číslo"}) : super(columnName);
  CisloPojisteniHold.full(dynamic pureInput, {String columnName = "rodné číslo"}) : super(columnName) {
    this.pureInput = pureInput;
    
    if (pureInput == null) {
      status = ParseStatus.empty;
      output = RodneCislo(""); // Create empty RodneCislo instead of null
      return;
    }

    if (pureInput is int || pureInput is double) {
      input = pureInput.toString();
    } else {
      input = pureInput.trim();
    }

    // Always call _converter(), even for empty input
    output = _converter();
    status ??= ParseStatus.empty;
  }
  
  @override
  InputHold fresh() => CisloPojisteniHold(columnName: columnName);

  @override
  _converter() {
    // Handle empty input by creating an empty RodneCislo
    if (input.isEmpty) {
      RodneCislo rc = RodneCislo("");
      status = ParseStatus.ok;
      output = rc;
      return rc;
    }
    
    RodneCislo rc = RodneCislo(input);
    if (!rc.hasValidFormat) {
      status = ParseStatus.bad;
      output = rc;
      return rc;
    }
    if (!rc.hasValidSum) {
      status = ParseStatus.warn;
      output = rc;
    } else {
      status = ParseStatus.ok;
      output = rc;
    }
    return rc;
  }

  /// Custom validator because rodne cislo validation has specific requirements
  @override
  validator(String? input) {
    addInput(input);
    _converter();
    if (status == ParseStatus.ok) {
      return null;
    } else if (status == ParseStatus.bad) {
      return null; // for the form
    } else if (status == ParseStatus.warn) {
      return null; // for the form
    }
    return "Unknown error";
  }
}
/// Validates and parses birth date information
class DatumNarozeniHold extends InputHold {
  DatumNarozeniHold({String columnName = "datum narození"}) : super(columnName);
  DatumNarozeniHold.full(dynamic pureInput, {String columnName = "datum narození"}) : super.full(pureInput, columnName);
  @override
  InputHold fresh() => DatumNarozeniHold(columnName: columnName);

  @override
  _converter() {
    // Handle empty input with warning status - same level as computed dates
    if (input.isEmpty) {
      status = ParseStatus.warn;
      return null;
    }
    
    DateTime? date = TextTools.parseDate(input);
    if (date == null) {
      // Per policy: date parsing should WARN (no silent normalization), not hard-fail
      status = ParseStatus.warn;
      return null;
    }
    status = ParseStatus.ok;
    return date;
  }
  
  /// Custom validator to provide specific message for missing birth date
  @override
  String? validator(String? input) {
    addInput(input);
    _converter();
    if (status == ParseStatus.ok) {
      return null;
    } else if (status == ParseStatus.bad) {
      return "$columnName má nesprávná data";
    } else if (status == ParseStatus.warn) {
      if (this.input.isEmpty) {
        return "datum narození je extrémně doporučeno";
      }
      return "Warning: Please check the input";
    }
    return "Unknown error";
  }
}
/// Validates telephone number format
class TelefonHold extends InputHold {
  TelefonHold({String columnName = "telefon rodič"}) : super(columnName);
  TelefonHold.full(dynamic pureInput, {String columnName = "telefon rodič"}) : super.full(pureInput, columnName);
  @override
  InputHold fresh() => TelefonHold(columnName: columnName);

  @override
  _converter() {
    status = ParseStatus.ok;
    return input;
  }
}

/// Validates email address format
class EmailHold extends InputHold {
  EmailHold({String columnName = "email rodič"}) : super(columnName);
  EmailHold.full(dynamic pureInput, {String columnName = "email rodič"}) : super.full(pureInput, columnName);
  @override
  InputHold fresh() => EmailHold(columnName: columnName);

  @override
  _converter() {
    if (input.isEmpty) {
      status = ParseStatus.ok;
      return input;
    }
    if (input.contains("@")) {
      status = ParseStatus.ok;
      return input;
    }
    status = ParseStatus.bad;
    return input;
  }
}
/// Validates confirmation/checkbox input (yes/no values)
class PotvrzeniHold extends InputHold {
  PotvrzeniHold({String columnName = "potvrzení"}) : super(columnName);
  PotvrzeniHold.full(dynamic pureInput, {String columnName = "potvrzení"}) : super(columnName) {
    this.pureInput = pureInput;
    
    if (pureInput == null) {
      status = ParseStatus.ok;
      output = false; // Default to false when null
      return;
    }

    if (pureInput is int || pureInput is double) {
      input = pureInput.toString();
    } else {
      input = pureInput.trim();
    }

    // Always call _converter(), even for empty input
    output = _converter();
    status ??= ParseStatus.empty;
  }
  
  @override
  InputHold fresh() => PotvrzeniHold(columnName: columnName);
  
  List<String> possibleYes = ["ano", "yes", "y", "1", "true"];
  List<String> possibleNo = ["ne", "no", "n", "0", "false"];

  @override
  dynamic addInput(dynamic intake) {
    pureInput = intake;

    if (pureInput == null) {
      status = ParseStatus.ok;
      output = false; // Default to false for null input
      return output;
    }

    if (pureInput is int || pureInput is double) {
      input = pureInput.toString();
    } else {
      input = pureInput.trim();
    }

    // Special handling for empty input - default to false (making způsobilost unrequired)
    if (input.isEmpty) {
      status = ParseStatus.ok;
      output = false;
      return output;
    }

    try {
      output = _converter();
    } catch (e) {
      status = ParseStatus.bad;
      output = null;
    }
    
    return output;
  }

  @override
  _converter() {
    if (TextTools.looseCmpWithList(input, possibleYes)) {
      status = ParseStatus.ok;
      return true;
    }
    if (TextTools.looseCmpWithList(input, possibleNo)) {
      status = ParseStatus.ok;
      return false;
    }
    status = ParseStatus.bad;
    return null;
  }
}
/// Validates health insurance company information
/// TODO: implement specific validation logic for Czech insurance companies
class PojistovnaHold extends InputHold {
  PojistovnaHold({String columnName = "pojišťovna"}) : super(columnName);
  PojistovnaHold.full(dynamic pureInput, {String columnName = "pojišťovna"}) : super.full(pureInput, columnName);
  @override
  InputHold fresh() => PojistovnaHold(columnName: columnName);
  
  @override
  _converter() {
    // Empty is acceptable, treat as OK with null output
    if (input.isEmpty) {
      status = ParseStatus.ok;
      return null;
    }

    // Known Czech health insurance companies with common synonyms and codes.
    // Policy: Loose compare and pick the first match's canonical.
    // Canonical is a short lowercase code to align with existing expectations (e.g., 'ozp').
    final List<_InsuranceEntry> insurers = [
      _InsuranceEntry(
        canonical: 'vzp',
        synonyms: [
          'vzp',
          '111',
          'všeobecná zdravotní pojišťovna',
          'vseobecna zdravotni pojistovna',
          '111 vzp',
          'vzp 111',
        ],
      ),
      _InsuranceEntry(
        canonical: 'vozp',
        synonyms: [
          'vozp',
          '201',
          'vojenská zdravotní pojišťovna',
          'vojenska zdravotni pojistovna',
          '201 vozp',
        ],
      ),
      _InsuranceEntry(
        canonical: 'cpzp',
        synonyms: [
          'cpzp',
          '205',
          'ceska prumyslova zdravotni pojistovna',
          'česká průmyslová zdravotní pojišťovna',
          '205 cpzp',
        ],
      ),
      _InsuranceEntry(
        canonical: 'ozp',
        synonyms: [
          'ozp',
          '207',
          'oborová zdravotní pojišťovna',
          'oborova zdravotni pojistovna',
          '207 ozp',
        ],
      ),
      _InsuranceEntry(
        canonical: 'zpmv',
        synonyms: [
          'zpmv',
          '211',
          'zdravotni pojistovna ministerstva vnitra ceske republiky',
          'zdravotní pojišťovna ministerstva vnitra české republiky',
          '211 zpmv',
        ],
      ),
      _InsuranceEntry(
        canonical: 'rbp',
        synonyms: [
          'rbp',
          '213',
          'revirni bratrská pokladna',
          'revírní bratrská pokladna',
          '213 rbp',
        ],
      ),
      _InsuranceEntry(
        canonical: 'zps',
        synonyms: [
          'zps',
          '209',
          'zdravotni pojistovna skoda',
          'zdravotní pojišťovna škoda',
          '209 zps',
        ],
      ),
    ];

    final String norm = TextTools.normText(input);
    for (final entry in insurers) {
      for (final syn in entry.synonyms) {
        if (TextTools.looseCmp(norm, syn)) {
          status = ParseStatus.ok;
          return entry.canonical;
        }
      }
    }

    // No match found: keep original value as-is, but still OK
    status = ParseStatus.ok;
    return input;
  }
}

/// Validates general text input (notes, comments)
class TextHold extends InputHold {
  TextHold({String columnName = "poznámka"}) : super(columnName);
  TextHold.full(dynamic pureInput, {String columnName = "poznámka"}) : super.full(pureInput, columnName);
  @override
  InputHold fresh() => TextHold(columnName: columnName);
  
  @override
  _converter() {
    status = ParseStatus.ok;
    return input;
  }
}

/// Internal helper to represent an insurance with its synonyms.
class _InsuranceEntry {
  final String canonical;
  final List<String> synonyms;
  const _InsuranceEntry({required this.canonical, required this.synonyms});
}
