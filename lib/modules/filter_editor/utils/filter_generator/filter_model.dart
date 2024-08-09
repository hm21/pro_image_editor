// Project imports:
import 'package:pro_image_editor/modules/filter_editor/types/filter_matrix.dart';

/// A model class that represents a filter with a name and associated filter
/// matrix.
class FilterModel {
  /// Constructs a [FilterModel] instance with the specified [name] and
  /// [filters].
  ///
  /// The [name] parameter is required and represents the name of the filter.
  /// The [filters] parameter is required and represents the filter matrix to
  /// be applied.
  const FilterModel({
    required this.name,
    required this.filters,
  });

  /// The name of the filter.
  final String name;

  /// The filter matrix associated with this filter.
  final FilterMatrix filters;
}
