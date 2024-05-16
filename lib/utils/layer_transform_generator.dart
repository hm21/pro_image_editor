import 'dart:math';
import 'dart:ui';

import 'package:pro_image_editor/modules/main_editor/utils/layer_copy_manager.dart';

import '../models/crop_rotate_editor/transform_factors.dart';
import '../models/layer.dart';
import '../modules/crop_rotate_editor/utils/rotate_angle.dart';

class LayerTransformGenerator {
  final List<Layer> updatedLayers = [];
  final TransformConfigs activeTransformConfigs;
  final TransformConfigs newTransformConfigs;
  final Size layerDrawAreaSize;
  final bool undoChanges;

  LayerTransformGenerator({
    required List<Layer> layers,
    required this.undoChanges,
    required this.activeTransformConfigs,
    required this.newTransformConfigs,
    required this.layerDrawAreaSize,
  }) {
    LayerCopyManager layerManager = LayerCopyManager();

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
    double getTransformedRatio(Rect rect) {
      return newTransformConfigs.is90DegRotated
          ? 1 / rect.size.aspectRatio
          : rect.size.aspectRatio;
    }

    Offset offset = newTransformConfigs.offset - activeTransformConfigs.offset;

    double radianAngle = -newTransformConfigs.angle;
    double cosAngle = cos(radianAngle);
    double sinAngle = sin(radianAngle);

    double dx = offset.dy * sinAngle + offset.dx * cosAngle;
    double dy = offset.dy * cosAngle - offset.dx * sinAngle;

    offset = Offset(dx, dy);

    bool fitToWidth = undoChanges
        ? getTransformedRatio(activeTransformConfigs.cropRect) >
            layerDrawAreaSize.aspectRatio
        : getTransformedRatio(newTransformConfigs.cropRect) >
            layerDrawAreaSize.aspectRatio;
    double areaScale = !fitToWidth
        ? (layerDrawAreaSize.width + 40) / layerDrawAreaSize.width
        : (layerDrawAreaSize.height + 40) / layerDrawAreaSize.height;

    print(areaScale);
    /*   print('----------------');
    print(areaScale);
    print(layerDrawAreaSize.height / (layerDrawAreaSize.height + 40));
    print((layerDrawAreaSize.height + 40) / layerDrawAreaSize.height);
    print(layerDrawAreaSize.width / (layerDrawAreaSize.width + 40));
    print((layerDrawAreaSize.width + 40) / layerDrawAreaSize.width);
    print(layerDrawAreaSize.height / (layerDrawAreaSize.height - 40));
    print((layerDrawAreaSize.height - 40) / layerDrawAreaSize.height);
    print(layerDrawAreaSize.width / (layerDrawAreaSize.width - 40));
    print((layerDrawAreaSize.width - 40) / layerDrawAreaSize.width); */

    if (undoChanges) {
      layer.offset += offset * activeTransformConfigs.scale * areaScale;
    } else {
      layer.offset += offset * activeTransformConfigs.scale * areaScale;
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

    var transformConfigs =
        undoChanges ? activeTransformConfigs : newTransformConfigs;

    if (transformConfigs.cropEditorScreenRatio != 0 &&
        !layerDrawAreaSize.isEmpty) {
      double aspectRatioScaleHelper = 1;

      Size originalSize = Size(activeTransformConfigs.originalSize.width + 40,
          activeTransformConfigs.originalSize.height + 40);

      bool originalFitToWidth =
          layerDrawAreaSize.aspectRatio < originalSize.aspectRatio;

      bool fitToWidth = transformConfigs.cropEditorScreenRatio <
          (transformConfigs.is90DegRotated
              ? 1 / transformConfigs.cropRect.size.aspectRatio
              : transformConfigs.cropRect.size.aspectRatio);

      if (!originalFitToWidth && fitToWidth) {
        aspectRatioScaleHelper = layerDrawAreaSize.aspectRatio /
            transformConfigs.cropEditorScreenRatio;
      } else if (originalFitToWidth && !fitToWidth) {
        aspectRatioScaleHelper = transformConfigs.cropEditorScreenRatio /
            layerDrawAreaSize.aspectRatio;
      }

      if (!undoChanges) {
        if (!newTransformConfigs.is90DegRotated) {
          layer.offset *= aspectRatioScaleHelper;
        }
      } else {
        layer.scale /= aspectRatioScaleHelper;
        layer.offset /= aspectRatioScaleHelper;
      }
    }
  }

  void _zoomLayer(Layer layer) {
    double scale = newTransformConfigs.scale / activeTransformConfigs.scale;

    layer.offset *= scale;
    layer.scale *= scale;
  }
}
