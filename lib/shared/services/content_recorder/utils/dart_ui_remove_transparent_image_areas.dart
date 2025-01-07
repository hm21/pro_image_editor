// Dart imports:
import 'dart:async';
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/foundation.dart';

/// Function to remove transparent areas from the image using dart:ui
Future<ui.Image?> dartUiRemoveTransparentImgAreas(
  ui.Image image,
) async {
  // Convert the Image to access pixels
  final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);

  if (byteData == null) return null;

  int width = image.width;
  int height = image.height;

  _RemoveHelper res = await compute(
    (_RemoveHelper helper) async {
      int originalWidth = helper.width;
      int originalHeight = helper.height;

      final pixels = helper.bytes.buffer.asUint32List();
      bool found = false;
      // Find top boundary
      for (int y = 0; y < originalHeight && !found; y++) {
        for (int x = 0; x < originalWidth; x++) {
          int index = x + y * helper.width;
          int pixel = pixels[index];
          int alpha = (pixel >> 24) & 0xFF;

          if (alpha != 0) {
            helper.minY = y;
            found = true;
            break;
          }
        }
      }

      found = false;
      // Find bottom boundary
      for (int y = originalHeight - 1; y >= helper.minY && !found; y--) {
        for (int x = 0; x < originalWidth; x++) {
          int index = x + y * helper.width;
          int pixel = pixels[index];
          int alpha = (pixel >> 24) & 0xFF;

          if (alpha != 0) {
            helper.maxY = y;
            found = true;
          }
        }
      }
      helper.maxY = helper.maxY.clamp(helper.minY, originalHeight);

      found = false;
      // Find left boundary
      for (int x = 0; x < originalWidth && !found; x++) {
        for (int y = helper.minY; y <= helper.maxY; y++) {
          int index = x + y * helper.width;
          int pixel = pixels[index];
          int alpha = (pixel >> 24) & 0xFF;

          if (alpha != 0) {
            helper.minX = x;
            found = true;
            break;
          }
        }
      }
      helper.minX = helper.minX.clamp(0, originalWidth);

      found = false;
      // Find right boundary
      for (int x = originalWidth - 1; x >= helper.minX && !found; x--) {
        for (int y = helper.minY; y <= helper.maxY; y++) {
          int index = x + y * helper.width;
          int pixel = pixels[index];
          int alpha = (pixel >> 24) & 0xFF;

          if (alpha != 0) {
            helper.maxX = x;
            found = true;
            break;
          }
        }
      }
      helper.maxX = helper.maxX.clamp(helper.minX, originalWidth);

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
    ),
  );

  int minX = res.minX;
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

  return croppedImage;
}

/// Helper class to manage image metadata and pixel data.
class _RemoveHelper {
  /// Constructs a [_RemoveHelper] instance.
  ///
  /// All parameters are required.
  _RemoveHelper({
    required this.width,
    required this.height,
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
    required this.bytes,
  });

  /// The width of the image.
  final int width;

  /// The height of the image.
  final int height;

  /// The minimum x-coordinate of the bounding box.
  int minX;

  /// The minimum y-coordinate of the bounding box.
  int minY;

  /// The maximum x-coordinate of the bounding box.
  int maxX;

  /// The maximum y-coordinate of the bounding box.
  int maxY;

  /// The byte data of the image.
  final ByteData bytes;
}
