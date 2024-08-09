// Package imports:
import 'package:image/image.dart' as img;
import 'package:image/image.dart' show JpegChroma, PngFilter;

// Project imports:
import 'package:pro_image_editor/models/editor_configs/image_generation_configs/output_formats.dart';

/// Represents an image object sent from the main thread.
class ImageConvertThreadRequest extends ThreadRequest {
  /// Constructor for creating an ImageConvertThreadRequest instance.
  const ImageConvertThreadRequest({
    required this.generateOnlyImageBounds,
    required super.id,
    required super.image,
    required super.outputFormat,
    required super.singleFrame,
    required super.pngLevel,
    required super.pngFilter,
    required super.jpegQuality,
    required super.jpegChroma,
  });

  /// Specifies whether only the bounds of the image should be generated.
  final bool generateOnlyImageBounds;
}

/// Represents a raw object sent from the main thread.
class ThreadRequest {
  /// Constructs an [ImageConvertThreadRequest] instance.
  ///
  /// All parameters are required.
  const ThreadRequest({
    required this.id,
    required this.image,
    required this.singleFrame,
    required this.pngLevel,
    required this.outputFormat,
    required this.pngFilter,
    required this.jpegQuality,
    required this.jpegChroma,
  });

  /// The unique identifier for this task.
  final String id;

  /// The image object from the `image` package.
  final img.Image image;

  /// Specifies the output format for the generated image.
  final OutputFormat outputFormat;

  /// Specifies whether single frame generation is enabled for the output
  /// formats PNG, TIFF, CUR, PVR, and ICO.
  final bool singleFrame;

  /// Specifies the compression level for PNG images. Ranges from 0 to 9.
  final int pngLevel;

  /// Specifies the filter method for optimizing PNG compression.
  final PngFilter pngFilter;

  /// Specifies the quality level for JPEG images. Ranges from 2 to 100.
  final int jpegQuality;

  /// Specifies the chroma subsampling method for JPEG images.
  final JpegChroma jpegChroma;
}
