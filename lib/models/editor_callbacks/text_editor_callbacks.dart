// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'editor_callbacks_typedef.dart';

/// A class representing callbacks for the text Editor.
class TextEditorCallbacks {
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

  /// A callback function that can be used to update the UI from custom widgets.
  final UpdateUiCallback? onUpdateUI;

  const TextEditorCallbacks({
    this.onUpdateUI,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
  });
}
