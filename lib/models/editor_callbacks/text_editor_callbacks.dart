// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../layer/layer_background_mode.dart';
import 'standalone_editor_callbacks.dart';

/// A class representing callbacks for the text editor.
class TextEditorCallbacks extends StandaloneEditorCallbacks {
  /// Creates a new instance of [TextEditorCallbacks].
  const TextEditorCallbacks({
    this.onChanged,
    this.onEditingComplete,
    this.onColorChanged,
    this.onSubmitted,
    this.onTextAlignChanged,
    this.onFontScaleChanged,
    this.onBackgroundModeChanged,
    super.onInit,
    super.onAfterViewInit,
    super.onDone,
    super.onCloseEditor,
    super.onUpdateUI,
  });

  /// A callback that is called when the value changes.
  ///
  /// This field holds a function that will be called when the value changes.
  /// The function takes a single parameter of type [String], which represents
  /// the new value.
  final ValueChanged<String>? onChanged;

  /// A callback that is called when the editing is complete.
  ///
  /// This field holds a function that will be called when the user has finished
  /// editing. It does not take any parameters and does not return a value.
  final VoidCallback? onEditingComplete;

  /// A callback that is called when the value is submitted.
  ///
  /// This field holds a function that will be called when the user submits the
  /// value (e.g., by pressing the enter key). The function takes a single
  /// parameter of type [String], which represents the submitted value.
  final ValueChanged<String>? onSubmitted;

  /// A callback that is called when the color is changed.
  ///
  /// This field holds a function that will be called when the color is changed.
  /// The function takes a single parameter of type [int], which represents the
  /// new color.
  final ValueChanged<int>? onColorChanged;

  /// A callback that is called when the text alignment is changed.
  ///
  /// This field holds a function that will be called when the text alignment
  /// is changed.
  /// The function takes a single parameter of type [TextAlign], which
  /// represents the new text alignment.
  final ValueChanged<TextAlign>? onTextAlignChanged;

  /// A callback that is called when the font scale is changed.
  ///
  /// This field holds a function that will be called when the font scale is
  /// changed.
  /// The function takes a single parameter of type [double], which represents
  /// the new font scale.
  final ValueChanged<double>? onFontScaleChanged;

  /// A callback that is called when the background mode is changed.
  ///
  /// This field holds a function that will be called when the background mode
  /// is changed.
  /// The function takes a single parameter of type [LayerBackgroundColorModeE],
  /// which represents the new background mode.
  final ValueChanged<LayerBackgroundMode>? onBackgroundModeChanged;

  /// Handles the value change event.
  ///
  /// This method calls the [onChanged] callback with the provided [newValue]
  /// and then calls [handleUpdateUI].
  void handleChanged(String newValue) {
    onChanged?.call(newValue);
    handleUpdateUI();
  }

  /// Handles the editing complete event.
  ///
  /// This method calls the [onEditingComplete] callback and then calls
  /// [handleUpdateUI].
  void handleEditingComplete() {
    onEditingComplete?.call();
    handleUpdateUI();
  }

  /// Handles the value submitted event.
  ///
  /// This method calls the [onSubmitted] callback with the provided [newValue]
  /// and then calls [handleUpdateUI].
  void handleSubmitted(String newValue) {
    onSubmitted?.call(newValue);
    handleUpdateUI();
  }

  /// Handles the color change event.
  ///
  /// This method calls the [onColorChanged] callback with the provided
  /// [newColor] and then calls [handleUpdateUI].
  void handleColorChanged(int newColor) {
    onColorChanged?.call(newColor);
    handleUpdateUI();
  }

  /// Handles the text alignment change event.
  ///
  /// This method calls the [onTextAlignChanged] callback with the provided
  /// [newTextAlign] and then calls [handleUpdateUI].
  void handleTextAlignChanged(TextAlign newTextAlign) {
    onTextAlignChanged?.call(newTextAlign);
    handleUpdateUI();
  }

  /// Handles the font scale change event.
  ///
  /// This method calls the [onFontScaleChanged] callback with the provided
  /// [newScale] and then calls [handleUpdateUI].
  void handleFontScaleChanged(double newScale) {
    onFontScaleChanged?.call(newScale);
    handleUpdateUI();
  }

  /// Handles the background mode change event.
  ///
  /// This method calls the [onBackgroundModeChanged] callback with the
  /// provided [newMode] and then calls [handleUpdateUI].
  void handleBackgroundModeChanged(LayerBackgroundMode newMode) {
    onBackgroundModeChanged?.call(newMode);
    handleUpdateUI();
  }
}
