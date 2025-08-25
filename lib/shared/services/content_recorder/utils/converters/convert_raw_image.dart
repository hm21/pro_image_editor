// Dart imports:
import 'dart:async';
import 'dart:typed_data';

import '/core/models/multi_threading/thread_request_model.dart';
import '/core/models/multi_threading/thread_response_model.dart';
import '/plugins/image/src/image/image.dart' as img;
import '../encoder/encode_image.dart';

/// Converts an image to PNG format and finds the bounding box of
/// non-transparent areas.
///
/// This function takes an [ImageFromMainThread] object, finds the bounding
/// box of the non-transparent area in the image, crops the image to this
/// bounding box, and encodes it to PNG format.
///
/// Returns a [ResponseFromThread] containing the PNG byte data.
@pragma('vm:entry-point')
Future<ThreadResponse> convertRawImage(
  ImageConvertThreadRequest res, {
  Completer<void>? destroy$,
}) async {
  try {
    // Find the bounding box of the non-transparent area
    final bbox = await _findBoundingBox(
      image: res.image,
      destroy$: destroy$,
      generateOnlyImageBounds: res.generateOnlyImageBounds,
    );

    await _healthCheck(destroy$);

    final croppedImage = res.generateOnlyImageBounds == true
        ? await _resizeCropRect(
            res.image,
            left: bbox.left,
            top: bbox.top,
            width: bbox.width,
            height: bbox.height,
            destroy$: destroy$,
          )
        : res.image;

    await _healthCheck(destroy$);

    Uint8List bytes = await encodeImage(
      image: croppedImage,
      outputFormat: res.outputFormat,
      singleFrame: res.singleFrame,
      jpegQuality: res.jpegQuality,
      jpegBackgroundColor: res.jpegBackgroundColor,
      jpegChroma: res.jpegChroma,
      pngFilter: res.pngFilter,
      pngLevel: res.pngLevel,
      destroy$: destroy$,
    );

    return ThreadResponse(bytes: bytes, id: res.id);
  } catch (e) {
    return ThreadResponse(bytes: null, id: res.id);
  }
}

Future<void> _healthCheck(Completer<void>? destroy$) async {
  await Future.delayed(const Duration(microseconds: 10));
  if (destroy$?.isCompleted == true) {
    throw ArgumentError('Kill thread');
  }
}

/// Finds the bounding box of the non-transparent area in the given [image].
///
/// Returns a [BoundingBox] object representing the coordinates and
/// dimensions of the bounding box.
Future<_BoundingBox> _findBoundingBox({
  required img.Image image,
  required Completer<void>? destroy$,
  required bool? generateOnlyImageBounds,
}) async {
  int left = image.width;
  int right = 0;
  int top = image.height;
  int bottom = 0;
  if (generateOnlyImageBounds == true) {
    // Find top boundary
    outer:
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        var pixel = image.getPixel(x, y);
        if (pixel.a != 0) {
          top = y;
          break outer;
        }
      }
    }

    await _healthCheck(destroy$);

    // Find bottom boundary
    outer:
    for (int y = image.height - 1; y >= top; y--) {
      for (int x = 0; x < image.width; x++) {
        var pixel = image.getPixel(x, y);
        if (pixel.a != 0) {
          bottom = y.clamp(top, image.height);
          break outer;
        }
      }
    }

    await _healthCheck(destroy$);

    // Find left boundary
    outer:
    for (int x = 0; x < image.width; x++) {
      for (int y = top; y <= bottom; y++) {
        var pixel = image.getPixel(x, y);
        if (pixel.a != 0) {
          left = x.clamp(0, image.width);
          break outer;
        }
      }
    }

    await _healthCheck(destroy$);

    // Find right boundary
    outer:
    for (int x = image.width - 1; x >= left; x--) {
      for (int y = top; y <= bottom; y++) {
        var pixel = image.getPixel(x, y);
        if (pixel.a != 0) {
          right = x.clamp(left, image.width);
          break outer;
        }
      }
    }
  } else {
    left = 0;
    top = 0;
    right = image.width;
    bottom = image.height;
  }
  final width = right - left + 1;
  final height = bottom - top + 1;

  return _BoundingBox(left, top, width, height);
}

/// Crop the image to the bounding box
Future<img.Image> _resizeCropRect(
  img.Image src, {
  required int left,
  required int top,
  required int width,
  required int height,
  Completer<void>? destroy$,
}) async {
  // Make sure crop rectangle is within the range of the src image.
  left = left.clamp(0, src.width - 1).ceil();
  top = top.clamp(0, src.height - 1).ceil();
  if (left + width > src.width) {
    width = src.width - left;
  }
  if (top + height > src.height) {
    height = src.height - top;
  }

  img.Image? firstFrame;
  final numFrames = src.numFrames;
  for (var i = 0; i < numFrames; ++i) {
    final frame = src.frames[i];
    final dst = firstFrame?.addFrame() ??
        img.Image.fromResized(
          frame,
          width: width,
          height: height,
          noAnimation: true,
        );
    firstFrame ??= dst;

    for (int y = 0; y < height; y++) {
      int topY = top + y;
      for (int x = 0; x < width; x++) {
        var pixel = frame.getPixel(left + x, topY);
        dst.setPixelRgba(x, y, pixel.r, pixel.g, pixel.b, pixel.a);
      }

      if (y % 100 == 0) {
        await _healthCheck(destroy$);
      }
    }
  }

  return firstFrame!;
}

/// Represents a bounding box in terms of its position (left and top) and size
/// (width and height).
class _BoundingBox {
  /// Constructs a [_BoundingBox] instance.
  _BoundingBox(this.left, this.top, this.width, this.height);

  /// The x-coordinate of the top-left corner of the bounding box.
  final int left;

  /// The y-coordinate of the top-left corner of the bounding box.
  final int top;

  /// The width of the bounding box.
  final int width;

  /// The height of the bounding box.
  final int height;
}
