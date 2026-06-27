// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/editor_configs/crop_rotate_editor_configs.dart';
import 'package:pro_image_editor/features/crop_rotate_editor/enums/crop_mode.enum.dart';
import 'package:pro_image_editor/shared/widgets/transform/transformed_content_generator.dart';

void main() {
  group('CropRotateEditorConfigs.initialOvalCropAspectRatio', () {
    test('returns the ratio for an oval cropper with a fixed ratio', () {
      const configs = CropRotateEditorConfigs(
        initialCropMode: CropMode.oval,
        initAspectRatio: 1.0,
      );
      expect(configs.initialOvalCropAspectRatio, 1.0);
    });

    test('is null for a free (-1) or original (0) ratio', () {
      expect(
        const CropRotateEditorConfigs(
          initialCropMode: CropMode.oval,
          initAspectRatio: -1,
        ).initialOvalCropAspectRatio,
        isNull,
      );
      expect(
        const CropRotateEditorConfigs(
          initialCropMode: CropMode.oval,
          initAspectRatio: 0,
        ).initialOvalCropAspectRatio,
        isNull,
      );
    });

    test('is null for the rectangular cropper', () {
      expect(
        const CropRotateEditorConfigs(
          initAspectRatio: 1.0,
        ).initialOvalCropAspectRatio,
        isNull,
      );
    });
  });

  group('CutOutsideArea.getClip (initial oval mask)', () {
    final emptyConfigs = TransformConfigs.empty();

    test(
      'clips a non-square image to a centered square for a 1:1 ratio (circle)',
      () {
        final clipper = CutOutsideArea(
          configs: emptyConfigs,
          cropMode: CropMode.oval,
          initialOvalCropAspectRatio: 1.0,
        );

        final rect = clipper.getClip(const Size(400, 800));

        // A 1:1 mask must be a circle, i.e. a square clip rect.
        expect(rect.width, rect.height);
        expect(rect.width, 400);
        expect(rect.center, const Offset(200, 400));
      },
    );

    test('keeps the full image bounds without a fixed ratio (ellipse)', () {
      final clipper = CutOutsideArea(
        configs: emptyConfigs,
        cropMode: CropMode.oval,
      );

      final rect = clipper.getClip(const Size(400, 800));

      expect(rect.width, 400);
      expect(rect.height, 800);
    });

    test('honors a wide ratio by fitting the width', () {
      final clipper = CutOutsideArea(
        configs: emptyConfigs,
        cropMode: CropMode.oval,
        initialOvalCropAspectRatio: 16 / 9,
      );

      final rect = clipper.getClip(const Size(400, 800));

      expect(rect.width, 400);
      expect(rect.height, closeTo(400 / (16 / 9), 0.001));
    });
  });
}
