import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/modules/paint_editor/utils/paint_editor_enum.dart';

import '../../../../models/paint_editor/painted_model.dart';
import '../../../../widgets/pro_image_editor_desktop_mode.dart';
import 'drawers/draw_element.dart';

/// Handles the painting ongoing on the canvas.
class DrawCanvas extends CustomPainter {
  /// The model containing information about the painting.
  final PaintedModel item;

  /// The scaling factor applied to the canvas.
  final double scale;

  /// Controls high-performance scaling for free-style drawing.
  /// When `true`, enables optimized scaling for improved performance.
  bool freeStyleHighPerformanceScaling = false;

  /// Controls high-performance moving for free-style drawing.
  /// When `true`, enables optimized moving for improved performance.
  bool freeStyleHighPerformanceMoving = false;

  /// Enables or disables hit detection.
  /// When `true`, allows detecting user interactions with the interface.
  bool enabledHitDetection = true;

  /// Constructor for the canvas.
  DrawCanvas({
    required this.item,
    required this.scale,
    required this.enabledHitDetection,
    required this.freeStyleHighPerformanceScaling,
    required this.freeStyleHighPerformanceMoving,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var painter = Paint()
      ..color = item.paint.color
      ..style = item.paint.style
      ..strokeWidth = item.paint.strokeWidth * scale;

    drawElement(
      canvas: canvas,
      size: size,
      mode: item.mode,
      painter: painter,
      scale: scale,
      offsets: item.offsets,
      start: item.offsets[0],
      end: item.offsets[1],
      freeStyleHighPerformanceScaling: freeStyleHighPerformanceScaling,
      freeStyleHighPerformanceMoving: freeStyleHighPerformanceMoving,
    );
  }

  @override
  bool shouldRepaint(DrawCanvas oldDelegate) {
    return oldDelegate.item != item;
  }

  @override
  bool shouldRebuildSemantics(DrawCanvas oldDelegate) => true;

  @override
  bool hitTest(Offset position) {
    if (!enabledHitDetection) return true;
    var offsets = item.offsets;
    var strokeW =
        isDesktop ? item.strokeWidth * scale : max(item.strokeWidth, 30);
    var strokeHalfW = strokeW / 2;
    switch (item.mode) {
      case PaintModeE.line:
      case PaintModeE.dashLine:
      case PaintModeE.arrow:
        item.hit = _hitTestLineWithStroke(
          start: offsets[0]! * scale,
          end: offsets[1]! * scale,
          position: position,
          strokeHalfWidth: strokeHalfW,
        );
        break;
      case PaintModeE.freeStyle:
        item.hit = false;
        for (int i = 0; i < offsets.length - 1; i++) {
          if (offsets[i] != null && offsets[i + 1] != null) {
            if (_hitTestFreeStyle(
              start: offsets[i]! * scale,
              end: offsets[i + 1]! * scale,
              position: position,
              strokeHalfWidth: strokeHalfW,
            )) {
              item.hit = true;
              break;
            }
          } else if (offsets[i] != null && offsets[i + 1] == null) {
            // Check if the position is within touchTolerance of a point
            if (offsets[i]!.distance * scale <= strokeHalfW) {
              item.hit = true;
              break;
            }
          }
        }
        break;
      case PaintModeE.rect:
        final rect =
            Rect.fromPoints(item.offsets[0]! * scale, item.offsets[1]! * scale);
        if (item.fill) {
          item.hit = rect.contains(position);
        } else {
          final left = strokeW;
          final top = strokeW;
          final right = rect.right - strokeHalfW;
          final bottom = rect.bottom - strokeHalfW;

          item.hit = position.dx < left ||
              position.dx > right ||
              position.dy < top ||
              position.dy > bottom;
        }
        break;
      case PaintModeE.circle:
        final path = Path();
        final insideStrokePath = Path();
        if (item.fill) {
          path.addOval(Rect.fromPoints(
              item.offsets[0]! * scale, item.offsets[1]! * scale));
        } else {
          var ovalRect = Rect.fromPoints(
              item.offsets[0]! * scale, item.offsets[1]! * scale);
          double centerX = (ovalRect.left + ovalRect.right) / 2;
          double centerY = (ovalRect.top + ovalRect.bottom) / 2;

          path.addOval(
            Rect.fromCenter(
              center: Offset(centerX, centerY),
              width: ovalRect.width + strokeW,
              height: ovalRect.height + strokeW,
            ),
          );

          insideStrokePath.addOval(
            Rect.fromCenter(
              center: Offset(centerX, centerY),
              width: ovalRect.width - strokeW,
              height: ovalRect.height - strokeW,
            ),
          );
        }
        item.hit =
            path.contains(position) && !insideStrokePath.contains(position);
        break;
      default:
        item.hit = true;
    }

    return item.hit;
  }

  bool _hitTestFreeStyle({
    required Offset start,
    required Offset end,
    required double strokeHalfWidth,
    required Offset position,
  }) {
    if (start.dx.isNaN ||
        start.dy.isNaN ||
        end.dx.isNaN ||
        end.dy.isNaN ||
        strokeHalfWidth.isNaN ||
        position.dx.isNaN ||
        position.dy.isNaN) {
      // Handle NaN values gracefully, e.g., return false or throw an error.
      return false;
    }
    final path = Path();

    // Calculate the vector from start to end
    final vector = end - start;

    // Calculate the normalized vector
    final normalizedVector = vector / vector.distance;

    // Calculate the perpendicular vector
    final perpendicularVector =
        Offset(-normalizedVector.dy, normalizedVector.dx);

    // Define the four points that represent the rounded line
    final startPoint = start + perpendicularVector * strokeHalfWidth;
    final endPoint = end + perpendicularVector * strokeHalfWidth;
    final startCap = start - perpendicularVector * strokeHalfWidth;
    final endCap = end - perpendicularVector * strokeHalfWidth;

    // Move to the starting point
    path.moveTo(startPoint.dx, startPoint.dy);

    // Add a straight line segment to the ending point
    path.lineTo(endPoint.dx, endPoint.dy);

    // Add rounded caps at both ends
    path.arcToPoint(
      startCap,
      radius: Radius.circular(strokeHalfWidth),
      clockwise: false,
    );
    path.arcToPoint(
      endCap,
      radius: Radius.circular(strokeHalfWidth),
      clockwise: false,
    );

    // Close the path
    path.close();

    // Check if the position is inside the path
    return path.contains(position);
  }

  bool _hitTestLineWithStroke({
    required Offset start,
    required Offset end,
    required double strokeHalfWidth,
    required Offset position,
  }) {
    final vector = end - start;
    final normalizedVector = vector / vector.distance;
    final perpendicularVector =
        Offset(-normalizedVector.dy, normalizedVector.dx);

    double x = perpendicularVector.dx * strokeHalfWidth;
    double y = perpendicularVector.dy * strokeHalfWidth;

    final path = Path()
      ..moveTo(
        start.dx + x,
        start.dy + y,
      )
      ..lineTo(
        end.dx + x,
        end.dy + y,
      )
      ..lineTo(
        end.dx - x,
        end.dy - y,
      )
      ..lineTo(
        start.dx - x,
        start.dy - y,
      )
      ..close();

    // Check if the position is inside the stroke path
    return path.contains(position);
  }
}
