// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:pro_image_editor/models/crop_rotate_editor/transform_factors.dart';

/// Decode the image being edited.
Future<ImageInfos> decodeImageInfos({
  required Uint8List bytes,
  required Size screenSize,
  TransformConfigs? configs,
}) async {
  var decodedImage = await decodeImageFromList(bytes);
  Size rawSize = Size(
    decodedImage.width.toDouble(),
    decodedImage.height.toDouble(),
  );

  bool rotated = configs?.is90DegRotated == true;
  int w = decodedImage.width;
  int h = decodedImage.height;

  if (configs != null && configs.isNotEmpty) {
    w = w ~/ configs.scaleUser;
    h = h ~/ configs.scaleUser;
  }

  /// If the image is rotated we also flip the width/ height
  if (rotated) {
    int hX = h;
    h = w;
    w = hX;
  }

  double widthRatio = w.toDouble() / screenSize.width;
  double heightRatio = h.toDouble() / screenSize.height;

  bool imageFitToHeight =
      screenSize.aspectRatio > Size(w.toDouble(), h.toDouble()).aspectRatio;

  double pixelRatio = imageFitToHeight ? heightRatio : widthRatio;

  Size renderedSize = rawSize / pixelRatio;

  return ImageInfos(
    rawSize: rawSize,
    renderedSize: renderedSize,
    cropRectSize: configs != null && configs.isNotEmpty
        ? configs.cropRect.size
        : renderedSize,
    pixelRatio: pixelRatio,
    isRotated: configs?.is90DegRotated ?? false,
  );
}

/// Contains information about an image's size and rotation status.
class ImageInfos {
  /// Creates an instance of [ImageInfos].
  const ImageInfos({
    required this.rawSize,
    required this.renderedSize,
    required this.cropRectSize,
    required this.pixelRatio,
    required this.isRotated,
  });

  /// The raw size of the image.
  final Size rawSize;

  /// The size of the image after rendering.
  final Size renderedSize;

  /// The size of the cropping rectangle.
  final Size cropRectSize;

  /// The pixel ratio of the image.
  final double pixelRatio;

  /// Whether the image is rotated.
  final bool isRotated;

  /// Creates a copy of the current [ImageInfos] instance with optional
  /// updated values.
  ImageInfos copyWith({
    Size? rawSize,
    Size? renderedSize,
    Size? cropRectSize,
    double? pixelRatio,
    bool? isRotated,
  }) {
    return ImageInfos(
      rawSize: rawSize ?? this.rawSize,
      renderedSize: renderedSize ?? this.renderedSize,
      cropRectSize: cropRectSize ?? this.cropRectSize,
      pixelRatio: pixelRatio ?? this.pixelRatio,
      isRotated: isRotated ?? this.isRotated,
    );
  }
}
