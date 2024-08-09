// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import '../../../models/paint_editor/painted_model.dart';
import '../utils/paint_element.dart';

/// Handles the painting ongoing on the canvas.
class DrawPainting extends CustomPainter {
  /// Constructor for the canvas.
  DrawPainting({
    this.selected = false,
    required this.item,
    this.scale = 1,
    this.enabledHitDetection = false,
    this.freeStyleHighPerformance = false,
  });

  /// The model containing information about the painting.
  final PaintedModel item;

  final PaintElement _paintModeHelper = PaintElement();

  /// The scaling factor applied to the canvas.
  final double scale;

  /// Controls high-performance for free-style drawing.
  bool freeStyleHighPerformance = false;

  /// Enables or disables hit detection.
  /// When `true`, allows detecting user interactions with the interface.
  bool enabledHitDetection = true;

  /// Indicates whether the layer is currently selected.
  bool selected = true;

  @override
  void paint(Canvas canvas, Size size) {
    _paintModeHelper.drawElement(
      canvas: canvas,
      size: size,
      item: item,
      scale: scale,
      freeStyleHighPerformance: freeStyleHighPerformance,
    );
  }

  @override
  bool shouldRepaint(DrawPainting oldDelegate) {
    return oldDelegate.item != item ||
        oldDelegate.freeStyleHighPerformance != freeStyleHighPerformance;
  }

  @override
  bool hitTest(Offset position) {
    if (!enabledHitDetection) {
      return true;
    } else if (selected) {
      item.hit = true;
      return true;
    }

    List<Offset?> offsets = item.offsets;
    double strokeW = isDesktop
        ? item.strokeWidth * scale
        : max(item.strokeWidth * scale, 30);
    double strokeHalfW = strokeW / 2;
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
          final path = Path();
          final insideStrokePath = Path();

          var strokeRect = Rect.fromPoints(
              item.offsets[0]! * scale, item.offsets[1]! * scale);
          double centerX = (strokeRect.left + strokeRect.right) / 2;
          double centerY = (strokeRect.top + strokeRect.bottom) / 2;

          path.addRect(
            Rect.fromCenter(
              center: Offset(centerX, centerY),
              width: strokeRect.width + strokeW,
              height: strokeRect.height + strokeW,
            ),
          );

          insideStrokePath.addRect(
            Rect.fromCenter(
              center: Offset(centerX, centerY),
              width: strokeRect.width - strokeW,
              height: strokeRect.height - strokeW,
            ),
          );
          item.hit =
              path.contains(position) && !insideStrokePath.contains(position);
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
    Offset vector = end - start;

    // Calculate the normalized vector
    Offset normalizedVector = vector / max(vector.distance, 0.00001);

    // Calculate the perpendicular vector
    Offset perpendicularVector =
        Offset(-normalizedVector.dy, normalizedVector.dx);

    // Define the four points that represent the rounded line
    Offset startPoint = start + perpendicularVector * strokeHalfWidth;
    Offset endPoint = end + perpendicularVector * strokeHalfWidth;
    Offset startCap = start - perpendicularVector * strokeHalfWidth;
    Offset endCap = end - perpendicularVector * strokeHalfWidth;
    // Move to the starting point
    path
      ..moveTo(startPoint.dx, startPoint.dy)

      // Add a straight line segment to the ending point
      ..lineTo(endPoint.dx, endPoint.dy)

      // Add rounded caps at both ends
      ..arcToPoint(
        startCap,
        radius: Radius.circular(strokeHalfWidth),
        clockwise: false,
      )
      ..arcToPoint(
        endCap,
        radius: Radius.circular(strokeHalfWidth),
        clockwise: false,
      )

      // Close the path
      ..close();

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
