import '../models/tune_adjustment_matrix.dart';

/// Merges the tune editor's [sliders] back into the [applied] adjustments.
///
/// The editor edits exactly one untimed entry per slider id. Every untimed
/// entry of such an id in [applied] is replaced by the slider (in place of the
/// first one, so stacked duplicates from the old append-on-apply bug collapse
/// to one), while timed entries and ids without a slider are kept in their
/// original order. Sliders whose id is not applied yet are appended.
List<TuneAdjustmentMatrix> mergeTuneAdjustments({
  required List<TuneAdjustmentMatrix> applied,
  required List<TuneAdjustmentMatrix> sliders,
}) {
  final sliderById = {for (final item in sliders) item.id: item};
  final placedIds = <String>{};
  final result = <TuneAdjustmentMatrix>[];

  for (final item in applied) {
    final slider = item.hasTimeline ? null : sliderById[item.id];
    if (slider == null) {
      result.add(item.copy());
    } else if (placedIds.add(item.id)) {
      result.add(slider.copy());
    }
  }

  for (final item in sliders) {
    if (placedIds.add(item.id)) result.add(item.copy());
  }

  return result;
}
