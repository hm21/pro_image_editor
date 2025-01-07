// dart compile js -o lib/web/web_worker.dart.js lib/web/web_worker.dart
// dart compile wasm -o lib/web/web_worker.dart.wasm lib/web/web_worker.dart

// ignore_for_file: argument_type_not_assignable

// Dart imports:
import 'dart:async';
import 'dart:js_interop' as js;
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import '/core/models/multi_threading/thread_web_request_model.dart';
import '/shared/services/content_recorder/managers/web_worker/web_utils.dart';
import '/shared/services/content_recorder/utils/convert_raw_image.dart';
import '/shared/services/content_recorder/utils/encode_image.dart';

void main() {
  WebWorkerManager();
}

/// The global scope for the dedicated web worker.
@js.JS('self')
external web.DedicatedWorkerGlobalScope get workerScope;

/// Manages the web workers for the application.
class WebWorkerManager {
  /// Creates a new [WebWorkerManager] instance and initializes it.
  WebWorkerManager() {
    _init();
  }

  /// Initializes the web worker manager by setting up message listeners.
  void _init() {
    workerScope.onmessage = (web.MessageEvent event) {
      final jsMode = jsGetProperty(event.data as js.JSObject, 'mode');
      String? mode = (jsMode as js.JSString).toDart;

      switch (mode) {
        case 'convert':
          var data = ThreadWebRequest.fromJs(event.data);
          _handleConvert(data);
          break;
        case 'encode':
          var data = ThreadWebRequest.fromJs(event.data);
          _handleEncode(data);
          break;
        case 'destroyActiveTasks':
          final jsIgnoreTaskId =
              jsGetProperty(event.data as js.JSObject, 'ignoreTaskId');
          String? ignoreTaskId = (jsIgnoreTaskId as js.JSString).toDart;
          _handleDestroyActiveTasks(ignoreTaskId);
          break;
        case 'kill':
          workerScope.close();
          break;
        default:
          break;
      }
    }.toJS;
  }

  /// A map to keep track of ongoing tasks and their corresponding completers.
  Map<String, Completer<void>> tasks = {};

  Future<void> _handleConvert(ThreadWebRequest data) async {
    String id = data.id;

    var destroy$ = Completer();
    tasks[id] = destroy$;

    await convertRawImage(
      data.toConvertThreadRequest(),
      destroy$: destroy$,
    ).then((res) {
      workerScope.postMessage(jsify({
        'bytes': res.bytes,
        'id': res.id,
      }));
    }).whenComplete(() {
      if (tasks[id]?.isCompleted != true) {
        tasks[id]?.complete(null);
      }
      tasks.remove(id);
    });
  }

  Future<void> _handleEncode(ThreadWebRequest data) async {
    String id = data.id;
    var imageData = data.image;

    Uint8List bytes = await encodeImage(
      jpegChroma: data.jpegChroma,
      jpegQuality: data.jpegQuality,
      pngFilter: data.pngFilter,
      pngLevel: data.pngLevel,
      singleFrame: data.singleFrame,
      outputFormat: data.outputFormat,
      image: imageData,
    );

    workerScope.postMessage(jsify({
      'bytes': bytes,
      'id': id,
    }));
  }

  void _handleDestroyActiveTasks(String ignoreTaskId) {
    tasks.forEach((key, value) {
      if (key != ignoreTaskId) {
        if (!value.isCompleted) value.complete();
      }
    });
  }
}
