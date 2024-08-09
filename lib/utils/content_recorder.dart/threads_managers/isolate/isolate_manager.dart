// Dart imports:
import 'dart:io';

// Project imports:
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/threads_managers/isolate/isolate_thread.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/threads_managers/threads/thread_manager.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/utils/processor_helper.dart';

/// Manages the lifecycle and communication of isolates.
///
/// This class handles the creation, management, and disposal of isolates
/// for performing background tasks. It ensures proper communication with
/// the main thread and handles the results from isolate operations.
class IsolateManager extends ThreadManager {
  /// List of isolate models used for managing isolates.
  @override
  final List<IsolateThread> threads = [];

  @override
  void init(ProImageEditorConfigs configs) async {
    processorConfigs = configs.imageGenerationConfigs.processorConfigs;

    int processors = getNumberOfProcessors(
      configs: configs.imageGenerationConfigs.processorConfigs,
      deviceNumberOfProcessors: Platform.numberOfProcessors,
    );
    for (var i = 0; i < processors && !isDestroyed; i++) {
      var isolate = IsolateThread(
        coreNumber: i + 1,
        onMessage: (message) {
          int i = tasks.indexWhere((el) => el.taskId == message.id);
          if (i >= 0) tasks[i].bytes$.complete(message.bytes);
        },
      );
      threads.add(isolate);

      /// Await that isolate is ready before spawn a new one.
      await isolate.readyState.future;
      isolate.isReady = true;
      if (isDestroyed) {
        isolate.destroy();
      }
    }
  }
}
