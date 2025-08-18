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

  /// Draws a Polygon with multiple connected lines.
  polygon,

  /// Remove paint-items when hit.
  eraser,

  /// Creates an area that blurs the background.
  blur,

  /// Creates an area that will pixelate the background.
  pixelate,

  /// Creates a cross item.
  cross,
}
