// Dart imports:
import 'dart:async';
import 'dart:typed_data';

// Project imports:
import '../../../utils/unique_id_generator.dart';

/// A class representing the state of an isolate capture.
class IsolateCaptureState {
  bool broken = false;
  bool readedRenderedImage = false;
  late String id;
  late Completer<Uint8List> completer;

  IsolateCaptureState() {
    completer = Completer.sync();
    id = generateUniqueId();
  }
}
