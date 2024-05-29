// Dart imports:
import 'dart:async';
import 'dart:isolate';

// Project imports:
import 'package:pro_image_editor/utils/content_recorder.dart/utils/encode_image.dart';

import 'content_recorder_models.dart';
import 'convert_raw_image.dart';

/// The isolated function to handle image conversion in a separate thread.
///
/// This function sets up a [ReceivePort] to listen for incoming messages.
/// When it receives an [ImageFromMainThread] message, it processes the image
/// and sends back the result.
@pragma('vm:entry-point')
void isolatedImageConverter(SendPort port) {
  final receivePort = ReceivePort();
  port.send(receivePort.sendPort);

  Map<String, Completer> tasks = {};

  receivePort.listen((dynamic message) async {
    if (message is ImageFromMainThread) {
      var killCompleter = Completer();
      tasks[message.completerId] = killCompleter;
      convertRawImage(message, killCompleter: killCompleter).then((res) {
        port.send(res);
      }).whenComplete(() {
        if (tasks[message.completerId]?.isCompleted != true) {
          tasks[message.completerId]?.complete(null);
        }
        tasks.remove(message.completerId);
      });
    } else if (message is RawFromMainThread) {
      var bytes = await encodeImage(
        image: message.image,
        outputFormat: message.outputFormat,
        singleFrame: message.singleFrame,
        jpegQuality: message.jpegQuality,
        jpegChroma: message.jpegChroma,
        pngFilter: message.pngFilter,
        pngLevel: message.pngLevel,
      );
      port.send(ResponseFromImageThread(
        completerId: message.completerId,
        bytes: bytes,
      ));
    } else if (message is Map<String, String>) {
      if (message.containsKey('kill')) {
        tasks.forEach((key, value) {
          if (key != message['kill']) {
            if (!value.isCompleted) value.complete();
          }
        });
      }
    }
  });
}
