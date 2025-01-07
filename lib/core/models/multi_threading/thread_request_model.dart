// Package imports:
import 'package:image/image.dart' as img;
import 'package:image/image.dart' show JpegChroma, PngFilter;

import '../editor_configs/image_generation_configs/output_formats.dart';

/// Represents an image object sent from the main thread.
class ImageConvertThreadRequest extends ThreadRequest {
  /// Constructor for creating an ImageConvertThreadRequest instance.
  const ImageConvertThreadRequest({
    required super.generateOnlyImageBounds,
    required super.id,
    required super.image,
    required super.outputFormat,
    required super.singleFrame,
    required super.pngLevel,
    required super.pngFilter,
    required super.jpegQuality,
    required super.jpegChroma,
  });

  @override
  String get mode => 'convert';
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
    this.generateOnlyImageBounds,
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

  /// Specifies whether only the bounds of the image should be generated.
  final bool? generateOnlyImageBounds;

  /// A getter that returns the operation mode of the request.
  ///
  /// This is set to `'encode'` by default, indicating that the operation
  /// is intended for encoding the image.
  String get mode => 'encode';

  /// Converts the [ThreadWebRequest] instance into a `Map<String, dynamic>`
  /// representation.
  ///
  /// This method serializes the request's properties into a map for easier
  /// data transfer or conversion to formats like JSON.
  ///
  /// The resulting map contains the following key-value pairs:
  /// - `'id'`: The unique identifier of the request.
  /// - `'mode'`: The mode of the operation (fixed to `'encode'`).
  /// - `'generateOnlyImageBounds'`: Always `null`, as it is not used in this
  ///   operation.
  /// - `'outputFormat'`: The output format of the image
  ///    (e.g., `'png'`, `'jpeg'`).
  /// - `'jpegChroma'`: The chroma subsampling mode for JPEG format
  ///    (e.g., `'yuv444'`).
  /// - `'pngFilter'`: The PNG filter type used for compression.
  /// - `'jpegQuality'`: An `int` specifying the JPEG quality (0–100).
  /// - `'pngLevel'`: An `int` specifying the PNG compression level (0–9).
  /// - `'singleFrame'`: A `bool` indicating whether to process a single frame
  ///    only.
  /// - `'image'`: A `Map<String, dynamic>` representation of the image, created
  ///   using [imageToMap].
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mode': mode,
      'generateOnlyImageBounds': null,
      'outputFormat': outputFormat.name,
      'jpegChroma': jpegChroma.name,
      'pngFilter': pngFilter.name,
      'jpegQuality': jpegQuality,
      'pngLevel': pngLevel,
      'singleFrame': singleFrame,
      'image': imageToMap(),
    };
  }

  /// Converts the [image] property into a `Map<String, dynamic>`
  ///     representation.
  ///
  /// The resulting map includes metadata and buffer data for the image:
  /// - `'buffer'`: The raw bytes of the image.
  /// - `'width'`: The width of the image in pixels.
  /// - `'height'`: The height of the image in pixels.
  /// - `'textData'`: A map of any text-based metadata associated with the
  ///     image.
  /// - `'frameDuration'`: The duration of the frame in milliseconds
  ///    (if applicable).
  /// - `'frameIndex'`: The index of the frame (for multi-frame images).
  /// - `'loopCount'`: The number of times the animation loops
  ///    (for animated images).
  /// - `'numChannels'`: The number of color channels in the image
  ///    (e.g., 3 for RGB).
  /// - `'rowStride'`: The number of bytes in a single row of the image.
  /// - `'frameType'`: The type of frame (e.g., `'sequence'`, `'key'`).
  /// - `'format'`: The format of the image (e.g., `'uint8'`, `'float32'`).
  Map<String, dynamic> imageToMap() {
    return {
      'buffer': image.buffer,
      'width': image.width,
      'height': image.height,
      'textData': image.textData,
      'frameDuration': image.frameDuration,
      'frameIndex': image.frameIndex,
      'loopCount': image.loopCount,
      'numChannels': image.numChannels,
      'rowStride': image.rowStride,
      'frameType': image.frameType.name,
      'format': image.format.name,
    };
  }

  /// Converts the `ThreadWebRequest` instance into an
  /// `ImageConvertThreadRequest`.
  ///
  /// This method is used to transform the incoming request object into a
  /// format that is processed by image conversion threads. It maps all
  /// properties, including ID, image data, and various configuration
  /// parameters related to encoding, such as JPEG quality, PNG filter levels,
  /// and output formats.
  ///
  /// Returns:
  /// - `ImageConvertThreadRequest`: A new request object containing the same
  ///   data but structured for internal conversion processes.
  ImageConvertThreadRequest toConvertThreadRequest() {
    return ImageConvertThreadRequest(
      id: id,
      generateOnlyImageBounds: generateOnlyImageBounds,
      jpegChroma: jpegChroma,
      jpegQuality: jpegQuality,
      pngFilter: pngFilter,
      pngLevel: pngLevel,
      singleFrame: singleFrame,
      outputFormat: outputFormat,
      image: image,
    );
  }
}
