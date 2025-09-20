import 'package:denik_zza/input/rodne_cislo.dart';
import 'package:logger/logger.dart';

import 'input_parser.dart';
import 'text_tools.dart';

/// This class parses one data item and validates input according to specific rules
abstract class InputHold {
  final Logger _logger = Logger();
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
  dynamic _converter() {
    status = ParseStatus.ok;
    return input;
  }
}

/// Validates gender input and converts to numeric format (1=male, 2=female)
class PohlaviHold extends InputHold {
  List<String> possibleMuz = ["m", "1", "muž", "chlapec", "kluk"];
  List<String> possibleZena = ["ž", "2", "žena", "dívka", "holka"];

  PohlaviHold({String columnName = "pohlaví"}) : super(columnName);
  PohlaviHold.full(dynamic pureInput, {String columnName = "pohlaví"}) : super.full(pureInput, columnName);

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
  _converter() {
    status = ParseStatus.ok;
    return input;
  }
}
/// Validates Czech national identification number (rodné číslo)
class CisloPojisteniHold extends InputHold {
  CisloPojisteniHold({String columnName = "rodné číslo"}) : super(columnName);
  CisloPojisteniHold.full(dynamic pureInput, {String columnName = "rodné číslo"}) : super.full(pureInput, columnName);

  @override
  _converter() {
    RodneCislo rc = RodneCislo(input);
    if (!rc.hasValidFormat) {
      status = ParseStatus.bad;
      return rc;
    }
    if (!rc.hasValidSum) {
      status = ParseStatus.warn;
      output = rc.getRc();
    } else {
      status = ParseStatus.ok;
      output = rc.getRc();
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
  _converter() {
    DateTime? date = TextTools.parseDate(input);
    if (date == null) {
      status = ParseStatus.bad;
      return null;
    }
    status = ParseStatus.ok;
    return date;
  }
}
/// Validates telephone number format
class TelefonHold extends InputHold {
  TelefonHold({String columnName = "telefon rodič"}) : super(columnName);
  TelefonHold.full(dynamic pureInput, {String columnName = "telefon rodič"}) : super.full(pureInput, columnName);

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
  PotvrzeniHold.full(dynamic pureInput, {String columnName = "potvrzení"}) : super.full(pureInput, columnName);
  
  List<String> possibleYes = ["ano", "yes", "y", "1", "true"];
  List<String> possibleNo = ["ne", "no", "n", "0", "false"];

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
  _converter() {
    status = ParseStatus.ok;
    return input;
  }
}

/// Validates general text input (notes, comments)
class TextHold extends InputHold {
  TextHold({String columnName = "poznámka"}) : super(columnName);
  TextHold.full(dynamic pureInput, {String columnName = "poznámka"}) : super.full(pureInput, columnName);
  
  @override
  _converter() {
    status = ParseStatus.ok;
    return input;
  }
}
