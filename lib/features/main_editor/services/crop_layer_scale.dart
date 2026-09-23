import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '/features/crop_rotate_editor/models/transform_configs.dart';

/// Size of the cropped image as fitted into [drawSize].
///
/// Matches the crop window the main editor paints: the crop aspect ratio is
/// inscribed in the editor body, sticking to height or width.
/// [fallbackAspectRatio] is the decoded image aspect, used only when
/// [transformConfigs] has no finite original size.
Size fittedCropDrawSize({
  required TransformConfigs transformConfigs,
  required Size drawSize,
  required double fallbackAspectRatio,
}) {
  final double ratio = transformConfigs.originalSize.isInfinite
      ? fallbackAspectRatio
      : transformConfigs.cropRect.size.aspectRatio;
  final double convertedRatio = transformConfigs.is90DegRotated
      ? 1 / ratio
      : ratio;

  if (convertedRatio < drawSize.aspectRatio) {
    return Size(drawSize.height * convertedRatio, drawSize.height);
  }
  return Size(drawSize.width, drawSize.width / convertedRatio);
}

/// Multiplier that keeps a layer on the same point of a cropped image when
/// the editor body changes from [oldBody] to [newBody].
///
/// Layer offsets are distances from the body center in pixels of the editor
/// where they were placed. The cropped preview is fitted into that body, so
/// the multiplier is the ratio of the two fitted crop sizes.
///
/// Returns null when the transform is not a real crop or either body is
/// unknown. Callers then keep the uncropped rendered-size scale.
double? cropReopenLayerScale({
  required Size oldBody,
  required Size newBody,
  required TransformConfigs transform,
}) {
  if (oldBody.isEmpty || newBody.isEmpty) return null;
  if (!isCroppedFrame(transform)) return null;

  final oldSize = fittedCropDrawSize(
    transformConfigs: transform,
    drawSize: oldBody,
    fallbackAspectRatio: 1,
  );
  final newSize = fittedCropDrawSize(
    transformConfigs: transform,
    drawSize: newBody,
    fallbackAspectRatio: 1,
  );
  if (oldSize.width == 0 || oldSize.height == 0) return null;

  final scale = min(
    newSize.width / oldSize.width,
    newSize.height / oldSize.height,
  );
  if (!scale.isFinite || scale == 0) return null;
  return scale;
}

/// Whether [transform] is a crop the editor fits into the body.
///
/// An empty transform, or one without a finite crop rectangle, is the frame
/// layers had before any crop.
bool isCroppedFrame(TransformConfigs transform) {
  if (transform.isEmpty) return false;
  final original = transform.originalSize;
  final crop = transform.cropRect;
  if (!original.isFinite || original.isEmpty) return false;
  if (!crop.isFinite || crop.isEmpty) return false;
  final aspect = crop.size.aspectRatio;
  return aspect.isFinite && aspect != 0;
}
