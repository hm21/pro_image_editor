import 'dart:ui';

/// Draws freehand lines on a canvas.
///
/// This function takes a list of [offsets] representing points and draws freehand
/// lines connecting those points on the specified [canvas] using the provided [painter].
/// The lines are scaled by the given [scale].
///
/// - [offsets]: A list of points representing the path of the freehand lines.
/// - [canvas]: The canvas on which to draw the freehand lines.
/// - [painter]: The paint object specifying the appearance of the lines (e.g., color,
///   stroke cap).
/// - [scale]: The scaling factor applied to the coordinates of the lines.
/// - [freeStyleHighPerformanceScaling]: Controls high-performance scaling for freehand
///   drawing. When set to `true`, it enables optimized scaling for improved performance.
/// - [freeStyleHighPerformanceScaling]: Controls high-performance moving for freehand
///   drawing. When set to `true`, it enables optimized moving for improved performance.
void drawFreeStyle({
  required List<Offset?> offsets,
  required Canvas canvas,
  required Paint painter,
  required double scale,
  required bool freeStyleHighPerformanceScaling,
  required bool freeStyleHighPerformanceMoving,
}) {
  painter.strokeCap = StrokeCap.round; // Set strokeCap outside the loop
  if (!freeStyleHighPerformanceScaling && !freeStyleHighPerformanceMoving) {
    for (int i = 0; i < offsets.length - 1; i++) {
      if (offsets[i] != null && offsets[i + 1] != null) {
        final path0 = Path()
          ..moveTo(offsets[i]!.dx * scale, offsets[i]!.dy * scale)
          ..lineTo(offsets[i + 1]!.dx * scale, offsets[i + 1]!.dy * scale);
        canvas.drawPath(path0, painter);
      } else if (offsets[i] != null && offsets[i + 1] == null) {
        canvas.drawPoints(PointMode.points, [offsets[i]!], painter);
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
          path.moveTo(startPoint.dx, startPoint.dy); // Move to the first point
        }

        path.lineTo(endPoint.dx, endPoint.dy); // Add line segment
      } else if (offsets[i] != null && offsets[i + 1] == null) {
        canvas.drawPoints(PointMode.points, [offsets[i]!], painter);
      }
    }

    canvas.drawPath(path, painter); // Draw the merged path
  }
}
