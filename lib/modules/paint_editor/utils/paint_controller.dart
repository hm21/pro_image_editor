// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../models/paint_editor/painted_model.dart';
import 'paint_editor_enum.dart';

/// The `PaintingController` class is responsible for managing and controlling
/// the painting state.
class PaintingController extends ChangeNotifier {
  /// Creates an instance of the `PaintingController` with initial settings.
  ///
  /// - `strokeWidth`: The initial stroke width.
  /// - `color`: The initial color.
  /// - `mode`: The initial painting mode (e.g., line, circle, rectangle).
  /// - `fill`: Whether the initial mode should fill the shape
  /// (e.g., circle or rectangle).
  /// - `strokeMultiplier`: The multiplier for the stroke width.
  PaintingController({
    required double strokeWidth,
    required Color color,
    required PaintModeE mode,
    required bool fill,
    required int strokeMultiplier,
    required this.opacity,
  }) {
    _strokeWidth = strokeWidth;
    _color = color;
    _mode = mode;
    _fill = fill;
    _strokeMultiplier = strokeMultiplier;
  }

  /// The width of the stroke for painting operations.
  late double _strokeWidth;

  /// The color used for painting operations.
  late Color _color;

  /// The mode of painting, specifying the type of painting operation.
  late PaintModeE _mode;

  /// A flag indicating whether painting operations should fill shapes.
  late bool _fill;

  /// The opacity for the drawing
  late double opacity;

  /// List of offsets representing points on the canvas during painting.
  final List<Offset?> _offsets = [];

  /// History of painted models representing previous painting operations.
  final List<List<PaintedModel>> paintHistory = [];

  /// The current position in the painting history.
  int historyPosition = 0;

  /// The starting point of the current painting operation.
  Offset? _start;

  /// The ending point of the current painting operation.
  Offset? _end;

  /// Multiplier for stroke width, used in scaling the stroke.
  int _strokeMultiplier = 1;

  /// Flag indicating whether a painting operation is in progress.
  bool _paintInProgress = false;

  /// Getter for the current state of the painted model.
  ///
  /// Returns a [PaintedModel] instance representing the current state of the
  /// painting.
  PaintedModel get paintedModel => PaintedModel(
        mode: mode,
        offsets: mode == PaintModeE.freeStyle ? offsets : [start, end],
        color: color,
        strokeWidth: strokeWidth,
        fill: fill,
        opacity: opacity,
      );

  /// Returns the current painting mode (e.g., line, circle, rectangle).
  PaintModeE get mode => _mode;

  /// Returns the current stroke width.
  double get strokeWidth => _strokeWidth;

  /// Returns the scaled stroke width based on the stroke multiplier.
  double get scaledStrokeWidth => _strokeWidth * _strokeMultiplier;

  /// Indicates whether there is an ongoing painting action.
  bool get busy => _paintInProgress;

  /// Indicates whether the current mode requires filling
  /// (e.g., circle or rectangle).
  bool get fill => _fill;

  /// Returns the current color used for painting.
  Color get color => _color;

  /// Returns the list of painted models representing the painting history.
  List<PaintedModel> get activePaintings =>
      historyPosition <= 0 || paintHistory.length < historyPosition
          ? []
          : paintHistory[historyPosition - 1];

  /// Returns the list of recorded painting offsets.
  List<Offset?> get offsets => _offsets;

  /// Returns the starting point of a painting action.
  Offset? get start => _start;

  /// Returns the ending point of a painting action.
  Offset? get end => _end;

  /// Determines whether undo actions can be performed on the current state.
  bool get canUndo => historyPosition > 0;

  /// Determines whether redo actions can be performed on the current state.
  bool get canRedo => historyPosition < paintHistory.length;

  /// Adds a painted model to the painting history and notifies listeners of
  /// the change.
  void addPaintInfo(PaintedModel paintInfo) {
    _cleanForwardChanges();
    paintHistory.add([...activePaintings, paintInfo]);
    historyPosition++;
  }

  /// Adds a painted model to the painting history and notifies listeners of
  /// the change.
  void removeLayers(List<String> idList) {
    _cleanForwardChanges();
    paintHistory.add([...activePaintings]);
    historyPosition++;
    activePaintings.removeWhere((el) => idList.contains(el.id));
  }

  /// Clean forward changes in the history.
  ///
  /// This method removes any changes made after the current edit position in
  /// the history.
  /// It ensures that the state history and screenshots are consistent with the
  /// current position. This is useful when performing an undo operation, and
  /// new edits are made, effectively discarding the "redo" history.
  void _cleanForwardChanges() {
    if (paintHistory.isNotEmpty) {
      while (paintHistory.length > historyPosition) {
        paintHistory.removeLast();
      }
    }
    historyPosition = paintHistory.length;
  }

  /// Undoes the last painting action by moving it from the history to the
  /// redo history and notifies listeners.
  void undo() {
    if (historyPosition > 0) {
      historyPosition--;
    }
  }

  /// Redoes the last undone painting action by moving it from the redo history
  /// to the history and notifies listeners.
  void redo() {
    if (historyPosition < paintHistory.length) {
      historyPosition++;
    }
  }

  /// Sets the stroke width to the specified value and notifies listeners.
  void setStrokeWidth(double val) {
    _strokeWidth = val;
    notifyListeners();
  }

  /// Sets the painting color to the specified color and notifies listeners.
  void setColor(Color color) {
    _color = color;
    notifyListeners();
  }

  /// Sets the painting mode to the specified mode and notifies listeners.
  void setMode(PaintModeE mode) {
    _mode = mode;
    notifyListeners();
  }

  /// Adds an offset to the list of offsets and notifies listeners.
  void addOffsets(Offset offset) {
    _offsets.add(offset);
    notifyListeners();
  }

  /// Sets the starting point of a painting action and notifies listeners.
  void setStart(Offset offset) {
    _start = offset;
    notifyListeners();
  }

  /// Sets the ending point of a painting action and notifies listeners.
  void setEnd(Offset offset) {
    _end = offset;
    notifyListeners();
  }

  /// Sets the stroke multiplier to the specified value and notifies listeners.
  void setStrokeMultiplier(int value) {
    _strokeMultiplier = value;
    notifyListeners();
  }

  /// Resets the starting and ending points and clears the offsets list, then
  /// notifies listeners.
  void reset() {
    _start = null;
    _end = null;
    offsets.clear();
    notifyListeners();
  }

  /// Sets whether the current mode should fill the shape and notifies
  /// listeners.
  void setFill(bool fill) {
    _fill = fill;
    notifyListeners();
  }

  /// Sets the current level of opacity.
  void setOpacity(double value) {
    opacity = value;
    notifyListeners();
  }

  /// Sets the painting progress state and notifies listeners.
  ///
  /// - [val]: The boolean value indicating the painting progress state.
  void setInProgress(bool val) {
    _paintInProgress = val;
    notifyListeners();
  }
}
