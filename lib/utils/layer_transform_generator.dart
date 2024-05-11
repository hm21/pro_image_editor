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

    /* print('is90Deg: ${activeTransformConfigs.is90DegRotated}'); */
    for (var el in layers) {
      Layer layer = layerManager.copyLayer(el);

      rotateLayer(layer);
      flipLayer(layer);
      translateLayer(layer);
      zoomLayer(layer);

      updatedLayers.add(layer);
    }
  }

  void flipLayer(Layer layer) {
    bool shouldFlipX =
        activeTransformConfigs.flipX != newTransformConfigs.flipX;
    bool shouldFlipY =
        activeTransformConfigs.flipY != newTransformConfigs.flipY;
    /*  
   print('shouldFlipY $shouldFlipY');
    print('shouldFlipX $shouldFlipX');
     */

    if (activeTransformConfigs.is90DegRotated &&
        newTransformConfigs.is90DegRotated) {
      if ((shouldFlipY)) {
        layer.flipX = !layer.flipX;
        layer.offset = Offset(
          -layer.offset.dx,
          layer.offset.dy,
        );
      }
      if (shouldFlipX) {
        layer.flipY = !layer.flipY;
        layer.offset = Offset(
          layer.offset.dx,
          -layer.offset.dy,
        );
      }
    } else if (activeTransformConfigs.is90DegRotated) {
      if ((shouldFlipY)) {
        layer.flipX = !layer.flipX;
        layer.offset = Offset(
          layer.offset.dx,
          -layer.offset.dy,
        );
      }
      if (shouldFlipX) {
        layer.flipY = !layer.flipY;
        layer.offset = Offset(
          -layer.offset.dx,
          layer.offset.dy,
        );
      }
    } else if (newTransformConfigs.is90DegRotated) {
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
      if ((shouldFlipX)) {
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

  void translateLayer(Layer layer) {
    Offset offset = newTransformConfigs.offset - activeTransformConfigs.offset;

    double scale = newTransformConfigs.scale / activeTransformConfigs.scale;

    layer.offset += offset / scale;
  }

  void rotateLayer(Layer layer) {
    double rotationAngle =
        activeTransformConfigs.angle - newTransformConfigs.angle;

    layer.rotation -= rotationAngle;

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

  void zoomLayer(Layer layer) {
    double scale = newTransformConfigs.scale / activeTransformConfigs.scale;

    layer.offset *= scale;
    layer.scale *= scale;
  }
}
