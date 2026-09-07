import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/shared/services/content_recorder/controllers/content_recorder_controller.dart';

/// Generates a high-quality image from the provided [ui.Image].
///
/// - [image]: The input [ui.Image] that needs to be processed.
/// - [configs]: Optional configurations for the image editor,
///   defaults to [ProImageEditorConfigs].
/// - [context]: The BuildContext allow to precache the image.
///
/// Returns a [Future] that resolves to a [Uint8List] containing the
/// high-quality image data, or `null` if the image generation fails.
///
/// Example usage:
/// ```dart
/// Uint8List? highQualityImage = await generateHighQualityImage(myImage);
/// ```
Future<Uint8List?> generateHighQualityImage(
  ui.Image image, {
  BuildContext? context,
  ImageGenerationConfigs configs = const ImageGenerationConfigs(
    outputFormat: OutputFormat.png,
    maxOutputSize: Size.infinite,
    processorConfigs: ProcessorConfigs(processorMode: ProcessorMode.minimum),
  ),
}) async {
  var recorder = ContentRecorderController(
    isVideoEditor: false,
    configs: configs.copyWith(
      processorConfigs: configs.processorConfigs.copyWith(
        processorMode: ProcessorMode.minimum,
      ),
    ),
  );

  var bytes = await recorder.convertRawImageData(image: image);
  await recorder.destroy();

  if (context != null && context.mounted && bytes != null) {
    await precacheImage(MemoryImage(bytes), context);
  }

  return bytes;
}
