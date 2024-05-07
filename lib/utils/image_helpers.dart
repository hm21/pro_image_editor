import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

class _RemoveHelper {
  int width;
  int height;
  int minX = 0, minY = 0, maxX = 0, maxY = 0;
  ByteData bytes;

  _RemoveHelper({
    required this.width,
    required this.height,
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
    required this.bytes,
  });
}

/// Function to remove transparent areas from the image using dart:ui
Future<Uint8List?> removeTransparentImgAreas(Uint8List bytes) async {
  // Decode the image from bytes
  ui.Codec codec = await ui.instantiateImageCodec(bytes);
  ui.FrameInfo frameInfo = await codec.getNextFrame();
  ui.Image image = frameInfo.image;

  // Convert the Image to access pixels
  final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (byteData == null) return null;

  int width = image.width;
  int height = image.height;

  var res = await compute((_RemoveHelper helper) async {
    final pixels = helper.bytes.buffer.asUint32List();

    // Determine the bounding box of non-transparent pixels
    for (int y = 0; y < helper.height; y++) {
      for (int x = 0; x < helper.width; x++) {
        int index = x + y * helper.width;
        int pixel = pixels[index];
        int alpha = (pixel >> 24) & 0xFF;

        // Check if the pixel is not fully transparent
        if (alpha != 0) {
          if (x < helper.minX) helper.minX = x;
          if (y < helper.minY) helper.minY = y;
          if (x > helper.maxX) helper.maxX = x;
          if (y > helper.maxY) helper.maxY = y;
        }
      }
    }
    return helper;
  },
      _RemoveHelper(
        bytes: byteData,
        minX: width,
        minY: height,
        maxX: 0,
        maxY: 0,
        width: width,
        height: height,
      ));

  int minX = res.minX;
  int minY = res.minY;
  int maxX = res.maxX;
  int maxY = res.maxY;

  if (maxX < minX || maxY < minY) return bytes;

  // Crop the image to the bounding box safely
  final pictureRecorder = ui.PictureRecorder();
  final canvas = ui.Canvas(pictureRecorder);

  // Define the crop area with validation to ensure it's within the image bounds
  final srcRect = ui.Rect.fromLTRB(minX.toDouble(), minY.toDouble(),
      (maxX + 1).toDouble(), (maxY + 1).toDouble());
  final dstRect = ui.Rect.fromLTWH(0, 0, srcRect.width, srcRect.height);

  canvas.drawImageRect(image, srcRect, dstRect, ui.Paint());

  // Create the cropped image from the canvas
  final croppedImage = await pictureRecorder
      .endRecording()
      .toImage((maxX - minX + 1).toInt(), (maxY - minY + 1).toInt());

  // Encode the cropped image to PNG
  final croppedByteData =
      await croppedImage.toByteData(format: ui.ImageByteFormat.png);
  return croppedByteData?.buffer.asUint8List();
}
