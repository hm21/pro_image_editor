import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

import '../models/line_metrics_model.dart';

/// A [CustomPainter] that paints text with a rounded background, optional
/// padding, and an optional cursor indicator.
///
/// This painter is useful for rendering styled text with enhanced visual
/// elements such as rounded corners, background color, and hit-testing
/// support. It can also reserve space for a cursor, making it suitable for
/// both static and interactive text UIs.
class RoundedBackgroundTextPainter extends CustomPainter {
  /// Creates a [RoundedBackgroundTextPainter] that paints text with a rounded
  /// background.
  RoundedBackgroundTextPainter({
    required this.backgroundColor,
    required this.painter,
    this.innerRadius = 8.0,
    this.outerRadius = 10.0,
    required this.onHitTestResult,
    required this.textAlign,
    required this.textDirection,
    required this.hitBoxCorrectionOffset,
    this.cursorWidth = 0.0,
  });

  /// Callback function triggered with the result of a hit test on the text
  /// area.
  final Function(bool hasHit)? onHitTestResult;

  /// The background color used to paint the rounded background behind the text.
  final Color backgroundColor;

  /// The [TextPainter] used to layout and paint the text.
  final TextPainter painter;

  /// Determines how the text should be aligned horizontally.
  final TextAlign textAlign;

  /// The text direction used to resolve [TextAlign.start] and [TextAlign.end].
  final TextDirection textDirection;

  /// The width of the text cursor (if shown).
  final double cursorWidth;

  /// The radius used for rounding the corners of the inner background shape.
  final double innerRadius;

  /// The radius used for rounding the corners of the outer background shape.
  final double outerRadius;

  /// An offset used to correct the position of the hitbox.
  final Offset hitBoxCorrectionOffset;

  Path _buildBackgroundPath() {
    final metrics = painter.computeLineMetrics();
    if (metrics.isEmpty) return Path();

    final path = Path();
    final cornerPath = Path();

    final bool isLeftAlign =
        textAlign == TextAlign.left ||
        (textAlign == TextAlign.start && textDirection == TextDirection.ltr);
    final bool isRightAlign =
        textAlign == TextAlign.right ||
        (textAlign == TextAlign.end && textDirection == TextDirection.rtl);
    final bool isCenterAlign =
        textAlign == TextAlign.center || textAlign == TextAlign.justify;

    final helpers = metrics.map((lineMetric) {
      return LineMetricsModel(
        metrics: lineMetric,
        length: metrics.length,
        textAlign: textAlign,
        cursorWidth: cursorWidth,
      );
    }).toList();

    double? firstMaximalWidth;

    final firstLine = helpers.first;
    final double paddingHorizontal = firstLine.rawHeight * 0.3;
    final double paddingVertical = firstLine.rawHeight * 0.1;
    final double radius = firstLine.innerRadius(innerRadius);

    for (int index = 0; index < helpers.length; index++) {
      final info = helpers[index];
      if (info.isEmpty) continue;

      final bool hasNoLineBefore = index == 0 || helpers[index - 1].isEmpty;
      final bool hasNoLineAfter =
          index == helpers.length - 1 || helpers[index + 1].isEmpty;

      if (!hasNoLineAfter && !info.isOverriden) {
        _connectSimilarLineWidth(
          isCenterAlign: isCenterAlign,
          info: info,
          radius: radius,
          index: index,
          helpers: helpers,
        );
      }

      bool roundTopRight =
          (!isRightAlign || hasNoLineBefore) && info.roundTopRight;
      bool roundTopLeft =
          (!isLeftAlign || hasNoLineBefore) && info.roundTopLeft;
      bool roundBottomRight =
          (!isRightAlign || hasNoLineAfter) && info.roundBottomRight;
      bool roundBottomLeft =
          (!isLeftAlign || hasNoLineAfter) && info.roundBottomLeft;

      final double startX = info.startX - paddingHorizontal;
      late final double endX;
      if (isRightAlign) {
        firstMaximalWidth ??= info.endX + paddingHorizontal;
        endX = firstMaximalWidth;
      } else {
        endX = info.endX + paddingHorizontal;
      }

      final double startY = info.startY - paddingVertical;
      final double endY = info.endY + paddingVertical;

      _drawBackgroundRectangle(
        path: path,
        startX: startX,
        startY: startY,
        endX: endX,
        endY: endY,
        radius: radius,
        roundTopRight: roundTopRight,
        roundTopLeft: roundTopLeft,
        roundBottomRight: roundBottomRight,
        roundBottomLeft: roundBottomLeft,
      );
      if (hasNoLineBefore) continue;

      if (!isLeftAlign) {
        _createInnerRoundingLeft(
          path: cornerPath,
          info: info,
          paddingHorizontal: paddingHorizontal,
          paddingVertical: paddingVertical,
          startY: startY,
          radius: radius,
          index: index,
          helpers: helpers,
        );
      }
      if (!isRightAlign) {
        _createInnerRoundingRight(
          path: cornerPath,
          info: info,
          paddingHorizontal: paddingHorizontal,
          paddingVertical: paddingVertical,
          startY: startY,
          radius: radius,
          index: index,
          helpers: helpers,
        );
      }
    }

    return Path.combine(PathOperation.union, path, cornerPath);
  }

