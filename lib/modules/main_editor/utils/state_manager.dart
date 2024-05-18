import 'dart:async';
import 'dart:typed_data';

import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';

import '../../../models/crop_rotate_editor/transform_factors.dart';
import '../../../models/history/blur_state_history.dart';
import '../../../models/history/filter_state_history.dart';
import '../../../models/history/state_history.dart';
import '../../../models/layer.dart';
import '../../../utils/content_recorder.dart/content_recorder_controller.dart';
import '../../../utils/unique_id_generator.dart';

/// A class for managing the state and history of image editing changes.
class StateManager {
  /// Position in the edit history.
  int editPosition = 0;

  /// List to store the history of image editor changes.
  List<EditorStateHistory> stateHistory = [];

  /// Get the list of filters from the current image editor changes.
  List<FilterStateHistory> get filters => stateHistory[editPosition].filters;

  /// Get the transformconfigurations from the crop/ rotate editor.
  TransformConfigs get transformConfigs =>
      stateHistory[editPosition].transformConfigs;

  /// Get the blur state from the current image editor changes.
  BlurStateHistory get blurStateHistory => stateHistory[editPosition].blur;

  /// Get the list of layers from the current image editor changes.
  List<Layer> get activeLayers => stateHistory[editPosition].layers;

  // ignore: library_private_types_in_public_api
  List<_IsolateCaptureState> screenshots = [];

  bool heroScreenshotRequired = false;

  /// Clean forward changes in the history.
  ///
  /// This method removes any changes made after the current edit position in the history.
  void cleanForwardChanges() {
    if (stateHistory.length > 1) {
      while (editPosition < stateHistory.length - 1) {
        stateHistory.removeLast();
      }
      while (editPosition < screenshots.length) {
        screenshots.removeLast();
      }
    }
    editPosition = stateHistory.length - 1;
  }

  /// Get the active screenshot.
  ///
  /// Returns the screenshot at the current edit position.
  Future<Uint8List> get activeScreenshot {
    return screenshots[editPosition - 1].completer.future;
  }

  /// Check if the active screenshot is broken.
  bool get activeScreenshotIsBroken => screenshots[editPosition - 1].broken;

  /// Capture an image of the current editor state in an isolate.
  ///
  /// This method captures the current state of the image editor as a screenshot.
  /// It sets all previously unprocessed screenshots to broken before capturing a new one.
  ///
  /// - `screenshotCtrl`: The controller to capture the screenshot.
  /// - `configs`: Configuration for the image editor.
  /// - `pixelRatio`: The pixel ratio to use for capturing the screenshot.
  void isolateCaptureImage({
    required ContentRecorderController screenshotCtrl,
    required ProImageEditorConfigs configs,
    required double? pixelRatio,
  }) async {
    /// Set every screenshot to broken which didn't read the ui image before
    /// changes happen.
    screenshots.where((el) => !el.readedRenderedImage).forEach((screenshot) {
      screenshot.broken = true;
    });

    _IsolateCaptureState isolateCaptureState = _IsolateCaptureState();
    screenshots.add(isolateCaptureState);
    Uint8List? bytes = await screenshotCtrl.capture(
      configs: configs,
      completerId: isolateCaptureState.id,
      pixelRatio: configs.removeTransparentAreas ? null : pixelRatio,
      onImageCaptured: (img) {
        isolateCaptureState.readedRenderedImage = true;
      },
    );
    isolateCaptureState.completer.complete(bytes ?? Uint8List.fromList([]));
    if (bytes == null) {
      isolateCaptureState.broken = true;
    }
  }
}

/// A class representing the state of an isolate capture.
class _IsolateCaptureState {
  bool broken = false;
  bool readedRenderedImage = false;
  late String id;
  late Completer<Uint8List> completer;

  _IsolateCaptureState() {
    completer = Completer.sync();
    id = generateUniqueId();
  }
}
