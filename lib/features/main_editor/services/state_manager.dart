import '/core/models/editor_image.dart';
import '/core/models/history/state_history.dart';
import '/core/models/layers/layer.dart';
import '/core/models/multi_threading/thread_capture_model.dart';
import '/features/filter_editor/types/filter_state.dart';
import '/features/tune_editor/models/tune_adjustment_matrix.dart';
import '../../crop_rotate_editor/models/transform_configs.dart';

/// A class for managing the state and history of image editing changes.
class StateManager {
  /// Creates an instance of [StateManager].
  StateManager({
    required this.onStateHistoryChange,
    required this.activeBackgroundImage,
  });

  /// Optional callbacks for additional editor actions.
  final Function()? onStateHistoryChange;

  /// Position in the state history.
  int _historyPointer = 0;

  /// A getter that returns the current position of the history pointer.
  /// The history pointer indicates the current index in the image editor's
  /// state history.
  int get historyPointer => _historyPointer;

  /// A setter for updating the history pointer.
  /// The history pointer must remain within the valid range of `_stateHistory`.
  /// Throws an `ArgumentError` if the provided value is out of range.
  ///
  /// - [value]: The new history pointer index.
  /// - Throws: `ArgumentError` if `value < 0` or `value >=
  /// _stateHistory.length`.
  set historyPointer(int value) {
    if (value < 0 || value >= _stateHistory.length) {
      throw ArgumentError('History pointer out of range');
    }
    _historyPointer = value;
  }

  /// A list that stores the history of changes made in the image editor.
  /// Each entry in the list is of type `EditorStateHistory`, representing a
  /// snapshot of the editor's state at a particular point in time.
  List<EditorStateHistory> _stateHistory = [];

  /// A getter that returns the list of historical editor states.
  /// This list provides a record of changes applied to the image, allowing
  /// for undo/redo functionality.
  List<EditorStateHistory> get stateHistory => _stateHistory;

  final Map<int, EditorImage> _backgroundImages = {};

  /// The currently active background image in the editor.
  EditorImage? activeBackgroundImage;

  /// Updates the background images in the editor's history.
  ///
  /// Replaces the background image at the current history pointer with
  /// [oldImage], and sets the next history entry to [newImage]. Also updates
  /// the [activeBackgroundImage] to [newImage].
  ///
  /// Parameters:
  /// - [oldImage]: The previous background image to store at the current
  /// history pointer.
  /// - [newImage]: The new background image to store at the next history
  /// pointer.
  void updateBackgroundImages({
    required EditorImage oldImage,
    required EditorImage newImage,
  }) {
    _backgroundImages[historyPointer - 1] ??= oldImage.copyWith();
    _backgroundImages[historyPointer] = newImage.copyWith();
    activeBackgroundImage = newImage.copyWith();
    for (var item in screenshots) {
      item.broken = true;
    }
  }

  /// A setter for updating the state history list.
  /// When a new list of editor states is assigned, it triggers
  /// `_updateActiveItems()` to refresh any dependent components based on the
  /// updated history.
  ///
  /// - [value]: A list of `EditorStateHistory` representing the updated state
  /// history.
  set stateHistory(List<EditorStateHistory> value) {
    _stateHistory = value;
    updateActiveItems();
  }

  /// Updates the active items in the editor state based on the current
  /// history pointer.
  ///
  /// This method performs the following actions:
  /// - Retrieves the active history up to the current history pointer.
  /// - Resets and updates the active filters from the last history entry that
  /// contains filters.
  /// - Updates the active tune adjustments from the last history entry that
  /// contains tune adjustments.
  /// - Sets the active layers to the layers of the current history entry.
  /// - Updates the transform configurations from the last history entry that
  /// contains transform configurations.
  /// - Updates the active blur value from the last history entry that contains
  /// a blur value.
  void updateActiveItems() {
    var activeHistory = _stateHistory.getRange(0, _historyPointer + 1);

    activeFilters = _stateHistory[historyPointer].filters;

    activeTuneAdjustments = _stateHistory[historyPointer].tuneAdjustments;

    activeLayers = _stateHistory[historyPointer].layers;

    activeMeta = _stateHistory[historyPointer].meta;

    _transformConfigs =
        activeHistory
            .lastWhere(
              (item) => item.transformConfigs != null,
              orElse: EditorStateHistory.new,
            )
            .transformConfigs ??
        TransformConfigs.empty();

    _activeBlur =
        activeHistory
            .lastWhere(
              (item) => item.blur != null,
              orElse: EditorStateHistory.new,
            )
            .blur ??
        0.0;

    onStateHistoryChange?.call();

    if (_backgroundImages[historyPointer] != null) {
      activeBackgroundImage = _backgroundImages[historyPointer]!.copyWith();
    }
  }

