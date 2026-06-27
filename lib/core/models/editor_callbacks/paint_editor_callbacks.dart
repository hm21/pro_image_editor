// Flutter imports:
import 'package:flutter/widgets.dart';

import '/features/paint_editor/paint_editor.dart';
import '../layers/paint_layer.dart';
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
    this.onEditorZoomMatrix4Change,
    this.onOpacityChange,
    this.onDoubleTap,
    this.onEditLayer,
    this.onTap,
    super.onInit,
    super.onAfterViewInit,
    super.onUndo,
    super.onRedo,
    super.onDone,
    super.onCloseEditor,
    super.onUpdateUI,
    super.onKeyboardEvent,
  });

  /// A callback function that is triggered when the line width changes.
  ///
  /// The [ValueChanged<double>] parameter provides the new line width.
  final ValueChanged<double>? onLineWidthChanged;

  /// A callback function that is triggered when the paint mode changes.
  ///
  /// The [ValueChanged<PaintMode>] parameter provides the new paint mode.
  final ValueChanged<PaintMode>? onPaintModeChanged;

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

  /// A callback function that is triggered when the user `doubleTap`
  /// on the body.
  final Function()? onDoubleTap;

  /// Callback function invoked when a paint layer is being edited.
  ///
  /// This function is called when the user attempts to edit an existing paint
  /// layer in the paint editor. It receives the current [PaintLayer] that is
  /// being edited and should return a [Future] that completes with the
  /// modified [PaintLayer], or `null` if the edit operation was
  /// cancelled or failed.
  ///
  /// Parameters:
  /// - [layer]: The paint layer that is being edited
  ///
  /// Returns:
  /// A [Future] that resolves to the updated [PaintLayer] if the edit was
  /// successful, or `null` if the edit was cancelled or unsuccessful.
  ///
  /// **Example:**
  /// ```dart
  ///  callbacks: ProImageEditorCallbacks(
  ///  paintEditorCallbacks: PaintEditorCallbacks(
  ///    onEditLayer: (layer) async {
  ///      return await Navigator.push<PaintLayer>(
  ///        context,
  ///        MaterialPageRoute(
  ///          builder: (context) {
  ///            return Scaffold(
  ///              appBar: AppBar(title: const Text('Layer-Editor')),
  ///              body: ListView(
  ///                children: [
  ///                  Container(
  ///                    clipBehavior: Clip.hardEdge,
  ///                    decoration: BoxDecoration(
  ///                      color: Colors.black,
  ///                      borderRadius: BorderRadius.circular(10),
  ///                    ),
  ///                    padding: const EdgeInsets.all(7),
  ///                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
  ///                    height: 140,
  ///                    child: FittedBox(
  ///                      child: SizedBox.fromSize(
  ///                        size: layer.rawSize,
  ///                        child: LayerWidgetPaintItem(
  ///                          willChange: true,
  ///                          layer: layer,
  ///                          paintEditorConfigs: const PaintEditorConfigs(),
  ///                        ),
  ///                      ),
  ///                    ),
  ///                  ),
  ///                  FilledButton(
  ///                    onPressed: () {
  ///                      Color randomColor() {
  ///                        final Random random = Random();
  ///                        return Color.fromARGB(
  ///                          255,
  ///                          random.nextInt(256),
  ///                          random.nextInt(256),
  ///                          random.nextInt(256),
  ///                        );
  ///                      }
  ///
  ///                      Navigator.pop(
  ///                        context,
  ///                        layer.copyWith(
  ///                          item: layer.item.copyWith(color: randomColor()),
  ///                        ),
  ///                      );
  ///                    },
  ///                    child: const Text('Toggle Color'),
  ///                  ),
  ///                ],
  ///              ),
  ///            );
  ///          },
  ///        ),
  ///      );
  ///    },
  ///  ),
  ///),
  /// ```
  final Future<PaintLayer?> Function(PaintLayer layer)? onEditLayer;

  /// Callback function that is triggered when a tap down event occurs on the
  /// canvas.
  ///
  /// The [details] parameter provides information about the position and
  /// characteristics of the tap event. This callback can be used to handle
  /// custom tap interactions within the paint editor.
  final Function(PaintEditorState editor, TapDownDetails details)? onTap;

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

  /// Called when the editor zoom matrix changes.
  final Function(Matrix4 value)? onEditorZoomMatrix4Change;

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
  void handlePaintModeChanged(PaintMode newMode) {
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

  /// Creates a copy with modified editor callbacks.
  PaintEditorCallbacks copyWith({
    ValueChanged<double>? onLineWidthChanged,
    ValueChanged<PaintMode>? onPaintModeChanged,
    ValueChanged<bool>? onToggleFill,
    ValueChanged<double>? onOpacityChange,
    Function()? onDrawingDone,
    Function()? onColorChanged,
    GestureScaleEndCallback? onEditorZoomScaleEnd,
    GestureScaleStartCallback? onEditorZoomScaleStart,
    Function(Matrix4 value)? onEditorZoomMatrix4Change,
    GestureScaleUpdateCallback? onEditorZoomScaleUpdate,
    Function()? onDoubleTap,
    Function(PaintEditorState editor, TapDownDetails details)? onTap,
    Function()? onInit,
    Function()? onAfterViewInit,
    Function()? onUpdateUI,
    Function()? onDone,
    Function()? onRedo,
    Function()? onUndo,
    Function()? onCloseEditor,
    bool Function(KeyEvent event)? onKeyboardEvent,
    Future<PaintLayer?> Function(PaintLayer layer)? onEditLayer,
  }) {
    return PaintEditorCallbacks(
      onKeyboardEvent: onKeyboardEvent ?? this.onKeyboardEvent,
      onLineWidthChanged: onLineWidthChanged ?? this.onLineWidthChanged,
      onPaintModeChanged: onPaintModeChanged ?? this.onPaintModeChanged,
      onToggleFill: onToggleFill ?? this.onToggleFill,
      onOpacityChange: onOpacityChange ?? this.onOpacityChange,
      onDrawingDone: onDrawingDone ?? this.onDrawingDone,
      onColorChanged: onColorChanged ?? this.onColorChanged,
      onEditorZoomScaleEnd: onEditorZoomScaleEnd ?? this.onEditorZoomScaleEnd,
      onEditorZoomScaleStart:
          onEditorZoomScaleStart ?? this.onEditorZoomScaleStart,
      onEditorZoomMatrix4Change:
          onEditorZoomMatrix4Change ?? this.onEditorZoomMatrix4Change,
      onEditorZoomScaleUpdate:
          onEditorZoomScaleUpdate ?? this.onEditorZoomScaleUpdate,
      onDoubleTap: onDoubleTap ?? this.onDoubleTap,
      onTap: onTap ?? this.onTap,
      onInit: onInit ?? this.onInit,
      onAfterViewInit: onAfterViewInit ?? this.onAfterViewInit,
      onUpdateUI: onUpdateUI ?? this.onUpdateUI,
      onDone: onDone ?? this.onDone,
      onRedo: onRedo ?? this.onRedo,
      onUndo: onUndo ?? this.onUndo,
      onCloseEditor: onCloseEditor ?? this.onCloseEditor,
      onEditLayer: onEditLayer ?? this.onEditLayer,
    );
  }
}
