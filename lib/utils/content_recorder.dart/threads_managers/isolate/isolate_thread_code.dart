// Dart imports:
import 'dart:async';
import 'dart:isolate';

// Project imports:
import 'package:pro_image_editor/models/multi_threading/thread_request_model.dart';
import 'package:pro_image_editor/models/multi_threading/thread_response_model.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/utils/convert_raw_image.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/utils/encode_image.dart';

/// The isolated function to handle image conversion in a separate thread.
///
/// This function sets up a [ReceivePort] to listen for incoming messages.
/// When it receives an [ImageFromMainThread] message, it processes the image
/// and sends back the result.
@pragma('vm:entry-point')
void isolatedImageConverter(SendPort port) {
  final receivePort = ReceivePort();
  port.send(receivePort.sendPort);

  Map<String, Completer<void>> tasks = {};

  receivePort.listen((dynamic message) async {
    if (message is ImageConvertThreadRequest) {
      _handleImageConvertRequest(message, port, tasks);
    } else if (message is ThreadRequest) {
      await _handleThreadRequest(message, port);
    } else if (message is Map<String, String>) {
      if (message.containsKey('mode') &&
          message['mode'] == 'destroyActiveTasks') {
        _handleKillRequest(message['ignoreTaskId']!, tasks);
      }
    }
  });
}

void _handleImageConvertRequest(
  ImageConvertThreadRequest message,
  SendPort port,
  Map<String, Completer<void>> tasks,
) {
  String id = message.id;
  var destroy$ = Completer();
  tasks[id] = destroy$;

  convertRawImage(message, destroy$: destroy$).then((res) {
    port.send(res);
  }).whenComplete(() {
    if (tasks[id]?.isCompleted != true) {
      tasks[id]?.complete(null);
    }
    tasks.remove(id);
  });
}

Future<void> _handleThreadRequest(
  ThreadRequest message,
  SendPort port,
) async {
  var bytes = await encodeImage(
    image: message.image,
    outputFormat: message.outputFormat,
    singleFrame: message.singleFrame,
    jpegQuality: message.jpegQuality,
    jpegChroma: message.jpegChroma,
    pngFilter: message.pngFilter,
    pngLevel: message.pngLevel,
  );
  port.send(ThreadResponse(
    id: message.id,
    bytes: bytes,
  ));
}

void _handleKillRequest(
  String ignoreTaskId,
  Map<String, Completer<void>> tasks,
) {
  tasks.forEach((key, completer) {
    if (key != ignoreTaskId && !completer.isCompleted) {
      completer.complete();
    }
  });
}
