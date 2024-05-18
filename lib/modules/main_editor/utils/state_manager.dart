// Dart imports:
// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

// Project imports:
import 'package:flutter/foundation.dart';
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
  /// Position in the state history.
  int position = 0;

  /// List to store the history of image editor changes.
  List<EditorStateHistory> stateHistory = [];

  /// Get the list of filters from the current image editor changes.
  List<FilterStateHistory> get activeFilters => stateHistory[position].filters;

  /// Get the transformconfigurations from the crop/ rotate editor.
  TransformConfigs get transformConfigs =>
      stateHistory[position].transformConfigs;

  /// Get the blur state from the current image editor changes.
  BlurStateHistory get activeBlur => stateHistory[position].blur;

  /// Get the list of layers from the current image editor changes.
  List<Layer> get activeLayers => stateHistory[position].layers;

  /// List of captured screenshots for each state in the history.
  List<_IsolateCaptureState> screenshots = [];

  /// Flag indicating if a hero screenshot is required.
  bool heroScreenshotRequired = false;

  /// Clean forward changes in the history.
  ///
  /// This method removes any changes made after the current edit position in the history.
  /// It ensures that the state history and screenshots are consistent with the current
  /// position. This is useful when performing an undo operation, and new edits are made,
  /// effectively discarding the "redo" history.
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
  /// This method sets a limit on the number of states that can be stored in the history.
  /// If the number of stored states exceeds this limit, the oldest states are removed to
  /// free up memory. This is crucial for preventing excessive memory usage, especially when
  /// each state includes large data such as screenshots.
  ///
  /// - `limit`: The maximum number of states to retain in the history. Must be 1 or greater.
  void setHistoryLimit(int limit) {
    if (limit <= 0) {
      throw ErrorHint('The state history limit must be 1 or greater!');
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

  /// Get the active screenshot.
  ///
  /// Returns the screenshot at the current edit position.
  Future<Uint8List> get activeScreenshot {
    return screenshots[position - 1].completer.future;
  }

  /// Check if the active screenshot is broken.
  bool get activeScreenshotIsBroken => screenshots[position - 1].broken;

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
