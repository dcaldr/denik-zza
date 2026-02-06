import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';

/// Comparator for sorting records by time (oldest first), null-safe.
///
/// Used across print ops, services, and UI to maintain consistent
/// chronological ordering of medical records.
int compareRecordsByTime(MemoryZaznam a, MemoryZaznam b) {
  final ad = a.casZaznamu;
  final bd = b.casZaznamu;
  if (ad == null && bd == null) return 0;
  if (ad == null) return -1;
  if (bd == null) return 1;
  return ad.compareTo(bd);
}

/// Sorts a list of records by time in-place (oldest first).
/// Convenience wrapper around [compareRecordsByTime].
void sortRecordsByTime(List<MemoryZaznam> records) {
  records.sort(compareRecordsByTime);
}
