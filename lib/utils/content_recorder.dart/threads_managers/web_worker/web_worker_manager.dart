import 'dart:js_interop' as js;

import 'package:web/web.dart' as web;

import '/models/editor_configs/pro_image_editor_configs.dart';
import '/utils/content_recorder.dart/threads_managers/threads/thread_manager.dart';
import '/utils/content_recorder.dart/threads_managers/web_worker/web_worker_thread.dart';
import '/utils/content_recorder.dart/utils/processor_helper.dart';
import '../../../../common/editor_web_constants.dart';
import 'web_utils.dart';

/// Manages web workers for background processing tasks.
///
/// Extends [ThreadManager] to initialize and handle web worker threads.
/// Uses the browser's Web Worker API to offload tasks.
class WebWorkerManager extends ThreadManager {
  /// List of web worker threads managed by this manager.
  @override
  final List<WebWorkerThread> threads = [];

  /// Indicates whether web workers are supported by the browser.
  late final bool supportWebWorkers =
      web.Worker(jsify(kImageEditorWebWorkerPath)!).isDefinedAndNotNull;

  @override
  void init(ProImageEditorConfigs configs) {
    processorConfigs = configs.imageGeneration.processorConfigs;

    int processors = getNumberOfProcessors(
      configs: configs.imageGeneration.processorConfigs,
      deviceNumberOfProcessors: _deviceNumberOfProcessors(),
    );

    for (var i = 0; i < processors && !isDestroyed; i++) {
      threads.add(WebWorkerThread(
        coreNumber: i + 1,
        onMessage: (message) {
          int i = tasks.indexWhere((el) => el.taskId == message.id);
          if (i >= 0) tasks[i].bytes$.complete(message.bytes);
        },
      ));
    }
  }

  /// Retrieves the number of processors available on the device.
  int _deviceNumberOfProcessors() {
    return web.window.navigator.hardwareConcurrency;
  }
}