  /// The active filter states applied to the image.
  /// Each [FilterState] contains filter matrices and optional
  /// video-timeline metadata.
  List<FilterState> activeFilters = const [];

  /// The active tune adjustments for the image, such as brightness,
  /// contrast, etc.
  /// Each element in the list is of type `TuneAdjustmentMatrix`, representing
  /// specific adjustment settings.
  List<TuneAdjustmentMatrix> activeTuneAdjustments = [];

  /// The current transformation configurations applied to the image,
  /// including rotation, scaling, or other transformations.
  /// `TransformConfigs.empty()` initializes the object with default values.
  TransformConfigs _transformConfigs = TransformConfigs.empty();

  /// A getter that returns the current transformation configuration.
  /// This can be used to retrieve details about active transformations on the
  /// image.
  TransformConfigs get transformConfigs => _transformConfigs;

  /// The current blur intensity applied to the image.
  /// The value is represented as a `double`, where `0.0` indicates no blur,
  /// and higher values correspond to increasing blur intensity.
  double _activeBlur = 0.0;

  /// A getter that returns the current blur value.
  /// This allows you to query the active blur level applied to the image.
  double get activeBlur => _activeBlur;

  /// Get the list of layers from the current image editor changes.
  List<Layer> activeLayers = [];

  /// The metadata of the current history entry.
  Map<String, dynamic> activeMeta = const {};

  /// Flag indicating if a hero screenshot is required.
  bool heroScreenshotRequired = false;

  /// List of captured screenshots for each state in the history.
  List<ThreadCaptureState> screenshots = [];

  /// Retrieves the currently active screenshot based on the position.
  ThreadCaptureState? get activeScreenshot {
    var historyPos = _historyPointer - 1;

    return screenshots.length > historyPos && historyPos >= 0
        ? screenshots[historyPos]
        : null;
  }

  /// Check if the active screenshot is broken.
  bool? get activeScreenshotIsBroken => activeScreenshot?.broken;

  /// Determines whether undo actions can be performed on the current state.
  bool get canUndo => _historyPointer > 0;

  /// Determines whether redo actions can be performed on the current state.
  bool get canRedo => _historyPointer < _stateHistory.length - 1;

  /// Clean forward changes in the history.
  ///
  /// This method removes any changes made after the current edit position in
  /// the history. It ensures that the state history and screenshots are
  /// consistent with the current position. This is useful when performing an
  /// undo operation, and new edits are made, effectively discarding the "redo"
  /// history.
  void _cleanForwardChanges() {
    if (_stateHistory.length > 1) {
      while (_historyPointer < _stateHistory.length - 1) {
        _stateHistory.removeLast();
      }
      while (_historyPointer < screenshots.length) {
        screenshots.removeLast();
      }
      _backgroundImages.removeWhere((index, _) => index > _historyPointer);
    }
    _historyPointer = _stateHistory.length - 1;
  }

