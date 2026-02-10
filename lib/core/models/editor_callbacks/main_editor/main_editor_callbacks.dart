// Flutter imports:
import 'package:flutter/widgets.dart';

import '/features/main_editor/main_editor.dart';
import '/features/main_editor/services/state_manager.dart';
import '/shared/services/import_export/import_state_history.dart';
import '../../../enums/sub_editors_name.dart';
import '../../layers/layer.dart';
import '../standalone_editor_callbacks.dart';
import 'helper_lines/helper_lines_callbacks.dart';

export 'helper_lines/helper_lines_callbacks.dart';

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
    this.onStartCloseSubEditor,
    this.onEndCloseSubEditor,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
    this.onEditorZoomScaleStart,
    this.onEditorZoomScaleUpdate,
    this.onEditorZoomScaleEnd,
    this.onEscapeButton,
    this.onKeyboardEvent,
    this.helperLines = const HelperLinesCallbacks(),
    this.onSelectedLayerChanged,
    this.onSelectedLayersChanged,
    this.onEditorZoomMatrix4Change,
    this.onLayerTapDown,
    this.onLayerTapUp,
    this.onImportHistoryStart,
    this.onImportHistoryEnd,
    this.onHoverRemoveAreaChange,
    this.onStateHistoryChange,
    this.onImageDecoded,
    this.onEditTextLayer,
    this.onCreateTextLayer,
    super.onInit,
    super.onAfterViewInit,
    super.onUpdateUI,
    super.onDone,
    super.onRedo,
    super.onUndo,
  });

  /// Callback triggered when a layer receives a tap down event.
  ///
  /// The [Layer] parameter provides the layer that was tapped.
  final Function(Layer layer)? onLayerTapDown;

  /// Callback triggered when a layer receives a tap up event.
  ///
  /// The [Layer] parameter provides the layer that was tapped.
  final Function(Layer layer)? onLayerTapUp;

  /// A callback function that is triggered when a layer is added.
  ///
  /// The [Layer] parameter provides information about the added layer.
  final Function(Layer layer)? onAddLayer;

  /// A callback function that is triggered when a layer is updated.
  ///
  /// The [Layer] parameter provides information about the updated layer.
  final Function(Layer layer)? onUpdateLayer;

  /// A callback function that is triggered when a layer is removed.
  ///
  /// The [Layer] parameter provides information about the removed layer.
  final Function(Layer layer)? onRemoveLayer;

  /// A callback function that is triggered when a sub-editor is opened.
  ///
  /// The [SubEditor] parameter provides information about the opened
  /// sub-editor.
  final Function(SubEditor editor)? onOpenSubEditor;

  /// A callback that is triggered when a sub-editor finishes closing.
  ///
  /// The [onEndCloseSubEditor] callback is triggered when a sub-editor has
  /// fully closed. It receives the [SubEditor] that was closed as its argument,
  /// allowing the parent widget to respond accordingly, such as cleaning up
  /// resources or updating the UI.
  ///
  /// This can be `null` if no action is required when the sub-editor closes.
  final Function(SubEditor editor)? onEndCloseSubEditor;

  /// A callback that is triggered when a sub-editor starts to close.
  ///
  /// The [onStartCloseSubEditor] callback is triggered when the process of
  /// closing a sub-editor begins. It receives the [SubEditor] that is about
  /// to close as its argument, allowing the parent widget to take any necessary
  /// actions, such as preparing the UI for the transition or saving state.
  ///
  /// This can be `null` if no action is required at the start of the close
  /// process.
  final Function(SubEditor editor)? onStartCloseSubEditor;

  /// Callback that is triggered whenever the state history of the editor
  /// changes.
  final Function(StateManager stateHistory, ProImageEditorState editor)?
      onStateHistoryChange;

  /// Callback that is triggered after the image has been successfully decoded.
  final Function()? onImageDecoded;

  /// A callback function that allows opening a custom text editor when a
  /// [TextLayer] is tapped.
  ///
  /// If this callback is provided and returns a non-null [TextLayer], the
  /// returned layer will be used to update the existing layer. If the callback
  /// returns `null`, no changes will be made.
  ///
  /// If this callback is not provided, the default text editor will be opened.
  ///
  /// Example usage:
  /// ```dart
  /// onEditTextLayer: (layer) async {
  ///   // Open your custom text editor
  ///   final result = await Navigator.push(
  ///     context,
  ///     MaterialPageRoute(
  ///       builder: (context) => MyCustomTextEditor(layer: layer),
  ///     ),
  ///   );
  ///   return result; // Return the updated TextLayer or null
  /// },
  /// ```
  final Future<TextLayer?> Function(TextLayer layer)? onEditTextLayer;

  /// A callback function that allows opening a custom text editor when
  /// creating a new text layer.
  ///
  /// If this callback is provided and returns a non-null [TextLayer], the
  /// returned layer will be added to the editor. If the callback returns
  /// `null`, no layer will be added.
  ///
  /// If this callback is not provided, the default text editor will be opened.
  ///
  /// Example usage:
  /// ```dart
  /// onCreateTextLayer: () async {
  ///   // Open your custom text editor for creating a new layer
  ///   final result = await Navigator.push(
  ///     context,
  ///     MaterialPageRoute(
  ///       builder: (context) => MyCustomTextEditor(),
  ///     ),
  ///   );
  ///   return result; // Return the new TextLayer or null
  /// },
  /// ```
  final Future<TextLayer?> Function()? onCreateTextLayer;

  /// A callback function that is triggered when the user `tap` on the body.
  final Function()? onTap;

  /// A callback function that is triggered when the user `doubleTap`
  /// on the body.
  final Function()? onDoubleTap;

  /// A callback function that is triggered when the user `longPress`
  /// on the body.
  final Function()? onLongPress;

  /// A function that handles pressing the ESC key.
  ///
  /// This function is called when the ESC key is pressed.
  /// By default it is null, which runs the default "close" behavior.
  final Function()? onEscapeButton;

  /// Callback invoked when a keyboard event occurs.
  ///
  /// If this function returns `true`, the keyboard event will be consumed and
  /// not propagated further. Returning `false` or `null` allows the event to
  /// continue propagating.
  ///
  /// Example usage:
  /// ```dart
  /// onKeyboardEvent: (event) {
  ///   if (event.logicalKey == LogicalKeyboardKey.escape) {
  ///     // Handle Escape key and consume the event.
  ///     return true;
  ///   }
  ///   return false; // Let other keys propagate.
  /// },
  /// ```
  final bool Function(KeyEvent event)? onKeyboardEvent;

  /// Callback triggered when the import of the editor's history starts.
  ///
  /// [state] provides the current state of the ProImageEditor.
  /// [import] contains information about the import operation.

  /// Callback triggered when the import of the editor's history ends.
  ///
  /// [state] provides the current state of the ProImageEditor.
  /// [import] contains information about the import operation.
  final Function(ProImageEditorState state, ImportStateHistory import)?
      onImportHistoryStart;

  /// Callback triggered when the import of the editor's history is done.
  ///
  /// [state] provides the current state of the ProImageEditor.
  /// [import] contains information about the import operation.

  /// Callback triggered when the import of the editor's history ends.
  ///
  /// [state] provides the current state of the ProImageEditor.
  /// [import] contains information about the import operation.
  final Function(ProImageEditorState state, ImportStateHistory import)?
      onImportHistoryEnd;

  /// A callback function that is triggered when a scaling gesture starts.
  ///
  /// The [ScaleStartDetails] parameter provides information about the scaling
  /// gesture.
  final Function(ScaleStartDetails value)? onScaleStart;

  /// A callback function that is triggered when a scaling gesture is updated.
  ///
  /// The [ScaleUpdateDetails] parameter provides information about the scaling
  /// gesture.
  final Function(ScaleUpdateDetails value)? onScaleUpdate;

  /// A callback function that is triggered when a scaling gesture ends.
  ///
  /// The [ScaleEndDetails] parameter provides information about the scaling
  /// gesture.
  final Function(ScaleEndDetails value)? onScaleEnd;

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

  /// Called when the editor zoom matrix changes.
  final Function(Matrix4 value)? onEditorZoomMatrix4Change;

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

  /// An instance of [HelperLinesCallbacks] that manages callback functions
  /// for handling helper line hit events.
  final HelperLinesCallbacks helperLines;

  /// A callback that is called when the selected layer of layer interaction
  /// manager changes.
  ///
  /// The callback is called with the id of the newly selected layer. If no
  /// layer is selected, the callback is called with blank.
  ///
  /// This callback is not called when [LayerInteractionSelectable] is disabled.
  final Function(String value)? onSelectedLayerChanged;

  /// A callback that is triggered when the set of selected layers changes.
  ///
  /// Called with the updated set of selected layer IDs.
  ///
  /// This callback is **not triggered** when [LayerInteractionSelectable] is
  /// disabled.
  final Function(Set<String> value)? onSelectedLayersChanged;

  /// Callback that is triggered when the hover state over the remove area
  /// changes.
  ///
  /// The [isPointerInside] parameter indicates whether the pointer is
  /// currently inside the remove area (`true`) or not (`false`). This can be
  /// used to update UI elements or trigger specific actions when the user
  /// hovers over or leaves the remove area.
  final Function(bool isPointerInside)? onHoverRemoveAreaChange;

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

  /// Handles the process when a sub-editor finishes closing.
  ///
  /// The [handleEndCloseSubEditor] method is called when a sub-editor has
  /// fully closed. It first triggers the [onEndCloseSubEditor] callback,
  /// if it has been provided, and then calls [handleUpdateUI] to update
  /// the user interface after the sub-editor has closed.
  ///
  /// * [subEditor] - The sub-editor that has finished closing.
  void handleEndCloseSubEditor(SubEditor subEditor) {
    onEndCloseSubEditor?.call(subEditor);
    handleUpdateUI();
  }

  /// Handles the process when a sub-editor starts closing.
  ///
  /// The [handleStartCloseSubEditor] method is called when a sub-editor begins
  /// the process of closing. It first triggers the [onStartCloseSubEditor]
  /// callback, if it has been provided, and then calls [handleUpdateUI] to
  /// update the user interface as the sub-editor starts to close.
  ///
  /// * [subEditor] - The sub-editor that is starting to close.
  void handleStartCloseSubEditor(SubEditor subEditor) {
    onStartCloseSubEditor?.call(subEditor);
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

  /// Creates a copy with modified editor callbacks.
  MainEditorCallbacks copyWith({
    Function(Layer layer)? onLayerTapDown,
    Function(Layer layer)? onLayerTapUp,
    Function(Layer layer)? onAddLayer,
    Function(Layer layer)? onUpdateLayer,
    Function(Layer layer)? onRemoveLayer,
    Function(SubEditor editor)? onOpenSubEditor,
    Function(SubEditor editor)? onEndCloseSubEditor,
    Function(SubEditor editor)? onStartCloseSubEditor,
    Function()? onTap,
    Function()? onDoubleTap,
    Function()? onLongPress,
    Function()? onEscapeButton,
    bool Function(KeyEvent event)? onKeyboardEvent,
    Function(ScaleStartDetails)? onScaleStart,
    Function(ScaleUpdateDetails)? onScaleUpdate,
    Function(ScaleEndDetails)? onScaleEnd,
    GestureScaleEndCallback? onEditorZoomScaleEnd,
    GestureScaleStartCallback? onEditorZoomScaleStart,
    GestureScaleUpdateCallback? onEditorZoomScaleUpdate,
    Function(Matrix4 value)? onEditorZoomMatrix4Change,
    PopInvokedWithResultCallback<dynamic>? onPopInvoked,
    HelperLinesCallbacks? helperLines,
    Function(String value)? onSelectedLayerChanged,
    Function(Set<String> value)? onSelectedLayersChanged,
    Function()? onInit,
    Function()? onAfterViewInit,
    Function()? onUpdateUI,
    Function()? onDone,
    Function()? onRedo,
    Function()? onUndo,
    Function()? onImageDecoded,
    Future<TextLayer?> Function(TextLayer layer)? onEditTextLayer,
    Future<TextLayer?> Function()? onCreateTextLayer,
    Function(ProImageEditorState state, ImportStateHistory import)?
        onImportHistoryStart,
    Function(ProImageEditorState state, ImportStateHistory import)?
        onImportHistoryEnd,
    Function(bool isPointerInside)? onHoverRemoveAreaChange,
    Function(StateManager stateHistory, ProImageEditorState editor)?
        onStateHistoryChange,
  }) {
    return MainEditorCallbacks(
      onLayerTapDown: onLayerTapDown ?? this.onLayerTapDown,
      onLayerTapUp: onLayerTapUp ?? this.onLayerTapUp,
      onAddLayer: onAddLayer ?? this.onAddLayer,
      onUpdateLayer: onUpdateLayer ?? this.onUpdateLayer,
      onRemoveLayer: onRemoveLayer ?? this.onRemoveLayer,
      onOpenSubEditor: onOpenSubEditor ?? this.onOpenSubEditor,
      onEndCloseSubEditor: onEndCloseSubEditor ?? this.onEndCloseSubEditor,
      onStartCloseSubEditor:
          onStartCloseSubEditor ?? this.onStartCloseSubEditor,
      onTap: onTap ?? this.onTap,
      onDoubleTap: onDoubleTap ?? this.onDoubleTap,
      onLongPress: onLongPress ?? this.onLongPress,
      onEscapeButton: onEscapeButton ?? this.onEscapeButton,
      onKeyboardEvent: onKeyboardEvent ?? this.onKeyboardEvent,
      onScaleStart: onScaleStart ?? this.onScaleStart,
      onScaleUpdate: onScaleUpdate ?? this.onScaleUpdate,
      onScaleEnd: onScaleEnd ?? this.onScaleEnd,
      onEditorZoomScaleEnd: onEditorZoomScaleEnd ?? this.onEditorZoomScaleEnd,
      onEditorZoomScaleStart:
          onEditorZoomScaleStart ?? this.onEditorZoomScaleStart,
      onEditorZoomScaleUpdate:
          onEditorZoomScaleUpdate ?? this.onEditorZoomScaleUpdate,
      onEditorZoomMatrix4Change:
          onEditorZoomMatrix4Change ?? this.onEditorZoomMatrix4Change,
      onPopInvoked: onPopInvoked ?? this.onPopInvoked,
      helperLines: helperLines ?? this.helperLines,
      onSelectedLayerChanged:
          onSelectedLayerChanged ?? this.onSelectedLayerChanged,
      onSelectedLayersChanged:
          onSelectedLayersChanged ?? this.onSelectedLayersChanged,
      onInit: onInit ?? this.onInit,
      onAfterViewInit: onAfterViewInit ?? this.onAfterViewInit,
      onUpdateUI: onUpdateUI ?? this.onUpdateUI,
      onDone: onDone ?? this.onDone,
      onRedo: onRedo ?? this.onRedo,
      onUndo: onUndo ?? this.onUndo,
      onImageDecoded: onImageDecoded ?? this.onImageDecoded,
      onEditTextLayer: onEditTextLayer ?? this.onEditTextLayer,
      onCreateTextLayer: onCreateTextLayer ?? this.onCreateTextLayer,
      onImportHistoryStart: onImportHistoryStart ?? this.onImportHistoryStart,
      onImportHistoryEnd: onImportHistoryEnd ?? this.onImportHistoryEnd,
      onHoverRemoveAreaChange:
          onHoverRemoveAreaChange ?? this.onHoverRemoveAreaChange,
      onStateHistoryChange: onStateHistoryChange ?? this.onStateHistoryChange,
    );
  }
}
