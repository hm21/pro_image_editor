// Dart imports:
import 'dart:async';
import 'dart:typed_data';

// Project imports:
import '../../../utils/unique_id_generator.dart';

class ThreadCaptureState {
  bool broken = false;
  bool readedRenderedImage = false;
  late String id;
  late Completer<Uint8List> completer;

  ThreadCaptureState() {
    completer = Completer();
    id = generateUniqueId();
  }
}
