/// The `PaintModeE` enum represents different painting modes for a drawing
/// application in Flutter.
enum PaintModeE {
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

  /// Remove paintings when hit.
  eraser,
}
