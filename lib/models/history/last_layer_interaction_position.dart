/// The `LayerLastPosition` enum represents positions relative to the center of an
/// image or container. It is used to specify alignments or positions in relation to
/// the center point, providing options such as left, right, top, bottom, or center.
///
/// Usage:
///
/// ```dart
/// LayerLastPosition position = LayerLastPosition.center;
/// ```
///
/// Enum Values:
///
/// - `left`: Represents the position to the left of the center point.
///
/// - `right`: Represents the position to the right of the center point.
///
/// - `top`: Represents the position above the center point.
///
/// - `bottom`: Represents the position below the center point.
///
/// - `center`: Represents the center position relative to the center point.
///
/// Example Usage:
///
/// ```dart
/// LayerLastPosition position = LayerLastPosition.center;
///
/// switch (position) {
///   case LayerLastPosition.left:
///     // Handle left position relative to the center.
///     break;
///   case LayerLastPosition.right:
///     // Handle right position relative to the center.
///     break;
///   case LayerLastPosition.top:
///     // Handle top position relative to the center.
///     break;
///   case LayerLastPosition.bottom:
///     // Handle bottom position relative to the center.
///     break;
///   case LayerLastPosition.center:
///     // Handle center position relative to the center.
///     break;
/// }
/// ```
///
/// Please refer to the documentation of individual enum values for more details.
enum LayerLastPosition {
  /// Represents the position to the left of the center point.
  left,

  /// Represents the position to the right of the center point.
  right,

  /// Represents the position above the center point.
  top,

  /// Represents the position below the center point.
  bottom,

  /// Represents the center position relative to the center point.
  center,
}
