// Project imports:
import '../../modules/filter_editor/types/filter_matrix.dart';
import '../crop_rotate_editor/transform_factors.dart';
import '../layer/layer.dart';
import '../tune_editor/tune_adjustment_matrix.dart';

/// The `EditorStateHistory` class represents changes made to an image in the
/// image editor. It contains information about the changes applied to the
/// image and a list of layers.
class EditorStateHistory {
  /// Constructs a new [EditorStateHistory] instance with the specified
  /// parameters.
  ///
  /// All parameters are required.
  EditorStateHistory({
    required this.blur,
    required this.layers,
    required this.filters,
    required this.tuneAdjustments,
    required this.transformConfigs,
  });

  /// The blur factor.
  final double blur;

  /// The list of layers.
  final List<Layer> layers;

  /// The applied filters.
  final FilterMatrix filters;

  /// The applied tune adjustments.
  final List<TuneAdjustmentMatrix> tuneAdjustments;

  /// The transformation from the crop/ rotate editor.
  TransformConfigs transformConfigs;
}
