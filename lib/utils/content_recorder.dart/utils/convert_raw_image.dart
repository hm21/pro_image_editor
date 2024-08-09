// Dart imports:
import 'dart:async';
import 'dart:typed_data';

// Package imports:
import 'package:image/image.dart' as img;

// Project imports:
import 'package:pro_image_editor/models/multi_threading/thread_request_model.dart';
import 'package:pro_image_editor/models/multi_threading/thread_response_model.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/utils/encode_image.dart';

/// Converts an image to PNG format and finds the bounding box of
/// non-transparent areas.
///
/// This function takes an [ImageFromMainThread] object, finds the bounding
/// box of the non-transparent area in the image, crops the image to this
/// bounding box, and encodes it to PNG format.
///
/// Returns a [ResponseFromThread] containing the PNG byte data.
@pragma('vm:entry-point')
Future<ThreadResponse> convertRawImage(ImageConvertThreadRequest res,
    {Completer<void>? destroy$}) async {
  try {
    Future<void> healthCheck() async {
      await Future.delayed(const Duration(microseconds: 10));
      if (destroy$?.isCompleted == true) {
        throw ArgumentError('Kill thread');
      }
    }

    /// Finds the bounding box of the non-transparent area in the given [image].
    ///
    /// Returns a [BoundingBox] object representing the coordinates and
    /// dimensions of the bounding box.
    Future<_BoundingBox> findBoundingBox(img.Image image) async {
      int left = image.width;
      int right = 0;
      int top = image.height;
      int bottom = 0;
      if (res.generateOnlyImageBounds) {
        bool found = false;
        // Find top boundary
        for (int y = 0; y < image.height && !found; y++) {
          for (int x = 0; x < image.width; x++) {
            var pixel = image.getPixel(x, y);
            if (pixel.a != 0) {
              top = y;
              found = true;
              break;
            }
          }
        }

        await healthCheck();

        found = false;
        // Find bottom boundary
        for (int y = image.height - 1; y >= top && !found; y--) {
          for (int x = 0; x < image.width; x++) {
            var pixel = image.getPixel(x, y);
            if (pixel.a != 0) {
              bottom = y;
              found = true;
              break;
            }
          }
        }
        bottom = bottom.clamp(top, image.height);

        await healthCheck();

        found = false;
        // Find left boundary
        for (int x = 0; x < image.width && !found; x++) {
          for (int y = top; y <= bottom; y++) {
            var pixel = image.getPixel(x, y);
            if (pixel.a != 0) {
              left = x;
              found = true;
              break;
            }
          }
        }
        left = left.clamp(0, image.width);

        await healthCheck();

        found = false;
        // Find right boundary
        for (int x = image.width - 1; x >= left && !found; x--) {
          for (int y = top; y <= bottom; y++) {
            var pixel = image.getPixel(x, y);
            if (pixel.a != 0) {
              right = x;
              found = true;
              break;
            }
          }
        }
        right = right.clamp(left, image.width);
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

    // Crop the image to the bounding box
    Future<img.Image> resizeCropRect(
      img.Image src, {
      required int left,
      required int top,
      required int width,
      required int height,
      num radius = 0,
      bool antialias = true,
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
            img.Image.fromResized(frame,
                width: width, height: height, noAnimation: true);
        firstFrame ??= dst;

        for (int y = 0; y < height; y++) {
          int topY = top + y;
          for (int x = 0; x < width; x++) {
            var pixel = frame.getPixel(left + x, topY);
            dst.setPixelRgba(x, y, pixel.r, pixel.g, pixel.b, pixel.a);
          }

          if (y % 100 == 0) {
            await healthCheck();
          }
        }
      }

      return firstFrame!;
    }

    // Find the bounding box of the non-transparent area
    final bbox = await findBoundingBox(res.image);

    await healthCheck();

    final croppedImage = res.generateOnlyImageBounds
        ? await resizeCropRect(
            res.image,
            left: bbox.left,
            top: bbox.top,
            width: bbox.width,
            height: bbox.height,
          )
        : res.image;

    await healthCheck();

    Uint8List bytes = await encodeImage(
      image: croppedImage,
      outputFormat: res.outputFormat,
      singleFrame: res.singleFrame,
      jpegQuality: res.jpegQuality,
      jpegChroma: res.jpegChroma,
      pngFilter: res.pngFilter,
      pngLevel: res.pngLevel,
      destroy$: destroy$,
    );

    return ThreadResponse(
      bytes: bytes,
      id: res.id,
    );
  } catch (e) {
    return ThreadResponse(
      bytes: null,
      id: res.id,
    );
  }
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
