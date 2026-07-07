import '../types/filter_state.dart';
import 'combine_color_matrix_utils.dart';

/// Whether [filters] carries video-timeline scheduling metadata.
///
/// A flattened static color matrix cannot reproduce a filter that is only
/// active during part of the timeline, so such filters are excluded from
/// merging.
bool _hasTimeline(FilterState filter) =>
    filter.startTime != null ||
    filter.endTime != null ||
    filter.enterDuration != null ||
    filter.exitDuration != null;

/// Whether [filters] can be flattened into a single [FilterState] without
/// changing the rendered result.
///
/// Requires at least two states and none carrying video-timeline metadata.
bool canMergeFilterStates(List<FilterState> filters) {
  if (filters.length < 2) return false;
  return filters.every((filter) => !_hasTimeline(filter));
}

/// Flattens [filters] into a single [FilterState] whose one matrix is the exact
/// composition of every source matrix, in the same order the renderer applies
/// them (see [mergeColorMatrices]).
///
/// The result is appearance-identical to the original stack because filters are
/// pure color matrices and the editor already renders them as one combined
/// `ColorFilter.matrix`. Tune adjustments are intentionally excluded so they
/// keep composing on top of the merged filter unchanged.
///
/// The metadata of every source filter is carried over into the merged state
/// (later filters win on key conflicts) so host-attached data is not lost.
FilterState mergeFilterStates(
  List<FilterState> filters, {
  String name = 'merged',
}) {
  final combined = mergeColorMatrices(
    filterList: filters.expand((filter) => filter.matrices).toList(),
    tuneAdjustmentList: const [],
  );
  final mergedMeta = <String, dynamic>{};
  for (final filter in filters) {
    mergedMeta.addAll(filter.meta);
  }
  return FilterState(name: name, matrices: [combined], meta: mergedMeta);
}
