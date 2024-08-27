// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import '../../../models/crop_rotate_editor/transform_factors.dart';
import '../../../models/multi_threading/thread_capture_model.dart';
import '../../filter_editor/types/filter_matrix.dart';

/// A class for managing the state and history of image editing changes.
class StateManager {
  /// Position in the state history.
  int position = 0;

  /// List to store the history of image editor changes.
  List<EditorStateHistory> stateHistory = [];

  /// Get the list of filters from the current image editor changes.
  FilterMatrix get activeFilters => stateHistory[position].filters;

  /// Get the transformConfigurations from the crop/ rotate editor.
  TransformConfigs get transformConfigs =>
      stateHistory[position].transformConfigs;

  /// Get the blur from the current image editor changes.
  double get activeBlur => stateHistory[position].blur;

  /// Get the list of layers from the current image editor changes.
  List<Layer> get activeLayers => stateHistory[position].layers;

  /// Flag indicating if a hero screenshot is required.
  bool heroScreenshotRequired = false;

  /// List of captured screenshots for each state in the history.
  List<ThreadCaptureState> screenshots = [];

  /// Retrieves the currently active screenshot based on the position.
  ThreadCaptureState? get activeScreenshot {
    return screenshots.length > position - 1 ? screenshots[position - 1] : null;
  }

  /// Check if the active screenshot is broken.
  bool? get activeScreenshotIsBroken => activeScreenshot?.broken;

  /// Clean forward changes in the history.
  ///
  /// This method removes any changes made after the current edit position in
  /// the history. It ensures that the state history and screenshots are
  /// consistent with the current position. This is useful when performing an
  /// undo operation, and new edits are made, effectively discarding the "redo"
  /// history.
  void cleanForwardChanges() {
    if (stateHistory.length > 1) {
      while (position < stateHistory.length - 1) {
        stateHistory.removeLast();
      }
      while (position < screenshots.length) {
        screenshots.removeLast();
      }
    }
    position = stateHistory.length - 1;
  }

  /// Set the history limit to manage the maximum number of stored states.
  ///
  /// This method sets a limit on the number of states that can be stored in
  /// the history.
  /// If the number of stored states exceeds this limit, the oldest states are
  /// removed to free up memory. This is crucial for preventing excessive
  /// memory usage, especially when each state includes large data such as
  /// screenshots.
  ///
  /// - `limit`: The maximum number of states to retain in the history. Must
  /// be 1 or greater.
  void setHistoryLimit(int limit) {
    if (limit <= 0) {
      throw ArgumentError('The state history limit must be 1 or greater!');
    }
    while (position > limit) {
      if (position > 0) {
        position--;
        stateHistory.removeAt(0);
        screenshots.removeAt(0);
      } else {
        stateHistory.removeLast();
        screenshots.removeLast();
      }
    }
  }
}
