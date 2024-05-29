// ignore_for_file: avoid_web_libraries_in_flutter

// Dart imports:
import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:math';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/content_recorder_controller.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/utils/content_recorder_models.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/utils/web_worker/web_worker_model.dart';

class ProImageEditorWebWorker {
  final List<WebWorkerModel> _webWorkers = [];

  /// A map to store unique completers for handling asynchronous image processing tasks.
  final Map<String, Completer<Uint8List?>> _uniqueCompleter = {};

  final bool supportWebWorkers = html.Worker.supported;

  void init(ProImageEditorConfigs configs) {
    int processors = getNumberOfProcessors(
      configs: configs.imageGenerationConfigs.processorConfigs,
      deviceNumberOfProcessors: _deviceNumberOfProcessors(),
    );
    for (var i = 0; i < processors; i++) {
      _webWorkers.add(WebWorkerModel(
        onMessage: (message) {
          _uniqueCompleter[message.completerId]?.complete(message.bytes);
        },
      ));
    }
  }

  void destroy() {
    for (var worker in _webWorkers) {
      worker.destroy();
    }
  }

  Future<Uint8List?> send(RawFromMainThread data) async {
    _uniqueCompleter[data.completerId] = Completer.sync();

    WebWorkerModel webWorker = _leastBusyWorker;

    webWorker.send(data);

    Uint8List? bytes = await _uniqueCompleter[data.completerId]!.future;
    _uniqueCompleter.remove(data.completerId);

    return bytes;
  }

  WebWorkerModel get _leastBusyWorker {
    var models = _webWorkers.where((model) => model.isReady).toList();
    if (models.isEmpty) models.add(_webWorkers.first);

    // Find the minimum number of active tasks among the ready models
    int minActiveTasks = models.map((model) => model.activeTasks).reduce(min);
    // Filter the models to include only those with the minimum number of active tasks
    List<WebWorkerModel> leastActiveTaskModels =
        models.where((model) => model.activeTasks == minActiveTasks).toList();
    // Randomly select one model from the list of models with the minimum number of active tasks
    return leastActiveTaskModels[
        Random().nextInt(leastActiveTaskModels.length)];
  }

  int _deviceNumberOfProcessors() {
    var hardwareConcurrency = js.context['navigator']?['hardwareConcurrency'];
    return hardwareConcurrency != null ||
            hardwareConcurrency.runtimeType is! int
        ? hardwareConcurrency as int
        : 1;
  }
}
