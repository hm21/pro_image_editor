import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/features/crop_rotate_editor/models/transform_configs.dart';
import 'package:pro_image_editor/features/main_editor/services/crop_layer_scale.dart';

TransformConfigs _crop({
  required Size originalSize,
  required Rect cropRect,
  double scaleUser = 2,
  double angle = 0,
}) {
  return TransformConfigs(
    angle: angle,
    cropRect: cropRect,
    originalSize: originalSize,
    cropEditorScreenRatio: 1,
    scaleUser: scaleUser,
    scaleRotation: 1,
    aspectRatio: cropRect.size.aspectRatio,
    flipX: false,
    flipY: false,
    offset: Offset.zero,
  );
}

void main() {
  group('cropReopenLayerScale', () {
    test('scales with the fitted crop, not the crop zoom', () {
      // Tall crop inside a square editor, reopened in an editor twice as tall.
      // The crop sticks to the body height both times, so the layer scale is
      // 2. scaleUser must not appear in that factor.
      final transform = _crop(
        originalSize: const Size(500, 500),
        cropRect: const Rect.fromLTWH(0, 0, 100, 200),
        scaleUser: 3,
      );

      final scale = cropReopenLayerScale(
        oldBody: const Size(400, 400),
        newBody: const Size(400, 800),
        transform: transform,
      );

      expect(scale, 2);
    });

    test('is 1 when the editor body does not change', () {
      final transform = _crop(
        originalSize: const Size(800, 600),
        cropRect: const Rect.fromLTWH(10, 20, 300, 200),
        scaleUser: 2.5,
      );

      expect(
        cropReopenLayerScale(
          oldBody: const Size(640, 480),
          newBody: const Size(640, 480),
          transform: transform,
        ),
        1,
      );
    });

    test('ignores a transform that is not a crop', () {
      expect(
        cropReopenLayerScale(
          oldBody: const Size(400, 400),
          newBody: const Size(800, 600),
          transform: TransformConfigs.empty(),
        ),
        isNull,
      );
    });

    test('ignores a missing editor body', () {
      final transform = _crop(
        originalSize: const Size(500, 500),
        cropRect: const Rect.fromLTWH(0, 0, 100, 200),
      );

      expect(
        cropReopenLayerScale(
          oldBody: Size.zero,
          newBody: const Size(400, 400),
          transform: transform,
        ),
        isNull,
      );
    });
  });
}
