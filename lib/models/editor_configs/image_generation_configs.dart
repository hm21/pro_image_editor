import 'package:flutter/foundation.dart';

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
  /// Refer to the `ProcessorConfigs` class for detailed information on available configuration settings.
  final ProcessorConfigs processorConfigs;

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
    this.customPixelRatio,
    this.processorConfigs = const ProcessorConfigs(),
  });
}

/// Configuration class for managing processor settings.
class ProcessorConfigs {
  /// The number of background processors to use.
  ///
  /// Must be a positive integer. Defaults to 2.
  ///
  /// Ignored if [processorMode] is [ProcessorMode.auto], [ProcessorMode.maximum], or [ProcessorMode.minimum].
  final int numberOfBackgroundProcessors;

  /// The maximum concurrency level.
  ///
  /// Must be a positive integer. Defaults to 2.
  ///
  /// Ignored if [processorMode] is [ProcessorMode.minimum] or if the platform is `Web`.
  final int maxConcurrency;

  /// The mode in which processors will operate.
  ///
  /// Defaults to [ProcessorMode.auto].
  final ProcessorMode processorMode;

  /// Creates a new instance of [ProcessorConfigs] with the given settings.
  ///
  /// The [numberOfBackgroundProcessors] must be a positive integer.
  /// The [maxBackgroundProcessors] must be greater than or equal to [numberOfBackgroundProcessors].
  /// The [maxConcurrency] must be a positive integer.
  /// The [processorMode] defaults to [ProcessorMode.auto].
  const ProcessorConfigs({
    this.numberOfBackgroundProcessors = 2,
    this.maxConcurrency = 2,
    this.processorMode = ProcessorMode.auto,
  })  : assert(numberOfBackgroundProcessors > 0,
            'minBackgroundProcessors must be positive'),
        assert(maxConcurrency > 0, 'maxConcurrency must be positive');
}

enum ProcessorMode {
  /// Automatically utilizes an optimal number of background processors.
  ///
  /// The [numberOfBackgroundProcessors] setting will be ignored.
  ///
  /// In Dart native, if there are too many tasks, it will automatically spawn new isolates.
  ///
  /// In Dart web, it ignores [maxConcurrency] and may overload the processor if too many tasks are incoming.
  auto,

  /// Uses the specified [numberOfBackgroundProcessors].
  ///
  /// In Dart native, if the limit specified by [maxConcurrency] is reached, it will terminate all active processors
  /// and respawn them.
  ///
  /// In Dart web, it ignores [maxConcurrency] and may overload the processor if too many tasks are incoming.
  limit,

  /// Utilizes all available processors.
  ///
  /// Be cautious, as this can negatively affect performance.
  ///
  /// It ignores [maxConcurrency] and may overload the processor if too many tasks are incoming.
  maximum,

  /// Uses only one processor.
  ///
  /// It ignores [maxConcurrency] and may overload the processor if too many tasks are incoming.
  minimum,
}
