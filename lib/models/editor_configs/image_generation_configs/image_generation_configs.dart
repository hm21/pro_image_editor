// Flutter imports:
import 'dart:ui';

import 'package:flutter/foundation.dart';

// Package imports:
import 'package:image/image.dart' show JpegChroma, PngFilter;

// Project imports:
import 'output_formats.dart';
import 'processor_configs.dart';

export 'output_formats.dart';
export 'processor_configs.dart';
export 'package:image/image.dart' show JpegChroma, PngFilter;

/// Configuration settings for image generation.
///
/// [ImageGeneratioConfigs] holds various configuration options
/// that affect how images are generated.
class ImageGeneratioConfigs {
  /// Determines whether to capture only the content within the boundaries of the image when editing is complete.
  ///
  /// If set to `true`, editing completion will result in cropping all content outside the image boundaries.
  ///
  /// Setting this property to `true` is useful when you want to focus on the image content and exclude any surrounding elements.
  /// Setting this property to `false` is useful when you want to capture the full content.
  ///
  /// By default, this property is set to `true`.
  final bool generateOnlyImageBounds;

  /// Captures the final image after each change, such as adding a layer.
  /// This significantly speeds up the editor because in most cases, the image is already created when the user presses "done".
  ///
  /// On Dart native platforms (all platforms except web), this runs on an isolate thread.
  /// On Dart web, it runs on a web worker.
  ///
  /// This option is enabled by default unless we are in debug mode or the platform is web.
  final bool generateImageInBackground;

  /// Allows image generation to run in an isolated thread, preventing any impact on the UI.
  /// On web platforms, this will run in a separate web worker.
  ///
  /// Enabling this feature will significantly speed up the image creation process.
  ///
  /// If this is disabled, `captureImagesInBackground` will also be disabled.
  final bool generateIsolated;

  /// Whether the callback `onImageEditingComplete` call with empty editing.
  ///
  /// The default value is true.
  ///
  /// This option only affects the main editor and does not work in standalone editors.
  ///
  /// <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/schema_callbacks.jpeg?raw=true" alt="Schema" height="500px" />
  final bool allowEmptyEditCompletion;

  /// This option is only required when using packages such as Asuka that display dialogs without context.
  /// When enabled, it ensures that the loading dialog's context is generated properly to prevent internal issues.
  final bool awaitLoadingDialogContext;

  /// The pixel ratio of the image relative to the content.
  ///
  /// Normally, you do not need to set any value here as the editor detects the pixel ratio automatically from the image.
  /// Only set a value here if you have a movable background, which may require a custom pixel ratio for proper scaling.
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
  /// where 1 indicates the lowest quality and 100 indicates the highest quality.
  final int jpegQuality;

  final Size maxOutputDimension;

  /// Specifies the chroma subsampling method for JPEG images. It defines the
  /// compression ratio for chrominance components.
  final JpegChroma jpegChroma;

  /// Creates a new instance of [ImageGeneratioConfigs].
  ///
  /// - The [allowEmptyEditCompletion] parameter controls if empty edit completions are allowed.
  /// - The [generateIsolated] parameter controls if image generation occurs inside an isolate.
  /// - The [generateImageInBackground] parameter controls if image generation runs in the background.
  /// - The [generateOnlyImageBounds] parameter controls if only image bounds are generated.
  /// - The [customPixelRatio] parameter set the pixel ratio of the image relative to the content.
  /// - The [processorConfigs] parameter set the processor configs.
  const ImageGeneratioConfigs({
    this.allowEmptyEditCompletion = true,
    this.generateIsolated = true,
    this.generateImageInBackground = !kIsWeb || !kDebugMode,
    this.generateOnlyImageBounds = true,
    this.awaitLoadingDialogContext = false,
    this.singleFrame = false,
    this.customPixelRatio,
    this.pngLevel = 6,
    this.pngFilter = PngFilter.none,
    this.jpegQuality = 100,
    this.jpegChroma = JpegChroma.yuv444,
    this.outputFormat = OutputFormat.jpg,
    this.processorConfigs = const ProcessorConfigs(),
    this.maxOutputDimension = const Size(2000, 2000),
  }) : assert(jpegQuality > 0 && jpegQuality <= 100,
            'Jpeg quality must be between 1 and 100');
}
