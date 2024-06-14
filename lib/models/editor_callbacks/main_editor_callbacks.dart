// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../layer/layer.dart';
import 'standalone_editor_callbacks.dart';
import 'utils/sub_editors_name.dart';

/// A class representing callbacks for the main editor.
class MainEditorCallbacks extends StandaloneEditorCallbacks {
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
  /// The [SubEditor] parameter provides information about the opened sub-editor.
  final ValueChanged<SubEditor>? onOpenSubEditor;

  /// A callback function that is triggered when a sub-editor is closed.
  ///
  /// The [SubEditor] parameter provides information about the closed sub-editor.
  final ValueChanged<SubEditor>? onCloseSubEditor;

  /// A callback function that is triggered when a scaling gesture starts.
  ///
  /// The [ScaleStartDetails] parameter provides information about the scaling gesture.
  final ValueChanged<ScaleStartDetails>? onScaleStart;

  /// A callback function that is triggered when a scaling gesture is updated.
  ///
  /// The [ScaleUpdateDetails] parameter provides information about the scaling gesture.
  final ValueChanged<ScaleUpdateDetails>? onScaleUpdate;

  /// A callback function that is triggered when a scaling gesture ends.
  ///
  /// The [ScaleEndDetails] parameter provides information about the scaling gesture.
  final ValueChanged<ScaleEndDetails>? onScaleEnd;

  /// Creates a new instance of [MainEditorCallbacks].
  const MainEditorCallbacks({
    this.onAddLayer,
    this.onUpdateLayer,
    this.onRemoveLayer,
    this.onOpenSubEditor,
    this.onCloseSubEditor,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
    super.onUpdateUI,
    super.onDone,
    super.onRedo,
    super.onUndo,
  });

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
  /// This method calls the [onOpenSubEditor] callback with the provided [subEditor]
  /// and then calls [handleUpdateUI].
  void handleOpenSubEditor(SubEditor subEditor) {
    onOpenSubEditor?.call(subEditor);
    handleUpdateUI();
  }

  /// Handles the closing of a sub-editor.
  ///
  /// This method calls the [onCloseSubEditor] callback with the provided [subEditor]
  /// and then calls [handleUpdateUI].
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