  /// Set the history limit to manage the maximum number of stored states.
  ///
  /// This method sets a limit on the number of states that can be stored in
  /// the history.
  /// If the number of stored states exceeds this limit, the oldest states are
  /// removed to free up memory. This is crucial for preventing excessive
  /// memory usage, especially when each state includes large data such as
  /// screenshots.
  ///
  /// - `limit`: The maximum number of states to retain in the history. Must
  /// be 1 or greater.
  void setHistoryLimit(int limit, bool enableScreenshotLimit) {
    if (limit <= 0) {
      throw ArgumentError('The state history limit must be 1 or greater!');
    }
    while (_historyPointer > limit) {
      if (_historyPointer > 0) {
        _historyPointer--;
        _stateHistory.removeAt(0);
        if (enableScreenshotLimit) screenshots.removeAt(0);
      } else {
        _stateHistory.removeLast();
        if (enableScreenshotLimit) screenshots.removeLast();
      }
    }
  }

  /// Adds a new entry to the history of image editor changes and updates the
  /// history pointer.
  /// This method ensures that any forward changes (redo history) are cleared
  /// before adding a new entry.
  ///
  /// - [history]: An `EditorStateHistory` object representing the new editor
  /// state to be added.
  /// - [historyLimit]: An optional parameter that sets a limit on the size of
  /// the history list.
  ///   Defaults to 1000. If the history exceeds this limit, older entries are
  /// removed.
  ///
  /// After adding the new history entry:
  /// 1. The history pointer is updated to point to the latest state.
  /// 2. The history list size is adjusted according to `historyLimit`.
  /// 3. Active editor components are refreshed.
  void addHistory(
    EditorStateHistory history, {
    int historyLimit = 1000,
    bool enableScreenshotLimit = true,
    bool skipUpdateActiveItems = false,
  }) {
    _cleanForwardChanges();
    _stateHistory.add(history);
    historyPointer = _stateHistory.length - 1;
    setHistoryLimit(historyLimit, enableScreenshotLimit);
    if (!skipUpdateActiveItems) updateActiveItems();
  }

  /// Replaces a history entry in the stack.
  ///
  /// By default, the currently active history entry is replaced. You can
  /// provide [index] to replace any specific history position.
  ///
  /// Throws an [ArgumentError] when [index] is out of range.
  void replaceHistory(
    EditorStateHistory history, {
    int? index,
    bool skipUpdateActiveItems = false,
  }) {
    final targetIndex = index ?? _historyPointer;

    if (targetIndex < 0 || targetIndex >= _stateHistory.length) {
      throw ArgumentError('History index out of range');
    }

    _stateHistory[targetIndex] = history;

    if (!skipUpdateActiveItems) updateActiveItems();
  }

  /// Redoes the last undone change, moving the history pointer forward by one
  /// step.
  /// If there is no forward change available, this operation will throw an
  /// error due to out-of-bounds access handled by the `historyPointer` setter.
  void redo() {
    historyPointer = _historyPointer + 1;
    updateActiveItems();
  }

  /// Undoes the last change by moving the history pointer back by one step.
  /// This reverts the editor to the previous state.
  /// If there is no previous state available, this operation will throw an
  /// error due to out-of-bounds access handled by the `historyPointer` setter.
  void undo() {
    historyPointer = _historyPointer - 1;
    updateActiveItems();
  }

  /// Locks or unlocks all layers based on the provided parameters.
  ///
  /// This method iterates through either the active layers or the entire state
  /// history and toggles the lock state of each layer's interaction.
  ///
  /// Parameters:
  /// - `enableInteraction` (required): A boolean value indicating whether to
  ///   lock (`false`) or unlock (`true`) the layers.
  /// - `onlyCurrentHistory` (required): A boolean value indicating whether to
  ///   apply the lock/unlock operation only to the current history (`true`)
  ///   or to all state history (`false`).
  ///
  /// If `onlyCurrentHistory` is `true`, the method will only affect the
  /// active layers.
  /// If `onlyCurrentHistory` is `false`, the method will iterate through all
  /// layers in the state history and apply the lock/unlock operation.
  void updateLayerInteraction({
    required bool enableInteraction,
    required bool onlyCurrentHistory,
  }) {
    if (onlyCurrentHistory) {
      for (Layer layer in activeLayers) {
        layer.interaction.toggleAll(enableInteraction);
      }
    } else {
      for (var history in stateHistory) {
        for (var layer in history.layers) {
          layer.interaction.toggleAll(enableInteraction);
        }
      }
    }
  }
}
