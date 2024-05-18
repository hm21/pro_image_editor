import 'dart:async';
import 'dart:isolate';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class RemoveHelper {
  int width;
  int height;
  int minX = 0, minY = 0, maxX = 0, maxY = 0;
  ByteData bytes;

  RemoveHelper({
    required this.width,
    required this.height,
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
    required this.bytes,
  });
}

class BoundingBox {
  final int left;
  final int top;
  final int width;
  final int height;

  BoundingBox(this.left, this.top, this.width, this.height);
}

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

void isolatedImageConverter(SendPort port) {
  final receivePort = ReceivePort();
  port.send(receivePort.sendPort);

  receivePort.listen((dynamic message) async {
    if (message is ImageFromMainThread) {
      port.send(await _dartNativeConvertImageToPng(message));
    }
  });
}

Future<ResponseFromImageThread> _dartNativeConvertImageToPng(
    ImageFromMainThread res) async {
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

class ImageFromMainThread {
  final String completerId;
  final img.Image image;

  const ImageFromMainThread({
    required this.completerId,
    required this.image,
  });
}

class ResponseFromImageThread {
  final String completerId;
  final Uint8List? bytes;

  const ResponseFromImageThread({
    required this.completerId,
    required this.bytes,
  });
}
