// Dart imports:
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/styles/crop_rotate_editor_style.dart';
import 'package:pro_image_editor/features/crop_rotate_editor/widgets/crop_corner_painter.dart';
import 'package:pro_image_editor/shared/extensions/matrix_extension.dart';

void main() {
  group('CropCornerPainter', () {
    test('Should repaint when properties change', () {
      const Rect cropRect = Rect.fromLTWH(100, 100, 200, 200);
      const Rect viewRect = Rect.fromLTWH(0, 0, 400, 400);
      const Size screenSize = Size(400, 400);

      final painter1 = CropCornerPainter(
        cropRect: cropRect,
        viewRect: viewRect,
        screenSize: screenSize,
        style: const CropRotateEditorStyle(),
        drawCircle: false,
        offset: Offset.zero,
        interactionOpacity: 0,
        fadeInOpacity: 0.5,
        rotationScaleFactor: 1.0,
        scaleFactor: 1.0,
      );

      final painter2 = CropCornerPainter(
        cropRect: cropRect.translate(10, 20), // Changed property
        viewRect: viewRect,
        screenSize: screenSize,
        style: const CropRotateEditorStyle(),
        drawCircle: false,
        offset: Offset.zero,
        fadeInOpacity: 0.5,
        interactionOpacity: 0,
        rotationScaleFactor: 1.0,
        scaleFactor: 1.0,
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test(
      'Darken overlay fully covers the image top edge when panned (#776)',
      () async {
        TestWidgetsFlutterBinding.ensureInitialized();

        const Size canvasSize = Size(400, 600);
        const Rect cropRect = Rect.fromLTWH(100, 200, 200, 200);

        /// Pan the image down by a fractional offset so its top edge lands on
        /// a sub-pixel boundary - the situation that previously left an
        /// anti-aliased seam revealing a thin line of the image.
        const Offset offset = Offset(0, 80.5);

        final painter = CropCornerPainter(
          cropRect: cropRect,
          viewRect: const Rect.fromLTWH(0, 0, 400, 600),
          screenSize: canvasSize,
          style: const CropRotateEditorStyle(
            cropOverlayColor: Color(0xFF000000),
            cropOverlayOpacity: 1,
            cropOverlayInteractionOpacity: 0,
          ),
          drawCircle: false,
          offset: offset,
          interactionOpacity: 0,
          fadeInOpacity: 1,
          rotationScaleFactor: 1.0,
          scaleFactor: 1.0,
        );

        final recorder = ui.PictureRecorder();
        painter.paint(Canvas(recorder), canvasSize);
        final ui.Image image = await recorder.endRecording().toImage(
          canvasSize.width.toInt(),
          canvasSize.height.toInt(),
        );
        final byteData = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        final bytes = byteData!.buffer.asUint8List();

        int alphaAt(int x, int y) =>
            bytes[(y * canvasSize.width.toInt() + x) * 4 + 3];

        /// The image's top edge sits at y = 80.5. The pixel row at y = 80 is
        /// the seam that used to show through; with the overscan it must be
        /// fully opaque, just like a clearly interior row.
        expect(alphaAt(200, 80), greaterThanOrEqualTo(250));
        expect(alphaAt(200, 100), 255);
      },
    );

    test('Should repaint when the tilt changes', () {
      const Rect cropRect = Rect.fromLTWH(100, 100, 200, 200);
      CropCornerPainter build({double tiltHorizontal = 0}) => CropCornerPainter(
        cropRect: cropRect,
        viewRect: const Rect.fromLTWH(0, 0, 400, 400),
        screenSize: const Size(400, 400),
        style: const CropRotateEditorStyle(),
        drawCircle: false,
        offset: Offset.zero,
        interactionOpacity: 0,
        fadeInOpacity: 0.5,
        rotationScaleFactor: 1.0,
        scaleFactor: 1.0,
        tiltHorizontal: tiltHorizontal,
      );

      expect(build().shouldRepaint(build(tiltHorizontal: 0.3)), isTrue);
    });

    test(
      'Darken overlay follows the tilted image quad, not an axis-aligned rect',
      () async {
        TestWidgetsFlutterBinding.ensureInitialized();

        const Size canvasSize = Size(400, 400);
        const Size imageSize = Size(200, 200);
        const double tiltHorizontal = 0.4;
        // Keep the crop hole away from the sampled points.
        const Rect cropRect = Rect.fromLTWH(0, 0, 20, 20);

        final painter = CropCornerPainter(
          cropRect: cropRect,
          viewRect: const Rect.fromLTWH(0, 0, 400, 400),
          screenSize: canvasSize,
          style: const CropRotateEditorStyle(
            cropOverlayColor: Color(0xFF000000),
            cropOverlayOpacity: 1,
            cropOverlayInteractionOpacity: 0,
          ),
          drawCircle: false,
          offset: Offset.zero,
          interactionOpacity: 0,
          fadeInOpacity: 1,
          rotationScaleFactor: 1.0,
          scaleFactor: 1.0,
          tiltHorizontal: tiltHorizontal,
        );

        final recorder = ui.PictureRecorder();
        painter.paint(Canvas(recorder), imageSize);
        final ui.Image image = await recorder.endRecording().toImage(
          canvasSize.width.toInt(),
          canvasSize.height.toInt(),
        );
        final byteData = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        final bytes = byteData!.buffer.asUint8List();
        int alphaAt(int x, int y) =>
            bytes[(y * canvasSize.width.toInt() + x) * 4 + 3];

        // Reconstruct the tilted image quad with the same transform the
        // painter uses, then sample its centroid (clearly inside the image,
        // outside the crop) and a point far outside the quad.
        final center = Offset(imageSize.width / 2, imageSize.height / 2);
        final tiltMatrix = Matrix4.identity().tilt(
          rotate: 0,
          vertical: 0,
          horizontal: tiltHorizontal,
        );
        Offset toScreen(Offset p) {
          final t = MatrixUtils.transformPoint(tiltMatrix, p - center);
          return center + t;
        }

        final corners = [
          toScreen(const Offset(0, 0)),
          toScreen(Offset(imageSize.width, 0)),
          toScreen(Offset(imageSize.width, imageSize.height)),
          toScreen(Offset(0, imageSize.height)),
        ];
        final centroid =
            corners.reduce((a, b) => a + b) / corners.length.toDouble();

        // The centroid of the tilted image must be darkened.
        expect(
          alphaAt(centroid.dx.round(), centroid.dy.round()),
          greaterThanOrEqualTo(250),
        );
        // A point well outside the tilted quad must stay transparent.
        expect(alphaAt(395, 395), 0);
      },
    );
  });
}
