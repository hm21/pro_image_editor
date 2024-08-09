// Dart imports:
import 'dart:async';
import 'dart:math';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/models/multi_threading/thread_request_model.dart';
import 'package:pro_image_editor/models/multi_threading/thread_task_model.dart';
import 'package:pro_image_editor/utils/content_recorder.dart/threads_managers/threads/thread.dart';

/// Manages multiple threads for background operations.
///
/// This abstract class defines the contract for managing and interacting
/// with threads, including starting, stopping, and communicating with them.
abstract class ThreadManager {
  /// List of threads.
  List<Thread> get threads;

  /// List of active tasks.
  @protected
  final List<ThreadTaskModel> tasks = [];

  /// Configuration settings for the image processing.
  @protected
  late final ProcessorConfigs processorConfigs;

  /// Flag indicating if the manager has been destroyed.
  @protected
  bool isDestroyed = false;

  /// Initializes the thread manager with the provided configuration settings.
  ///
  /// [configs] - The configuration settings for the image editor.
  @protected
  void init(ProImageEditorConfigs configs);

  /// Destroys the thread manager and all associated threads.
  ///
  /// This method sets [isDestroyed] to true and destroys each thread in
  /// [threads].
  void destroy() {
    isDestroyed = true;
    for (var model in threads) {
      model.destroy();
    }
  }

  /// Destroys all active tasks in each thread, except the task with the given
  /// [ignoreId].
  ///
  /// [ignoreId] - The ID of the task that should not be destroyed.
  void destroyAllActiveTasks(String ignoreId) {
    for (var thread in threads) {
      thread.destroyActiveTasks(ignoreId);
    }
  }

  /// Sends a [ThreadRequest] to the least busy thread and returns the result
  /// as a [Uint8List].
  ///
  /// [data] - The data to be processed by the thread.
  ///
  /// Returns the result of the processing as a [Uint8List].
  Future<Uint8List?> send(ThreadRequest data) async {
    String taskId = data.id;

    Thread thread = leastBusyThread;
    thread.activeTasks++;

    /// Await that isolate is ready and setup new completer
    if (!thread.readyState.isCompleted) {
      await thread.readyState.future;
    }

    ThreadTaskModel task = ThreadTaskModel(
      taskId: taskId,
      bytes$: Completer(),
      threadId: thread.id,
    );
    tasks.add(task);

    /// Destroy active tasks in thread if reached the concurrency limit
    if ((processorConfigs.processorMode == ProcessorMode.limit ||
            processorConfigs.processorMode == ProcessorMode.auto) &&
        thread.activeTasks > processorConfigs.maxConcurrency) {
      thread.destroyActiveTasks(taskId);

      /// Await that all active tasks stopped.
      List<ThreadTaskModel> activeTasks = tasks
          .where((el) => el.threadId == thread.id && el.taskId != taskId)
          .toList();
      await Future.wait(activeTasks.map((el) async {
        if (!el.bytes$.isCompleted) {
          await el.bytes$.future;
        }
      }));
    }

    thread.send(data);

    Uint8List? bytes = await task.bytes$.future;
    tasks.remove(task);

    return bytes;
  }

  /// Gets the thread that is currently the least busy.
  ///
  /// This method finds the thread with the fewest active tasks among the ready
  /// threads.
  /// If no thread is ready, it selects the first thread in the list.
  ///
  /// Returns the least busy [Thread].
  @protected
  Thread get leastBusyThread {
    var models = threads.where((model) => model.isReady).toList();
    if (models.isEmpty) models.add(threads.first);

    /// Find the minimum number of active tasks among the ready models
    int minActiveTasks = models.map((model) => model.activeTasks).reduce(min);

    /// Filter the models to include only those with the minimum number of
    /// active tasks
    List<Thread> leastActiveTaskModels =
        models.where((model) => model.activeTasks == minActiveTasks).toList();

    /// Randomly select one model from the list of models with the minimum
    /// number of active tasks
    return leastActiveTaskModels[
        Random().nextInt(leastActiveTaskModels.length)];
  }
}
