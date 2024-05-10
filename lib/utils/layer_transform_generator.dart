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

      translateLayer(layer);
      rotateLayer(layer);
      flipLayer(layer);
      zoomLayer(layer);

      updatedLayers.add(layer);
    }
  }

  void flipLayer(Layer layer) {
    if (activeTransformConfigs.flipY != newTransformConfigs.flipY) {
      layer.flipY = !layer.flipY;
      layer.offset = Offset(
        layer.offset.dx,
        -layer.offset.dy,
      );
    }
    if (activeTransformConfigs.flipX != newTransformConfigs.flipX) {
      layer.flipX = !layer.flipX;
      layer.offset = Offset(
        -layer.offset.dx,
        layer.offset.dy,
      );
    }
  }

  void translateLayer(Layer layer) {
    Offset offset = newTransformConfigs.offset - activeTransformConfigs.offset;

    /*    print(activeTransformConfigs.cropRect);
    Rect rect = activeTransformConfigs.cropRect;
    if (!rect.isInfinite) {
      double oldScale = activeTransformConfigs.scale;
      double newScale = newTransformConfigs.scale;

      double newPaddingWidth = rect.width * newScale - rect.width;
      double oldPaddingWidth = rect.width * oldScale - rect.width;
      double newPaddingHeight = rect.height * newScale - rect.height;
      double oldPaddingHeight = rect.height * oldScale - rect.height;

      print(newPaddingWidth - oldPaddingWidth);
      layer.offset -= Offset(
        newPaddingWidth - oldPaddingWidth,
        newPaddingHeight - oldPaddingHeight,
      );
    } */
    double scale = newTransformConfigs.scale / activeTransformConfigs.scale;

    // TODO: layer.offset += newTransformConfigs.offset * newTransformConfigs.scale;
  }

  void rotateLayer(Layer layer) {
    double scale = newTransformConfigs.scale;
    double rotationAngle =
        activeTransformConfigs.angle - newTransformConfigs.angle;

    layer.rotation += rotationAngle;

    var angleSide = getRotateAngleSide(rotationAngle);

    var screenW =
        angleSide == RotateAngleSide.top || angleSide == RotateAngleSide.bottom
            ? layerDrawAreaSize.width
            : layerDrawAreaSize.height;
    var screenH =
        angleSide == RotateAngleSide.top || angleSide == RotateAngleSide.bottom
            ? layerDrawAreaSize.height
            : layerDrawAreaSize.width;

    print(angleSide);
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

  void zoomLayer(Layer layer) {
    double scale = newTransformConfigs.scale / activeTransformConfigs.scale;

    layer.offset *= scale;
    layer.scale *= scale;
  }
}
