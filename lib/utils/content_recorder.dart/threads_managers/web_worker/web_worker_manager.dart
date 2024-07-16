// ignore_for_file: avoid_web_libraries_in_flutter

// Dart imports:
import 'dart:html' as html;
import 'dart:js' as js;

// Project imports:
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/threads_managers/threads/thread_manager.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/threads_managers/web_worker/web_worker_thread.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/utils/processor_helper.dart';

class WebWorkerManager extends ThreadManager {
  @override
  final List<WebWorkerThread> threads = [];

  final bool supportWebWorkers = html.Worker.supported;

  @override
  void init(ProImageEditorConfigs configs) {
    processorConfigs = configs.imageGenerationConfigs.processorConfigs;

    int processors = getNumberOfProcessors(
      configs: configs.imageGenerationConfigs.processorConfigs,
      deviceNumberOfProcessors: _deviceNumberOfProcessors(),
    );
    for (var i = 0; i < processors && !isDestroyed; i++) {
      threads.add(WebWorkerThread(
        onMessage: (message) {
          int i = tasks.indexWhere((el) => el.taskId == message.id);
          if (i >= 0) tasks[i].bytes$.complete(message.bytes);
        },
      ));
    }
  }

  int _deviceNumberOfProcessors() {
    var hardwareConcurrency = js.context['navigator']?['hardwareConcurrency'];
    return hardwareConcurrency != null ||
            hardwareConcurrency.runtimeType is! int
        ? hardwareConcurrency as int
        : 1;
  }
}
