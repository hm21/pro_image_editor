import 'dart:ui';

import 'package:pro_image_editor/modules/main_editor/utils/layer_manager.dart';

import '../models/crop_rotate_editor/transform_factors.dart';
import '../models/layer.dart';
import '../modules/crop_rotate_editor/utils/rotate_angle.dart';

class LayerTransformGenerator {
  final List<Layer> updatedLayers = [];
  final List<Layer> rawLayers = [];
  final TransformConfigs activeTransformConfigs;
  final TransformConfigs newTransformConfigs;
  final Size layerDrawAreaSize;

  LayerTransformGenerator({
    required List<Layer> layers,
    required this.activeTransformConfigs,
    required this.newTransformConfigs,
    required this.layerDrawAreaSize,
  }) {
    LayerManager layerManager = LayerManager();

    for (var el in layers) {
      Layer layer = layerManager.copyLayer(el);

      rotateLayer(layer);
      flipLayer(layer);
      //TODO:  zoomLayer(layer);

      updatedLayers.add(layer);
    }
  }

  void flipLayer(Layer layer) {
    if (activeTransformConfigs.flipY != newTransformConfigs.flipY) {
      layer.flipY = !layer.flipY;
      layer.offset = Offset(
        layer.offset.dx,
        layerDrawAreaSize.height - layer.offset.dy,
      );
    }
    if (activeTransformConfigs.flipX != newTransformConfigs.flipX) {
      layer.flipX = !layer.flipX;
      layer.offset = Offset(
        layerDrawAreaSize.width - layer.offset.dx,
        layer.offset.dy,
      );
    }
  }

  /// Rotate a layer.
  void rotateLayer(Layer layer) {
    double rotationScale = newTransformConfigs.scaleRotation;
    double rotationAngle = newTransformConfigs.angle;

    print(activeTransformConfigs.angle);
    print(newTransformConfigs.angle);

    layer.rotation -= rotationAngle;

    var angleSide = getRotateAngleSide(rotationAngle);
    print(angleSide);

    var screenW =
        angleSide == RotateAngleSide.top || angleSide == RotateAngleSide.bottom
            ? layerDrawAreaSize.width
            : layerDrawAreaSize.height;
    var screenH =
        angleSide == RotateAngleSide.top || angleSide == RotateAngleSide.bottom
            ? layerDrawAreaSize.height
            : layerDrawAreaSize.width;

    if (angleSide == RotateAngleSide.bottom) {
      layer.offset = Offset(
        screenW - layer.offset.dx,
        screenH - layer.offset.dy,
      );
    } else if (angleSide == RotateAngleSide.right) {
      layer.scale *= rotationScale;
      layer.offset = Offset(
        layer.offset.dy * rotationScale,
        screenH - layer.offset.dx * rotationScale,
      );
    } else if (angleSide == RotateAngleSide.left) {
      layer.scale *= rotationScale;
      layer.offset = Offset(
        layer.offset.dy * rotationScale,
        screenH - layer.offset.dx * rotationScale,
      );
    }
  }

  /// Zooming of a layer.
  void zoomLayer(Layer layer) {
    Rect cropRect = newTransformConfigs.cropRect;
    double scale = newTransformConfigs.scale;

    var initialIconX = (cropRect.width * scale - cropRect.width);
    var initialIconY = (cropRect.height * scale - cropRect.height);
    layer.offset = Offset(
      layer.offset.dx - initialIconX,
      layer.offset.dy - initialIconY,
    );

    layer.scale *= scale;
  }
}
