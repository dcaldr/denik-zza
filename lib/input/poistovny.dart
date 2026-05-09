// Helper utilities for handling Czech health insurance (pojišťovna) names.
//
// This module centralizes the canonical insurer list and the mapping logic
// so other code (parsers, DB wiring) can reuse consistent logic.
import 'package:denik_zza/input/text_tools.dart';

/// Internal representation of an insurer entry.
class _InsuranceEntry {
  final String canonical;
  final List<String> synonyms;
  const _InsuranceEntry({required this.canonical, required this.synonyms});
}

/// Compact list of known Czech insurers with canonical short codes.
///
/// Note: the synonyms list is intentionally compact — the matching is
/// delegated to TextTools.looseCmpWithList which performs diacritic-insensitive
/// fuzzy comparison, so we don't need to provide every diacritic/no-diacritic
/// permutation here.
const List<_InsuranceEntry> _insurers = [
  _InsuranceEntry(
    canonical: 'vzp',
    synonyms: ['vzp', '111', 'všeobecná zdravotní pojišťovna', '111 vzp'],
  ),
  _InsuranceEntry(
    canonical: 'vozp',
    synonyms: ['vozp', '201', 'vojenská zdravotní pojišťovna', '201 vozp'],
  ),
  _InsuranceEntry(
    canonical: 'cpzp',
    synonyms: ['cpzp', '205', 'česká průmyslová zdravotní pojišťovna', '205 cpzp'],
  ),
  _InsuranceEntry(
    canonical: 'ozp',
    synonyms: ['ozp', '207', 'oborová zdravotní pojišťovna', '207 ozp'],
  ),
  _InsuranceEntry(
    canonical: 'zpmv',
    synonyms: ['zpmv', '211', 'zdravotní pojišťovna ministerstva vnitra české republiky', '211 zpmv'],
  ),
  _InsuranceEntry(
    canonical: 'rbp',
    synonyms: ['rbp', '213', 'revírní bratrská pokladna', '213 rbp'],
  ),
  _InsuranceEntry(
    canonical: 'zps',
    synonyms: ['zps', '209', 'zdravotní pojišťovna škoda', '209 zps'],
  ),
];

/// Attempts to canonicalize an insurer name to the short code used in the DB.
///
/// - If [input] is null or empty, returns null.
/// - If [input] loosely matches a known insurer synonym, returns the canonical
///   short code (e.g., 'vzp', 'ozp').
/// - Otherwise returns the original trimmed input string (unknown insurers are
///   allowed and should be stored as-is in the DB).
String? canonicalizeInsurance(String? input) {
  if (input == null) return null;
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;

  final norm = TextTools.normText(trimmed);
  for (final entry in _insurers) {
    if (TextTools.looseCmpWithList(norm, entry.synonyms)) {
      return entry.canonical;
    }
  }

  // Unknown insurer - return user-provided string so it can be saved to DB
  return trimmed;
}

/// Expose a read-only view for test/consumers that need to iterate known insurers.
List<Map<String, Object>> knownInsurersForTest() {
  return _insurers.map((e) => {'canonical': e.canonical, 'synonyms': e.synonyms}).toList();
}
