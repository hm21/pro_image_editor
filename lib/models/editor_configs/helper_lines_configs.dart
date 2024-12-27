import '../styles/helper_line_style.dart';

export '../styles/helper_line_style.dart';

/// The `HelperLineConfigs` class defines the settings for displaying helper
/// lines in the image editor.
/// Helper lines are used to guide users in positioning and rotating layers.
///
/// Usage:
///
/// ```dart
/// HelperLineConfigs helperLines = HelperLineConfigs(
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
/// - `showHorizontalLine`: Specifies whether to show the horizontal helper
///   line.
///
/// - `showRotateLine`: Specifies whether to show the rotate helper line.
///
/// Example Usage:
///
/// ```dart
/// HelperLineConfigs helperLines = HelperLineConfigs(
///   showVerticalLine: true,
///   showHorizontalLine: true,
///   showRotateLine: true,
/// );
///
/// bool showVerticalLine = helperLines.showVerticalLine;
/// bool showHorizontalLine = helperLines.showHorizontalLine;
/// // Access other helper lines settings...
/// ```
class HelperLineConfigs {
  /// Creates an instance of the `HelperLines` class with the specified
  /// settings.
  const HelperLineConfigs({
    this.showVerticalLine = true,
    this.showHorizontalLine = true,
    this.showRotateLine = true,
    this.hitVibration = true,
    this.style = const HelperLineStyle(),
  });

  /// Specifies whether to show the vertical helper line.
  final bool showVerticalLine;

  /// Specifies whether to show the horizontal helper line.
  final bool showHorizontalLine;

  /// Specifies whether to show the rotate helper line.
  final bool showRotateLine;

  /// Controls whether haptic feedback is enabled when a layer intersects with a
  /// helper line.
  ///
  /// When set to `true`, haptic feedback is triggered when a layer's position
  /// or boundary intersects with a helper line, providing tactile feedback to
  /// the user.
  /// This feature enhances the user experience by providing feedback on layer
  /// alignment.
  ///
  /// By default, this option is set to `true`, enabling haptic feedback for hit
  /// detection with helper lines. You can set it to `false` to disable haptic
  /// feedback.
  final bool hitVibration;

  /// Style configuration for helper lines.
  final HelperLineStyle style;

  /// Creates a copy of this `HelperLineConfigs` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [HelperLineConfigs] with some properties updated while keeping the
  /// others unchanged.
  HelperLineConfigs copyWith({
    bool? showVerticalLine,
    bool? showHorizontalLine,
    bool? showRotateLine,
    bool? hitVibration,
    HelperLineStyle? style,
  }) {
    return HelperLineConfigs(
      showVerticalLine: showVerticalLine ?? this.showVerticalLine,
      showHorizontalLine: showHorizontalLine ?? this.showHorizontalLine,
      showRotateLine: showRotateLine ?? this.showRotateLine,
      hitVibration: hitVibration ?? this.hitVibration,
      style: style ?? this.style,
    );
  }
}
