// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../mixins/standalone_editor.dart';
import '../../../models/crop_rotate_editor/transform_factors.dart';
import '../../../models/init_configs/crop_rotate_editor_init_configs.dart';
import '../crop_rotate_editor.dart';
import 'crop_aspect_ratios.dart';

mixin CropAreaHistory
    on
        StandaloneEditorState<CropRotateEditor, CropRotateEditorInitConfigs>,
        State<CropRotateEditor> {
  @protected
  late AnimationController rotateCtrl;
  @protected
  late AnimationController scaleCtrl;
  @protected
  late Animation<double> rotateAnimation;
  @protected
  late Animation<double> scaleAnimation;

  @protected
  int rotationCount = 0;
  @protected
  double oldScaleFactor = 1;
  @protected
  double get zoomFactor => userZoom;
  @protected
  late double aspectRatio;
  @protected
  double userZoom = 1;
  @protected
  double cropEditorScreenRatio = 1;

  @protected
  bool flipX = false;
  @protected
  bool flipY = false;
  @protected
  bool initialized = false;

  @protected
  Offset translate = const Offset(0, 0);
  @protected
  Rect cropRect = Rect.zero;
  @protected
  Size originalSize = Size.zero;

  final List<TransformConfigs> history = [TransformConfigs.empty()];

  /// Retrieves the active transformation history.
  TransformConfigs get activeHistory => history[screenshotHistoryPosition];

  /// Determines whether undo actions can be performed on the current state.
  bool get canUndo => screenshotHistoryPosition > 0;

  /// Determines whether redo actions can be performed on the current state.
  bool get canRedo => screenshotHistoryPosition < history.length - 1;

  @protected
  void setInitHistory(TransformConfigs configs) {
    history.clear();
    history.add(configs);
  }

  /// Adds the current transformation to the history.
  void addHistory({double? scale, double? angle}) {
    if (!initialized) return;
    cleanForwardChanges();
    history.add(
      TransformConfigs(
        cropEditorScreenRatio: cropEditorScreenRatio,
        angle: angle ?? rotateAnimation.value,
        cropRect: cropRect,
        originalSize: originalSize,
        scaleUser: userZoom,
        scaleRotation: scale ?? scaleAnimation.value,
        aspectRatio: aspectRatio,
        flipX: flipX,
        flipY: flipY,
        offset: translate,
      ),
    );
    screenshotHistoryPosition++;
    takeScreenshot();
  }

  /// Clears forward changes from the history.
  void cleanForwardChanges() {
    if (history.length > 1) {
      while (screenshotHistoryPosition < history.length - 1) {
        history.removeLast();
      }
      while (screenshotHistoryPosition < screenshotHistory.length - 1) {
        screenshotHistory.removeLast();
      }
    }
    screenshotHistoryPosition = history.length - 1;
  }

  /// Undoes the last action performed in the painting editor.
  void undoAction() {
    if (canUndo) {
      setState(() {
        screenshotHistoryPosition--;
        if (screenshotHistoryPosition == 0) {
          reset(skipAddHistory: true);
        } else {
          _setParametersFromHistory();
        }
        cropRotateEditorCallbacks?.handleUndo();
      });
    }
  }

  /// Redoes the previously undone action in the painting editor.
  void redoAction() {
    if (canRedo) {
      setState(() {
        screenshotHistoryPosition++;
        _setParametersFromHistory();
        cropRotateEditorCallbacks?.handleRedo();
      });
    }
  }

  /// Sets parameters based on the active history.
  void _setParametersFromHistory() {
    flipX = activeHistory.flipX;
    flipY = activeHistory.flipY;
    translate = activeHistory.offset;
    userZoom = activeHistory.scaleUser;
    cropRect = activeHistory.cropRect;
    aspectRatio = activeHistory.aspectRatio < 0
        ? cropRect.size.aspectRatio
        : activeHistory.aspectRatio;

    rotationCount = (activeHistory.angle * 2 / pi).abs().toInt();
    rotateAnimation =
        Tween<double>(begin: rotateAnimation.value, end: activeHistory.angle)
            .animate(
      CurvedAnimation(
        parent: rotateCtrl,
        curve: cropRotateEditorConfigs.rotateAnimationCurve,
      ),
    );
    rotateCtrl
      ..reset()
      ..forward();

    calcCropRect();
    calcFitToScreen();
    // Important to set aspectRatio to -1 after calcCropRect that the viewRect
    // will have the correct size
    if (activeHistory.aspectRatio < 0) {
      aspectRatio = -1;
    }
  }

  void reset({
    bool skipAddHistory = false,
  }) {
    initialized = false;
    flipX = false;
    flipY = false;
    translate = Offset.zero;

    int rCount = rotationCount % 4;
    rotateAnimation =
        Tween<double>(begin: rCount == 3 ? pi / 2 : -rCount * pi / 2, end: 0)
            .animate(rotateCtrl);
    rotateCtrl
      ..reset()
      ..forward();
    rotationCount = 0;

    scaleAnimation = Tween<double>(begin: oldScaleFactor * zoomFactor, end: 1)
        .animate(scaleCtrl);
    scaleCtrl
      ..reset()
      ..forward();
    oldScaleFactor = 1;

    userZoom = 1;
    aspectRatio =
        cropRotateEditorConfigs.initAspectRatio ?? CropAspectRatios.custom;

    calcCropRect();
    calcFitToScreen();

    initialized = true;
    if (!skipAddHistory) {
      addHistory(
        scale: 1,
        angle: 0,
      );
    }

    cropRotateEditorCallbacks?.handleReset();
    setState(() {});
  }

  @protected
  void calcCropRect() {}
  @protected
  calcFitToScreen() {}
}
