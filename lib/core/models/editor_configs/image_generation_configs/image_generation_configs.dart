import 'dart:ui';

import 'package:flutter/foundation.dart';

import '/plugins/image/src/formats/jpeg/jpeg_chroma.dart';
import '/plugins/image/src/formats/png/png_filter.dart';
import 'output_formats.dart';
import 'processor_configs.dart';

export '/plugins/image/src/formats/jpeg/jpeg_chroma.dart';
export '/plugins/image/src/formats/png/png_filter.dart';
export 'output_formats.dart';
export 'processor_configs.dart';

/// Configuration settings for image generation.
///
/// [ImageGenerationConfigs] holds various configuration options
/// that affect how images are generated.
class ImageGenerationConfigs {
  /// Creates a new instance of [ImageGenerationConfigs].
  const ImageGenerationConfigs({
    this.cropToImageBounds = true,
    this.cropToDrawingBounds = true,
    this.allowEmptyEditingCompletion = true,
    this.enableIsolateGeneration = true,
    this.enableBackgroundGeneration = !kIsWeb || !kDebugMode,
    this.enableUseOriginalBytes = true,
    this.singleFrame = false,
    this.captureImageByteFormat = ImageByteFormat.rawRgba,
    this.customPixelRatio,
    this.jpegQuality = 100,
    this.pngLevel = 6,
    this.pngFilter = PngFilter.none,
    this.jpegChroma = JpegChroma.yuv444,
    this.jpegBackgroundColor = const Color(0xFFFFFFFF),
    this.outputFormat = OutputFormat.jpg,
    this.processorConfigs = const ProcessorConfigs(),
    this.maxOutputSize = const Size(2000, 2000),
    this.maxThumbnailSize = const Size(100, 100),
  })  : assert(jpegQuality > 0 && jpegQuality <= 100,
            'jpegQuality must be between 1 and 100'),
        assert(
            pngLevel >= 0 && pngLevel <= 9, 'pngLevel must be between 0 and 9'),
        assert(customPixelRatio == null || customPixelRatio > 0,
            'customPixelRatio must be greater than 0'),
        assert(
            captureImageByteFormat != ImageByteFormat.png,
            'ImageByteFormat.png is not supported. '
            'Use rawRgba or rawStraightRgba instead.');

  /// Indicates if it should only capture the background image area and cut all
  /// stuff outside, such as when a layer overlaps the image.
  ///
  /// When set to `true`, this flag ensures that the capture process focuses
  /// on the image area and crop everything outside.
  ///
  /// If set to `false`, the capture will include all elements even when they
  /// are outside of the image.
  ///
  /// **Note:** If you disable this flag, it may require more performance to
  /// generate the image, especially on high resolution images in a large
  /// screen, cuz the editor need to find the bounding box by itself.
  ///
  /// By default, this property is set to `true`.
  final bool cropToImageBounds;

  /// Determines whether to crop the final image to the bounds of the drawing
  /// area.
  ///
  /// - If `true`, the output image will be cropped to include only the drawn
  ///   content, removing any empty or surrounding areas.
  /// - If `false`, the full image, including any blank space around the
  ///   drawings, will be retained.
  ///
  /// Enabling this is useful when you want to focus solely on the drawn
  /// content.
  /// Disabling it ensures the entire canvas, including unused space, is
  /// preserved.
  ///
  /// This option has only an effect when `cropToImageBounds` is `false`.
  ///
  /// **Default:** `true`
  final bool cropToDrawingBounds;

  /// Captures the image after each modification, such as adding a layer.
  /// This improves editor performance by ensuring the image is pre-generated
  /// in most cases before the user presses "Done."
  ///
  /// - On Dart native platforms (all except web), this runs in an isolate
  /// thread.
  /// - On Dart web, it runs in a web worker.
  ///
  /// **Default:** `!kIsWeb || !kDebugMode`
  final bool enableBackgroundGeneration;

  /// Allows image generation to run in an isolated thread, preventing any
  /// impact on the UI.
  /// On web platforms, this will run in a separate web worker.
  ///
  /// Enabling this feature will significantly speed up the image creation
  /// process.
  ///
  /// If this is disabled, `enableBackgroundGeneration` will also be disabled.
  final bool enableIsolateGeneration;

  /// Whether the callback `onImageEditingComplete` call with empty editing.
  ///
  /// The default value is `true`.
  ///
  /// This option only affects the main editor and does not work in standalone
  /// editors.
  ///
  /// <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/schema_capture_image.jpeg?raw=true" alt="Schema" height="500px" />
  final bool allowEmptyEditingCompletion;

  /// When disabled, this flag allows the editor to re-record the original
  /// image even if there are no changes made. This is useful when
  /// the editor use `bodyItemsRecorded` inside `customWidgets`.
  ///
  /// If `true`, the editor will skip re-recording when no changes are
  /// detected, optimizing performance.
  ///
  /// **Default**: `true`
  final bool enableUseOriginalBytes;

