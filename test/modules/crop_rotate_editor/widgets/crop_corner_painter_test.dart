// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pro_image_editor/modules/crop_rotate_editor/widgets/crop_corner_painter.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

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
          imageEditorTheme: const ImageEditorTheme(),
          drawCircle: false,
          offset: Offset.zero,
          interactionOpacity: 0,
          fadeInOpacity: 0.5,
          cornerLength: 20.0,
          rotationScaleFactor: 1.0,
          scaleFactor: 1.0,
          cornerThickness: 6);

      final painter2 = CropCornerPainter(
          cropRect: cropRect.translate(10, 20), // Changed property
          viewRect: viewRect,
          screenSize: screenSize,
          imageEditorTheme: const ImageEditorTheme(),
          drawCircle: false,
          offset: Offset.zero,
          fadeInOpacity: 0.5,
          interactionOpacity: 0,
          cornerLength: 20.0,
          rotationScaleFactor: 1.0,
          scaleFactor: 1.0,
          cornerThickness: 6);

      expect(painter1.shouldRepaint(painter2), isTrue);
    });
  });
}
