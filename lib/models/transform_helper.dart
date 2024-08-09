// Dart imports:
import 'dart:ui';

// Project imports:
import 'package:pro_image_editor/models/crop_rotate_editor/transform_factors.dart';

/// A helper class for managing transformation calculations in the image editor.
///
/// This class provides utilities for handling transformations related to the
/// image and editor body sizes, offering a unified approach to scale
/// calculations based on the current transformation configurations.
class TransformHelper {
  /// Creates an instance of [TransformHelper].
  ///
  /// The constructor initializes the sizes of the main body, main image, and
  /// editor body, as well as optional transformation configurations.
  ///
  /// Example:
  /// ```
  /// TransformHelper(
  ///   mainBodySize: Size(300, 400),
  ///   mainImageSize: Size(600, 800),
  ///   editorBodySize: Size(300, 400),
  ///   transformConfigs: myTransformConfigs,
  /// )
  /// ```
  const TransformHelper({
    required this.mainBodySize,
    required this.mainImageSize,
    required this.editorBodySize,
    this.transformConfigs,
  });

  /// The size of the main body.
  ///
  /// This [Size] object represents the dimensions of the main body area in the
  /// editor, providing a reference for scaling transformations.
  final Size mainBodySize;

  /// The size of the main image.
  ///
  /// This [Size] object represents the dimensions of the main image being
  /// edited, affecting how transformations are applied relative to the image.
  final Size mainImageSize;

  /// The size of the editor body.
  ///
  /// This [Size] object represents the dimensions of the editor's visible
  /// area, influencing how the image is scaled and displayed.
  final Size editorBodySize;

  /// Optional transformation configurations.
  ///
  /// This [TransformConfigs] object contains optional settings for
  /// transformations, such as rotation and cropping, allowing for dynamic
  /// adjustments.
  final TransformConfigs? transformConfigs;

  /// Calculates the scale factor for transformations.
  ///
  /// This getter computes the appropriate scale factor based on the current
  /// body and image sizes, taking into account rotation and cropping
  /// configurations.
  ///
  /// Returns:
  /// - A double representing the scale factor used to transform the image
  ///   within the editor body.
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