  /// The byte format used when capturing images for processing.
  ///
  /// Available options:
  /// - `ImageByteFormat.rawStraightRgba` (default): Non-premultiplied alpha.
  ///   Prevents black border artifacts around transparent edges. Recommended
  ///   for PNG output or any format that preserves transparency.
  /// - `ImageByteFormat.rawRgba`: Premultiplied alpha. May be slightly faster
  ///   but can cause dark fringing around semi-transparent edges.
  /// - `ImageByteFormat.png`: Encodes directly to PNG format.
  /// - `ImageByteFormat.rawExtendedRgba128`: Extended range RGBA.
  /// - `ImageByteFormat.rawUnmodified`: Platform-specific unmodified format.
  ///
  /// **Default**: `ImageByteFormat.rawStraightRgba`
  final ImageByteFormat captureImageByteFormat;

  /// The pixel ratio of the image relative to the content.
  ///
  /// Normally, you do not need to set any value here as the editor detects the
  /// pixel ratio automatically from the image.
  /// Only set a value here if you have a movable background, which may require
  /// a custom pixel ratio for proper scaling.
  final double? customPixelRatio;

  /// Configuration settings for the processor.
  ///
  /// Use this property to customize various processing options.
  /// Refer to the `ProcessorConfigs` class for detailed information on
  /// available configuration settings.
  final ProcessorConfigs processorConfigs;

  /// Specifies the output format for the generated image.
  final OutputFormat outputFormat;

  /// Specifies whether single frame generation is enabled for the output
  /// formats PNG, TIFF, CUR, PVR, and ICO.
  /// The default value is `false`.
  final bool singleFrame;

  /// Specifies the compression level for PNG images. It ranges from 0 to 9,
  /// where 0 indicates no compression and 9 indicates maximum compression.
  final int pngLevel;

  /// Specifies the filter method for optimizing PNG compression. It determines
  /// how scanline filtering is applied.
  final PngFilter pngFilter;

  /// Specifies the quality level for JPEG images. It ranges from 1 to 100,
  /// where 1 indicates the lowest quality and 100 indicates the highest
  /// quality.
  final int jpegQuality;

  /// The background color used when generating JPEG images.
  /// This color is applied to areas of the image that are transparent,
  /// as JPEG format does not support transparency.
  final Color jpegBackgroundColor;

  /// The maximum output size for the image. It will maintain the image's aspect
  /// ratio but will fit within the specified constraints, similar to
  /// `BoxFit.contain`.
  final Size maxOutputSize;

  /// The maximum output size for the thumbnail image. It will maintain the
  /// image's aspect ratio but will fit within the specified constraints,
  /// similar to `BoxFit.contain`.
  ///
  /// This option is useful if you have a high-resolution image that typically
  /// takes a long time to generate, but you need to display it quickly.
  ///
  /// This option only works when the `onThumbnailGenerated` callback is set.
  /// It will disable the `onImageEditingComplete` callback.
  final Size maxThumbnailSize;

  /// Specifies the chroma subsampling method for JPEG images. It defines the
  /// compression ratio for chrominance components.
  final JpegChroma jpegChroma;

  /// Creates a copy of this object with the given fields replaced with the new
  /// values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [ImageGenerationConfigs] with some properties updated while keeping the
  /// others unchanged.
  ImageGenerationConfigs copyWith({
    bool? cropToImageBounds,
    bool? cropToDrawingBounds,
    bool? enableBackgroundGeneration,
    bool? enableIsolateGeneration,
    bool? allowEmptyEditingCompletion,
    bool? enableUseOriginalBytes,
    ImageByteFormat? captureImageByteFormat,
    double? customPixelRatio,
    ProcessorConfigs? processorConfigs,
    OutputFormat? outputFormat,
    bool? singleFrame,
    int? pngLevel,
    PngFilter? pngFilter,
    int? jpegQuality,
    Color? jpegBackgroundColor,
    Size? maxOutputSize,
    Size? maxThumbnailSize,
    JpegChroma? jpegChroma,
  }) {
    return ImageGenerationConfigs(
      cropToImageBounds: cropToImageBounds ?? this.cropToImageBounds,
      cropToDrawingBounds: cropToDrawingBounds ?? this.cropToDrawingBounds,
      enableBackgroundGeneration:
          enableBackgroundGeneration ?? this.enableBackgroundGeneration,
      enableIsolateGeneration:
          enableIsolateGeneration ?? this.enableIsolateGeneration,
      allowEmptyEditingCompletion:
          allowEmptyEditingCompletion ?? this.allowEmptyEditingCompletion,
      enableUseOriginalBytes:
          enableUseOriginalBytes ?? this.enableUseOriginalBytes,
      captureImageByteFormat:
          captureImageByteFormat ?? this.captureImageByteFormat,
      customPixelRatio: customPixelRatio ?? this.customPixelRatio,
      processorConfigs: processorConfigs ?? this.processorConfigs,
      outputFormat: outputFormat ?? this.outputFormat,
      singleFrame: singleFrame ?? this.singleFrame,
      pngLevel: pngLevel ?? this.pngLevel,
      pngFilter: pngFilter ?? this.pngFilter,
      jpegQuality: jpegQuality ?? this.jpegQuality,
      jpegBackgroundColor: jpegBackgroundColor ?? this.jpegBackgroundColor,
      maxOutputSize: maxOutputSize ?? this.maxOutputSize,
      maxThumbnailSize: maxThumbnailSize ?? this.maxThumbnailSize,
      jpegChroma: jpegChroma ?? this.jpegChroma,
    );
  }
}
