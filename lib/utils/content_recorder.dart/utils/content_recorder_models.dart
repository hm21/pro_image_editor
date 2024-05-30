// Dart imports:
import 'dart:typed_data';

// Package imports:
import 'package:image/image.dart' as img;
import 'package:image/image.dart' show JpegChroma, PngFilter;

// Project imports:
import 'package:pro_image_editor/models/editor_configs/image_generation_configs/output_formats.dart';

/// Helper class to manage image metadata and pixel data.
class RemoveHelper {
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

  /// Constructs a [RemoveHelper] instance.
  ///
  /// All parameters are required.
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

/// Represents a bounding box in terms of its position (left and top) and size (width and height).
class BoundingBox {
  /// The x-coordinate of the top-left corner of the bounding box.
  final int left;

  /// The y-coordinate of the top-left corner of the bounding box.
  final int top;

  /// The width of the bounding box.
  final int width;

  /// The height of the bounding box.
  final int height;

  /// Constructs a [BoundingBox] instance.
  BoundingBox(this.left, this.top, this.width, this.height);
}

/// Represents an image object sent from the main thread.
class ImageFromMainThread extends RawFromMainThread {
  /// Specifies whether only the bounds of the image should be generated.
  final bool generateOnlyImageBounds;

  const ImageFromMainThread({
    required this.generateOnlyImageBounds,
    required super.completerId,
    required super.image,
    required super.outputFormat,
    required super.singleFrame,
    required super.pngLevel,
    required super.pngFilter,
    required super.jpegQuality,
    required super.jpegChroma,
  });
}

class RawFromMainThread {
  /// The unique identifier for the completer.
  final String completerId;

  /// The image object from the `image` package.
  final img.Image image;

  /// Specifies the output format for the generated image.
  final OutputFormat outputFormat;

  /// Specifies whether single frame generation is enabled for the output formats PNG, TIFF, CUR, PVR, and ICO.
  final bool singleFrame;

  /// Specifies the compression level for PNG images. Ranges from 0 to 9.
  final int pngLevel;

  /// Specifies the filter method for optimizing PNG compression.
  final PngFilter pngFilter;

  /// Specifies the quality level for JPEG images. Ranges from 2 to 100.
  final int jpegQuality;

  /// Specifies the chroma subsampling method for JPEG images.
  final JpegChroma jpegChroma;

  /// Constructs an [ImageFromMainThread] instance.
  ///
  /// All parameters are required.
  const RawFromMainThread({
    required this.completerId,
    required this.image,
    required this.singleFrame,
    required this.pngLevel,
    required this.outputFormat,
    required this.pngFilter,
    required this.jpegQuality,
    required this.jpegChroma,
  });
}

/// Represents a response containing image data from the image processing thread.
class ResponseFromImageThread {
  /// The unique identifier for the completer.
  final String completerId;

  /// The byte data of the image, can be null.
  final Uint8List? bytes;

  /// Constructs a [ResponseFromImageThread] instance.
  ///
  /// All parameters are required.
  const ResponseFromImageThread({
    required this.completerId,
    required this.bytes,
  });
}
