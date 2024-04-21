import '../../../models/crop_rotate_editor/transform_factors.dart';
import '../../../models/editor_image.dart';
import '../../../models/history/blur_state_history.dart';
import '../../../models/history/filter_state_history.dart';
import '../../../models/history/state_history.dart';
import '../../../models/layer.dart';

/// A class for managing the state and history of image editing changes.
class StateManager {
  /// Position in the edit history.
  int editPosition = 0;

  /// List to track changes made to the image during editing.
  List<EditorImage> imgStateHistory = [];

  /// List to store the history of image editor changes.
  List<EditorStateHistory> stateHistory = [];

  /// Get the list of filters from the current image editor changes.
  List<FilterStateHistory> get filters => stateHistory[editPosition].filters;

  /// Get the transformconfigurations from the crop/ rotate editor.
  TransformConfigs get transformConfigs =>
      stateHistory[editPosition].transformConfigs;

  /// Get the blur state from the current image editor changes.
  BlurStateHistory get blurStateHistory => stateHistory[editPosition].blur;

  /// Get the current image being edited from the change list.
  EditorImage get image =>
      imgStateHistory[stateHistory[editPosition].bytesRefIndex];

  /// Get the list of layers from the current image editor changes.
  List<Layer> get activeLayers => stateHistory[editPosition].layers;

  /// Clean forward changes in the history.
  ///
  /// This method removes any changes made after the current edit position in the history.
  void cleanForwardChanges() {
    if (stateHistory.length > 1) {
      while (editPosition < stateHistory.length - 1) {
        stateHistory.removeLast();
        if (imgStateHistory.length - 1 > stateHistory.last.bytesRefIndex) {
          imgStateHistory.removeLast();
        }
      }
    }
    editPosition = stateHistory.length - 1;
  }
}
