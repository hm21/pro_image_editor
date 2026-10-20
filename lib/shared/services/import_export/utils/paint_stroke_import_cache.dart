import '/features/paint_editor/models/painted_model.dart';

/// Shares the paint strokes parsed during one import between its history
/// steps.
///
/// An import merges each history step over the step before it, so every step
/// that leaves a paint layer's strokes alone passes the very same raw `items`
/// list or `item` map to `PaintLayer.fromMap` again. Parsing it anew gave each
/// step its own copy of every point: a drawing of 15,000 points in 900 undo
/// steps took over 500 MB to open.
///
/// The cache only lives while [run] runs, so a raw map that is changed in
/// place and imported again is parsed again.
abstract final class PaintStrokeImportCache {
  static Map<Object, List<PaintedModel>>? _strokes;

  /// Runs [body] with a cache shared by every `PaintLayer.fromMap` call in it.
  ///
  /// [body] must be synchronous, since the cache is dropped once it returns.
  static T run<T>(T Function() body) {
    if (_strokes != null) return body();
    _strokes = Map.identity();
    try {
      return body();
    } finally {
      _strokes = null;
    }
  }

  /// The strokes parsed from [rawStrokes], which [parse] reads on first use.
  ///
  /// Returns `null` outside [run], where every call parses on its own.
  static List<PaintedModel>? lookup(
    Object rawStrokes,
    List<PaintedModel> Function() parse,
  ) {
    final strokes = _strokes;
    if (strokes == null) return null;
    return strokes[rawStrokes] ??= parse();
  }
}
