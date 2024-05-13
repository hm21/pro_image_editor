import 'dart:ui';

import 'package:pro_image_editor/modules/main_editor/utils/layer_manager.dart';

import '../models/crop_rotate_editor/transform_factors.dart';
import '../models/layer.dart';
import '../modules/crop_rotate_editor/utils/rotate_angle.dart';

class LayerTransformGenerator {
  final List<Layer> updatedLayers = [];
  final TransformConfigs activeTransformConfigs;
  final TransformConfigs newTransformConfigs;
  final Size layerDrawAreaSize; // Required parameter?
  final bool undoChanges;

  LayerTransformGenerator({
    required List<Layer> layers,
    required this.undoChanges,
    required this.activeTransformConfigs,
    required this.newTransformConfigs,
    required this.layerDrawAreaSize,
  }) {
    LayerManager layerManager = LayerManager();

    for (var el in layers) {
      Layer layer = layerManager.copyLayer(el);
      _rotateLayer(layer);
      _flipLayer(layer);
      _translateLayer(layer);
      _zoomLayer(layer);

      updatedLayers.add(layer);
    }
  }

  void _flipLayer(Layer layer) {
    bool shouldFlipX =
        activeTransformConfigs.flipX != newTransformConfigs.flipX;
    bool shouldFlipY =
        activeTransformConfigs.flipY != newTransformConfigs.flipY;

    if (newTransformConfigs.is90DegRotated) {
      if (shouldFlipX) {
        layer.flipY = !layer.flipY;
        layer.offset = Offset(
          layer.offset.dx,
          -layer.offset.dy,
        );
      }
      if (shouldFlipY) {
        layer.flipX = !layer.flipX;
        layer.offset = Offset(
          -layer.offset.dx,
          layer.offset.dy,
        );
      }
    } else {
      if (shouldFlipX) {
        layer.flipX = !layer.flipX;
        layer.offset = Offset(
          -layer.offset.dx,
          layer.offset.dy,
        );
      }
      if (shouldFlipY) {
        layer.flipY = !layer.flipY;
        layer.offset = Offset(
          layer.offset.dx,
          -layer.offset.dy,
        );
      }
    }
  }

  void _translateLayer(Layer layer) {
    Offset offset = newTransformConfigs.offset - activeTransformConfigs.offset;

    double scale = newTransformConfigs.scale / activeTransformConfigs.scale;

    double areaScale =
        layerDrawAreaSize.height / (layerDrawAreaSize.height + 40);

    print('----------------');
    print(areaScale);
    print(layerDrawAreaSize.height / (layerDrawAreaSize.height + 40));
    print((layerDrawAreaSize.height + 40) / layerDrawAreaSize.height);
    print(layerDrawAreaSize.width / (layerDrawAreaSize.width + 40));
    print((layerDrawAreaSize.width + 40) / layerDrawAreaSize.width);

    // 0.9416195856873822

    if (undoChanges) {
      layer.offset += offset / scale * 1.062;
    } else {
      layer.offset += offset * newTransformConfigs.scale / scale;
    }
  }

  void _rotateLayer(Layer layer) {
    double rotationAngle =
        activeTransformConfigs.angle - newTransformConfigs.angle;

    bool beforeRotated = activeTransformConfigs.is90DegRotated;
    bool beforeFlipY = activeTransformConfigs.flipY;
    bool beforeFlipX = activeTransformConfigs.flipX;

    bool afterRotated = newTransformConfigs.is90DegRotated;
    bool afterFlipY = newTransformConfigs.flipY;
    bool afterFlipX = newTransformConfigs.flipX;

    if (undoChanges) {
      if (beforeRotated &&
          (beforeFlipY || beforeFlipX) &&
          !(beforeFlipX && beforeFlipY)) {
        layer.rotation += rotationAngle;
      } else {
        layer.rotation -= rotationAngle;
      }
    } else {
      if (!afterFlipX && !afterFlipY && !beforeFlipX && !beforeFlipY) {
        layer.rotation -= rotationAngle;
      } else if (beforeRotated != afterRotated) {
        if ((afterFlipX || afterFlipY) && beforeFlipX == beforeFlipY) {
          layer.rotation -= rotationAngle;
        } else {
          layer.rotation += rotationAngle;
        }
      } else if (beforeRotated && afterRotated) {
        layer.rotation += rotationAngle;
      } else {
        layer.rotation -= rotationAngle;
      }
    }

    var angleSide = getRotateAngleSide(rotationAngle);

    if (angleSide == RotateAngleSide.bottom) {
      layer.offset = Offset(
        -layer.offset.dx,
        -layer.offset.dy,
      );
    } else if (angleSide == RotateAngleSide.right) {
      layer.offset = Offset(
        layer.offset.dy,
        -layer.offset.dx,
      );
    } else if (angleSide == RotateAngleSide.left) {
      layer.offset = Offset(
        -layer.offset.dy,
        layer.offset.dx,
      );
    }
  }

  void _zoomLayer(Layer layer) {
    double scale = newTransformConfigs.scale / activeTransformConfigs.scale;

    layer.offset *= scale;
    layer.scale *= scale;
  }
}
