// Dart imports:
import 'dart:async';
import 'dart:isolate';
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'content_recorder_models.dart';

/// Function to remove transparent areas from the image using dart:ui
Future<ui.Image?> dartUiRemoveTransparentImgAreas(
  ui.Image image, {
  SendPort? sendport,
  Completer<RemoveHelper>? completer,
}) async {
  // Convert the Image to access pixels
  final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);

  if (byteData == null) return null;

  int width = image.width;
  int height = image.height;

  sendport?.send(
    RemoveHelper(
      bytes: byteData,
      minX: width,
      minY: height,
      maxX: 0,
      maxY: 0,
      width: width,
      height: height,
    ),
  );

  RemoveHelper? res = await completer?.future;

  res ??= await compute((RemoveHelper helper) async {
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
      RemoveHelper(
        bytes: byteData,
        minX: width,
        minY: height,
        maxX: 0,
        maxY: 0,
        width: width,
        height: height,
      ));

  int minX = res!.minX;
  int minY = res.minY;
  int maxX = res.maxX;
  int maxY = res.maxY;

  if (maxX < minX || maxY < minY) return image;

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
  return croppedImage;
}
