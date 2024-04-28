import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Represents the interaction settings for layers in the theme.
///
/// This class defines the visual interaction properties such as button radius,
/// stroke width, dash width, dash space, dash color, and cursor styles for
/// interacting with layers in the theme.
class ThemeLayerInteraction {
  /// The radius of buttons used for layer interactions.
  final double buttonRadius;

  /// The width of the stroke used for layer interactions.
  final double strokeWidth;

  /// The width of the dash used for layer interactions.
  final double dashWidth;

  /// The space between dashes used for layer interactions.
  final double dashSpace;

  /// The color of the dash used for layer interactions.
  final Color dashColor;

  /// The cursor style for removing a layer.
  final SystemMouseCursor removeCursor;

  /// The cursor style for rotating or scaling a layer.
  final SystemMouseCursor rotateScaleCursor;

  /// The cursor style when hovering over a layer.
  final SystemMouseCursor hoverCursor;

  /// Creates a new instance of [ThemeLayerInteraction].
  ///
  /// The [buttonRadius] defaults to 10.0.
  /// The [strokeWidth] defaults to 1.2.
  /// The [dashWidth] defaults to 7.0.
  /// The [dashSpace] defaults to 5.0.
  /// The [dashColor] defaults to blue.
  /// The [removeCursor] defaults to [SystemMouseCursors.click].
  /// The [rotateScaleCursor] defaults to [SystemMouseCursors.click].
  /// The [hoverCursor] defaults to [SystemMouseCursors.move].
  const ThemeLayerInteraction({
    this.buttonRadius = 10,
    this.strokeWidth = 1.2,
    this.dashWidth = 7,
    this.dashSpace = 5,
    this.dashColor = Colors.blue,
    this.removeCursor = SystemMouseCursors.click,
    this.rotateScaleCursor = SystemMouseCursors.click,
    this.hoverCursor = SystemMouseCursors.move,
  });
}
