// dart compile js -o lib/web/web_worker.dart.js lib/web/web_worker.dart

// ignore_for_file: avoid_web_libraries_in_flutter

// Dart imports:
import 'dart:html' as html;

// Package imports:
import 'package:image/image.dart' as img;

// Project imports:
import 'package:pro_image_editor/utils/content_recorder.dart/utils/content_recorder_models.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/utils/convert_image_to_png.dart';

void main() {
  final workerScope = html.DedicatedWorkerGlobalScope.instance;

  workerScope.onMessage.listen((dynamic event) async {
    var data = event.data;

    if (data?['completerId'] != null) {
      String id = data['completerId'];
      var imageData = data['image'] ?? {};
      ImageFromMainThread image = ImageFromMainThread(
        completerId: id,
        generateOnlyImageBounds: data['generateOnlyImageBounds'] ?? true,
        image: img.Image.fromBytes(
          bytes: imageData['buffer'],
          width: imageData['width'],
          height: imageData['height'],
          textData: imageData['textData'],
          frameDuration: imageData['frameDuration'] ?? 0,
          frameIndex: imageData['frameIndex'] ?? 0,
          loopCount: imageData['loopCount'] ?? 0,
          numChannels: imageData['numChannels'],
          rowStride: imageData['rowStride'],
          frameType: imageData['frameType'] == null
              ? img.FrameType.sequence
              : img.FrameType.values
                  .firstWhere((el) => el.name == imageData['frameType']),
          format: imageData['format'] == null
              ? img.Format.uint8
              : img.Format.values
                  .firstWhere((el) => el.name == imageData['format']),
          // backgroundColor: data['backgroundColor'],
          // palette: data['palette'],
          // exif: data['exif'],
        ),
      );

      var result = await convertImageToPng(image);
      workerScope.postMessage({
        'bytes': result.bytes,
        'completerId': result.completerId,
      });
    }
  });
}
