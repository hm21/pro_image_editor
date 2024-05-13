import 'dart:ui';

class TransformHelper {
  final Size mainBodySize;
  final Size mainImageSize;
  final Size editorBodySize;
  final double? cropAspectRatio;

  const TransformHelper({
    required this.mainBodySize,
    required this.mainImageSize,
    required this.editorBodySize,
    this.cropAspectRatio,
  });

  double get scale {
    if (mainBodySize.isEmpty) return 1;

    double scaleW = editorBodySize.width / mainBodySize.width;
    double scaleH = editorBodySize.height / mainBodySize.height;

    double scaleOldDifferenceW = mainBodySize.width / mainImageSize.width;
    double scaleOldDifferenceH = mainBodySize.height / mainImageSize.height;

    bool stickOnHeightOld = mainBodySize.aspectRatio >
        (cropAspectRatio ?? mainImageSize.aspectRatio);
    bool stickOnHeightNew = editorBodySize.aspectRatio >
        (cropAspectRatio ?? mainImageSize.aspectRatio);

    double scaleStickSize = stickOnHeightNew != stickOnHeightOld
        ? (stickOnHeightOld ? scaleOldDifferenceW : scaleOldDifferenceH)
        : 1;

    double scaleImgSize = stickOnHeightNew ? scaleH : scaleW;
    return scaleImgSize * scaleStickSize;
  }
}
