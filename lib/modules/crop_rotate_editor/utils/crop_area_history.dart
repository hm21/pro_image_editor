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

/// A mixin providing functionality for managing the crop area history in an
/// image editor.
///
/// This mixin extends the standalone editor state for crop and rotate editors,
/// offering methods and properties to handle transformations, history
/// management, and user interactions with the crop area.
mixin CropAreaHistory
    on
        StandaloneEditorState<CropRotateEditor, CropRotateEditorInitConfigs>,
        State<CropRotateEditor> {
  /// Key for managing the translation state of the transformation.
  ///
  /// This key provides access to the `ExtendedTransformTranslateState`,
  /// allowing for direct manipulation of translation transformations.
  @protected
  final translateKey = GlobalKey<ExtendedTransformTranslateState>();

  /// Key for managing the user scale state of the transformation.
  ///
  /// This key provides access to the `ExtendedTransformScaleState`, allowing
  /// for direct manipulation of scaling transformations.
  final userScaleKey = GlobalKey<ExtendedTransformScaleState>();

  /// Key for managing the crop painter state.
  ///
  /// This key provides access to the `ExtendedCustomPaintState`, enabling
  /// updates to the custom paint widget used for displaying crop boundaries.
  final cropPainterKey = GlobalKey<ExtendedCustomPaintState>();

  /// Animation controller for handling rotation animations.
  ///
  /// This controller manages animations related to image rotation, providing
  /// smooth transitions between different rotation states.
  @protected
  late AnimationController rotateCtrl;

  /// Animation controller for handling scale animations.
  ///
  /// This controller manages animations related to image scaling, providing
  /// smooth transitions between different scale states.
  @protected
  late AnimationController scaleCtrl;

  /// Animation object representing the rotation of the image.
  ///
  /// This animation tracks the current rotation angle and updates the UI
  /// accordingly during rotation operations.
  @protected
  late Animation<double> rotateAnimation;

  /// Animation object representing the scale of the image.
  ///
  /// This animation tracks the current scale factor and updates the UI
  /// accordingly during scaling operations.
  @protected
  late Animation<double> scaleAnimation;

  /// Counter for tracking the number of 90-degree rotations applied.
  ///
  /// This counter is used to manage and apply cumulative rotation
  /// transformations.
  @protected
  int rotationCount = 0;

  /// The previous scale factor before the current scaling operation.
  ///
  /// This value is used to revert to the previous scale factor during undo
  /// operations or reset actions.
  @protected
  double oldScaleFactor = 1;

  double _userScaleFactor = 1;

  /// The current scale factor applied by the user.
  ///
  /// This property tracks the scaling transformation applied by the user,
  /// allowing for dynamic resizing of the image.
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

  /// The current translation offset applied to the image.
  ///
  /// This property tracks the translation transformation, enabling movement of
  /// the image within the editor.
  @protected
  Offset get translate => _translate;

  @protected
  set translate(Offset value) {
    _translate = value;
    translateKey.currentState?.setOffset(translate);
    cropPainterKey.currentState?.setForegroundPainter(cropPainter);
  }

  /// The painter for rendering crop corners and boundaries.
  ///
  /// This getter provides access to the painter used for displaying crop
  /// boundaries, which can be overridden for custom behavior.
  @protected
  CropCornerPainter? get cropPainter => null;

  /// Indicates whether to show additional widgets during editing.
  ///
  /// This boolean flag determines whether supplementary UI elements are
  /// displayed during crop and rotate operations.
  @protected
  bool showWidgets = false;

  /// The aspect ratio of the crop area.
  ///
  /// This value defines the ratio between width and height for the crop area,
  /// ensuring consistent aspect ratios during transformations.
  @protected
  late double aspectRatio;

  /// The screen ratio for the crop editor.
  ///
  /// This value represents the aspect ratio of the screen in the crop editor,
  /// influencing how images are displayed and cropped.
  @protected
  double cropEditorScreenRatio = 1;

  /// Returns the currently selected aspect ratio.
  ///
  /// This method retrieves the aspect ratio from the active history entry,
  /// providing a reference for current crop settings.
  ///
  /// Returns:
  ///   The aspect ratio of the current active history entry.
  double get activeAspectRatio {
    return activeHistory.aspectRatio;
  }

  /// Indicates whether the image is flipped horizontally.
  ///
  /// This flag tracks the horizontal flip state, affecting how the image is
  /// rendered during transformations.
  @protected
  bool flipX = false;

  /// Indicates whether the image is flipped vertically.
  ///
  /// This flag tracks the vertical flip state, affecting how the image is
  /// rendered during transformations.
  @protected
  bool flipY = false;

  /// Indicates whether the editor has been initialized.
  ///
  /// This boolean flag tracks whether the editor has completed its
  /// initialization process, allowing for safe application of transformations.
  @protected
  bool initialized = false;

  /// The current crop rectangle applied to the image.
  ///
  /// This property defines the area of the image that is visible after
  /// cropping, and is used to manage crop boundaries.
  @protected
  Rect get cropRect => _cropRect;

  set cropRect(Rect value) {
    _cropRect = value;
    cropPainterKey.currentState?.setForegroundPainter(cropPainter);
  }

  Rect _cropRect = Rect.zero;

  /// The original size of the image before transformations.
  ///
  /// This size represents the dimensions of the image in its unaltered state,
  /// providing a reference for transformations.
  @protected
  Size originalSize = Size.zero;

  /// A list of transformation configurations representing the history.
  ///
  /// This list stores each transformation state applied to the image,
  /// enabling undo and redo functionality.
  final List<TransformConfigs> history = [TransformConfigs.empty()];

  /// Retrieves the active transformation history.
  ///
  /// This getter returns the transformation configuration of the current
  /// state in the history, allowing for retrieval of applied settings.
  TransformConfigs get activeHistory => history[screenshotHistoryPosition];

  /// Determines whether undo actions can be performed on the current state.
  ///
  /// This boolean property returns `true` if there are previous states
  /// available in the history, allowing for undo operations.
  bool get canUndo => screenshotHistoryPosition > 0;

  /// Determines whether redo actions can be performed on the current state.
  ///
  /// This boolean property returns `true` if there are subsequent states
  /// available in the history, allowing for redo operations.
  bool get canRedo => screenshotHistoryPosition < history.length - 1;

  /// Initializes the transformation history with a specific configuration.
  ///
  /// This method clears any existing transformation history and sets the
  /// initial state with the provided configuration, preparing the editor for
  /// new transformations.
  ///
  /// Parameters:
  /// - [configs]: The initial transformation configuration to be added to the
  ///   history.
  ///
  /// Example:
  /// ```
  /// setInitHistory(TransformConfigs(
  ///   angle: 0,
  ///   cropRect: Rect.fromLTWH(0, 0, 100, 100),
  ///   originalSize: Size(200, 200),
  ///   cropEditorScreenRatio: 1.0,
  ///   scaleUser: 1.0,
  ///   scaleRotation: 1.0,
  ///   aspectRatio: 1.0,
  ///   flipX: false,
  ///   flipY: false,
  ///   offset: Offset.zero,
  /// ));
  /// ```
  @protected
  void setInitHistory(TransformConfigs configs) {
    history
      ..clear()
      ..add(configs);
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

  /// Resets the editor state to its initial configuration.
  ///
  /// This method resets all transformations applied to the image, such as
  /// scaling, rotation, and translation, and recalculates the crop rectangle
  /// and screen fitting. It optionally skips adding the reset state to the
  /// transformation history.
  ///
  /// Parameters:
  /// - [skipAddHistory]: A boolean flag indicating whether to skip adding the
  ///   reset state to the transformation history. Defaults to `false`.
  ///
  /// Example:
  /// ```
  /// reset(skipAddHistory: true);
  /// ```
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

  /// Calculates the crop rectangle for the image.
  ///
  /// This method determines the dimensions and position of the crop rectangle
  /// based on the current transformation state. It should be overridden to
  /// implement specific crop rectangle calculations.
  @protected
  void calcCropRect() {}

  /// Adjusts the image to fit the screen dimensions.
  ///
  /// This method recalculates the scale and positioning of the image to ensure
  /// it fits within the screen dimensions appropriately. It should be
  /// overridden to implement specific fitting logic.
  @protected
  calcFitToScreen() {}
}
