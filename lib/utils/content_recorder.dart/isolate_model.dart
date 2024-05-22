// Dart imports:
import 'dart:async';
import 'dart:isolate';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../models/editor_configs/image_generation_configs.dart';
import 'utils/content_recorder_models.dart';
import 'utils/convert_image_to_png.dart';
import 'utils/isolate_image_converter.dart';

class IsolateModel {
  /// The isolate used for offloading image processing tasks.
  Isolate? isolate;

  /// The port used to send messages to the isolate.
  late SendPort sendPort;

  /// The port used to receive messages from the isolate.
  late ReceivePort receivePort;

  /// A completer to track when the isolate is ready for communication.
  late Completer isolateReady;

  /// Flag indicating whether the isolate is ready for communication.
  bool isReady = false;

  /// List of IDs of tasks currently being processed by the isolate.
  List<String> activeTaskIds = [];

  /// Number of active tasks currently being processed by the isolate.
  int activeTasks = 0;

  /// Callback function for handling messages received from the isolate.
  final Function(ResponseFromImageThread) onMessage;

  /// Configuration settings for the image processing.
  final ProcessorConfigs processorConfigs;

  /// Number of processor cores available for the isolate to utilize.
  final int coreNumber;

  IsolateModel({
    required this.onMessage,
    required this.processorConfigs,
    required this.coreNumber,
  }) {
    init();
  }

  void init() async {
    isolateReady = Completer.sync();
    receivePort = ReceivePort();
    receivePort.listen((message) {
      if (message is SendPort) {
        sendPort = message;
        isolateReady.complete();
      } else if (message is ResponseFromImageThread) {
        onMessage(message);
        activeTasks--;
        activeTaskIds.remove(message.completerId);
      }
    });
    isolate = await Isolate.spawn(
      isolatedImageConverter,
      receivePort.sendPort,
      debugName: 'Background-Task-$coreNumber',
    );
  }

  void send(ImageFromMainThread data) async {
    if (activeTasks >= processorConfigs.maxConcurrency &&
        processorConfigs.processorMode == ProcessorMode.auto) {
      // Spawn new isolate if concurrency limit reached and mode is auto.
      onMessage(await compute(convertImageToPng, data,
          debugLabel: 'Temporary-Isolate-$coreNumber'));
    } else {
      sendPort.send(data);
      activeTaskIds.add(data.completerId);
    }
  }

  void destroy() async {
    await isolateReady.future;
    isolate?.kill(priority: Isolate.immediate);
    receivePort.close();
  }
}
