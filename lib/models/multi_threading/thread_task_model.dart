// Dart imports:
import 'dart:async';
import 'dart:typed_data';

class ThreadTaskModel {
  final String taskId;
  final Completer<Uint8List?> bytes$;
  final String threadId;

  ThreadTaskModel({
    required this.taskId,
    required this.bytes$,
    required this.threadId,
  });
}
