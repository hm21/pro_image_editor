// Project imports:
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '../threads/thread.dart';
import '../threads/thread_manager.dart';

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
