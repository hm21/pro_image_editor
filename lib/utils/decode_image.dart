import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:pro_image_editor/models/crop_rotate_editor/transform_factors.dart';

/// Decode the image being edited.
Future<DecodedImageInfos> decodeImageInfos({
  required Uint8List bytes,
  required Size screenSize,
  TransformConfigs? configs,
}) async {
  var decodedImage = await decodeImageFromList(bytes);

  bool rotated = configs?.is90DegRotated == true;
  int w = decodedImage.width;
  int h = decodedImage.height;

  double widthRatio = (rotated ? h : w).toDouble() / screenSize.width;
  double heightRatio = (rotated ? w : h).toDouble() / screenSize.height;
  double pixelRatio = max(heightRatio, widthRatio);

  /// TODO: fix pixel ratio bug
  print({
    'decodedImage': Size(w.toDouble(), h.toDouble()),
    'screenSize': screenSize,
    'pixelRatio': pixelRatio,
    'imageSize': Size(w / pixelRatio, h / pixelRatio),
    'rawImageSize': Size(w.toDouble(), h.toDouble()),
  });
  return DecodedImageInfos(
    rawImageSize: Size(w.toDouble(), h.toDouble()),
    imageSize: Size(w / pixelRatio, h / pixelRatio),
    pixelRatio: pixelRatio,
  );
}

class DecodedImageInfos {
  final Size rawImageSize;
  final Size imageSize;
  final double pixelRatio;

  const DecodedImageInfos({
    required this.rawImageSize,
    required this.imageSize,
    required this.pixelRatio,
  });
}

/// Original 1024 x 1792 => 2.258
/*
Size(1024.0, 1792.0)
Size(1536.0, 681.6)
2.629107981220657 
*/
