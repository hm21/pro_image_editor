// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:pro_image_editor/modules/paint_editor/utils/paint_editor_enum.dart';
import 'standalone_editor_callbacks.dart';

/// A class representing callbacks for the paint editor.
class PaintEditorCallbacks extends StandaloneEditorCallbacks {
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

  /// A callback function that is triggered when drawing is done.
  final Function()? onDrawingDone;

  /// A callback function that is triggered when the color is changed.
  final Function()? onColorChanged;

  /// Creates a new instance of [PaintEditorCallbacks].
  const PaintEditorCallbacks({
    this.onPaintModeChanged,
    this.onDrawingDone,
    this.onColorChanged,
    this.onLineWidthChanged,
    this.onToggleFill,
    super.onUndo,
    super.onRedo,
    super.onDone,
    super.onCloseEditor,
    super.onUpdateUI,
  });

  /// Handles the line width change event.
  ///
  /// This method calls the [onLineWidthChanged] callback with the provided [newWidth]
  /// and then calls [handleUpdateUI].
  void handleLineWidthChanged(double newWidth) {
    onLineWidthChanged?.call(newWidth);
    handleUpdateUI();
  }

  /// Handles the drawing done event.
  ///
  /// This method calls the [onDrawingDone] callback and then calls [handleUpdateUI].
  void handleDrawingDone() {
    onDrawingDone?.call();
    handleUpdateUI();
  }

  /// Handles the paint mode change event.
  ///
  /// This method calls the [onPaintModeChanged] callback with the provided [newMode]
  /// and then calls [handleUpdateUI].
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

  /// Handles the color changed event.
  ///
  /// This method calls the [onColorChanged] callback and then calls [handleUpdateUI].
  void handleColorChanged() {
    onColorChanged?.call();
    handleUpdateUI();
  }
}
