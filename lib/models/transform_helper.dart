import 'dart:ui';

class TransformHelper {
  final Size mainBodySize;
  final Size mainImageSize;
  final Size editorBodySize;

  const TransformHelper({
    required this.mainBodySize,
    required this.mainImageSize,
    required this.editorBodySize,
  });

  double get scale {
    if (mainBodySize.isEmpty) return 1;

    /// Image width == Screen width
    if (mainBodySize.width == mainImageSize.width &&
        mainImageSize.aspectRatio < editorBodySize.aspectRatio) {
      return editorBodySize.height / mainImageSize.height;
    }

    /// Image height == Screen height
    else if (mainBodySize.height == mainImageSize.height) {
      return editorBodySize.height / mainImageSize.height;
    }

    return 1;
  }

  Offset get offset {
    if (mainBodySize.isEmpty) return Offset.zero;

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
