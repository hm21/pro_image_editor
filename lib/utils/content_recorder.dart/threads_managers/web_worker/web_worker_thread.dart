// ignore_for_file: avoid_web_libraries_in_flutter

// Dart imports:
import 'dart:async';
import 'dart:js_interop' as js;

import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:web/web.dart' as web;

import '/models/multi_threading/thread_request_model.dart';
import '/models/multi_threading/thread_response_model.dart';
import '/utils/content_recorder.dart/threads_managers/threads/thread.dart';
import '../../../../common/editor_web_constants.dart';
import 'web_utils.dart';

/// A class representing a web worker thread.
///
/// Extends [Thread] to handle web worker operations including
/// sending messages, receiving responses, and managing the worker's lifecycle.
class WebWorkerThread extends Thread {
  /// Creates an instance of [WebWorkerThread].
  ///
  /// The [onMessage] callback is required to handle messages received
  /// from the web worker.
  WebWorkerThread({
    required super.onMessage,
    required super.coreNumber,
  });

  /// The [web.Worker] instance managing the web worker.
  ///
  /// This is the web worker instance that executes the worker script
  /// and communicates with the main thread.
  late final web.Worker worker;

  @override
  void init() {
    try {
      worker = web.Worker(
        kImageEditorWebWorkerPath.toJS,
        web.WorkerOptions(
          name: 'PIE-Thread-$coreNumber',
        ),
      );

      if (worker.isDefinedAndNotNull) {
        worker.onmessage = (web.MessageEvent event) {
          var data = dartify(event.data);
          if (data?['id'] != null) {
            activeTasks--;
            List<dynamic>? bytes = data['bytes'] as List<dynamic>?;
            onMessage(ThreadResponse(
              bytes: bytes != null
                  ? Uint8List.fromList(List.castFrom<dynamic, int>(bytes))
                  : null,
              id: data['id'] as String,
            ));
          }
        }.toJS;

        readyState.complete(true);
        isReady = true;
      } else {
        debugPrint('Your browser doesn\'t support web workers.');
        readyState.complete(false);
      }
    } catch (e) {
      if (readyState.isCompleted) readyState = Completer();
      readyState.complete(false);
    }
  }

  @override
  void send(ThreadRequest data) {
    activeTasks++;
    worker.postMessage(jsify({
      'mode': data is ImageConvertThreadRequest ? 'convert' : 'encode',
      'id': data.id,
      'generateOnlyImageBounds': data is ImageConvertThreadRequest
          ? data.generateOnlyImageBounds
          : null,
      'outputFormat': data.outputFormat.name,
      'jpegChroma': data.jpegChroma.name,
      'pngFilter': data.pngFilter.name,
      'jpegQuality': data.jpegQuality,
      'pngLevel': data.pngLevel,
      'singleFrame': data.singleFrame,
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
    }));
  }

  @override
  void destroyActiveTasks(String ignoreTaskId) async {
    worker.postMessage(jsify({
      'mode': 'destroyActiveTasks',
      'ignoreTaskId': ignoreTaskId,
    }));
  }

  @override
  void destroy() {
    worker
      ..postMessage(jsify({'mode': 'kill'}))
      ..terminate();
  }
}
