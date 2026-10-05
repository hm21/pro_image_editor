import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/editor_configs/paint_editor/censor_configs.dart';
import 'package:pro_image_editor/shared/widgets/censor/layer_space_pixelate_filter.dart';

void main() {
  group(LayerSpacePixelateGrid, () {
    test('scales the blocks with the transform and the pixel ratio', () {
      final grid = LayerSpacePixelateGrid.of(
        transform: Matrix4.identity()
          ..translateByDouble(40, 30, 0, 1)
          ..scaleByDouble(2, 2, 1, 1),
        layerBlockSize: 12,
        devicePixelRatio: 3,
      );

      expect(grid.blockSize, 72);
      expect(grid.origin, const Offset(120, 90));
    });

    test('keeps the block size of a rotated area', () {
      final grid = LayerSpacePixelateGrid.of(
        transform: Matrix4.rotationZ(math.pi / 4)..scaleByDouble(2, 2, 1, 1),
        layerBlockSize: 10,
        devicePixelRatio: 1,
      );

      expect(grid.blockSize, closeTo(20, 1e-9));
    });

    test('never shrinks a block below one device pixel', () {
      final grid = LayerSpacePixelateGrid.of(
        transform: Matrix4.diagonal3Values(0.01, 0.01, 1),
        layerBlockSize: 10,
        devicePixelRatio: 1,
      );

      expect(grid.blockSize, 1);
    });
  });

  group(CensorConfigs, () {
    test('pixelates in screen space unless asked otherwise', () {
      const configs = CensorConfigs();

      expect(configs.pixelateInLayerSpace, isFalse);
      expect(
        configs.copyWith(pixelateInLayerSpace: true).pixelateInLayerSpace,
        isTrue,
      );
    });
  });
}
