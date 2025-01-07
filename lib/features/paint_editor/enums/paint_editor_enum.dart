/// The `PaintMode` enum represents different paint-item modes for a drawing
/// application in Flutter.
enum PaintMode {
  /// Allows to move and zoom the editor
  moveAndZoom,

  /// Allows freehand drawing.
  freeStyle,

  /// Draws a straight line between two points.
  line,

  /// Creates a rectangle shape.
  rect,

  /// Draws a line with an arrowhead at the end point.
  arrow,

  /// Creates a circle shape starting from a point.
  circle,

  /// Draws a dashed line between two points.
  dashLine,

  /// Remove paint-items when hit.
  eraser,
}

// TODO: Remove in version 8.0.0
/// Old version of `PaintMode`.
///
/// Deprecated: Use `PaintMode` instead.
@Deprecated(
  'Use PaintMode instead. This will be removed in a future release.',
)
enum PaintModeE {
  /// Represents the Material Design style.
  material,

  /// Represents the Cupertino Design style.
  cupertino,
}
