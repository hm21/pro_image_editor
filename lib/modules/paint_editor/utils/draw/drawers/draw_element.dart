import 'dart:ui';

import '../../paint_editor_enum.dart';
import 'draw_arrow.dart';
import 'draw_dash_line.dart';
import 'draw_free_style.dart';

/// Draws an element on a canvas based on the specified mode and parameters.
///
/// This function is used to draw various elements such as freehand lines, straight
/// lines, arrows, dashed lines, rectangles, and circles on a canvas. The appearance
/// of the element is determined by the provided [mode] and additional parameters
/// such as [offsets], [painter], [scale], [start], and [end].
///
/// - [canvas]: The canvas on which to draw the element.
/// - [size]: The size of the canvas.
/// - [mode]: The paint mode indicating the type of element to draw (e.g., freehand,
///   straight line, arrow, etc.).
/// - [offsets]: A list of points representing the element's path (used for freehand
///   drawing).
/// - [painter]: The paint object specifying the element's appearance (e.g., color,
///   stroke width).
/// - [scale]: The scaling factor applied to the coordinates of the element.
/// - [start]: The starting point of the element (used for straight lines, arrows,
///   dashed lines, rectangles, and circles).
/// - [end]: The ending point of the element (used for straight lines, arrows,
///   dashed lines, rectangles, and circles).
/// - [freeStyleHighPerformanceScaling]: Controls high-performance scaling for
///   free-style drawing. When set to `true`, it enables optimized scaling for
///   improved performance.
/// - [freeStyleHighPerformanceMoving]: Controls high-performance moving for
///   free-style drawing. When set to `true`, it enables optimized moving for
///   improved performance.
void drawElement({
  required Canvas canvas,
  required Size size,
  required PaintModeE mode,
  required List<Offset?> offsets,
  required Paint painter,
  required bool freeStyleHighPerformanceScaling,
  required bool freeStyleHighPerformanceMoving,
  double scale = 1,
  Offset? start,
  Offset? end,
}) {
  switch (mode) {
    case PaintModeE.freeStyle:
      drawFreeStyle(
        offsets: offsets,
        canvas: canvas,
        painter: painter,
        scale: scale,
        freeStyleHighPerformanceScaling: freeStyleHighPerformanceScaling,
        freeStyleHighPerformanceMoving: freeStyleHighPerformanceMoving,
      );
      break;
    case PaintModeE.line:
      canvas.drawLine(start! * scale, end! * scale, painter);
      break;
    case PaintModeE.arrow:
      drawArrow(canvas, start! * scale, end! * scale, painter);
      break;
    case PaintModeE.dashLine:
      final path = Path()
        ..moveTo(start!.dx * scale, start.dy * scale)
        ..lineTo(end!.dx * scale, end.dy * scale);
      canvas.drawPath(drawDashLine(path, painter.strokeWidth), painter);
      break;
    case PaintModeE.rect:
      canvas.drawRect(Rect.fromPoints(start! * scale, end! * scale), painter);
      break;
    case PaintModeE.circle:
      final path = Path();
      var ovalRect = Rect.fromPoints(start! * scale, end! * scale);
      path.addOval(ovalRect);
      canvas.drawPath(path, painter);
      break;
    default:
      throw '$mode is not a valid PaintModeE';
  }
}
