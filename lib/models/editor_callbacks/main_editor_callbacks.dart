// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../layer/layer.dart';
import 'standalone_editor_callbacks.dart';
import 'utils/sub_editors_name.dart';

/// A class representing callbacks for the main editor.
class MainEditorCallbacks extends StandaloneEditorCallbacks {
  /// Creates a new instance of [MainEditorCallbacks].
  const MainEditorCallbacks({
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onPopInvoked,
    this.onAddLayer,
    this.onUpdateLayer,
    this.onRemoveLayer,
    this.onOpenSubEditor,
    this.onCloseSubEditor,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
    this.onEditorZoomScaleStart,
    this.onEditorZoomScaleUpdate,
    this.onEditorZoomScaleEnd,
    super.onInit,
    super.onAfterViewInit,
    super.onUpdateUI,
    super.onDone,
    super.onRedo,
    super.onUndo,
  });

  /// A callback function that is triggered when a layer is added.
  ///
  /// The [Layer] parameter provides information about the added layer.
  final ValueChanged<Layer>? onAddLayer;

  /// A callback function that is triggered when a layer is updated.
  ///
  /// The [Layer] parameter provides information about the updated layer.
  final ValueChanged<Layer>? onUpdateLayer;

  /// A callback function that is triggered when a layer is removed.
  ///
  /// The [Layer] parameter provides information about the removed layer.
  final ValueChanged<Layer>? onRemoveLayer;

  /// A callback function that is triggered when a sub-editor is opened.
  ///
  /// The [SubEditor] parameter provides information about the opened
  /// sub-editor.
  final ValueChanged<SubEditor>? onOpenSubEditor;

  /// A callback function that is triggered when a sub-editor is closed.
  ///
  /// The [SubEditor] parameter provides information about the closed
  /// sub-editor.
  final ValueChanged<SubEditor>? onCloseSubEditor;

  /// A callback function that is triggered when the user `tap` on the body.
  final Function()? onTap;

  /// A callback function that is triggered when the user `doubleTap`
  /// on the body.
  final Function()? onDoubleTap;

  /// A callback function that is triggered when the user `longPress`
  /// on the body.
  final Function()? onLongPress;

  /// A callback function that is triggered when a scaling gesture starts.
  ///
  /// The [ScaleStartDetails] parameter provides information about the scaling
  /// gesture.
  final ValueChanged<ScaleStartDetails>? onScaleStart;

  /// A callback function that is triggered when a scaling gesture is updated.
  ///
  /// The [ScaleUpdateDetails] parameter provides information about the scaling
  /// gesture.
  final ValueChanged<ScaleUpdateDetails>? onScaleUpdate;

  /// A callback function that is triggered when a scaling gesture ends.
  ///
  /// The [ScaleEndDetails] parameter provides information about the scaling
  /// gesture.
  final ValueChanged<ScaleEndDetails>? onScaleEnd;

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
  ///    interaction.
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
  ///    interaction.
  ///  * [onEditorZoomScaleEnd], which handles the end of the same interaction.
  final GestureScaleUpdateCallback? onEditorZoomScaleUpdate;

  /// {@template flutter.widgets.PopScope.onPopInvoked}
  /// Called after a route pop was handled.
  /// {@endtemplate}
  ///
  /// It's not possible to prevent the pop from happening at the time that this
  /// method is called; the pop has already happened.
  ///
  /// This will still be called even when the pop is canceled. A pop is canceled
  /// when the relevant [Route.popDisposition] returns false, such as when
  /// [canPop] is set to false on a [PopScope]. The `didPop` parameter
  /// indicates whether or not the back navigation actually happened
  /// successfully.
  ///
  /// See also:
  ///
  ///  * [Route.onPopInvokedWithResult], which is similar.
  final PopInvokedWithResultCallback<dynamic>? onPopInvoked;

  /// Handles the addition of a layer.
  ///
  /// This method calls the [onAddLayer] callback with the provided [layer]
  /// and then calls [handleUpdateUI].
  void handleAddLayer(Layer layer) {
    onAddLayer?.call(layer);
    handleUpdateUI();
  }

  /// Handles the update of a layer.
  ///
  /// This method calls the [onUpdateLayer] callback with the provided [layer]
  /// and then calls [handleUpdateUI].
  void handleUpdateLayer(Layer layer) {
    onUpdateLayer?.call(layer);
    handleUpdateUI();
  }

  /// Handles the removal of a layer.
  ///
  /// This method calls the [onRemoveLayer] callback with the provided [layer]
  /// and then calls [handleUpdateUI].
  void handleRemoveLayer(Layer layer) {
    onRemoveLayer?.call(layer);
    handleUpdateUI();
  }

  /// Handles the opening of a sub-editor.
  ///
  /// This method calls the [onOpenSubEditor] callback with the provided
  /// [subEditor] and then calls [handleUpdateUI].
  void handleOpenSubEditor(SubEditor subEditor) {
    onOpenSubEditor?.call(subEditor);
    handleUpdateUI();
  }

  /// Handles the closing of a sub-editor.
  ///
  /// This method calls the [onCloseSubEditor] callback with the provided
  /// [subEditor] and then calls [handleUpdateUI].
  void handleCloseSubEditor(SubEditor subEditor) {
    onCloseSubEditor?.call(subEditor);
    handleUpdateUI();
  }

  /// Handles the start of a scaling gesture.
  ///
  /// This method calls the [onScaleStart] callback with the provided [details]
  /// and then calls [handleUpdateUI].
  void handleScaleStart(ScaleStartDetails details) {
    onScaleStart?.call(details);
    handleUpdateUI();
  }

  /// Handles the update of a scaling gesture.
  ///
  /// This method calls the [onScaleUpdate] callback with the provided [details]
  /// and then calls [handleUpdateUI].
  void handleScaleUpdate(ScaleUpdateDetails details) {
    onScaleUpdate?.call(details);
    handleUpdateUI();
  }

  /// Handles the end of a scaling gesture.
  ///
  /// This method calls the [onScaleEnd] callback with the provided [details]
  /// and then calls [handleUpdateUI].
  void handleScaleEnd(ScaleEndDetails details) {
    onScaleEnd?.call(details);
    handleUpdateUI();
  }
}
