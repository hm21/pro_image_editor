// Dart imports:
import 'dart:ui';

// Project imports:
import '../../../models/paint_editor/painted_model.dart';
import 'paint_editor_enum.dart';

/// Represents an element within the painting editor.
class PaintElement {
  /// Draws an element on a canvas based on the specified mode and parameters.
  ///
  /// This function is used to draw various elements such as freehand lines,
  /// straight lines, arrows, dashed lines, rectangles, and circles on a
  /// canvas. The appearance of the element is determined by the provided
  /// [mode] and additional parameters such as [offsets], [painter], [scale],
  /// [start], and [end].
  ///
  /// - `canvas`: The canvas on which to draw the element.
  /// - `size`: The size of the canvas.
  /// - `scale`: The scaling factor applied to the coordinates of the element.
  /// - `freeStyleHighPerformance`: Controls high-performance for free-style
  ///   drawing.
  /// - `item` Represents a unit of shape or drawing information used in
  ///   painting.
  void drawElement({
    required Canvas canvas,
    required Size size,
    required PaintedModel item,
    bool freeStyleHighPerformance = false,
    double scale = 1,
  }) {
    var painter = Paint()
      ..color = item.paint.color
      ..style = item.paint.style
      ..strokeWidth = item.paint.strokeWidth * scale;

    PaintModeE mode = item.mode;
    List<Offset?> offsets = item.offsets;
    Offset? start = item.offsets[0];
    Offset? end = item.offsets[1];

    switch (mode) {
      case PaintModeE.freeStyle:
        _drawFreeStyle(
          offsets: offsets,
          canvas: canvas,
          painter: painter,
          scale: scale,
          freeStyleHighPerformance: freeStyleHighPerformance,
        );
        break;
      case PaintModeE.line:
        canvas.drawLine(start! * scale, end! * scale, painter);
        break;
      case PaintModeE.arrow:
        _drawArrow(canvas, start! * scale, end! * scale, painter);
        break;
      case PaintModeE.dashLine:
        _drawDashLine(
            canvas, start! * scale, end! * scale, painter.strokeWidth, painter);
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
        throw ArgumentError('$mode is not a valid PaintModeE');
    }
  }

  /// Draws freehand lines on a canvas.
  ///
  /// This function takes a list of [offsets] representing points and draws
  /// freehand lines connecting those points on the specified [canvas] using
  /// the provided [painter].
  /// The lines are scaled by the given [scale].
  ///
  /// - [offsets]: A list of points representing the path of the freehand lines.
  /// - [canvas]: The canvas on which to draw the freehand lines.
  /// - [painter]: The paint object specifying the appearance of the lines
  ///   (e.g., color, stroke cap).
  /// - [scale]: The scaling factor applied to the coordinates of the lines.
  /// - [freeStyleHighPerformance]: Controls high-performance for freehand
  ///   drawing.
  void _drawFreeStyle({
    required List<Offset?> offsets,
    required Canvas canvas,
    required Paint painter,
    required double scale,
    required bool freeStyleHighPerformance,
  }) {
    painter.strokeCap = StrokeCap.round;
    if (!freeStyleHighPerformance) {
      final path = Path();

      for (int i = 0; i < offsets.length - 1; i++) {
        final currentOffset = offsets[i];
        final nextOffset = offsets[i + 1];

        if (currentOffset != null && nextOffset != null) {
          path
            ..reset()
            ..moveTo(currentOffset.dx * scale, currentOffset.dy * scale)
            ..lineTo(nextOffset.dx * scale, nextOffset.dy * scale);
          canvas.drawPath(path, painter);
        } else if (currentOffset != null && nextOffset == null) {
          canvas.drawPoints(PointMode.points, [currentOffset], painter);
        }
      }
    } else {
      final path = Path();

      for (int i = 0; i < offsets.length - 1; i++) {
        if (offsets[i] != null && offsets[i + 1] != null) {
          final startPoint =
              Offset(offsets[i]!.dx * scale, offsets[i]!.dy * scale);
          final endPoint =
              Offset(offsets[i + 1]!.dx * scale, offsets[i + 1]!.dy * scale);

          if (i == 0) {
            path.moveTo(startPoint.dx, startPoint.dy);
          }

          path.lineTo(endPoint.dx, endPoint.dy);
        } else if (offsets[i] != null && offsets[i + 1] == null) {
          canvas.drawPoints(PointMode.points, [offsets[i]!], painter);
        }
      }

      canvas.drawPath(path, painter);
    }
  }

  /// Draws a line with an arrowhead on top of it.
  ///
  /// This function is used to draw a line from the specified [start] point to
  /// the [end] point using the provided [painter], and it also adds an
  /// arrowhead at the [end] point.
  ///
  /// - `canvas`: The canvas on which to draw the arrow.
  /// - `start`: The starting point of the line.
  /// - `end`: The ending point of the line and the location of the arrowhead.
  /// - `painter`: The paint object specifying the line's color, width, and
  /// style.
  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint painter) {
    final arrowPainter = Paint()
      ..color = painter.color
      ..strokeWidth = painter.strokeWidth
      ..style = PaintingStyle.stroke;

    // Draw the line.
    canvas.drawLine(start, end, painter);

    // Calculate the path for the arrowhead.
    final pathOffset = painter.strokeWidth / 15;
    final path = Path()
      ..lineTo(-15 * pathOffset, 10 * pathOffset)
      ..lineTo(-15 * pathOffset, -10 * pathOffset)
      ..close();

    // Save the canvas state, translate it to the end point, rotate it to match
    // the direction of the line, and then draw the arrowhead.
    canvas
      ..save()
      ..translate(end.dx, end.dy)
      ..rotate((end - start).direction)
      ..drawPath(path, arrowPainter)
      ..restore();
  }

  /// Draws a dashed path based on the provided path and stroke width.
  ///
  /// This function takes an existing [path] and returns a new path that
  /// consists of dashed segments. The spacing between dashes and the width of
  /// dashes depend on the [width] parameter, which is typically the
  /// `strokeWidth` of the painter used for drawing the path.
  ///
  /// - [path]: The original path to be converted into a dashed path.
  /// - [width]: The stroke width used to determine the proportion of spacing
  ///   and dashes.
  ///
  /// Returns a new path representing the dashed line.
  void _drawDashLine(
      Canvas canvas, Offset start, Offset end, double width, Paint painter) {
    final dashPath = Path();
    final dashWidth = 10.0 * width / 5;
    final dashSpace = 10.0 * width / 5;
    var distance = 0.0;
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);

    for (final pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth;
        distance += dashSpace;
      }
    }

    canvas.drawPath(dashPath, painter);
  }
}
