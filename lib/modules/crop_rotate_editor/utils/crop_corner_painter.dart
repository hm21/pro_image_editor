import 'package:flutter/material.dart';

import '../../../models/theme/theme.dart';

class CropCornerPainter extends CustomPainter {
  final Rect cropRect;
  final Rect viewRect;
  final Size screenSize;
  final ImageEditorTheme imageEditorTheme;
  final bool interactionActive;
  final Offset offset;

  final double cornerLength;
  double cornerWidth = 6;

  double helperLineWidth = 0.5;

  final double scaleFactor;

  double get _cropOffsetLeft => cropRect.left;
  double get _cropOffsetRight => cropRect.right;
  double get _cropOffsetTop => cropRect.top;
  double get _cropOffsetBottom => cropRect.bottom;

  CropCornerPainter({
    required this.offset,
    required this.cropRect,
    required this.viewRect,
    required this.screenSize,
    required this.scaleFactor,
    required this.imageEditorTheme,
    required this.interactionActive,
    required this.cornerLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: Create rounded cropper and other aspect ratios
    _drawDarkenOutside(canvas: canvas, size: size);
    if (interactionActive) _drawHelperAreas(canvas: canvas, size: size);
    _drawCorners(canvas: canvas, size: size);
  }

  void _drawDarkenOutside({
    required Canvas canvas,
    required Size size,
  }) {
    /// Draw outline darken layers
    ///
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

    /// Draw the darkened area
    canvas.drawPath(
      path,
      Paint()
        ..color = interactionActive ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.7)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawCorners({
    required Canvas canvas,
    required Size size,
  }) {
    Path path = Path();

    /// Top-Left
    path.addRect(Rect.fromLTWH(_cropOffsetLeft, _cropOffsetTop, cornerLength, cornerWidth));
    path.addRect(Rect.fromLTWH(_cropOffsetLeft, _cropOffsetTop, cornerWidth, cornerLength));

    /// Top-Right
    path.addRect(Rect.fromLTWH(_cropOffsetRight - cornerLength, _cropOffsetTop, cornerLength, cornerWidth));
    path.addRect(Rect.fromLTWH(_cropOffsetRight - cornerWidth, _cropOffsetTop, cornerWidth, cornerLength));

    /// Bottom-Left
    path.addRect(Rect.fromLTWH(0 + _cropOffsetLeft, _cropOffsetBottom - cornerWidth, cornerLength, cornerWidth));
    path.addRect(Rect.fromLTWH(0 + _cropOffsetLeft, _cropOffsetBottom - cornerLength, cornerWidth, cornerLength));

    /// Bottom-Right
    path.addRect(Rect.fromLTWH(_cropOffsetRight - cornerLength, _cropOffsetBottom - cornerWidth, cornerLength, cornerWidth));
    path.addRect(Rect.fromLTWH(_cropOffsetRight - cornerWidth, _cropOffsetBottom - cornerLength, cornerWidth, cornerLength));

    canvas.drawPath(
      path,
      Paint()
        ..color = imageEditorTheme.cropRotateEditor.cropCornerColor
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

    for (var i = 1; i < 3; i++) {
      path.addRect(
        Rect.fromLTWH(
          cropWidth / 3 * i + _cropOffsetLeft,
          _cropOffsetTop,
          helperLineWidth,
          _cropOffsetBottom - _cropOffsetTop,
        ),
      );

      path.addRect(
        Rect.fromLTWH(
          _cropOffsetLeft,
          cropHeight / 3 * i + _cropOffsetTop,
          cropWidth,
          helperLineWidth,
        ),
      );
    }

    final cornerPaint = Paint()
      ..color = imageEditorTheme.cropRotateEditor.helperLineColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! CropCornerPainter || oldDelegate.cropRect != cropRect || oldDelegate.viewRect != viewRect;
  }
}
