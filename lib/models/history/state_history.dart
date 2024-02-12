import '../filter_state_history.dart';
import '../layer.dart';

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
  // Save memory to ref to a sepperated array which contain only image changes and not also layer-changes
  int bytesRefIndex = 0;
  List<Layer> layers = [];
  List<FilterStateHistory> filters = [];

  EditorStateHistory({
    required this.bytesRefIndex,
    required this.layers,
    required this.filters,
  });
}
