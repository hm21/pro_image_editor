// Project imports:
import 'package:flutter/foundation.dart';

import '/features/crop_rotate_editor/models/transform_configs.dart';
import '/features/filter_editor/types/filter_state.dart';
import '/features/tune_editor/models/tune_adjustment_matrix.dart';
import '../layers/layer.dart';

/// The `EditorStateHistory` class represents changes made to an image in the
/// image editor. It contains information about the changes applied to the
/// image and a list of layers.
class EditorStateHistory {
  /// Constructs a new [EditorStateHistory] instance with the specified
  /// parameters.
  ///
  /// All parameters are required.
  EditorStateHistory({
    this.blur,
    this.layers = const [],
    this.filters = const [],
    this.tuneAdjustments = const [],
    this.transformConfigs,
    this.meta = const {},
  });

  /// The blur factor.
  final double? blur;

  /// The list of layers.
  final List<Layer> layers;

  /// The applied filters.
  final List<FilterState> filters;

  /// The applied tune adjustments.
  final List<TuneAdjustmentMatrix> tuneAdjustments;

  /// The transformation from the crop/ rotate editor.
  TransformConfigs? transformConfigs;

  /// Optional user-defined metadata that is preserved across undo/redo.
  final Map<String, dynamic> meta;

  /// Creates a copy of the current `EditorStateHistory` instance with the
  /// option to override some of its properties.
  ///
  /// If a property is not provided, the current value of that property will be
  /// used in the copied instance.
  ///
  /// Returns a new `EditorStateHistory` instance with the updated properties.
  EditorStateHistory copyWith({
    double? blur,
    List<Layer>? layers,
    List<FilterState>? filters,
    List<TuneAdjustmentMatrix>? tuneAdjustments,
    TransformConfigs? transformConfigs,
    Map<String, dynamic>? meta,
  }) {
    return EditorStateHistory(
      blur: blur ?? this.blur,
      layers: layers ?? this.layers,
      filters: filters ?? this.filters,
      tuneAdjustments: tuneAdjustments ?? this.tuneAdjustments,
      transformConfigs: transformConfigs ?? this.transformConfigs,
      meta: meta ?? this.meta,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EditorStateHistory &&
        other.blur == blur &&
        listEquals(other.layers, layers) &&
        listEquals(other.filters, filters) &&
        listEquals(other.tuneAdjustments, tuneAdjustments) &&
        transformConfigs == other.transformConfigs &&
        mapEquals(other.meta, meta);
  }

  @override
  int get hashCode {
    return blur.hashCode ^
        layers.hashCode ^
        filters.hashCode ^
        tuneAdjustments.hashCode ^
        transformConfigs.hashCode ^
        meta.hashCode;
  }
}
