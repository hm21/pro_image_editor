import 'dart:ui';

/// Draws a dashed path based on the provided path and stroke width.
///
/// This function takes an existing [path] and returns a new path that consists
/// of dashed segments. The spacing between dashes and the width of dashes depend
/// on the [width] parameter, which is typically the `strokeWidth` of the painter
/// used for drawing the path.
///
/// - [path]: The original path to be converted into a dashed path.
/// - [width]: The stroke width used to determine the proportion of spacing and dashes.
///
/// Returns a new path representing the dashed line.
Path drawDashLine(Path path, double width) {
  final dashPath = Path();
  final dashWidth = 10.0 * width / 5;
  final dashSpace = 10.0 * width / 5;
  var distance = 0.0;

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

  return dashPath;
}
