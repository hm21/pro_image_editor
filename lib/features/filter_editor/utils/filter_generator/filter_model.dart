// Project imports:
import '/features/filter_editor/types/filter_matrix.dart';
import 'color_filter_step.dart';

/// A model class that represents a filter with a name and associated filter
/// matrix.
class FilterModel {
  /// Constructs a [FilterModel] instance with the specified [name] and
  /// [filters].
  ///
  /// The [name] parameter is required and represents the name of the filter.
  /// The [filters] parameter is required and represents the filter matrix to
  /// be applied.
  ///
  /// A filter built from matrices alone has no [steps].
  const FilterModel({required this.name, required this.filters})
    : steps = const [];

  /// Constructs a [FilterModel] from the [steps] of its recipe; its
  /// [filters] are the steps' matrices, in order.
  ///
  /// Keeping the steps lets an app show and change the values a filter was
  /// made with, then rebuild it with [copyWith].
  FilterModel.fromSteps({
    required this.name,
    required List<ColorFilterStep> steps,
  }) : steps = List.unmodifiable(steps),
       filters = [for (final step in steps) step.matrix];

  const FilterModel._({
    required this.name,
    required this.filters,
    required this.steps,
  });

  /// The name of the filter.
  final String name;

  /// The filter matrix associated with this filter.
  final FilterMatrix filters;

  /// The recipe [filters] was built from, or empty for a filter built from
  /// matrices alone.
  final List<ColorFilterStep> steps;

  /// Creates a copy of this filter with the given fields replaced.
  ///
  /// With [steps], the copy's [filters] are rebuilt from them, replacing the
  /// matrices of a filter that had no steps.
  FilterModel copyWith({String? name, List<ColorFilterStep>? steps}) {
    if (steps != null) {
      return FilterModel.fromSteps(name: name ?? this.name, steps: steps);
    }
    return FilterModel._(
      name: name ?? this.name,
      filters: filters,
      steps: this.steps,
    );
  }
}
