// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../complete_parameters.dart';
import 'editor_callbacks_typedef.dart';
import 'standalone_editor_callbacks.dart';

/// A class representing callbacks for the crop-rotate editor.
class CropRotateEditorCallbacks extends StandaloneEditorCallbacks {
  /// Creates a new instance of [CropRotateEditorCallbacks].
  const CropRotateEditorCallbacks({
    this.onRotateStart,
    this.onRotateEnd,
    this.onFlip,
    this.onRatioSelected,
    this.onMove,
    this.onScale,
    this.onDoubleTap,
    this.onResize,
    this.onReset,
    this.onTransformUpdateEnd,
    super.onInit,
    super.onAfterViewInit,
    super.onUndo,
    super.onRedo,
    super.onDone,
    super.onCloseEditor,
    super.onUpdateUI,
  });

  /// A callback function that is triggered when a rotation gesture starts.
  ///
  /// The [ValueChanged<double>] parameter provides the initial rotation value.
  final ValueChanged<double>? onRotateStart;

  /// A callback function that is triggered when a rotation gesture ends.
  ///
  /// The [ValueChanged<double>] parameter provides the final rotation value.
  final ValueChanged<double>? onRotateEnd;

  /// A callback function that is triggered when the flip action is performed.
  ///
  /// The [FlipCallback] provides information on the flip actions for the x
  /// and y axes.
  final FlipCallback? onFlip;

  /// A callback function that is triggered when a ratio is selected.
  ///
  /// The [ValueChanged<double>] parameter provides the selected ratio value.
  final ValueChanged<double>? onRatioSelected;

  /// A callback function that is triggered when a move action is performed.
  final Function()? onMove;

  /// A callback function that is triggered when a resize action is performed.
  final Function()? onResize;

  /// A callback function that is triggered when a scale action is performed.
  final Function()? onScale;

  /// A callback function that is triggered when a double tap action is
  /// performed.
  final Function()? onDoubleTap;

  /// A callback function that is triggered when a reset action is performed.
  final Function()? onReset;

  /// Callback that is triggered when a transformation update ends.
  ///
  /// This callback is invoked when the user completes a gesture that modifies
  /// the crop or rotation transformation (e.g., releasing a pinch gesture or
  /// finishing a rotation gesture).
  ///
  /// The [parameters] contain information about the completed transformation,
  /// including the final state of the crop and rotation values.
  ///
  /// **IMPORTANT:** The `imageBytes` will always be empty.
  final Function(CompleteParameters parameters)? onTransformUpdateEnd;

  /// Handles the rotate start event.
  ///
  /// This method calls the [onRotateStart] callback with the provided [value]
  /// and then calls [handleUpdateUI].
  void handleRotateStart(double value) {
    onRotateStart?.call(value);
    handleUpdateUI();
  }

  /// Handles the rotate end event.
  ///
  /// This method calls the [onRotateEnd] callback with the provided [value]
  /// and then calls [handleUpdateUI].
  void handleRotateEnd(double value) {
    onRotateEnd?.call(value);
    handleUpdateUI();
  }

  /// Handles the flip event.
  ///
  /// This method calls the [onFlip] callback with the provided [flipX] and
  /// [flipY] and then calls [handleUpdateUI].
  void handleFlip(bool flipX, bool flipY) {
    onFlip?.call(flipX, flipY);
    handleUpdateUI();
  }

  /// Handles the ratio selected event.
  ///
  /// This method calls the [onRatioSelected] callback with the provided [value]
  /// and then calls [handleUpdateUI].
  void handleRatioSelected(double value) {
    onRatioSelected?.call(value);
    handleUpdateUI();
  }

  /// Handles the move event.
  ///
  /// This method calls the [onMove] callback and then calls [handleUpdateUI].
  void handleMove() {
    onMove?.call();
    handleUpdateUI();
  }

  /// Handles the scale event.
  ///
  /// This method calls the [onScale] callback and then calls [handleUpdateUI].
  void handleScale() {
    onScale?.call();
    handleUpdateUI();
  }

  /// Handles the double tap event.
  ///
  /// This method calls the [onDoubleTap] callback and then calls
  /// [handleUpdateUI].
  void handleDoubleTap() {
    onDoubleTap?.call();
    handleUpdateUI();
  }

  /// Handles the resize event.
  ///
  /// This method calls the [onResize] callback and then calls [handleUpdateUI].
  void handleResize() {
    onResize?.call();
    handleUpdateUI();
  }

  /// Handles the reset event.
  ///
  /// This method calls the [onReset] callback and then calls [handleUpdateUI].
  void handleReset() {
    onReset?.call();
    handleUpdateUI();
  }

  /// Creates a copy with modified editor callbacks.
  CropRotateEditorCallbacks copyWith({
    ValueChanged<double>? onRotateStart,
    ValueChanged<double>? onRotateEnd,
    FlipCallback? onFlip,
    ValueChanged<double>? onRatioSelected,
    Function()? onMove,
    Function()? onResize,
    Function()? onScale,
    Function()? onDoubleTap,
    Function()? onReset,
    Function()? onInit,
    Function()? onAfterViewInit,
    Function()? onUpdateUI,
    Function()? onDone,
    Function()? onRedo,
    Function()? onUndo,
    Function()? onCloseEditor,
    Function(CompleteParameters parameters)? onTransformUpdateEnd,
  }) {
    return CropRotateEditorCallbacks(
      onRotateStart: onRotateStart ?? this.onRotateStart,
      onRotateEnd: onRotateEnd ?? this.onRotateEnd,
      onFlip: onFlip ?? this.onFlip,
      onRatioSelected: onRatioSelected ?? this.onRatioSelected,
      onMove: onMove ?? this.onMove,
      onResize: onResize ?? this.onResize,
      onScale: onScale ?? this.onScale,
      onDoubleTap: onDoubleTap ?? this.onDoubleTap,
      onReset: onReset ?? this.onReset,
      onInit: onInit ?? this.onInit,
      onAfterViewInit: onAfterViewInit ?? this.onAfterViewInit,
      onUpdateUI: onUpdateUI ?? this.onUpdateUI,
      onDone: onDone ?? this.onDone,
      onRedo: onRedo ?? this.onRedo,
      onUndo: onUndo ?? this.onUndo,
      onCloseEditor: onCloseEditor ?? this.onCloseEditor,
      onTransformUpdateEnd: onTransformUpdateEnd ?? this.onTransformUpdateEnd,
    );
  }
}
