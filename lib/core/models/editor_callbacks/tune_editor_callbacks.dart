// Project imports:
import 'package:flutter/widgets.dart';

import '/features/tune_editor/models/tune_adjustment_matrix.dart';
import 'standalone_editor_callbacks.dart';

/// A class representing callbacks for the tune editor.
class TuneEditorCallbacks extends StandaloneEditorCallbacks {
  /// Creates a new instance of [TuneEditorCallbacks].
  const TuneEditorCallbacks({
    this.onTuneFactorChange,
    this.onTuneFactorChangeEnd,
    this.onTuneChanged,
    super.onInit,
    super.onAfterViewInit,
    super.onUpdateUI,
    super.onDone,
    super.onRedo,
    super.onUndo,
    super.onCloseEditor,
    super.onKeyboardEvent,
  });

  /// A callback function that is triggered when the tune factor changes.
  ///
  /// The [ValueChanged<double>] parameter provides the new tune factor.
  final ValueChanged<List<TuneAdjustmentMatrix>>? onTuneFactorChange;

  /// A callback function that is triggered when the tune factor change ends.
  ///
  /// The [ValueChanged<double>] parameter provides the final tune factor.
  final ValueChanged<List<TuneAdjustmentMatrix>>? onTuneFactorChangeEnd;

  /// A callback function that is triggered when the tune type is changed.
  ///
  /// The [ValueChanged<TuneAdjustmentType>] parameter provides the new tune
  /// type.
  final ValueChanged<String>? onTuneChanged;

  /// Handles the tune factor change event.
  ///
  /// This method calls the [onTuneFactorChange] callback with the provided
  /// [matrix] and then calls [handleUpdateUI].
  void handleTuneFactorChange(List<TuneAdjustmentMatrix> matrix) {
    onTuneFactorChange?.call(matrix);
    handleUpdateUI();
  }

  /// Handles the tune factor change end event.
  ///
  /// This method calls the [onTuneFactorChangeEnd] callback with the
  /// provided [matrix] and then calls [handleUpdateUI].
  void handleTuneFactorChangeEnd(List<TuneAdjustmentMatrix> matrix) {
    onTuneFactorChangeEnd?.call(matrix);
    handleUpdateUI();
  }

  /// Handles the tune changed event.
  ///
  /// This method calls the [onTuneChanged] callback with the provided
  /// [id] and then calls [handleUpdateUI].
  void handleTuneChanged(String id) {
    onTuneChanged?.call(id);
    handleUpdateUI();
  }

  /// Creates a copy with modified editor callbacks.
  TuneEditorCallbacks copyWith({
    ValueChanged<List<TuneAdjustmentMatrix>>? onTuneFactorChange,
    ValueChanged<List<TuneAdjustmentMatrix>>? onTuneFactorChangeEnd,
    ValueChanged<String>? onTuneChanged,
    Function()? onInit,
    Function()? onAfterViewInit,
    Function()? onUpdateUI,
    Function()? onDone,
    Function()? onRedo,
    Function()? onUndo,
    Function()? onCloseEditor,
    bool Function(KeyEvent event)? onKeyboardEvent,
  }) {
    return TuneEditorCallbacks(
      onTuneFactorChange: onTuneFactorChange ?? this.onTuneFactorChange,
      onTuneFactorChangeEnd:
          onTuneFactorChangeEnd ?? this.onTuneFactorChangeEnd,
      onTuneChanged: onTuneChanged ?? this.onTuneChanged,
      onKeyboardEvent: onKeyboardEvent ?? this.onKeyboardEvent,
      onInit: onInit ?? this.onInit,
      onAfterViewInit: onAfterViewInit ?? this.onAfterViewInit,
      onUpdateUI: onUpdateUI ?? this.onUpdateUI,
      onDone: onDone ?? this.onDone,
      onRedo: onRedo ?? this.onRedo,
      onUndo: onUndo ?? this.onUndo,
      onCloseEditor: onCloseEditor ?? this.onCloseEditor,
    );
  }
}
