import 'package:flutter/material.dart';

import '../../../models/paint_editor/painted_model.dart';
import 'paint_editor_enum.dart';

/// The `PaintingController` class is responsible for managing and controlling the painting state in a Flutter application.
class PaintingController extends ChangeNotifier {
  late double _strokeWidth;
  late Color _color;
  late PaintModeE _mode;
  late bool _fill;

  final List<Offset?> _offsets = [];

  final List<PaintedModel> _paintHistory = [];
  final List<PaintedModel> _paintRedoHistory = [];

  Offset? _start, _end;

  int _strokeMultiplier = 1;
  bool _paintInProgress = false;

  /// Returns a [Paint] object configured with the current color, stroke width, and fill settings.
  Paint get brush => Paint()
    ..color = _color
    ..strokeWidth = _strokeWidth * _strokeMultiplier
    ..style = needFill ? PaintingStyle.fill : PaintingStyle.stroke;

  /// Returns the current painting mode (e.g., line, circle, rectangle).
  PaintModeE get mode => _mode;

  /// Returns the current stroke width.
  double get strokeWidth => _strokeWidth;

  /// Returns the scaled stroke width based on the stroke multiplier.
  double get scaledStrokeWidth => _strokeWidth * _strokeMultiplier;

  /// Indicates whether there is an ongoing painting action.
  bool get busy => _paintInProgress;

  /// Indicates whether the current mode requires filling (e.g., circle or rectangle).
  bool get fill => _fill;

  /// Returns the current color used for painting.
  Color get color => _color;

  /// Returns the list of painted models representing the painting history.
  List<PaintedModel> get paintHistory => _paintHistory;

  /// Returns the list of painted models representing the redo history.
  List<PaintedModel> get paintRedoHistory => _paintRedoHistory;

  /// Returns the list of recorded painting offsets.
  List<Offset?> get offsets => _offsets;

  /// Returns the starting point of a painting action.
  Offset? get start => _start;

  /// Returns the ending point of a painting action.
  Offset? get end => _end;

  /// Creates an instance of the `PaintingController` with initial settings.
  ///
  /// - [strokeWidth]: The initial stroke width.
  /// - [color]: The initial color.
  /// - [mode]: The initial painting mode (e.g., line, circle, rectangle).
  /// - [fill]: Whether the initial mode should fill the shape (e.g., circle or rectangle).
  /// - [strokeMultiplier]: The multiplier for the stroke width.
  PaintingController({
    required double strokeWidth,
    required Color color,
    required PaintModeE mode,
    required bool fill,
    required int strokeMultiplier,
  }) {
    _strokeWidth = strokeWidth;
    _color = color;
    _mode = mode;
    _fill = fill;
    _strokeMultiplier = strokeMultiplier;
  }

  /// Adds a painted model to the painting history and notifies listeners of the change.
  void addPaintInfo(PaintedModel paintInfo) {
    _paintHistory.add(paintInfo);
    notifyListeners();
  }

  /// Undoes the last painting action by moving it from the history to the redo history and notifies listeners.
  void undo() {
    if (_paintHistory.isNotEmpty) {
      _paintRedoHistory.add(_paintHistory.removeLast());
      notifyListeners();
    }
  }

  /// Redoes the last undone painting action by moving it from the redo history to the history and notifies listeners.
  void redo() {
    if (_paintRedoHistory.isNotEmpty) {
      _paintHistory.add(_paintRedoHistory.removeLast());
      notifyListeners();
    }
  }

  /// Clears the painting history and notifies listeners.
  void clear() {
    if (_paintHistory.isNotEmpty) {
      _paintHistory.clear();
      notifyListeners();
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

  /// Resets the starting and ending points and clears the offsets list, then notifies listeners.
  void resetStartAndEnd() {
    _start = null;
    _end = null;
    offsets.clear();
    notifyListeners();
  }

  /// Sets whether the current mode should fill the shape and notifies listeners.
  void setFill(bool fill) {
    _fill = fill;
    notifyListeners();
  }

  /// Initializes the painting settings with optional parameters and notifies listeners.
  ///
  /// - [strokeWidth]: The optional stroke width to set.
  /// - [color]: The optional color to set.
  /// - [mode]: The optional painting mode to set.
  void init({
    double? strokeWidth,
    Color? color,
    PaintModeE? mode,
  }) {
    _strokeWidth = strokeWidth ?? _strokeWidth;
    _color = color ?? _color;
    _mode = mode ?? _mode;
    notifyListeners();
  }

  /// Sets the painting progress state and notifies listeners.
  ///
  /// - [val]: The boolean value indicating the painting progress state.
  void setInProgress(bool val) {
    _paintInProgress = val;
    notifyListeners();
  }

  /// Indicates whether the current mode requires filling (e.g., circle or rectangle).
  bool get needFill =>
      mode == PaintModeE.circle || mode == PaintModeE.rect ? fill : false;
}
