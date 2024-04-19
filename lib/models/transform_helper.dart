import 'dart:ui';

class TransformHelper {
  final Size mainBodySize;
  final Size mainImageSize;
  final Size editorBodySize;

  /// Determines whether the editor aligns content to the top-left or center.
  final bool alignTopLeft;

  const TransformHelper({
    required this.mainBodySize,
    required this.mainImageSize,
    required this.editorBodySize,
    this.alignTopLeft = true,
  });

  double get scale {
    if (mainBodySize.isEmpty) return 1;

    double scaleW = editorBodySize.width / mainBodySize.width;
    double scaleH = editorBodySize.height / mainBodySize.height;

    double scaleOldDifferenceW = mainBodySize.width / mainImageSize.width;
    double scaleOldDifferenceH = mainBodySize.height / mainImageSize.height;

    bool stickOnHeightOld =
        mainBodySize.aspectRatio > mainImageSize.aspectRatio;
    bool stickOnHeightNew =
        editorBodySize.aspectRatio > mainImageSize.aspectRatio;

    double scaleStickSize = stickOnHeightNew != stickOnHeightOld
        ? (stickOnHeightOld ? scaleOldDifferenceW : scaleOldDifferenceH)
        : 1;
    double scaleImgSize = stickOnHeightNew ? scaleH : scaleW;

    return scaleImgSize * scaleStickSize;
  }

  Offset get offset {
    if (mainBodySize.isEmpty) return Offset.zero;

    if (!alignTopLeft) {
      return Offset(
        (editorBodySize.width * scale - editorBodySize.width) / 2,
        (editorBodySize.height * scale - editorBodySize.height) / 2,
      );
    }

    /// Image width == Screen width
    if (mainBodySize.width == mainImageSize.width) {
      /// Image size still same
      if (mainImageSize.aspectRatio > editorBodySize.aspectRatio) {
        double editorSpaceHeight =
            (editorBodySize.height - mainImageSize.height) / 2;
        return Offset(
          0,
          editorSpaceHeight,
        );
      }

      /// Image size changed
      else {
        double mainSpace = (mainBodySize.height - mainImageSize.height) / 2;
        return Offset(
          0,
          ((editorBodySize.height - mainBodySize.height) / 2 + mainSpace) *
              scale,
        );
      }
    }

    /// Image height == Screen height
    else if (mainBodySize.height == mainImageSize.height) {
      double imageWidth = editorBodySize.height * mainImageSize.aspectRatio;
      double mainScreenSpaceWidth =
          (mainBodySize.width - mainImageSize.width) / 2;

      double editorScreenSpaceWidth =
          mainScreenSpaceWidth - (editorBodySize.width - imageWidth) / 2;

      return Offset(
        ((mainBodySize.width - imageWidth) / 2 + editorScreenSpaceWidth) *
            scale,
        (editorBodySize.height - mainBodySize.height) / 2 * scale,
      );
    }

    return Offset.zero;
  }
}