  void _connectSimilarLineWidth({
    required bool isCenterAlign,
    required LineMetricsModel info,
    required double radius,
    required int index,
    required List<LineMetricsModel> helpers,
  }) {
    final maxLineDifference = radius * (isCenterAlign ? 4 : 2);

    bool shouldConnect(int index) {
      if (index >= helpers.length - 1) return false;

      final currentLine = helpers[index];
      final nextLine = helpers[index + 1];

      /// Check first if it's necessary to calculate the minimum width
      double lineDifference = currentLine.rawWidth - nextLine.rawWidth;
      bool shouldConnect = lineDifference.abs() < maxLineDifference;
      return shouldConnect;
    }

    if (!shouldConnect(index)) return;

    double minimumWidth = info.rawWidth;
    double minimumX = info.x;
    int endIndex = index;

    /// Find the minimum required width
    for (var i = index; i < helpers.length; i++) {
      final helper = helpers[i];
      if (helper.rawWidth > minimumWidth) {
        minimumWidth = helper.rawWidth;
        minimumX = helper.x;
      }
      if (!shouldConnect(i)) {
        endIndex = i;
        break;
      }
    }

    /// Apply changes
    for (var i = index; i <= endIndex; i++) {
      helpers[i]
        ..overrideX = minimumX
        ..overrideWidth = minimumWidth;

      if (i == index) {
        helpers[i]
          ..roundBottomLeft = false
          ..roundBottomRight = false;
      }
      if (i == endIndex) {
        helpers[i]
          ..roundTopLeft = false
          ..roundTopRight = false;
      }
    }
  }

  double _calculateAdaptiveRadius({
    required LineMetricsModel info,
    required int index,
    required double radius,
    required List<LineMetricsModel> helpers,
  }) {
    final lineBefore = helpers[index - 1];

    double lineDifference = (info.rawWidth - lineBefore.rawWidth).abs();

    if (textAlign == TextAlign.center) {
      lineDifference /= 4;
    } else {
      lineDifference /= 2;
    }

    return min(radius, lineDifference);
  }

  void _drawInnerRoundingPath({
    required Path path,
    required Offset from,
    required double lineToX,
    required Offset arcEnd,
    required double radius,
    required bool clockwise,
  }) {
    final radiusC = Radius.circular(radius);

    path
      ..moveTo(from.dx, from.dy)
      ..lineTo(lineToX, from.dy)
      ..arcToPoint(arcEnd, radius: radiusC, clockwise: clockwise)
      ..moveTo(from.dx, from.dy)
      ..lineTo(lineToX, from.dy)
      ..arcToPoint(
        arcEnd,
        radius: radiusC,
        clockwise: clockwise,
        largeArc: true,
      )
      ..close();
  }

  void _createInnerRoundingLeft({
    required Path path,
    required LineMetricsModel info,
    required double paddingHorizontal,
    required double paddingVertical,
    required double startY,
    required double radius,
    required int index,
    required List<LineMetricsModel> helpers,
  }) {
    final lineBefore = helpers[index - 1];
    if (lineBefore.isEmpty) return;

    final beforeStartX = lineBefore.startX - paddingHorizontal;
    final beforeY = lineBefore.endY + paddingVertical;
    final startX = info.startX - paddingHorizontal;
    final r = _calculateAdaptiveRadius(
      info: info,
      index: index,
      radius: radius,
      helpers: helpers,
    );

    if (info.rawWidth > lineBefore.rawWidth) {
      _drawInnerRoundingPath(
        path: path,
        from: Offset(beforeStartX, startY),
        lineToX: beforeStartX - r,
        arcEnd: Offset(beforeStartX, startY - r),
        radius: r,
        clockwise: false,
      );
    } else {
      _drawInnerRoundingPath(
        path: path,
        from: Offset(startX, beforeY),
        lineToX: startX - r,
        arcEnd: Offset(startX, beforeY + r),
        radius: r,
        clockwise: true,
      );
    }
  }

