import 'dart:math';

import 'package:flutter/material.dart';

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

  int _historyIndex = 0;
  @protected
  int rotationCount = 0;
  @protected
  double oldScaleFactor = 1;
  @protected
  double get zoomFactor => aspectRatioZoomHelper * userZoom;
  @protected
  late double aspectRatio;
  @protected
  double aspectRatioZoomHelper = 1;
  @protected
  double userZoom = 1;

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

  final List<TransformConfigs> history = [TransformConfigs.empty()];

  /// Retrieves the active transformation history.
  TransformConfigs get activeHistory => history[_historyIndex];

  /// Determines whether undo actions can be performed on the current state.
  bool get canUndo => _historyIndex > 0;

  /// Determines whether redo actions can be performed on the current state.
  bool get canRedo => _historyIndex < history.length - 1;

  /// Adds the current transformation to the history.
  void addHistory() {
    if (!initialized) return;
    cleanForwardChanges();
    history.add(
      TransformConfigs(
        angle: rotateAnimation.value,
        cropRect: cropRect,
        scaleAspectRatio: aspectRatioZoomHelper,
        scaleUser: userZoom,
        scaleRotation: scaleAnimation.value,
        aspectRatio: aspectRatio,
        flipX: flipX,
        flipY: flipY,
        offset: translate,
      ),
    );
    _historyIndex++;
    onUpdateUI?.call();
  }

  /// Clears forward changes from the history.
  void cleanForwardChanges() {
    if (history.length > 1) {
      while (_historyIndex < history.length - 1) {
        history.removeLast();
      }
    }
    _historyIndex = history.length - 1;
  }

  /// Undoes the last action performed in the painting editor.
  void undoAction() {
    if (canUndo) {
      setState(() {
        _historyIndex--;
        _setParametersFromHistory();
      });
    }
  }

  /// Redoes the previously undone action in the painting editor.
  void redoAction() {
    if (canRedo) {
      setState(() {
        _historyIndex++;
        _setParametersFromHistory();
      });
    }
  }

  /// Sets parameters based on the active history.
  void _setParametersFromHistory() {
    flipX = activeHistory.flipX;
    flipY = activeHistory.flipY;
    translate = activeHistory.offset;
    userZoom = activeHistory.scaleUser;
    aspectRatio = activeHistory.aspectRatio;
    cropRect = activeHistory.cropRect;

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
    calcAspectRatioZoomHelper();
    calcFitToScreen();
    onUpdateUI?.call();
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
    aspectRatioZoomHelper = 1;
    aspectRatio =
        cropRotateEditorConfigs.initAspectRatio ?? CropAspectRatios.custom;

    calcCropRect();
    calcAspectRatioZoomHelper();
    calcFitToScreen();

    initialized = true;
    if (!skipAddHistory) {
      addHistory();
    }

    setState(() {});
  }

  @protected
  void calcCropRect() {}
  @protected
  void calcAspectRatioZoomHelper() {}
  @protected
  calcFitToScreen() {}
}
