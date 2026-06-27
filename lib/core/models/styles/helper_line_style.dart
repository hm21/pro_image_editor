// Flutter imports:
import 'package:flutter/widgets.dart';

/// The `HelperLineStyle` class defines the style for helper lines in the image
/// editor.
/// Helper lines are used to assist with alignment and positioning of elements
/// in the editor.
///
/// Usage:
///
/// ```dart
/// HelperLineStyle HelperLineStyle = HelperLineStyle(
///   horizontalColor: Colors.blue,
///   verticalColor: Colors.red,
///   rotateColor: Colors.pink,
/// );
/// ```
///
/// Properties:
///
/// - `horizontalColor`: Color of horizontal helper lines.
///
/// - `verticalColor`: Color of vertical helper lines.
///
/// - `rotateColor`: Color of rotation helper lines.
///
/// Example Usage:
///
/// ```dart
/// HelperLineStyle HelperLineStyle = HelperLineStyle(
///   horizontalColor: Colors.blue,
///   verticalColor: Colors.red,
///   rotateColor: Colors.pink,
/// );
///
/// Color horizontalColor = HelperLineStyle.horizontalColor;
/// Color verticalColor = HelperLineStyle.verticalColor;
/// // Access other style properties...
/// ```
class HelperLineStyle {
  /// Creates an instance of the `HelperLineStyle` class with the specified
  /// style properties.
  const HelperLineStyle({
    this.horizontalColor = const Color(0xFF1565C0),
    this.verticalColor = const Color(0xFF1565C0),
    this.rotateColor = const Color(0xFFE91E63),
    this.layerAlignColor = const Color(0xFF7C4DFF),
    this.customGuideColor = const Color(0xFF00BFA5),
    this.strokeWidth = 1.25,
  });

  /// Color of horizontal helper lines.
  final Color horizontalColor;

  /// Color of vertical helper lines.
  final Color verticalColor;

  /// Color of rotation helper lines.
  final Color rotateColor;

  /// Color of layer align helper lines.
  final Color layerAlignColor;

  /// Color of app-defined custom guide lines.
  final Color customGuideColor;

  /// Stroke width of all helper lines.
  final double strokeWidth;

  /// Creates a copy of this `HelperLineStyle` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [HelperLineStyle] with some properties updated while keeping the
  /// others unchanged.
  HelperLineStyle copyWith({
    Color? horizontalColor,
    Color? verticalColor,
    Color? rotateColor,
    Color? layerAlignColor,
    Color? customGuideColor,
    double? strokeWidth,
  }) {
    return HelperLineStyle(
      horizontalColor: horizontalColor ?? this.horizontalColor,
      verticalColor: verticalColor ?? this.verticalColor,
      rotateColor: rotateColor ?? this.rotateColor,
      layerAlignColor: layerAlignColor ?? this.layerAlignColor,
      customGuideColor: customGuideColor ?? this.customGuideColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }
}
