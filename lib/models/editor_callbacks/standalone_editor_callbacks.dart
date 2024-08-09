// Project imports:
import 'package:flutter/widgets.dart';

import 'editor_callbacks_typedef.dart';

/// A class representing callbacks for standalone editors.
abstract class StandaloneEditorCallbacks {
  /// Creates a new instance of [StandaloneEditorCallbacks].
  const StandaloneEditorCallbacks({
    this.onUpdateUI,
    this.onUndo,
    this.onRedo,
    this.onDone,
    this.onCloseEditor,
    this.onInit,
    this.onAfterViewInit,
  });

  /// A callback function that can be used to update the UI from custom widgets.
  final UpdateUiCallback? onUpdateUI;

  /// A callback function that is triggered when the undo action is performed.
  final Function()? onUndo;

  /// A callback function that is triggered when the redo action is performed.
  final Function()? onRedo;

  /// A callback function that is triggered when the editing is done.
  final Function()? onDone;

  /// A callback function that is triggered when the editor is closed.
  final Function()? onCloseEditor;

  /// Called when this object is inserted into the tree.
  ///
  /// The framework will call this method exactly once for each [State] object
  /// it creates.
  final Function()? onInit;

  /// Called when this object is inserted into the tree and rendered in the
  /// `build`.
  ///
  /// The framework will call this method exactly once for each [State] object
  /// it creates.
  final Function()? onAfterViewInit;

  /// Handles the undo action.
  ///
  /// This method calls the [onUndo] callback and then calls [handleUpdateUI].
  void handleUndo() {
    onUndo?.call();
    handleUpdateUI();
  }

  /// Handles the redo action.
  ///
  /// This method calls the [onRedo] callback and then calls [handleUpdateUI].
  void handleRedo() {
    onRedo?.call();
    handleUpdateUI();
  }

  /// Handles the done action.
  ///
  /// This method calls the [onDone] callback and then calls [handleUpdateUI].
  void handleDone() {
    onDone?.call();
    handleUpdateUI();
  }

  /// Handles the close editor action.
  ///
  /// This method calls the [onCloseEditor] callback and then calls
  /// [handleUpdateUI].
  void handleCloseEditor() {
    onCloseEditor?.call();
    handleUpdateUI();
  }

  /// Handles the update UI action.
  ///
  /// This method calls the [onUpdateUI] callback.
  void handleUpdateUI() {
    onUpdateUI?.call();
  }
}
