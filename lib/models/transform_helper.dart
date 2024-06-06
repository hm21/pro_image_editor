// Dart imports:
import 'dart:ui';

// Project imports:
import 'package:pro_image_editor/models/crop_rotate_editor/transform_factors.dart';

class TransformHelper {
  final Size mainBodySize;
  final Size mainImageSize;
  final Size editorBodySize;
  final TransformConfigs? transformConfigs;

  const TransformHelper({
    required this.mainBodySize,
    required this.mainImageSize,
    required this.editorBodySize,
    this.transformConfigs,
  });

  double get scale {
    if (mainBodySize.isEmpty) return 1;

    Size imageSize = transformConfigs?.is90DegRotated == true
        ? mainImageSize.flipped
        : mainImageSize;
    double? cropRectRatio =
        transformConfigs != null && transformConfigs!.isNotEmpty
            ? transformConfigs?.cropRect.size.aspectRatio
            : null;
    if (transformConfigs?.is90DegRotated == true) {
      cropRectRatio = 1 / cropRectRatio!;
    }

    double scaleW = editorBodySize.width / mainBodySize.width;
    double scaleH = editorBodySize.height / mainBodySize.height;

    double scaleOldDifferenceW = mainBodySize.width / imageSize.width;
    double scaleOldDifferenceH = mainBodySize.height / imageSize.height;

    bool stickOnHeightOld =
        mainBodySize.aspectRatio > (cropRectRatio ?? imageSize.aspectRatio);
    bool stickOnHeightNew =
        editorBodySize.aspectRatio > (cropRectRatio ?? imageSize.aspectRatio);

    double scaleStickSize = stickOnHeightNew != stickOnHeightOld
        ? (stickOnHeightOld ? scaleOldDifferenceW : scaleOldDifferenceH)
        : 1;

    double scaleImgSize = stickOnHeightNew ? scaleH : scaleW;
    return scaleImgSize * scaleStickSize;
  }
}
