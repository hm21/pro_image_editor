// Dart imports:
import 'dart:isolate';

// Project imports:
import 'package:pro_image_editor/models/multi_threading/thread_request_model.dart';
import 'package:pro_image_editor/models/multi_threading/thread_response_model.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/threads_managers/isolate/isolate_thread_code.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/threads_managers/threads/thread.dart';

/// Represents a thread managed by an isolate.
///
/// Inherits from [Thread] and includes an additional parameter for specifying
/// the number of cores used by the thread.
class IsolateThread extends Thread {
  /// Creates an instance of [IsolateThread].
  ///
  /// [onMessage] is a callback that is triggered when a message is received
  /// by the thread.
  /// [coreNumber] specifies the number of cores allocated to the thread.
  IsolateThread({
    required super.onMessage,
    required this.coreNumber,
  });

  /// The isolate used for offloading image processing tasks.
  Isolate? isolate;

  /// The port used to send messages to the isolate.
  late SendPort sendPort;

  /// The port used to receive messages from the isolate.
  late ReceivePort receivePort;

  /// Number of processor cores available for the isolate to utilize.
  final int coreNumber;

  @override
  void init() async {
    receivePort = ReceivePort();
    receivePort.listen((message) {
      if (message is SendPort) {
        sendPort = message;
        readyState.complete(true);
      } else if (message is ThreadResponse) {
        onMessage(message);
        activeTasks--;
        activeTaskIds.remove(message.id);
      }
    });
    isolate = await Isolate.spawn(
      isolatedImageConverter,
      receivePort.sendPort,
      debugName: 'PIE-Thread-$coreNumber',
    );
  }

  @override
  void send(ThreadRequest data) async {
    sendPort.send(data);
    activeTaskIds.add(data.id);
  }

  @override
  void destroyActiveTasks(String ignoreTaskId) async {
    await readyState.future;
    sendPort.send({'mode': 'destroyActiveTasks', 'ignoreTaskId': ignoreTaskId});
  }

  @override
  void destroy() async {
    await readyState.future;
    isolate?.kill(priority: Isolate.immediate);
    receivePort.close();
  }
}
