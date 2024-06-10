// Dart imports:
import 'dart:math';

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

  bool rotated = configs?.is90DegRotated == true;
  int w = decodedImage.width;
  int h = decodedImage.height;

  if (configs != null && configs.isNotEmpty) {
    w = w ~/ configs.scaleUser;
    h = h ~/ configs.scaleUser;
  }

  double widthRatio = (rotated ? h : w).toDouble() / screenSize.width;
  double heightRatio = (rotated ? w : h).toDouble() / screenSize.height;
  double pixelRatio = max(heightRatio, widthRatio);

  Size renderedSize =
      Size(w.toDouble() / pixelRatio, h.toDouble() / pixelRatio);

  return ImageInfos(
    rawSize: Size(w.toDouble(), h.toDouble()),
    renderedSize: renderedSize,
    cropRectSize: configs != null && configs.isNotEmpty
        ? configs.cropRect.size
        : renderedSize,
    pixelRatio: pixelRatio,
    isRotated: configs?.is90DegRotated ?? false,
  );
}

class ImageInfos {
  final Size rawSize;
  final Size renderedSize;
  final Size cropRectSize;
  final double pixelRatio;
  final bool isRotated;

  const ImageInfos({
    required this.rawSize,
    required this.renderedSize,
    required this.cropRectSize,
    required this.pixelRatio,
    required this.isRotated,
  });

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
