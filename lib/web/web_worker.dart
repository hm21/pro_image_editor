// dart compile js -o lib/web/web_worker.dart.js lib/web/web_worker.dart

// ignore_for_file: avoid_web_libraries_in_flutter

// Dart imports:
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

// Package imports:
import 'package:image/image.dart' as img;

// Project imports:
import 'package:pro_image_editor/models/editor_configs/image_generation_configs/output_formats.dart';
import 'package:pro_image_editor/models/multi_threading/thread_request_model.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/utils/convert_raw_image.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/utils/encode_image.dart';

void main() {
  WebWorkerManager();
}

class WebWorkerManager {
  final workerScope = html.DedicatedWorkerGlobalScope.instance;

  WebWorkerManager() {
    _init();
  }

  void _init() {
    workerScope.onMessage.listen((dynamic event) async {
      var data = event.data;

      switch (data?['mode']) {
        case 'convert':
          await _handleConvert(data);
          break;
        case 'encode':
          await _handleEncode(data);
          break;
        case 'destroyActiveTasks':
          _handleDestroyActiveTasks(data['ignoreTaskId']);
          break;
        case 'kill':
          workerScope.close();
          break;
        default:
          break;
      }
    });
  }

  Map<String, Completer> tasks = {};

  Future<void> _handleConvert(dynamic data) async {
    final workerScope = html.DedicatedWorkerGlobalScope.instance;
    String id = data['id'];
    var imageData = data['image'] ?? {};

    var destroy$ = Completer();
    tasks[id] = destroy$;
    ImageConvertThreadRequest image =
        _parseImageFromMainThread(id, imageData, data);
    await convertRawImage(image, destroy$: destroy$).then((res) {
      workerScope.postMessage({
        'bytes': res.bytes,
        'id': res.id,
      });
    }).whenComplete(() {
      if (tasks[id]?.isCompleted != true) {
        tasks[id]?.complete(null);
      }
      tasks.remove(id);
    });
  }

  Future<void> _handleEncode(dynamic data) async {
    final workerScope = html.DedicatedWorkerGlobalScope.instance;
    String id = data['id'];
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

    workerScope.postMessage({
      'bytes': bytes,
      'id': id,
    });
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
      generateOnlyImageBounds: data['generateOnlyImageBounds'] ?? true,
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

  int _getJpgQuality(dynamic data) => data['jpegQuality'] ?? 100;
  int _getPngLevel(dynamic data) => data['pngLevel'] ?? 6;
  bool _getSingleFrame(dynamic data) => data['singleFrame'] ?? false;
}
