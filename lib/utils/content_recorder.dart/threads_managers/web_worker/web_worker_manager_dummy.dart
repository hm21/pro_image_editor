// Dart imports:
// ignore_for_file: unused_field

// Project imports:
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/threads_managers/threads/thread.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/threads_managers/threads/thread_manager.dart';

class WebWorkerManager extends ThreadManager {
  @override
  final List<Thread> threads = [];

  final bool supportWebWorkers = false;

  @override
  void init(ProImageEditorConfigs configs) {}
}
