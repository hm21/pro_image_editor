// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:pro_image_editor/modules/paint_editor/utils/paint_editor_enum.dart';
import 'standalone_editor_callbacks.dart';

/// A class representing callbacks for the paint editor.
class PaintEditorCallbacks extends StandaloneEditorCallbacks {
  /// Creates a new instance of [PaintEditorCallbacks].
  const PaintEditorCallbacks({
    this.onPaintModeChanged,
    this.onDrawingDone,
    this.onColorChanged,
    this.onLineWidthChanged,
    this.onToggleFill,
    this.onEditorZoomScaleStart,
    this.onEditorZoomScaleUpdate,
    this.onEditorZoomScaleEnd,
    this.onOpacityChange,
    super.onInit,
    super.onAfterViewInit,
    super.onUndo,
    super.onRedo,
    super.onDone,
    super.onCloseEditor,
    super.onUpdateUI,
  });

  /// A callback function that is triggered when the line width changes.
  ///
  /// The [ValueChanged<double>] parameter provides the new line width.
  final ValueChanged<double>? onLineWidthChanged;

  /// A callback function that is triggered when the paint mode changes.
  ///
  /// The [ValueChanged<PaintModeE>] parameter provides the new paint mode.
  final ValueChanged<PaintModeE>? onPaintModeChanged;

  /// A callback function that is triggered when the fill mode is toggled.
  ///
  /// The [ValueChanged<bool>] parameter provides the new fill mode state.
  final ValueChanged<bool>? onToggleFill;

  /// A callback function that is triggered when the opacity changed.
  ///
  /// The [ValueChanged<double>] parameter provides the new opacity level.
  final ValueChanged<double>? onOpacityChange;

  /// A callback function that is triggered when drawing is done.
  final Function()? onDrawingDone;

  /// A callback function that is triggered when the color is changed.
  final Function()? onColorChanged;

  /// Called when the user ends a pan or scale gesture on the widget.
  ///
  /// At the time this is called, the [TransformationController] will have
  /// already been updated to reflect the change caused by the interaction,
  /// though a pan may cause an inertia animation after this is called as well.
  ///
  /// {@template flutter.widgets.InteractiveViewer.onInteractionEnd}
  /// Will be called even if the interaction is disabled with [panEnabled] or
  /// [scaleEnabled] for both touch gestures and mouse interactions.
  ///
  /// A [GestureDetector] wrapping the InteractiveViewer will not respond to
  /// [GestureDetector.onScaleStart], [GestureDetector.onScaleUpdate], and
  /// [GestureDetector.onScaleEnd]. Use [onEditorZoomScaleStart],
  /// [onEditorZoomScaleUpdate], and [onEditorZoomScaleEnd] to respond to those
  /// gestures.
  /// {@endtemplate}
  ///
  /// See also:
  ///
  ///  * [onEditorZoomScaleStart], which handles the start of the same
  ///    interaction.
  ///  * [onEditorZoomScaleUpdate], which handles an update to the same
  ///    interaction.
  final GestureScaleEndCallback? onEditorZoomScaleEnd;

  /// Called when the user begins a pan or scale gesture on the editor.
  ///
  /// At the time this is called, the [TransformationController] will not have
  /// changed due to this interaction.
  ///
  /// {@macro flutter.widgets.InteractiveViewer.onInteractionEnd}
  ///
  /// The coordinates provided in the details' `focalPoint` and
  /// `localFocalPoint` are normal Flutter event coordinates, not
  /// InteractiveViewer scene coordinates. See
  /// [TransformationController.toScene] for how to convert these coordinates to
  /// scene coordinates relative to the child.
  ///
  /// See also:
  ///
  ///  * [onEditorZoomScaleUpdate], which handles an update to the same
  /// interaction.
  ///  * [onEditorZoomScaleEnd], which handles the end of the same interaction.
  final GestureScaleStartCallback? onEditorZoomScaleStart;

  /// Called when the user updates a pan or scale gesture on the editor.
  ///
  /// At the time this is called, the [TransformationController] will have
  /// already been updated to reflect the change caused by the interaction, if
  /// the interaction caused the matrix to change.
  ///
  /// {@macro flutter.widgets.InteractiveViewer.onEditorZoomScaleEnd}
  ///
  /// The coordinates provided in the details' `focalPoint` and
  /// `localFocalPoint` are normal Flutter event coordinates, not
  /// InteractiveViewer scene coordinates. See
  /// [TransformationController.toScene] for how to convert these coordinates to
  /// scene coordinates relative to the child.
  ///
  /// See also:
  ///
  ///  * [onEditorZoomScaleStart], which handles the start of the same
  /// interaction.
  ///  * [onEditorZoomScaleEnd], which handles the end of the same interaction.
  final GestureScaleUpdateCallback? onEditorZoomScaleUpdate;

  /// Handles the line width change event.
  ///
  /// This method calls the [onLineWidthChanged] callback with the provided
  /// [newWidth] and then calls [handleUpdateUI].
  void handleLineWidthChanged(double newWidth) {
    onLineWidthChanged?.call(newWidth);
    handleUpdateUI();
  }

  /// Handles the drawing done event.
  ///
  /// This method calls the [onDrawingDone] callback and then calls
  /// [handleUpdateUI].
  void handleDrawingDone() {
    onDrawingDone?.call();
    handleUpdateUI();
  }

  /// Handles the paint mode change event.
  ///
  /// This method calls the [onPaintModeChanged] callback with the provided
  /// [newMode] and then calls [handleUpdateUI].
  void handlePaintModeChanged(PaintModeE newMode) {
    onPaintModeChanged?.call(newMode);
    handleUpdateUI();
  }

  /// Handles the toggle fill event.
  ///
  /// This method calls the [onToggleFill] callback with the provided [fill]
  /// and then calls [handleUpdateUI].
  void handleToggleFill(bool fill) {
    onToggleFill?.call(fill);
    handleUpdateUI();
  }

  /// Handles the opacity change event.
  ///
  /// This method calls the [onToggleFill] callback with the provided [opacity]
  /// and then calls [handleUpdateUI].
  void handleOpacity(double opacity) {
    onOpacityChange?.call(opacity);
    handleUpdateUI();
  }

  /// Handles the color changed event.
  ///
  /// This method calls the [onColorChanged] callback and then calls
  /// [handleUpdateUI].
  void handleColorChanged() {
    onColorChanged?.call();
    handleUpdateUI();
  }
}
