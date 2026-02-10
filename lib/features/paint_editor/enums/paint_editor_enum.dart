/// The `PaintMode` enum represents different paint-item modes for a drawing
/// application in Flutter.
enum PaintMode {
  /// Allows to move and zoom the editor
  moveAndZoom,

  /// Allows freehand drawing.
  freeStyle,

  /// Allows freehand drawing with an arrow at the start point.
  freeStyleArrowStart,

  /// Allows freehand drawing with an arrow at the end point.
  freeStyleArrowEnd,

  /// Allows freehand drawing with arrows at both start and end points.
  freeStyleArrowStartEnd,

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

  /// Draws a dash-dot line between two points.
  dashDotLine,

  /// Creates a hexagon shape starting from a point.
  hexagon,

  /// Draws a Polygon with multiple connected lines.
  polygon,

  /// Remove paint-items when hit.
  eraser,

  /// Creates an area that blurs the background.
  blur,

  /// Creates an area that will pixelate the background.
  pixelate;

  /// Returns `true` if this mode is any of the freehand drawing modes.
  ///
  /// This includes [freeStyle], [freeStyleArrowStart], [freeStyleArrowEnd],
  /// and [freeStyleArrowStartEnd].
  bool get isFreeStyleMode =>
      this == PaintMode.freeStyle ||
      this == PaintMode.freeStyleArrowStart ||
      this == PaintMode.freeStyleArrowEnd ||
      this == PaintMode.freeStyleArrowStartEnd;
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
