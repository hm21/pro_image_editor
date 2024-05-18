// Dart imports:
import 'dart:isolate';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:image/image.dart' as img;

// Project imports:
import 'content_recorder_models.dart';

/// The isolated function to handle image conversion in a separate thread.
///
/// This function sets up a [ReceivePort] to listen for incoming messages.
/// When it receives an [ImageFromMainThread] message, it processes the image
/// and sends back the result.
void isolatedImageConverter(SendPort port) {
  final receivePort = ReceivePort();
  port.send(receivePort.sendPort);

  receivePort.listen((dynamic message) async {
    if (message is ImageFromMainThread) {
      port.send(await _dartNativeConvertImageToPng(message));
    }
  });
}

/// Converts an image to PNG format and finds the bounding box of non-transparent areas.
///
/// This function takes an [ImageFromMainThread] object, finds the bounding box of
/// the non-transparent area in the image, crops the image to this bounding box,
/// and encodes it to PNG format.
///
/// Returns a [ResponseFromImageThread] containing the PNG byte data.
Future<ResponseFromImageThread> _dartNativeConvertImageToPng(
    ImageFromMainThread res) async {
  /// Finds the bounding box of the non-transparent area in the given [image].
  ///
  /// Returns a [BoundingBox] object representing the coordinates and dimensions of the bounding box.
  BoundingBox findBoundingBox(img.Image image) {
    int left = image.width;
    int right = 0;
    int top = image.height;
    int bottom = 0;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        var pixel = image.getPixel(x, y);
        if (pixel.a != 0) {
          if (x < left) left = x;
          if (x > right) right = x;
          if (y < top) top = y;
          if (y > bottom) bottom = y;
        }
      }
    }

    final width = right - left + 1;
    final height = bottom - top + 1;

    return BoundingBox(left, top, width, height);
  }

  try {
    // Find the bounding box of the non-transparent area
    final bbox = findBoundingBox(res.image);

    // Crop the image to the bounding box
    final croppedImage = img.copyCrop(
      res.image,
      x: bbox.left,
      y: bbox.top,
      width: bbox.width,
      height: bbox.height,
    );

    Uint8List bytes = img.encodePng(croppedImage, filter: img.PngFilter.none);

    return ResponseFromImageThread(
      bytes: bytes,
      completerId: res.completerId,
    );
  } catch (e) {
    debugPrint(e.toString());
    return ResponseFromImageThread(
      bytes: null,
      completerId: res.completerId,
    );
  }
}
