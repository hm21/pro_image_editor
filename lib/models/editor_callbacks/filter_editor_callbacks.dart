// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:pro_image_editor/modules/filter_editor/utils/filter_generator/filter_model.dart';
import 'standalone_editor_callbacks.dart';

/// A class representing callbacks for the filter editor.
class FilterEditorCallbacks extends StandaloneEditorCallbacks {
  /// Creates a new instance of [FilterEditorCallbacks].
  const FilterEditorCallbacks({
    this.onFilterFactorChange,
    this.onFilterFactorChangeEnd,
    this.onFilterChanged,
    super.onInit,
    super.onAfterViewInit,
    super.onUpdateUI,
    super.onDone,
    super.onCloseEditor,
  });

  /// A callback function that is triggered when the filter factor changes.
  ///
  /// The [ValueChanged<double>] parameter provides the new filter factor.
  final ValueChanged<double>? onFilterFactorChange;

  /// A callback function that is triggered when the filter factor change ends.
  ///
  /// The [ValueChanged<double>] parameter provides the final filter factor.
  final ValueChanged<double>? onFilterFactorChangeEnd;

  /// A callback function that is triggered when the filter is changed.
  ///
  /// The [ValueChanged<FilterModel>] parameter provides the new filter model.
  final ValueChanged<FilterModel>? onFilterChanged;

  /// Handles the filter factor change event.
  ///
  /// This method calls the [onFilterFactorChange] callback with the provided
  /// [newFactor] and then calls [handleUpdateUI].
  void handleFilterFactorChange(double newFactor) {
    onFilterFactorChange?.call(newFactor);
    handleUpdateUI();
  }

  /// Handles the filter factor change end event.
  ///
  /// This method calls the [onFilterFactorChangeEnd] callback with the
  /// provided [newFactor] and then calls [handleUpdateUI].
  void handleFilterFactorChangeEnd(double newFactor) {
    onFilterFactorChangeEnd?.call(newFactor);
    handleUpdateUI();
  }

  /// Handles the filter changed event.
  ///
  /// This method calls the [onFilterChanged] callback with the provided
  /// [filter] and then calls [handleUpdateUI].
  void handleFilterChanged(FilterModel filter) {
    onFilterChanged?.call(filter);
    handleUpdateUI();
  }
}
