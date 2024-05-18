// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../content_recorder_models.dart';

class ProImageEditorWebWorker {
  Completer readyState = Completer.sync();
  void init() {
    readyState.complete(false);
  }

  Future<Uint8List?> sendImage(ImageFromMainThread data) async {
    return null;
  }
}
