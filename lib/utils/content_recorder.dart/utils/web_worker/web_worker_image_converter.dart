// ignore_for_file: avoid_web_libraries_in_flutter

// Dart imports:
import 'dart:async';
import 'dart:html' as html;

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../content_recorder_models.dart';

class ProImageEditorWebWorker {
  Completer readyState = Completer.sync();
  final String _workerUrl =
      'assets/packages/pro_image_editor/lib/web/web_worker.dart.js';

  late final html.Worker _worker;

  /// A map to store unique completers for handling asynchronous image processing tasks.
  final Map<String, Completer<Uint8List?>> _uniqueCompleter = {};

  void init() {
    try {
      if (html.Worker.supported) {
        _worker = html.Worker(_workerUrl);
        _worker.onMessage.listen((event) {
          var data = event.data;
          if (data?['completerId'] != null) {
            _uniqueCompleter[data['completerId']]?.complete(data['bytes']);
          }
        });
        readyState.complete(true);
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

  Future<Uint8List?> sendImage(ImageFromMainThread data) async {
    _uniqueCompleter[data.completerId] = Completer.sync();

    _worker.postMessage({
      'completerId': data.completerId,
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

    Uint8List? bytes = await _uniqueCompleter[data.completerId]!.future;
    _uniqueCompleter.remove(data.completerId);

    return bytes;
  }
}
