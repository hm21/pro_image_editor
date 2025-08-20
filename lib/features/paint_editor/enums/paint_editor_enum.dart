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
}

/// Defines the available erasing modes.
///
/// The [EraserMode] determines how the eraser tool behaves when
/// applied to an image or canvas.
enum EraserMode {
  /// Erases entire objects or shapes at once.
  ///
  /// Useful when the goal is to remove a complete element without
  /// affecting its surrounding parts.
  object,

  /// Erases only the selected portion of an object or area.
  ///
  /// Useful for fine-grained control when you want to erase
  /// part of an element rather than removing it entirely.
  partial,
}
