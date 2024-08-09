// Dart imports:
import 'dart:typed_data';
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/content_recorder_controller.dart';
import 'package:pro_image_editor/utils/unique_id_generator.dart';

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
    processorConfigs: ProcessorConfigs(
      processorMode: ProcessorMode.minimum,
    ),
  ),
}) async {
  var recorder = ContentRecorderController(
    configs: ProImageEditorConfigs(
      imageGenerationConfigs: configs.copyWith(
        processorConfigs: configs.processorConfigs.copyWith(
          processorMode: ProcessorMode.minimum,
        ),
      ),
    ),
  );

  var bytes = await recorder.chooseCaptureMode(
    image: image,
    id: generateUniqueId(),
  );
  await recorder.destroy();

  if (context != null && context.mounted && bytes != null) {
    await precacheImage(MemoryImage(bytes), context);
  }

  return bytes;
}
