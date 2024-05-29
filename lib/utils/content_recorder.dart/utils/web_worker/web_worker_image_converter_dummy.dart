// Dart imports:
// ignore_for_file: unused_field

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/utils/content_recorder_models.dart';

class ProImageEditorWebWorker {
  final List<dynamic> _webWorkers = [];

  /// A map to store unique completers for handling asynchronous image processing tasks.
  final Map<String, Completer<Uint8List?>> _uniqueCompleter = {};

  final bool supportWebWorkers = false;

  void init(ProImageEditorConfigs configs) {}

  void destroy() {}

  Future<Uint8List?> send(RawFromMainThread data) async {
    return null;
  }
}
