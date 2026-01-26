// Flutter imports:
import 'package:flutter/material.dart';

import '../enums/paint_editor_enum.dart';
// Project imports:
import '../models/painted_model.dart';

/// The `PaintController` class is responsible for managing and controlling
/// the paint state.
class PaintController extends ChangeNotifier {
  /// Creates an instance of the `PaintController` with initial settings.
  ///
  /// - `strokeWidth`: The initial stroke width.
  /// - `color`: The initial color.
  /// - `mode`: The initial paint mode (e.g., line, circle, rectangle).
  /// - `fill`: Whether the initial mode should fill the shape
  /// (e.g., circle or rectangle).
  /// - `strokeMultiplier`: The multiplier for the stroke width.
  PaintController({
    required double strokeWidth,
    required Color color,
    required PaintMode mode,
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

  /// The width of the stroke for paint operations.
  late double _strokeWidth;

  /// The color used for paint operations.
  late Color _color;

  /// The mode of paint, specifying the type of paint operation.
  late PaintMode _mode;

  /// A flag indicating whether paint operations should fill shapes.
  late bool _fill;

  /// The opacity for the drawing
  late double opacity;

  /// List of offsets representing points on the canvas during paint.
  final List<Offset?> _offsets = [];

  /// The starting point of the current paint operation.
  Offset? _start;

  /// The ending point of the current paint operation.
  Offset? _end;

  /// Multiplier for stroke width, used in scaling the stroke.
  int _strokeMultiplier = 1;

  /// Flag indicating whether a paint operation is in progress.
  bool _paintInProgress = false;

  /// Getter for the current state of the painted model.
  ///
  /// Returns a [PaintedModel] instance representing the current state of the
  /// paint.
  PaintedModel get paintedModel => PaintedModel(
        mode: mode,
        offsets: mode == PaintMode.freeStyle ||
                mode == PaintMode.freeStyleArrowStart ||
                mode == PaintMode.freeStyleArrowEnd ||
                mode == PaintMode.freeStyleArrowStartEnd ||
                mode == PaintMode.polygon
            ? [..._offsets]
            : [start, end],
        erasedOffsets: [],
        color: color,
        strokeWidth: strokeWidth,
        fill: fill,
        opacity: opacity,
      );

  /// Returns the current paint mode (e.g., line, circle, rectangle).
  PaintMode get mode => _mode;

  /// Returns the current stroke width.
  double get strokeWidth => _strokeWidth;

  /// Returns the scaled stroke width based on the stroke multiplier.
  double get scaledStrokeWidth => _strokeWidth * _strokeMultiplier;

  /// Indicates whether there is an ongoing paint action.
  bool get busy => _paintInProgress;

  /// Indicates whether the current mode requires filling
  /// (e.g., circle or rectangle).
  bool get fill => _fill;

  /// Returns the current color used for paint.
  Color get color => _color;

  /// Returns the list of recorded paint offsets.
  List<Offset?> get offsets => _offsets;

  /// Returns the starting point of a paint action.
  Offset? get start => _start;

  /// Returns the ending point of a paint action.
  Offset? get end => _end;

  /// Sets the stroke width to the specified value and notifies listeners.
  void setStrokeWidth(double val) {
    _strokeWidth = val;
    notifyListeners();
  }

  /// Sets the paint color to the specified color and notifies listeners.
  void setColor(Color color) {
    _color = color;
    notifyListeners();
  }

  /// Sets the paint mode to the specified mode and notifies listeners.
  void setMode(PaintMode mode) {
    setInProgress(false);
    reset();
    _mode = mode;
    notifyListeners();
  }

  /// Adds an offset to the list of offsets and notifies listeners.
  void addOffsets(Offset offset) {
    _offsets.add(offset);
    notifyListeners();
  }

  /// Sets the starting point of a paint action and notifies listeners.
  void setStart(Offset offset) {
    _start = offset;
    notifyListeners();
  }

  /// Sets the ending point of a paint action and notifies listeners.
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

  /// Sets the paint progress state and notifies listeners.
  ///
  /// - [val]: The boolean value indicating the paint progress state.
  void setInProgress(bool val) {
    _paintInProgress = val;
    notifyListeners();
  }
}
