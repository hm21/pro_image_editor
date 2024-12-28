// dart compile js -o lib/web/web_worker.dart.js lib/web/web_worker.dart
// dart compile wasm -o lib/web/web_worker.dart.wasm lib/web/web_worker.dart

// ignore_for_file: argument_type_not_assignable

// Dart imports:
import 'dart:async';
import 'dart:js_interop' as js;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:web/web.dart' as web;

import '/models/editor_configs/image_generation_configs/output_formats.dart';
import '/models/multi_threading/thread_request_model.dart';
import '/utils/content_recorder.dart/threads_managers/web_worker/web_utils.dart';
import '/utils/content_recorder.dart/utils/convert_raw_image.dart';
import '/utils/content_recorder.dart/utils/encode_image.dart';

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
      var data = dartify(event.data);

      switch (data?['mode']) {
        case 'convert':
          _handleConvert(data);
          break;
        case 'encode':
          _handleEncode(data);
          break;
        case 'destroyActiveTasks':
          _handleDestroyActiveTasks(data['ignoreTaskId'] as String);
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

  Future<void> _handleConvert(dynamic data) async {
    String id = data['id'] as String;
    var imageData = data['image'] ?? {};

    var destroy$ = Completer();
    tasks[id] = destroy$;
    ImageConvertThreadRequest image =
        _parseImageFromMainThread(id, imageData, data);
    await convertRawImage(image, destroy$: destroy$).then((res) {
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

  Future<void> _handleEncode(dynamic data) async {
    String id = data['id'] as String;
    var imageData = data['image'] ?? {};

    Uint8List bytes = await encodeImage(
      jpegChroma: _getJpegChroma(data),
      jpegQuality: _getJpgQuality(data),
      pngFilter: _getPngFilter(data),
      pngLevel: _getPngLevel(data),
      singleFrame: _getSingleFrame(data),
      outputFormat: _getOutputFormat(data),
      image: _parseImage(imageData),
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

  ImageConvertThreadRequest _parseImageFromMainThread(
      String id, dynamic imageData, dynamic data) {
    return ImageConvertThreadRequest(
      id: id,
      generateOnlyImageBounds:
          (data['generateOnlyImageBounds'] as bool?) ?? true,
      jpegChroma: _getJpegChroma(data),
      jpegQuality: _getJpgQuality(data),
      pngFilter: _getPngFilter(data),
      pngLevel: _getPngLevel(data),
      singleFrame: _getSingleFrame(data),
      outputFormat: _getOutputFormat(data),
      image: _parseImage(imageData),
    );
  }

  img.Image _parseImage(dynamic imageData) {
    return img.Image.fromBytes(
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
    );
  }

  img.JpegChroma _getJpegChroma(dynamic imageData) {
    return imageData['jpegChroma'] == null
        ? img.JpegChroma.yuv444
        : img.JpegChroma.values
            .firstWhere((el) => el.name == imageData['jpegChroma']);
  }

  img.PngFilter _getPngFilter(dynamic imageData) {
    return imageData['pngFilter'] == null
        ? img.PngFilter.none
        : img.PngFilter.values
            .firstWhere((el) => el.name == imageData['pngFilter']);
  }

  OutputFormat _getOutputFormat(dynamic imageData) {
    return imageData['outputFormat'] == null
        ? OutputFormat.jpg
        : OutputFormat.values
            .firstWhere((el) => el.name == imageData['outputFormat']);
  }

  int _getJpgQuality(dynamic data) => (data['jpegQuality'] as int?) ?? 100;
  int _getPngLevel(dynamic data) => (data['pngLevel'] as int?) ?? 6;
  bool _getSingleFrame(dynamic data) => (data['singleFrame'] as bool?) ?? false;
}
