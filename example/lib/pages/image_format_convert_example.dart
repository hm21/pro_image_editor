// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '../utils/example_constants.dart';
import '../utils/example_helper.dart';

class ImageFormatConvertExample extends StatefulWidget {
  const ImageFormatConvertExample({super.key});

  @override
  State<ImageFormatConvertExample> createState() =>
      _ImageFormatConvertExampleState();
}

class _ImageFormatConvertExampleState extends State<ImageFormatConvertExample>
    with ExampleHelperState<ImageFormatConvertExample> {
  Future<void> _convertImage(Uint8List bytes) async {
    try {
      /// FlutterImageCompress is not supported for windows and linux,
      /// so we use the package `image` to convert the bytes.
      if (!kIsWeb && (Platform.isLinux || Platform.isWindows)) {
        _convertDart(bytes);
      } else {
        await _convertNative(bytes);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Supports only Android, iOS, Web, MacOS
  Future<void> _convertNative(Uint8List bytes) async {
    contentType = 'image/jpeg';
    final result = await FlutterImageCompress.compressWithList(
      bytes,
      format: CompressFormat.jpeg,
      // format: CompressFormat.webp, => https://pub.dev/packages/flutter_image_compress#web
      // format: CompressFormat.heic,
    );
    editedBytes = result;
    debugPrint('Converted image size: ${result.length}');
    // Upload or save the result from the converted image.
  }

  Future<void> _convertDart(Uint8List bytes) async {
    // In a real case you should use a web worker that does not freeze the main ui.
    img.Image? image = img.decodePng(bytes);

    if (image != null) {
      // Encode the image to JPEG format
      Uint8List jpegBytes = img.encodeJpg(image);
      contentType = 'image/jpeg';

      editedBytes = jpegBytes;
      // Upload or save the result from the converted image.
    } else {
      debugPrint('Error: Could not decode the PNG image.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        await precacheImage(
            AssetImage(ExampleConstants.of(context)!.demoAssetPath), context);
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _buildEditor(),
          ),
        );
      },
      leading: const Icon(Icons.compare_outlined),
      title: const Text('Change output format'),
      subtitle: const Text(
          'Convert the output format from png to other formats like jpeg.'),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildEditor() {
    return ProImageEditor.asset(
      ExampleConstants.of(context)!.demoAssetPath,
      callbacks: ProImageEditorCallbacks(
        onImageEditingStarted: onImageEditingStarted,
        onImageEditingComplete: (bytes) async {
          editedBytes = bytes;

          await _convertImage(bytes);

          setGenerationTime();
        },
        onCloseEditor: onCloseEditor,
      ),
      configs: const ProImageEditorConfigs(
        imageGenerationConfigs: ImageGeneratioConfigs(
          allowEmptyEditCompletion: true,
        ),
      ),
    );
  }
}
