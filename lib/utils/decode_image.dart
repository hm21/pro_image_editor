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

  if (configs != null && !configs.isEmpty) {
    w = w ~/ configs.scaleUser;
    h = h ~/ configs.scaleUser;
  }

  double widthRatio = (rotated ? h : w).toDouble() / screenSize.width;
  double heightRatio = (rotated ? w : h).toDouble() / screenSize.height;
  double pixelRatio = max(heightRatio, widthRatio);

  return ImageInfos(
    rawSize: Size(w.toDouble(), h.toDouble()),
    renderedSize: Size(w.toDouble() / pixelRatio, h.toDouble() / pixelRatio),
    pixelRatio: pixelRatio,
  );
}

class ImageInfos {
  final Size rawSize;
  final Size renderedSize;
  final double pixelRatio;

  const ImageInfos({
    required this.rawSize,
    required this.renderedSize,
    required this.pixelRatio,
  });

  ImageInfos copyWith({
    Size? rawSize,
    Size? renderedSize,
    double? pixelRatio,
  }) {
    return ImageInfos(
      rawSize: rawSize ?? this.rawSize,
      renderedSize: renderedSize ?? this.renderedSize,
      pixelRatio: pixelRatio ?? this.pixelRatio,
    );
  }
}
