/// Enum representing different spans of export history.
enum ExportHistorySpan {
  /// Export the entire export history.
  all,

  /// Export only the current state without any history.
  current,

  /// Export the current state and all future changes.
  currentAndForward,

  /// Export the current state and all past changes.
  currentAndBackward,
}

/// Enum representing different merge modes for importing editor data.
enum ImportEditorMergeMode {
  /// Merge imported data with existing editor data.
  merge,

  /// Replace existing editor data with imported data.
  replace,
}
