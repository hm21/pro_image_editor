// Dart imports:
import 'dart:isolate';

// Project imports:
import 'content_recorder_models.dart';
import 'convert_image_to_png.dart';

/// The isolated function to handle image conversion in a separate thread.
///
/// This function sets up a [ReceivePort] to listen for incoming messages.
/// When it receives an [ImageFromMainThread] message, it processes the image
/// and sends back the result.
void isolatedImageConverter(SendPort port) {
  final receivePort = ReceivePort();
  port.send(receivePort.sendPort);

  receivePort.listen((dynamic message) async {
    if (message is ImageFromMainThread) {
      port.send(await convertImageToPng(message));
    }
  });
}
