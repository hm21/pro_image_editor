// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '/core/models/editor_callbacks/standalone_editor_callbacks.dart';

/// A class representing callbacks for the blur editor.
class BlurEditorCallbacks extends StandaloneEditorCallbacks {
  /// Creates a new instance of [BlurEditorCallbacks].
  const BlurEditorCallbacks({
    this.onBlurFactorChange,
    this.onBlurFactorChangeEnd,
    super.onInit,
    super.onAfterViewInit,
    super.onUpdateUI,
    super.onDone,
    super.onCloseEditor,
    super.onKeyboardEvent,
  });

  /// A callback function that is triggered when the blur factor changes.
  ///
  /// The [ValueChanged<double>] parameter provides the new blur factor.
  final ValueChanged<double>? onBlurFactorChange;

  /// A callback function that is triggered when the blur factor change ends.
  ///
  /// The [ValueChanged<double>] parameter provides the final blur factor.
  final ValueChanged<double>? onBlurFactorChangeEnd;

  /// Handles the blur factor change event.
  ///
  /// This method calls the [onBlurFactorChange] callback with the provided
  /// [newFactor] and then calls [handleUpdateUI].
  void handleBlurFactorChange(double newFactor) {
    onBlurFactorChange?.call(newFactor);
    handleUpdateUI();
  }

  /// Handles the blur factor change end event.
  ///
  /// This method calls the [onBlurFactorChangeEnd] callback with the provided
  /// [finalFactor] and then calls [handleUpdateUI].
  void handleBlurFactorChangeEnd(double finalFactor) {
    onBlurFactorChangeEnd?.call(finalFactor);
    handleUpdateUI();
  }

  /// Creates a copy with modified editor callbacks.
  BlurEditorCallbacks copyWith({
    ValueChanged<double>? onBlurFactorChange,
    ValueChanged<double>? onBlurFactorChangeEnd,
    Function()? onInit,
    Function()? onAfterViewInit,
    Function()? onUpdateUI,
    Function()? onDone,
    Function()? onCloseEditor,
    bool Function(KeyEvent event)? onKeyboardEvent,
  }) {
    return BlurEditorCallbacks(
      onBlurFactorChange: onBlurFactorChange ?? this.onBlurFactorChange,
      onBlurFactorChangeEnd:
          onBlurFactorChangeEnd ?? this.onBlurFactorChangeEnd,
      onKeyboardEvent: onKeyboardEvent ?? this.onKeyboardEvent,
      onInit: onInit ?? this.onInit,
      onAfterViewInit: onAfterViewInit ?? this.onAfterViewInit,
      onUpdateUI: onUpdateUI ?? this.onUpdateUI,
      onDone: onDone ?? this.onDone,
      onCloseEditor: onCloseEditor ?? this.onCloseEditor,
    );
  }
}
