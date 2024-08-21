// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
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
  // ignore: unused_element
  Future<void> _convertImage(Uint8List bytes) async {
    try {
      /// Install first `flutter_image_compress: any` and import it
      /// import 'package:flutter_image_compress/flutter_image_compress.dart';
      ///
      /// FlutterImageCompress is not supported for windows and linux
      if (!kIsWeb && (Platform.isLinux || Platform.isWindows)) {
        throw ArgumentError(
            'This platform didn\'t support the package "FlutterImageCompress"');
      } else {
        /// Supports only Android, iOS, Web, MacOS
        /// final result = await FlutterImageCompress.compressWithList(
        ///   bytes,
        ///   format: CompressFormat
        ///       .webp, // For web follow this url => https://pub.dev/packages/flutter_image_compress#web
        ///   // format: CompressFormat.heic,
        /// );
        /// editedBytes = result;
        /// debugPrint('Converted image size: ${result.length}');
      }
    } catch (e) {
      debugPrint(e.toString());
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
      subtitle: const Text('Choose the output format like jpg or png'),
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

          /// For special formats like webp, you can uncomment the line below,
          /// and follow the instructions there.
          /// await _convertImage(bytes);

          setGenerationTime();
        },
        onCloseEditor: onCloseEditor,
      ),
      configs: ProImageEditorConfigs(
        designMode: platformDesignMode,
        imageGenerationConfigs: const ImageGenerationConfigs(
          /// Choose the output format below
          outputFormat: kIsWeb ? OutputFormat.png : OutputFormat.tiff,
          pngFilter: PngFilter.none,
          pngLevel: 6,
          jpegChroma: JpegChroma.yuv444,
          jpegQuality: 100,
        ),
      ),
    );
  }
}
