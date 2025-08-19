import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

void main() {
  group('TransformConfigs', () {
    test('empty factory returns default values', () {
      final config = TransformConfigs.empty();
      expect(config.angle, 0);
      expect(config.originalSize, Size.infinite);
      expect(config.cropRect, Rect.largest);
      expect(config.cropEditorScreenRatio, 0);
      expect(config.scaleUser, 1);
      expect(config.scaleRotation, 1);
      expect(config.aspectRatio, -1);
      expect(config.flipX, false);
      expect(config.flipY, false);
      expect(config.offset, Offset.zero);
      expect(config.isEmpty, true);
      expect(config.isNotEmpty, false);
    });

    test('fromMap creates correct instance', () {
      final map = {
        'angle': 1.57,
        'cropRect': {'left': 10, 'top': 20, 'right': 110, 'bottom': 120},
        'originalSize': {'width': 200, 'height': 300},
        'cropEditorScreenRatio': 1.5,
        'scaleUser': 2.0,
        'scaleRotation': 1.1,
        'aspectRatio': 1.33,
        'flipX': true,
        'flipY': false,
        'cropMode': 'oval',
        'offset': {'dx': 5, 'dy': 6},
      };
      final config = TransformConfigs.fromMap(map);
      expect(config.angle, 1.57);
      expect(config.cropRect, const Rect.fromLTRB(10, 20, 110, 120));
      expect(config.originalSize, const Size(200, 300));
      expect(config.cropEditorScreenRatio, 1.5);
      expect(config.scaleUser, 2.0);
      expect(config.scaleRotation, 1.1);
      expect(config.aspectRatio, 1.33);
      expect(config.flipX, true);
      expect(config.flipY, false);
      expect(config.cropMode, CropMode.oval);
      expect(config.offset, const Offset(5, 6));
      expect(config.isOvalCropper, true);
      expect(config.isRectangularCropper, false);
    });

    test('toMap returns correct map', () {
      final config = TransformConfigs(
        angle: 0.5,
        cropRect: const Rect.fromLTRB(1, 2, 3, 4),
        originalSize: const Size(100, 200),
        cropEditorScreenRatio: 1.2,
        scaleUser: 1.5,
        scaleRotation: 1.1,
        aspectRatio: 1.0,
        flipX: true,
        flipY: false,
        offset: const Offset(7, 8),
        cropMode: CropMode.rectangular,
        tiltRotate: 0,
        tiltHorizontal: 0,
        tiltVertical: 0,
      );
      final map = config.toMap();
      expect(map['angle'], 0.5);
      expect(map['cropRect']['left'], 1);
      expect(map['cropRect']['top'], 2);
      expect(map['cropRect']['right'], 3);
      expect(map['cropRect']['bottom'], 4);
      expect(map['originalSize']['width'], 100);
      expect(map['originalSize']['height'], 200);
      expect(map['cropEditorScreenRatio'], 1.2);
      expect(map['scaleUser'], 1.5);
      expect(map['scaleRotation'], 1.1);
      expect(map['aspectRatio'], 1.0);
      expect(map['flipX'], true);
      expect(map['flipY'], false);
      expect(map['cropMode'], 'rectangular');
      expect(map['offset']['dx'], 7);
      expect(map['offset']['dy'], 8);
    });

    test('is90DegRotated returns correct value', () {
      for (var i = 0; i < 20; i++) {
        final config = TransformConfigs(
          angle: pi * (0.5 * i),
          cropRect: Rect.zero,
          originalSize: Size.zero,
          cropEditorScreenRatio: 0,
          scaleUser: 1,
          scaleRotation: 1,
          aspectRatio: 1,
          flipX: false,
          flipY: false,
          offset: Offset.zero,
          tiltRotate: 0,
          tiltHorizontal: 0,
          tiltVertical: 0,
        );
        expect(config.is90DegRotated, i.isOdd);
      }
    });

    test('angleToTurns returns correct quarter turns', () {
      for (var i = 0; i < 20; i++) {
        final config = TransformConfigs(
          angle: pi * (0.5 * i),
          cropRect: Rect.zero,
          originalSize: Size.zero,
          cropEditorScreenRatio: 0,
          scaleUser: 1,
          scaleRotation: 1,
          aspectRatio: 1,
          flipX: false,
          flipY: false,
          offset: Offset.zero,
          tiltRotate: 0,
          tiltHorizontal: 0,
          tiltVertical: 0,
        );
        expect(config.angleToTurns(), i);
      }
    });

    test('scale returns product of scaleUser and scaleRotation', () {
      final config = TransformConfigs(
        angle: 0,
        cropRect: Rect.zero,
        originalSize: Size.zero,
        cropEditorScreenRatio: 0,
        scaleUser: 2,
        scaleRotation: 3,
        aspectRatio: 1,
        flipX: false,
        flipY: false,
        offset: Offset.zero,
        tiltRotate: 0,
        tiltHorizontal: 0,
        tiltVertical: 0,
      );
      expect(config.scale, 6);
    });

    test('== and hashCode', () {
      final config1 = TransformConfigs(
        angle: 0.1,
        cropRect: const Rect.fromLTRB(1, 2, 3, 4),
        originalSize: const Size(10, 20),
        cropEditorScreenRatio: 1.1,
        scaleUser: 1.2,
        scaleRotation: 1.3,
        aspectRatio: 1.4,
        flipX: true,
        flipY: false,
        offset: const Offset(5, 6),
        cropMode: CropMode.oval,
        tiltRotate: 0,
        tiltHorizontal: 0,
        tiltVertical: 0,
      );
      final config2 = config1.copyWith();
      final config3 = TransformConfigs.empty();
      expect(config1, config2);
      expect(config1.hashCode, config2.hashCode);
      expect(config1 == config3, false);
    });

    test('getCropStartOffset returns correct offset', () {
      final config = TransformConfigs(
        angle: 0,
        cropRect: const Rect.fromLTWH(0, 0, 100, 100),
        originalSize: const Size(200, 200),
        cropEditorScreenRatio: 1,
        scaleUser: 2,
        scaleRotation: 1,
        aspectRatio: 1,
        flipX: false,
        flipY: false,
        offset: const Offset(10, 20),
        tiltRotate: 0,
        tiltHorizontal: 0,
        tiltVertical: 0,
      );
      final offset = config.getCropStartOffset(const Size(400, 400));
      expect(offset.dx, isNonNegative);
      expect(offset.dy, isNonNegative);
    });

    test('getCropSize returns correct size', () {
      final config = TransformConfigs(
        angle: 0,
        cropRect: const Rect.fromLTWH(0, 0, 100, 200),
        originalSize: const Size(200, 400),
        cropEditorScreenRatio: 1,
        scaleUser: 2,
        scaleRotation: 1,
        aspectRatio: 2,
        flipX: false,
        flipY: false,
        offset: Offset.zero,
        tiltRotate: 0,
        tiltHorizontal: 0,
        tiltVertical: 0,
      );
      final size = config.getCropSize(const Size(400, 800));
      expect(size.width, 100);
      expect(size.height, 200);
    });
  });
}
