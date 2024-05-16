import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:image/image.dart' as img;

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
    // Decode the PNG image
    img.Image? image = img.decodePng(bytes);

    if (image != null) {
      // Encode the image to JPEG format
      Uint8List jpegBytes = img.encodeJpg(image);

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
      'assets/demo.png',
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: (bytes) async {
          editedBytes = bytes;

          await _convertImage(bytes);

          if (mounted) Navigator.pop(context);
        },
        onCloseEditor: onCloseEditor,
      ),
      configs: const ProImageEditorConfigs(
        allowCompleteWithEmptyEditing: true,
      ),
    );
  }
}
