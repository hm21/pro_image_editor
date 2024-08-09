// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../models/theme/theme.dart';

/// A custom painter for drawing crop corners and interaction elements.
///
/// This class extends [CustomPainter] and is used to draw the crop corners,
/// guide lines, and other interaction elements for a crop and rotate editor.
/// It takes into account the current view rectangle, crop rectangle, and
/// various style settings provided by the image editor theme.
class CropCornerPainter extends CustomPainter {
  /// Creates an instance of [CropCornerPainter].
  ///
  /// The constructor initializes various parameters needed to draw the crop
  /// corners and interaction elements, such as the crop rectangle, view
  /// rectangle, and other style configurations.
  ///
  /// Example:
  /// ```
  /// CropCornerPainter(
  ///   drawCircle: true,
  ///   offset: Offset.zero,
  ///   cropRect: myCropRect,
  ///   fadeInOpacity: 0.5,
  ///   interactionOpacity: 1.0,
  ///   viewRect: myViewRect,
  ///   screenSize: myScreenSize,
  ///   scaleFactor: 1.0,
  ///   imageEditorTheme: myImageEditorTheme,
  ///   cornerLength: 10.0,
  ///   cornerThickness: 2.0,
  ///   rotationScaleFactor: 1.0,
  /// )
  /// ```
  CropCornerPainter({
    required this.drawCircle,
    required this.offset,
    required this.cropRect,
    required this.fadeInOpacity,
    required this.interactionOpacity,
    required this.viewRect,
    required this.screenSize,
    required this.scaleFactor,
    required this.imageEditorTheme,
    required this.cornerLength,
    required this.cornerThickness,
    required this.rotationScaleFactor,
  });

  /// The rectangle defining the crop area.
  ///
  /// This [Rect] represents the area of the image currently being cropped,
  /// used to draw the crop corners and other elements.
  final Rect cropRect;

  /// The rectangle representing the current viewable area.
  ///
  /// This [Rect] is used to determine the position and scaling of elements
  /// relative to the viewable area of the editor.
  final Rect viewRect;

  /// The size of the screen or canvas.
  ///
  /// This [Size] object represents the dimensions of the entire editing area,
  /// affecting how elements are drawn and scaled.
  final Size screenSize;

  /// The theme settings for the image editor.
  ///
  /// This [ImageEditorTheme] object provides style configurations for the
  /// elements drawn by this painter, such as colors and line thicknesses.
  final ImageEditorTheme imageEditorTheme;

  /// Whether to draw circles at the crop corners.
  ///
  /// This boolean flag determines whether circular elements should be drawn at
  /// the corners of the crop rectangle for visual guidance.
  final bool drawCircle;

  /// The offset for positioning elements.
  ///
  /// This [Offset] is used to adjust the positioning of elements drawn by this
  /// painter, allowing for dynamic placement based on user interactions.
  final Offset offset;

  /// The opacity for fade-in effects.
  ///
  /// This double value represents the opacity level for fade-in effects,
  /// allowing for smooth visual transitions when the crop corners appear.
  final double fadeInOpacity;

  /// The opacity for interaction effects.
  ///
  /// This double value represents the opacity level for interaction effects,
  /// such as highlighting or accentuating elements during user actions.
  final double interactionOpacity;

  /// The length of the crop corner lines.
  ///
  /// This double value determines how long the lines at the corners of the
  /// crop rectangle are drawn, affecting their visual appearance.
  final double cornerLength;

  /// The thickness of the crop corner lines.
  ///
  /// This double value determines the thickness of the lines at the corners
  /// of the crop rectangle, influencing their visual prominence.
  final double cornerThickness;

  /// The width of the helper lines.
  ///
  /// This double value specifies the thickness of auxiliary lines drawn to
  /// assist with cropping, providing additional visual guides.
  double helperLineWidth = 0.5;

