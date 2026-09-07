import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/services/layer_transform_generator.dart';

TransformConfigs _configs({
  double angle = 0,
  bool flipX = false,
  bool flipY = false,
  Offset offset = Offset.zero,
  double scaleUser = 1.0,
  double scaleRotation = 1.0,
}) {
  return TransformConfigs(
    angle: angle,
    flipX: flipX,
    flipY: flipY,
    offset: offset,
    scaleUser: scaleUser,
    scaleRotation: scaleRotation,
    aspectRatio: 1,
    cropEditorScreenRatio: 1,
    cropRect: const Rect.fromLTWH(0, 0, 110, 100),
    originalSize: const Size(300, 300),
  );
}

Layer _makeLayer({
  Offset offset = Offset.zero,
  double rotation = 0,
  double scale = 1.0,
  bool flipX = false,
  bool flipY = false,
}) {
  return Layer(
    offset: offset,
    rotation: rotation,
    scale: scale,
    flipX: flipX,
    flipY: flipY,
  );
}

void main() {
  group('LayerTransformGenerator', () {
    test('applies rotation transformation', () {
      final layer = _makeLayer(offset: const Offset(10, 20), rotation: 0.0);
      final active = _configs(angle: 0.0);
      final next = _configs(angle: 1.5708); // 90 deg in radians

      final generator = LayerTransformGenerator(
        layers: [layer],
        undoChanges: false,
        activeTransformConfigs: active,
        newTransformConfigs: next,
        layerDrawAreaSize: const Size(100, 100),
      );

      final updated = generator.updatedLayers.first;
      expect(updated.rotation, isNot(equals(0.0)));
      expect(updated.offset, isNot(equals(const Offset(10, 20))));
    });

    test('applies flipX transformation', () {
      final layer = _makeLayer(offset: const Offset(5, 5), flipX: false);
      final active = _configs(flipX: false);
      final next = _configs(flipX: true);

      final generator = LayerTransformGenerator(
        layers: [layer],
        undoChanges: false,
        activeTransformConfigs: active,
        newTransformConfigs: next,
        layerDrawAreaSize: const Size(100, 100),
      );

      final updated = generator.updatedLayers.first;
      expect(updated.flipX, isTrue);
      expect(updated.offset.dx, equals(-5));
    });

    test('applies flipY transformation', () {
      final layer = _makeLayer(offset: const Offset(5, 5), flipY: false);
      final active = _configs(flipY: false);
      final next = _configs(flipY: true);

      final generator = LayerTransformGenerator(
        layers: [layer],
        undoChanges: false,
        activeTransformConfigs: active,
        newTransformConfigs: next,
        layerDrawAreaSize: const Size(100, 100),
      );

      final updated = generator.updatedLayers.first;
      expect(updated.flipY, isTrue);
      expect(updated.offset.dy, equals(-5));
    });

    test('applies translation transformation', () {
      final layer = _makeLayer(offset: const Offset(0, 0));
      final active = _configs(offset: const Offset(0, 0));
      final next = _configs(offset: const Offset(10, 20));

      final generator = LayerTransformGenerator(
        layers: [layer],
        undoChanges: false,
        activeTransformConfigs: active,
        newTransformConfigs: next,
        layerDrawAreaSize: const Size(100, 100),
      );

      final updated = generator.updatedLayers.first;
      expect(updated.offset.dx, isNonZero);
      expect(updated.offset.dy, isNonZero);
    });

    test('applies zoom transformation', () {
      final layer = _makeLayer(scale: 1.0, offset: const Offset(2, 2));
      final active = _configs(scaleUser: 1.0);
      final next = _configs(scaleUser: 2.0);

      final generator = LayerTransformGenerator(
        layers: [layer],
        undoChanges: false,
        activeTransformConfigs: active,
        newTransformConfigs: next,
        layerDrawAreaSize: const Size(100, 100),
      );

      final updated = generator.updatedLayers.first;
      expect(updated.scale, greaterThan(1.0));
      expect(updated.offset.dx, greaterThan(2.0));
      expect(updated.offset.dy, greaterThan(2.0));
    });

    test('undoChanges reverses transformations', () {
      final layer = _makeLayer(
        offset: const Offset(10, 10),
        rotation: 0.5,
        scale: 2.0,
        flipX: true,
        flipY: false,
      );
      final active = _configs(
        angle: 0.5,
        flipX: true,
        scaleUser: 2.0,
        offset: const Offset(10, 10),
      );
      final next = _configs(
        angle: 0.0,
        flipX: false,
        scaleUser: 1.0,
        offset: const Offset(0, 0),
      );

      final generator = LayerTransformGenerator(
        layers: [layer],
        undoChanges: true,
        activeTransformConfigs: active,
        newTransformConfigs: next,
        layerDrawAreaSize: const Size(100, 100),
      );

      final updated = generator.updatedLayers.first;
      expect(updated.rotation, isNot(equals(0.5)));
      expect(updated.scale, isNot(equals(2.0)));
      expect(updated.offset, isNot(equals(const Offset(10, 10))));
    });
  });
}
