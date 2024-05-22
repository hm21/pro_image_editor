// ignore_for_file: avoid_web_libraries_in_flutter

// Dart imports:
import 'dart:async';
import 'dart:html' as html;

// Flutter imports:
import 'package:flutter/rendering.dart';

// Project imports:
import '../content_recorder_models.dart';

class WebWorkerModel {
  final String _workerUrl =
      'assets/packages/pro_image_editor/lib/web/web_worker.dart.js';

  Completer readyState = Completer.sync();

  late final html.Worker worker;

  bool isReady = false;
  int activeTasks = 0;
  final Function(ResponseFromImageThread) onMessage;

  WebWorkerModel({
    required this.onMessage,
  }) {
    try {
      if (html.Worker.supported) {
        worker = html.Worker(_workerUrl);
        worker.onMessage.listen((event) {
          var data = event.data;
          if (data?['completerId'] != null) {
            activeTasks--;
            onMessage(ResponseFromImageThread(
              bytes: data['bytes'],
              completerId: data['completerId'],
            ));
          }
        });
        readyState.complete(true);
        isReady = true;
      } else {
        debugPrint('Your browser doesn\'t support web workers.');
        readyState.complete(false);
      }
    } catch (e) {
      if (readyState.isCompleted) {
        readyState = Completer.sync();
      }
      readyState.complete(false);
    }
  }

  void send(ImageFromMainThread data) {
    activeTasks++;
    worker.postMessage({
      'completerId': data.completerId,
      'generateOnlyImageBounds': data.generateOnlyImageBounds,
      'image': {
        'buffer': data.image.buffer,
        'width': data.image.width,
        'height': data.image.height,
        'textData': data.image.textData,
        'frameDuration': data.image.frameDuration,
        'frameIndex': data.image.frameIndex,
        'loopCount': data.image.loopCount,
        'numChannels': data.image.numChannels,
        'rowStride': data.image.rowStride,
        'frameType': data.image.frameType.name,
        'format': data.image.format.name,
        // 'exif': data.image.exif,
        // 'palette': data.image.palette,
        // 'backgroundColor': data.image.backgroundColor,
      }
    });
  }

  void destroy() {
    worker.postMessage({'kill': true});
    worker.terminate();
  }
}
