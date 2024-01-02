/// The `HelperLines` class defines the settings for displaying helper lines in the image editor.
/// Helper lines are used to guide users in positioning and rotating layers.
///
/// Usage:
///
/// ```dart
/// HelperLines helperLines = HelperLines(
///   showVerticalLine: true,
///   showHorizontalLine: true,
///   showRotateLine: true,
/// );
/// ```
///
/// Properties:
///
/// - `showVerticalLine`: Specifies whether to show the vertical helper line.
///
/// - `showHorizontalLine`: Specifies whether to show the horizontal helper line.
///
/// - `showRotateLine`: Specifies whether to show the rotate helper line.
///
/// Example Usage:
///
/// ```dart
/// HelperLines helperLines = HelperLines(
///   showVerticalLine: true,
///   showHorizontalLine: true,
///   showRotateLine: true,
/// );
///
/// bool showVerticalLine = helperLines.showVerticalLine;
/// bool showHorizontalLine = helperLines.showHorizontalLine;
/// // Access other helper lines settings...
/// ```
class HelperLines {
  /// Specifies whether to show the vertical helper line.
  final bool showVerticalLine;

  /// Specifies whether to show the horizontal helper line.
  final bool showHorizontalLine;

  /// Specifies whether to show the rotate helper line.
  final bool showRotateLine;

  /// Controls whether haptic feedback is enabled when a layer intersects with a
  /// helper line.
  ///
  /// When set to `true`, haptic feedback is triggered when a layer's position or
  /// boundary intersects with a helper line, providing tactile feedback to the user.
  /// This feature enhances the user experience by providing feedback on layer alignment.
  ///
  /// By default, this option is set to `true`, enabling haptic feedback for hit
  /// detection with helper lines. You can set it to `false` to disable haptic feedback.
  final bool hitVibration;

  /// Creates an instance of the `HelperLines` class with the specified settings.
  const HelperLines({
    this.showVerticalLine = true,
    this.showHorizontalLine = true,
    this.showRotateLine = true,
    this.hitVibration = true,
  });
}
