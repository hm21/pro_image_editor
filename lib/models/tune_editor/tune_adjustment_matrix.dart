/// A class representing the adjustment matrix for a tune adjustment item.
///
/// This class holds the adjustment [id], the [value] of the adjustment, and
/// the corresponding transformation [matrix] that applies the adjustment.
class TuneAdjustmentMatrix {
  /// Creates a [TuneAdjustmentMatrix] instance from a [Map] representation.
  ///
  /// This factory constructor extracts [id], [value], and [matrix] from the
  /// provided [map].
  factory TuneAdjustmentMatrix.fromMap(Map<String, dynamic> map) {
    return TuneAdjustmentMatrix(
      id: map['id']?.toString() ?? '-',
      value: double.tryParse(map['value']?.toString() ?? '0') ?? 0,
      matrix: List.castFrom<dynamic, double>((map['matrix'] ?? []) as List),
    );
  }

  /// Creates a [TuneAdjustmentMatrix] with the given [id], [value], and
  /// [matrix].
  ///
  /// - [id] is the unique identifier for the adjustment.
  /// - [value] is the adjustment value.
  /// - [matrix] is a list of doubles representing the matrix transformation.
  TuneAdjustmentMatrix({
    required this.id,
    required this.value,
    required this.matrix,
  });

  /// The unique identifier for the tune adjustment.
  final String id;

  /// The value of the tune adjustment.
  final double value;

  /// The transformation matrix associated with the tune adjustment.
  final List<double> matrix;

  /// Converts this [TuneAdjustmentMatrix] instance into a [Map] representation.
  ///
  /// The map contains the [id], [value], and [matrix] as key-value pairs.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'value': value,
      'matrix': matrix,
    };
  }

  /// Creates a copy of this [TuneAdjustmentMatrix] instance with the same
  /// values.
  ///
  /// The [copy] method allows duplicating the matrix with identical properties.
  TuneAdjustmentMatrix copy() {
    return TuneAdjustmentMatrix(
      id: id,
      value: value,
      matrix: [...matrix],
    );
  }
}
