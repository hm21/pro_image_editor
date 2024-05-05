import 'dart:math';

import 'package:flutter/material.dart';

import '../../../models/theme/theme.dart';

class CropCornerPainter extends CustomPainter {
  final Rect cropRect;
  final Rect viewRect;
  final Size screenSize;
  final ImageEditorTheme imageEditorTheme;
  final bool interactionActive;
  final bool drawCircle;
  final Offset offset;
  final double opacity;

  final double cornerLength;
  double cornerWidth = 6;

  double helperLineWidth = 0.5;

  final double scaleFactor;
  final double rotationScaleFactor;

  double get _cropOffsetLeft => cropRect.left;
  double get _cropOffsetRight => cropRect.right;
  double get _cropOffsetTop => cropRect.top;
  double get _cropOffsetBottom => cropRect.bottom;

  CropCornerPainter({
    required this.drawCircle,
    required this.offset,
    required this.cropRect,
    required this.opacity,
    required this.viewRect,
    required this.screenSize,
    required this.scaleFactor,
    required this.imageEditorTheme,
    required this.interactionActive,
    required this.cornerLength,
    required this.rotationScaleFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: Create rounded cropper
    _drawDarkenOutside(canvas: canvas, size: size);
/*     if (interactionActive) */ _drawHelperAreas(canvas: canvas, size: size);
    _drawCorners(canvas: canvas, size: size);
  }

  void _drawDarkenOutside({
    required Canvas canvas,
    required Size size,
  }) {
    /// Draw outline darken layers
    double cropWidth = _cropOffsetRight - _cropOffsetLeft;
    double cropHeight = _cropOffsetBottom - _cropOffsetTop;

    Path path = Path();
    path.addRect(Rect.fromCenter(
      center: Offset(
        size.width / 2 + offset.dx * scaleFactor,
        size.height / 2 + offset.dy * scaleFactor,
      ),
      width: size.width * scaleFactor,
      height: size.height * scaleFactor,
    ));
    if (drawCircle) {
      /// Create a path for the current rectangle
      Path circlePath = Path()
        ..addOval(
          Rect.fromCenter(
            center: Offset(
              cropWidth / 2 + _cropOffsetLeft,
              cropHeight / 2 + _cropOffsetTop,
            ),
            width: cropWidth,
            height: cropHeight,
          ),
        );

      /// Subtract the area of the current rectangle from the path for the entire canvas
      path = Path.combine(PathOperation.difference, path, circlePath);
    } else {
      /// Create a path for the current rectangle
      Path rectPath = Path()
        ..addRect(
          Rect.fromCenter(
            center: Offset(
              cropWidth / 2 + _cropOffsetLeft,
              cropHeight / 2 + _cropOffsetTop,
            ),
            width: cropWidth,
            height: cropHeight,
          ),
        );

      /// Subtract the area of the current rectangle from the path for the entire canvas
      path = Path.combine(PathOperation.difference, path, rectPath);
    }

    Color backgroundColor = imageEditorTheme.cropRotateEditor.background;

    /// Draw the darkened area
    canvas.drawPath(
      path,
      Paint()
        ..color = interactionActive
            ? backgroundColor.withOpacity(
                (0.6 + 0.4 * (1 - opacity)).clamp(0, 1),
              )
            : backgroundColor.withOpacity(
                (0.84 + 0.16 * (1 - opacity)).clamp(0, 1),
              )
        ..style = PaintingStyle.fill,
    );
  }

  void _drawCorners({
    required Canvas canvas,
    required Size size,
  }) {
    Path path = Path();

    double length = cornerLength / rotationScaleFactor;
    double width = cornerWidth / rotationScaleFactor;

    /// Top-Left
    path.addRect(Rect.fromLTWH(_cropOffsetLeft, _cropOffsetTop, length, width));
    path.addRect(Rect.fromLTWH(_cropOffsetLeft, _cropOffsetTop, width, length));

    /// Top-Right
    path.addRect(Rect.fromLTWH(
        _cropOffsetRight - length, _cropOffsetTop, length, width));
    path.addRect(
        Rect.fromLTWH(_cropOffsetRight - width, _cropOffsetTop, width, length));

    /// Bottom-Left
    path.addRect(Rect.fromLTWH(
        0 + _cropOffsetLeft, _cropOffsetBottom - width, length, width));
    path.addRect(Rect.fromLTWH(
        0 + _cropOffsetLeft, _cropOffsetBottom - length, width, length));

    /// Bottom-Right
    path.addRect(Rect.fromLTWH(
        _cropOffsetRight - length, _cropOffsetBottom - width, length, width));
    path.addRect(Rect.fromLTWH(
        _cropOffsetRight - width, _cropOffsetBottom - length, width, length));

    canvas.drawPath(
      path,
      Paint()
        ..color = imageEditorTheme.cropRotateEditor.cropCornerColor
            .withOpacity(opacity)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawHelperAreas({
    required Canvas canvas,
    required Size size,
  }) {
    Path path = Path();

    double cropWidth = _cropOffsetRight - _cropOffsetLeft;
    double cropHeight = _cropOffsetBottom - _cropOffsetTop;

    double degreesToRadians(double degrees) {
      return degrees * (pi / 180);
    }

    double lineWidth =
        !drawCircle ? cropWidth : cropWidth * cos(degreesToRadians(19.5));
    double lineHeight =
        !drawCircle ? cropHeight : cropHeight * cos(degreesToRadians(19.5));
    double lineOffsetX = (cropWidth - lineWidth) / 2;
    double lineOffsetY = (cropHeight - lineHeight) / 2;

    for (var i = 1; i < 3; i++) {
      path.addRect(
        Rect.fromLTWH(
          cropWidth / 3 * i + _cropOffsetLeft,
          _cropOffsetTop + lineOffsetY,
          helperLineWidth,
          lineHeight,
        ),
      );

      path.addRect(
        Rect.fromLTWH(
          _cropOffsetLeft + lineOffsetX,
          cropHeight / 3 * i + _cropOffsetTop,
          lineWidth,
          helperLineWidth,
        ),
      );
    }

    final cornerPaint = Paint()
      ..color =
          imageEditorTheme.cropRotateEditor.helperLineColor.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! CropCornerPainter ||
        oldDelegate.cropRect != cropRect ||
        oldDelegate.viewRect != viewRect ||
        oldDelegate.rotationScaleFactor != rotationScaleFactor;
  }
}