  void _createInnerRoundingRight({
    required Path path,
    required LineMetricsModel info,
    required double paddingHorizontal,
    required double paddingVertical,
    required double startY,
    required double radius,
    required int index,
    required List<LineMetricsModel> helpers,
  }) {
    final lineBefore = helpers[index - 1];
    if (lineBefore.isEmpty) return;

    final beforeEndX = lineBefore.endX + paddingHorizontal;
    final beforeY = lineBefore.endY + paddingVertical;
    final endX = info.endX + paddingHorizontal;
    final r = _calculateAdaptiveRadius(
      info: info,
      index: index,
      radius: radius,
      helpers: helpers,
    );

    if (info.rawWidth > lineBefore.rawWidth) {
      _drawInnerRoundingPath(
        path: path,
        from: Offset(beforeEndX, startY),
        lineToX: beforeEndX + r,
        arcEnd: Offset(beforeEndX, startY - r),
        radius: r,
        clockwise: true,
      );
    } else {
      _drawInnerRoundingPath(
        path: path,
        from: Offset(endX, beforeY),
        lineToX: endX + r,
        arcEnd: Offset(endX, beforeY + r),
        radius: r,
        clockwise: false,
      );
    }
  }

  void _drawBackgroundRectangle({
    required Path path,
    required double startX,
    required double startY,
    required double endX,
    required double endY,
    required double radius,
    required bool roundTopRight,
    required bool roundTopLeft,
    required bool roundBottomRight,
    required bool roundBottomLeft,
  }) {
    path
      ..moveTo(startX + (roundTopLeft ? radius : 0), startY)
      /// Top-Right edge
      ..lineTo(endX - radius, startY);
    if (roundTopRight) {
      path.arcToPoint(
        Offset(endX, startY + radius),
        radius: Radius.circular(radius),
      );
    } else {
      path.lineTo(endX, startY);
    }

    /// Bottom-Right edge
    path.lineTo(endX, endY - (roundBottomRight ? radius : 0));
    if (roundBottomRight) {
      path.arcToPoint(
        Offset(endX - radius, endY),
        radius: Radius.circular(radius),
      );
    } else {
      path.lineTo(endX - radius, endY);
    }

    /// Bottom edge
    path.lineTo(startX + (roundBottomLeft ? radius : 0), endY);
    if (roundBottomLeft) {
      path.arcToPoint(
        Offset(startX, endY - radius),
        radius: Radius.circular(radius),
      );
    } else {
      path.lineTo(startX, endY);
    }

    /// Left edge
    path.lineTo(startX, startY + (roundTopLeft ? radius : 0));
    if (roundTopLeft) {
      path.arcToPoint(
        Offset(startX + radius, startY),
        radius: Radius.circular(radius),
      );
    } else {
      path.lineTo(startX, startY);
    }

    path.close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final painter = Paint()..color = backgroundColor;

    _cachedPath = _buildBackgroundPath();
    canvas
      ..translate(hitBoxCorrectionOffset.dx, hitBoxCorrectionOffset.dy)
      ..drawPath(_cachedPath!, painter);

    this.painter.paint(canvas, Offset.zero);
  }

  Path? _cachedPath;

  @override
  bool? hitTest(Offset position) {
    final path = _cachedPath ?? _buildBackgroundPath();

    bool hasHit = path.contains(position - hitBoxCorrectionOffset);

    onHitTestResult?.call(hasHit);
    return hasHit;
  }

  @override
  bool shouldRepaint(covariant RoundedBackgroundTextPainter oldDelegate) {
    final changed =
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.painter.width != painter.width ||
        oldDelegate.painter.height != painter.height ||
        oldDelegate.painter.ellipsis != painter.ellipsis ||
        oldDelegate.painter.plainText != painter.plainText ||
        oldDelegate.painter.textAlign != painter.textAlign ||
        oldDelegate.painter.preferredLineHeight !=
            painter.preferredLineHeight ||
        oldDelegate.innerRadius != innerRadius ||
        oldDelegate.textAlign != textAlign ||
        oldDelegate.hitBoxCorrectionOffset != hitBoxCorrectionOffset ||
        oldDelegate.textDirection != textDirection ||
        oldDelegate.outerRadius != outerRadius;

    if (changed) _cachedPath = null; // invalidate cache

    return changed;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RoundedBackgroundTextPainter &&
        other.onHitTestResult == onHitTestResult &&
        other.backgroundColor == backgroundColor &&
        other.painter == painter &&
        other.textAlign == textAlign &&
        other.textDirection == textDirection &&
        other.cursorWidth == cursorWidth &&
        other.hitBoxCorrectionOffset == hitBoxCorrectionOffset &&
        other.innerRadius == innerRadius &&
        other.outerRadius == outerRadius;
  }

  @override
  int get hashCode {
    return onHitTestResult.hashCode ^
        backgroundColor.hashCode ^
        painter.hashCode ^
        textAlign.hashCode ^
        textDirection.hashCode ^
        cursorWidth.hashCode ^
        hitBoxCorrectionOffset.hashCode ^
        innerRadius.hashCode ^
        outerRadius.hashCode;
  }
}
