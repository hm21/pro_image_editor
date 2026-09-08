import '../models/tune_adjustment_matrix.dart';

/// Latest untimed/global adjustment for [id], or `null` if none exist.
///
/// Duplicate global entries (from a session that stacked the same ids) are
/// collapsed by taking the last write. Timed entries with the same [id] are
/// ignored so they can keep coexisting with the global slot.
TuneAdjustmentMatrix? latestGlobalTuneAdjustment(
  Iterable<TuneAdjustmentMatrix> applied,
  String id,
) {
  TuneAdjustmentMatrix? latest;
  for (final adjustment in applied) {
    if (adjustment.id == id && !adjustment.hasTimeline) {
      latest = adjustment;
    }
  }
  return latest;
}

/// Merges a TuneEditor session with previously applied adjustments.
///
/// TuneEditor only edits one untimed/global slot per known option id. This
/// keeps timed entries and any id absent from [session] (order and duplicates
/// included), replaces the matching global slots with [session], and drops
/// leftover untimed duplicates of those known ids created by the old
/// append-on-apply stacking bug.
List<TuneAdjustmentMatrix> mergeTuneEditorResult({
  required List<TuneAdjustmentMatrix> existing,
  required List<TuneAdjustmentMatrix> session,
}) {
  final sessionById = <String, TuneAdjustmentMatrix>{
    for (final item in session) item.id: item,
  };
  final result = <TuneAdjustmentMatrix>[];
  final placedSessionIds = <String>{};

  for (final item in existing) {
    if (item.hasTimeline) {
      result.add(item.copy());
      continue;
    }

    final replacement = sessionById[item.id];
    if (replacement != null) {
      if (placedSessionIds.add(item.id)) {
        result.add(replacement.copy());
      }
      continue;
    }

    result.add(item.copy());
  }

  for (final item in session) {
    if (placedSessionIds.add(item.id)) {
      result.add(item.copy());
    }
  }

  return result;
}
