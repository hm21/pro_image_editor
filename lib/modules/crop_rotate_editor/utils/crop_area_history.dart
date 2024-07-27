// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../mixins/standalone_editor.dart';
import '../../../models/crop_rotate_editor/transform_factors.dart';
import '../../../models/init_configs/crop_rotate_editor_init_configs.dart';
import '../../../widgets/extended/extended_custom_paint.dart';
import '../../../widgets/extended/extended_transform_scale.dart';
import '../../../widgets/extended/extended_transform_translate.dart';
import '../crop_rotate_editor.dart';
import '../widgets/crop_corner_painter.dart';
import 'crop_aspect_ratios.dart';

mixin CropAreaHistory
    on
        StandaloneEditorState<CropRotateEditor, CropRotateEditorInitConfigs>,
        State<CropRotateEditor> {
  @protected
  final translateKey = GlobalKey<ExtendedTransformTranslateState>();
  final userScaleKey = GlobalKey<ExtendedTransformScaleState>();
  final cropPainterKey = GlobalKey<ExtendedCustomPaintState>();

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

  double _userScaleFactor = 1;
  @protected
  double get userScaleFactor => _userScaleFactor;
  @protected
  set userScaleFactor(double value) {
    _userScaleFactor = value;
    userScaleKey.currentState?.setScale(userScaleFactor);
    cropPainterKey.currentState?.update(
      foregroundPainter: cropPainter,
      isComplex: showWidgets,
      willChange: showWidgets,
    );
  }

  Offset _translate = const Offset(0, 0);
  @protected
  Offset get translate => _translate;
  @protected
  set translate(Offset value) {
    _translate = value;
    translateKey.currentState?.setOffset(translate);
    cropPainterKey.currentState?.setForegroundPainter(cropPainter);
  }

  @protected
  CropCornerPainter? get cropPainter => null;

  /// Indicates whether to show additional widgets.
  @protected
  bool showWidgets = false;

  @protected
  late double aspectRatio;
  @protected
  double cropEditorScreenRatio = 1;

  /// Returns the currently selected aspect ratio.
  ///
  /// This method retrieves the aspect ratio from the active history entry.
  ///
  /// Returns:
  ///   The aspect ratio of the current active history entry.
  double get activeAspectRatio {
    return activeHistory.aspectRatio;
  }

  @protected
  bool flipX = false;
  @protected
  bool flipY = false;
  @protected
  bool initialized = false;

  @protected
  Rect get cropRect => _cropRect;
  set cropRect(Rect value) {
    _cropRect = value;
    cropPainterKey.currentState?.setForegroundPainter(cropPainter);
  }

  Rect _cropRect = Rect.zero;

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
  void addHistory({double? scaleRotation, double? angle}) {
    if (!initialized) return;
    cleanForwardChanges();
    history.add(
      TransformConfigs(
        cropEditorScreenRatio: cropEditorScreenRatio,
        angle: angle ?? rotateAnimation.value,
        cropRect: cropRect,
        originalSize: originalSize,
        scaleUser: userScaleFactor,
        scaleRotation: scaleRotation ?? scaleAnimation.value,
        aspectRatio: aspectRatio,
        flipX: flipX,
        flipY: flipY,
        offset: translate,
      ),
    );
    screenshotHistoryPosition++;
    setState(() {});
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
    userScaleFactor = activeHistory.scaleUser;
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

    scaleAnimation =
        Tween<double>(begin: oldScaleFactor * userScaleFactor, end: 1)
            .animate(scaleCtrl);
    scaleCtrl
      ..reset()
      ..forward();
    oldScaleFactor = 1;

    userScaleFactor = 1;
    aspectRatio =
        cropRotateEditorConfigs.initAspectRatio ?? CropAspectRatios.custom;

    calcCropRect();
    calcFitToScreen();

    initialized = true;
    if (!skipAddHistory) {
      addHistory(
        scaleRotation: 1,
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
