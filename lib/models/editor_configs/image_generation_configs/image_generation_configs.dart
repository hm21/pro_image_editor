import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' show JpegChroma, PngFilter;

import 'output_formats.dart';
import 'processor_configs.dart';

export 'package:image/image.dart' show JpegChroma, PngFilter;
export 'output_formats.dart';
export 'processor_configs.dart';

/// Configuration settings for image generation.
///
/// [ImageGenerationConfigs] holds various configuration options
/// that affect how images are generated.
class ImageGenerationConfigs {
  /// Creates a new instance of [ImageGenerationConfigs].
  ///
  /// - The [allowEmptyEditCompletion] parameter controls if empty edit
  ///   completions are allowed.
  /// - The [generateInsideSeparateThread] parameter controls if image
  ///   generation occurs inside an isolate.
  /// - The [generateImageInBackground] parameter controls if image generation
  ///   runs in the background.
  /// - The [captureOnlyDrawingBounds] parameter controls if only image
  ///   bounds are generated.
  /// - The [customPixelRatio] parameter set the pixel ratio of the image
  ///   relative to the content.
  /// - The [processorConfigs] parameter set the processor configs.
  const ImageGenerationConfigs({
    this.captureOnlyBackgroundImageArea = true,
    this.allowEmptyEditCompletion = true,
    this.generateInsideSeparateThread = true,
    this.generateImageInBackground = !kIsWeb || !kDebugMode,
    this.captureOnlyDrawingBounds = true,
    this.customPixelRatio,
    this.pngLevel = 6,
    this.pngFilter = PngFilter.none,
    this.singleFrame = false,
    this.jpegQuality = 100,
    this.jpegChroma = JpegChroma.yuv444,
    this.outputFormat = OutputFormat.jpg,
    this.processorConfigs = const ProcessorConfigs(),
    this.maxOutputSize = const Size(2000, 2000),
    this.maxThumbnailSize = const Size(100, 100),
  })  : assert(jpegQuality > 0 && jpegQuality <= 100,
            'jpegQuality must be between 1 and 100'),
        assert(
            captureOnlyDrawingBounds || !captureOnlyBackgroundImageArea,
            'When [captureOnlyDrawingBounds] is true must '
            '[captureOnlyBackgroundImageArea] be false'),
        assert(
            pngLevel >= 0 && pngLevel <= 9, 'pngLevel must be between 0 and 9'),
        assert(customPixelRatio == null || customPixelRatio > 0,
            'customPixelRatio must be greater than 0');

  /// Indicates if it should only capture the background image area and cut all
  /// stuff outside, such as when a layer overlaps the image.
  ///
  /// When set to `true`, this flag ensures that the capture process focuses
  /// solely on the background image area, ignoring any other elements that
  /// might be present.
  ///
  /// If set to `false`, the capture will include all elements within the image
  /// area, not just the background.
  ///
  /// **Note:** If you disable this flag, it may require more performance to
  /// generate the image, especially on high resolution images in a large
  /// screen, cuz the editor need to find the bounding box by itself.
  final bool captureOnlyBackgroundImageArea;

  /// Determines whether to capture only the content within the boundaries of
  /// the painting when editing is complete.
  ///
  /// If set to `true`, editing completion will result in cropping all content
  /// outside the image boundaries.
  ///
  /// Setting this property to `true` is useful when you want to focus on the
  /// image content and exclude any surrounding elements.
  /// Setting this property to `false` is useful when you want to capture the
  /// full content.
  ///
  /// By default, this property is set to `true`.
  final bool captureOnlyDrawingBounds;

  /// Captures the final image after each change, such as adding a layer.
  /// This significantly speeds up the editor because in most cases, the image
  /// is already created when the user presses "done".
  ///
  /// On Dart native platforms (all platforms except web), this runs on an
  /// isolate thread.
  /// On Dart web, it runs on a web worker.
  ///
  /// This option is enabled by default unless we are in debug mode or the
  /// platform is web.
  final bool generateImageInBackground;

  /// Allows image generation to run in an isolated thread, preventing any
  /// impact on the UI.
  /// On web platforms, this will run in a separate web worker.
  ///
  /// Enabling this feature will significantly speed up the image creation
  /// process.
  ///
  /// If this is disabled, `captureImagesInBackground` will also be disabled.
  final bool generateInsideSeparateThread;

  /// Whether the callback `onImageEditingComplete` call with empty editing.
  ///
  /// The default value is true.
  ///
  /// This option only affects the main editor and does not work in standalone
  /// editors.
  ///
  /// <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/schema_callbacks.jpeg?raw=true" alt="Schema" height="500px" />
  final bool allowEmptyEditCompletion;

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
    bool? captureOnlyBackgroundImageArea,
    bool? allowEmptyEditCompletion,
    bool? generateInsideSeparateThread,
    bool? generateImageInBackground,
    bool? captureOnlyDrawingBounds,
    bool? awaitLoadingDialogContext,
    double? customPixelRatio,
    ProcessorConfigs? processorConfigs,
    OutputFormat? outputFormat,
    bool? singleFrame,
    int? pngLevel,
    PngFilter? pngFilter,
    int? jpegQuality,
    Size? maxOutputSize,
    Size? maxThumbnailSize,
    JpegChroma? jpegChroma,
  }) {
    return ImageGenerationConfigs(
      captureOnlyBackgroundImageArea:
          captureOnlyBackgroundImageArea ?? this.captureOnlyBackgroundImageArea,
      allowEmptyEditCompletion:
          allowEmptyEditCompletion ?? this.allowEmptyEditCompletion,
      generateInsideSeparateThread:
          generateInsideSeparateThread ?? this.generateInsideSeparateThread,
      generateImageInBackground:
          generateImageInBackground ?? this.generateImageInBackground,
      captureOnlyDrawingBounds:
          captureOnlyDrawingBounds ?? this.captureOnlyDrawingBounds,
      customPixelRatio: customPixelRatio ?? this.customPixelRatio,
      processorConfigs: processorConfigs ?? this.processorConfigs,
      outputFormat: outputFormat ?? this.outputFormat,
      singleFrame: singleFrame ?? this.singleFrame,
      pngLevel: pngLevel ?? this.pngLevel,
      pngFilter: pngFilter ?? this.pngFilter,
      jpegQuality: jpegQuality ?? this.jpegQuality,
      maxOutputSize: maxOutputSize ?? this.maxOutputSize,
      maxThumbnailSize: maxThumbnailSize ?? this.maxThumbnailSize,
      jpegChroma: jpegChroma ?? this.jpegChroma,
    );
  }
}
