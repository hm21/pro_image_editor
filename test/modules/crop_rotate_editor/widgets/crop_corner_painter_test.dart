// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/styles/crop_rotate_editor_style.dart';
import 'package:pro_image_editor/features/crop_rotate_editor/widgets/crop_corner_painter.dart';

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
  });
}
