import 'package:flutter/widgets.dart';

import '../../constants/editor_style_constants.dart';

/// Defines the visual style of the tilt editor widgets.
///
/// Provides colors, sizes, and cursor styling for the tilt ruler,
/// tick marks, indicator, and bottom bar.
class TiltStyle {
  /// Creates a [TiltStyle] with optional overrides.
  ///
  /// Default values are taken from [kImageEditorPrimaryColor] and
  /// standard Material-like dimensions.
  const TiltStyle({
    this.bottomBarSelectedColor = kImageEditorPrimaryColor,
    this.activeColor = kImageEditorPrimaryColor,
    this.indicatorColor = const Color(0xFFFFFFFF),
    this.tickMarkColor = const Color(0xFFFFFFFF),
    this.tickMarkHeight = 12,
    this.tickMarkWidth = 0.8,
    this.indicatorHeight = 20,
    this.indicatorWidth = 2,
    this.barHeight = 50,
    this.cursor = SystemMouseCursors.grab,
  });

  /// The color used for the selected item in the bottom bar.
  final Color bottomBarSelectedColor;

  /// The active color used for the tilt ruler indicator.
  final Color activeColor;

  /// The color of the indicator (center knob).
  final Color indicatorColor;

  /// The color of the tick marks on the ruler.
  final Color tickMarkColor;

  /// The height of each tick mark.
  final double tickMarkHeight;

  /// The width of each tick mark.
  final double tickMarkWidth;

  /// The height of the center indicator.
  final double indicatorHeight;

  /// The width of the center indicator.
  final double indicatorWidth;

  /// The overall height of the tilt ruler bar.
  final double barHeight;

  /// The mouse cursor displayed while interacting with the ruler.
  final MouseCursor cursor;
}
