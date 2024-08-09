// Dart imports:
import 'dart:async';
import 'dart:typed_data';

/// Model representing a task to be processed in a separate thread.
class ThreadTaskModel {
  /// Constructor for creating a ThreadTaskModel instance.
  ThreadTaskModel({
    /// Unique identifier for the task.
    required this.taskId,

    /// Completer to handle asynchronous data processing.
    required this.bytes$,

    /// Identifier for the thread handling this task.
    required this.threadId,
  });

  /// Unique identifier for the task.
  final String taskId;

  /// Completer for handling asynchronous byte data.
  final Completer<Uint8List?> bytes$;

  /// Identifier for the thread handling this task.
  final String threadId;
}
