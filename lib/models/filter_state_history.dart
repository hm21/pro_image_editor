import 'package:colorfilter_generator/colorfilter_generator.dart';

/// Represents the history of a filter state.
class FilterStateHistory {
  /// The color filter generator.
  final ColorFilterGenerator filter;

  /// The opacity of the filter.
  final double opacity;

  /// Constructs a [FilterStateHistory] instance.
  FilterStateHistory({
    required this.filter,
    required this.opacity,
  });

  /// Constructs a [FilterStateHistory] instance from a map representation.
  ///
  /// The [map] should contain 'name', 'filters', and 'opacity' keys.
  FilterStateHistory.fromMap(Map map)
      : filter = ColorFilterGenerator(
          name: map['name'] ?? 'Filter',
          filters: (map['filters'] as List<dynamic>?)
                  ?.map((e) => (e as List<dynamic>)
                      .map((e) => (e as num).toDouble())
                      .toList())
                  .toList() ??
              [],
        ),
        opacity =
            num.tryParse(map['opacity']?.toString() ?? '1')?.toDouble() ?? 1;

  /// Converts this filter state history object to a Map.
  ///
  /// Returns a Map representing the properties of this filter state history object,
  /// including the filter name, filter parameters, and opacity.
  Map toMap() {
    return {
      'name': filter.name,
      'filters': filter.filters,
      'opacity': opacity,
    };
  }
}
