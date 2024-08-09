// Dart imports:
import 'dart:math';
import 'dart:ui';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import '../models/crop_rotate_editor/transform_factors.dart';
import '../modules/crop_rotate_editor/utils/rotate_angle.dart';
import '../modules/main_editor/utils/layer_copy_manager.dart';

/// A class for generating transformed layers in an image editor.
///
/// This class applies various transformations to a list of layers, including
/// rotation, translation, flipping, and zooming. It initializes with the
/// current and new transformation configurations and manages the updated
/// layers after transformations.
class LayerTransformGenerator {
  /// Creates an instance of [LayerTransformGenerator].
  ///
  /// The constructor initializes the transformation process by copying each
  /// layer, applying the specified transformations, and storing the updated
  /// layers in the [updatedLayers] list.
  ///
  /// Example:
  /// ```
  /// LayerTransformGenerator(
  ///   layers: myLayers,
  ///   undoChanges: false,
  ///   activeTransformConfigs: activeConfigs,
  ///   newTransformConfigs: newConfigs,
  ///   layerDrawAreaSize: Size(500, 500),
  ///   fitToScreenFactor: 1.0,
  ///   transformHelperScale: 1.0,
  /// )
  /// ```
  LayerTransformGenerator({
    required List<Layer> layers,
    required this.undoChanges,
    required this.activeTransformConfigs,
    required this.newTransformConfigs,
    required this.layerDrawAreaSize,
    this.fitToScreenFactor = 1.0,
    this.transformHelperScale = 1.0,
  }) {
    LayerCopyManager layerManager = LayerCopyManager();

    for (var el in layers) {
      Layer layer = layerManager.copyLayer(el);
      _rotateLayer(layer);
      _translateLayer(layer);
      _flipLayer(layer);
      _zoomLayer(layer);

      updatedLayers.add(layer);
    }
  }

  /// A list of layers that have been updated with transformations.
  ///
  /// This list contains copies of the original layers, each modified according
  /// to the specified transformations.
  final List<Layer> updatedLayers = [];

  /// The active transformation configurations.
  ///
  /// This [TransformConfigs] object contains the current transformation
  /// settings applied to the layers, serving as a baseline for transformations.
  final TransformConfigs activeTransformConfigs;

  /// The new transformation configurations to apply.
  ///
  /// This [TransformConfigs] object contains the desired transformation
  /// settings to be applied to the layers.
  final TransformConfigs newTransformConfigs;

  /// The size of the layer drawing area.
  ///
  /// This [Size] object represents the dimensions of the area where layers are
  /// drawn, affecting how transformations are scaled.
  final Size layerDrawAreaSize;

  /// Indicates whether to undo changes.
  ///
  /// This boolean flag determines if the transformations should be reverted,
  /// allowing for undo functionality.
  final bool undoChanges;

  /// The factor for fitting transformations to the screen.
  ///
  /// This double value specifies how transformations should be adjusted to
  /// fit within the visible screen area.
  final double fitToScreenFactor;

  /// The scale factor used by the transform helper.
  ///
  /// This double value affects the overall scale of transformations, allowing
  /// for additional scaling adjustments.
  final double transformHelperScale;

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
    } else {
      return;
    }

    if (undoChanges) {
      layer
        ..offset /= activeTransformConfigs.scaleRotation
        ..scale /= activeTransformConfigs.scaleRotation;
    } else {
      double scaleRotation = newTransformConfigs.scaleRotation /
          activeTransformConfigs.scaleRotation;

      layer
        ..offset *= scaleRotation
        ..scale *= scaleRotation;
    }
  }

  void _flipLayer(Layer layer) {
    bool shouldFlipX =
        activeTransformConfigs.flipX != newTransformConfigs.flipX;
    bool shouldFlipY =
        activeTransformConfigs.flipY != newTransformConfigs.flipY;

    if (newTransformConfigs.is90DegRotated) {
      if (shouldFlipX) {
        layer
          ..flipY = !layer.flipY
          ..offset = Offset(
            layer.offset.dx,
            -layer.offset.dy,
          );
      }
      if (shouldFlipY) {
        layer
          ..flipX = !layer.flipX
          ..offset = Offset(
            -layer.offset.dx,
            layer.offset.dy,
          );
      }
    } else {
      if (shouldFlipX) {
        layer
          ..flipX = !layer.flipX
          ..offset = Offset(
            -layer.offset.dx,
            layer.offset.dy,
          );
      }
      if (shouldFlipY) {
        layer
          ..flipY = !layer.flipY
          ..offset = Offset(
            layer.offset.dx,
            -layer.offset.dy,
          );
      }
    }
  }

  void _translateLayer(Layer layer) {
    Offset newOffset =
        newTransformConfigs.offset * newTransformConfigs.scaleUser;

    Offset oldOffset = activeTransformConfigs.offset *
        (undoChanges
            ? activeTransformConfigs.scaleUser
            : newTransformConfigs.scaleUser);

    Offset offset = newOffset - oldOffset;

    double radianAngle = -newTransformConfigs.angle;
    double cosAngle = cos(radianAngle);
    double sinAngle = sin(radianAngle);

    double dx = offset.dy * sinAngle + offset.dx * cosAngle;
    double dy = offset.dy * cosAngle - offset.dx * sinAngle;

    /// If the layer is flipped we need to reverse the offset.
    /// When the layer is rotated, the x and y position are also switched.
    bool isRotated = newTransformConfigs.is90DegRotated;
    if (activeTransformConfigs.flipX) {
      if (isRotated) {
        dy *= -1;
      } else {
        dx *= -1;
      }
    }
    if (activeTransformConfigs.flipY) {
      if (isRotated) {
        dx *= -1;
      } else {
        dy *= -1;
      }
    }

    offset = Offset(dx, dy);
    double scaleRotation = undoChanges
        ? activeTransformConfigs.scaleRotation
        : newTransformConfigs.scaleRotation;

    if (undoChanges) {
      layer.offset += offset / transformHelperScale;
    } else {
      double scale =
          newTransformConfigs.scaleUser / activeTransformConfigs.scaleUser;

      layer.offset += offset * scaleRotation / scale / fitToScreenFactor;
    }
  }

  void _zoomLayer(Layer layer) {
    double scale =
        newTransformConfigs.scaleUser / activeTransformConfigs.scaleUser;

    layer
      ..offset *= scale * transformHelperScale
      ..scale *= scale * transformHelperScale;
  }
}
