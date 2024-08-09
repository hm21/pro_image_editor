// Dart imports:
// ignore_for_file: unused_field

// Project imports:
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/threads_managers/threads/thread.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/threads_managers/threads/thread_manager.dart';

/// Manages web workers for background operations.
///
/// Extends [ThreadManager] to handle the initialization and management of
/// web workers, which can perform background tasks in a web environment.
class WebWorkerManager extends ThreadManager {
  /// The list of threads managed by this manager.
  @override
  final List<Thread> threads = [];

  /// Indicates whether web workers are supported.
  final bool supportWebWorkers = false;

  @override
  void init(ProImageEditorConfigs configs) {
    // Initialization logic for web workers.
  }
}