  /// The scale factor for resizing elements.
  ///
  /// This double value determines how much the elements are scaled, allowing
  /// for dynamic resizing based on zoom levels or screen sizes.
  final double scaleFactor;

  /// The factor for scaling elements based on rotation.
  ///
  /// This double value influences how elements are scaled when the image is
  /// rotated, ensuring that elements remain proportionate.
  final double rotationScaleFactor;

  double get _cropOffsetLeft => cropRect.left;
  double get _cropOffsetRight => cropRect.right;
  double get _cropOffsetTop => cropRect.top;
  double get _cropOffsetBottom => cropRect.bottom;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isInfinite) return;
    _drawDarkenOutside(canvas: canvas, size: size);
    if (fadeInOpacity > 0) _drawHelperAreas(canvas: canvas, size: size);
    _drawCorners(canvas: canvas, size: size);
  }

  void _drawDarkenOutside({
    required Canvas canvas,
    required Size size,
  }) {
    /// Draw outline darken layers
    double cropWidth = _cropOffsetRight - _cropOffsetLeft;
    double cropHeight = _cropOffsetBottom - _cropOffsetTop;

    Path path = Path()
      // FillType "evenOdd" is important for the canvas web renderer
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromCenter(
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

      /// Subtract the area of the current rectangle from the path for the
      /// entire canvas
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

      /// Subtract the area of the current rectangle from the path for the
      /// entire canvas
      path = Path.combine(PathOperation.difference, path, rectPath);
    }

    Color interpolatedColor = Color.lerp(
      imageEditorTheme.cropRotateEditor.background,
      imageEditorTheme.cropRotateEditor.cropOverlayColor,
      fadeInOpacity,
    )!;

    double opacity = 0.7 - 0.25 * interactionOpacity;

    double fadeInFactor = (1 - opacity) * (1 - fadeInOpacity);

    /// Draw the darkened area
    canvas.drawPath(
      path,
      Paint()
        ..color =
            interpolatedColor.withOpacity((opacity + fadeInFactor).clamp(0, 1))
        ..style = PaintingStyle.fill,
    );
  }

  void _drawCorners({
    required Canvas canvas,
    required Size size,
  }) {
    Path path = Path();

    double width = cornerThickness / rotationScaleFactor;
    if (!drawCircle) {
      double length = cornerLength / rotationScaleFactor;

      /// Top-Left
      path
        ..addRect(Rect.fromLTWH(_cropOffsetLeft, _cropOffsetTop, length, width))
        ..addRect(Rect.fromLTWH(_cropOffsetLeft, _cropOffsetTop, width, length))

        /// Top-Right
        ..addRect(Rect.fromLTWH(
            _cropOffsetRight - length, _cropOffsetTop, length, width))
        ..addRect(Rect.fromLTWH(
            _cropOffsetRight - width, _cropOffsetTop, width, length))

        /// Bottom-Left
        ..addRect(Rect.fromLTWH(
            0 + _cropOffsetLeft, _cropOffsetBottom - width, length, width))
        ..addRect(Rect.fromLTWH(
            0 + _cropOffsetLeft, _cropOffsetBottom - length, width, length))

        /// Bottom-Right
        ..addRect(Rect.fromLTWH(_cropOffsetRight - length,
            _cropOffsetBottom - width, length, width))
        ..addRect(Rect.fromLTWH(_cropOffsetRight - width,
            _cropOffsetBottom - length, width, length));

      canvas.drawPath(
        path,
        Paint()
          ..color = imageEditorTheme.cropRotateEditor.cropCornerColor
              .withOpacity(fadeInOpacity)
          ..style = PaintingStyle.fill,
      );
    } else {
      double calculateAngleFromArcLength(
          double circumference, double arcLength) {
        if (circumference <= 0 || arcLength <= 0) {
          throw ArgumentError(
              'Circumference and arc length must be positive values.');
        }
        return circumference / 360 * arcLength * pi / 180;
      }

      double angleRadians =
          calculateAngleFromArcLength(cropRect.width, width * 2);

      /// Top
      path
        ..addArc(
          Rect.fromCenter(
              center: cropRect.center,
              width: cropRect.width,
              height: cropRect.height),
          3 * pi / 2 - angleRadians / 2,
          angleRadians,
        )

        /// Left
        ..addArc(
          Rect.fromCenter(
              center: cropRect.center,
              width: cropRect.width,
              height: cropRect.height),
          pi - angleRadians / 2,
          angleRadians,
        )

        /// Right
        ..addArc(
          Rect.fromCenter(
              center: cropRect.center,
              width: cropRect.width,
              height: cropRect.height),
          pi / 2 - angleRadians / 2,
          angleRadians,
        )

        /// Right
        ..addArc(
          Rect.fromCenter(
              center: cropRect.center,
              width: cropRect.width,
              height: cropRect.height),
          -angleRadians / 2,
          angleRadians,
        );

      canvas.drawPath(
        path,
        Paint()
          ..color = imageEditorTheme.cropRotateEditor.cropCornerColor
              .withOpacity(fadeInOpacity)
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }
  }

  void _drawHelperAreas({
    required Canvas canvas,
    required Size size,
  }) {
    Path path = Path();

    double cropWidth = _cropOffsetRight - _cropOffsetLeft;
    double cropHeight = _cropOffsetBottom - _cropOffsetTop;

    double cropAreaSpaceW = cropWidth / 3;
    double cropAreaSpaceH = cropHeight / 3;

    /// Calculation is important for the round-cropper
    double lineWidth = !drawCircle
        ? cropWidth
        : sqrt(pow(cropWidth, 2) - pow(cropAreaSpaceW, 2));
    double lineHeight = !drawCircle
        ? cropHeight
        : sqrt(pow(cropHeight, 2) - pow(cropAreaSpaceH, 2));

    double gapW = (cropWidth - lineWidth) / 2;
    double gapH = (cropHeight - lineHeight) / 2;

    for (var i = 1; i < 3; i++) {
      path
        ..addRect(
          Rect.fromLTWH(
            cropAreaSpaceW * i + _cropOffsetLeft,
            gapH + _cropOffsetTop,
            helperLineWidth,
            lineHeight,
          ),
        )
        ..addRect(
          Rect.fromLTWH(
            gapW + _cropOffsetLeft,
            cropAreaSpaceH * i + _cropOffsetTop,
            lineWidth,
            helperLineWidth,
          ),
        );
    }

    final cornerPaint = Paint()
      ..color = imageEditorTheme.cropRotateEditor.helperLineColor
          .withOpacity(fadeInOpacity * interactionOpacity)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! CropCornerPainter ||
        oldDelegate.drawCircle != drawCircle ||
        oldDelegate.offset != offset ||
        oldDelegate.cropRect != cropRect ||
        oldDelegate.fadeInOpacity != fadeInOpacity ||
        oldDelegate.interactionOpacity != interactionOpacity ||
        oldDelegate.viewRect != viewRect ||
        oldDelegate.screenSize != screenSize ||
        oldDelegate.scaleFactor != scaleFactor ||
        oldDelegate.imageEditorTheme != imageEditorTheme ||
        oldDelegate.cornerLength != cornerLength ||
        oldDelegate.rotationScaleFactor != rotationScaleFactor;
  }

  /// Create a copy of the [CropCornerPainter].
  CropCornerPainter copy() {
    return CropCornerPainter(
      drawCircle: drawCircle,
      offset: offset,
      cropRect: cropRect,
      fadeInOpacity: fadeInOpacity,
      interactionOpacity: interactionOpacity,
      viewRect: viewRect,
      screenSize: screenSize,
      scaleFactor: scaleFactor,
      imageEditorTheme: imageEditorTheme,
      cornerLength: cornerLength,
      cornerThickness: cornerThickness,
      rotationScaleFactor: rotationScaleFactor,
    );
  }
}
