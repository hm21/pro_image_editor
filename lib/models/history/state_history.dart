// Project imports:
import '../crop_rotate_editor/transform_factors.dart';
import '../layer.dart';
import 'blur_state_history.dart';
import 'filter_state_history.dart';

/// The `EditorStateHistory` class represents changes made to an image in the image
/// editor. It contains information about the changes applied to the image, including
/// a reference to the image data and a list of layers.
///
/// Usage:
///
/// ```dart
/// EditorStateHistory changes = EditorStateHistory(
///   bytesRefIndex: 0,
///   layers: [
///     Layer(
///       // Layer data and properties
///     ),
///     // Additional layers...
///   ],
/// );
/// ```
///
/// Properties:
///
/// - `bytesRefIndex` (required): An integer representing the reference index to the
///   image data. It allows identifying the specific image that the changes are applied
///   to.
///
/// - `layers` (required): A list of `Layer` objects representing the layers and their
///   properties that have been added or modified in the image editor.
///
/// Example Usage:
///
/// ```dart
/// EditorStateHistory changes = EditorStateHistory(
///   bytesRefIndex: 0,
///   blur: BlurStateHistory(blur: 0),
///   filters: [],
///   layers: [
///     Layer(
///       name: 'Text Layer',
///       type: LayerType.text,
///       // Additional layer properties...
///     ),
///     Layer(
///       name: 'Filter Layer',
///       type: LayerType.filter,
///       // Additional layer properties...
///     ),
///   ],
/// );
/// ```
///
/// Please refer to the documentation of individual properties and methods for more details.

class EditorStateHistory {
  /// The history of blur states.
  final BlurStateHistory blur;

  /// The list of layers.
  final List<Layer> layers;

  /// The list of filter state histories.
  final List<FilterStateHistory> filters;

  /// The transformation from the crop/ rotate editor.
  TransformConfigs transformConfigs;

  /// Constructs a new [EditorStateHistory] instance with the specified parameters.
  ///
  /// All parameters are required.
  EditorStateHistory({
    required this.blur,
    required this.layers,
    required this.filters,
    required this.transformConfigs,
  });
}
