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

  /// The width of the border element used for layer interactions.
  final double borderElementWidth;

  /// The space between the border element used for layer interactions.
  final double borderElementSpace;

  /// The color of the border element used for layer interactions.
  final Color borderColor;

  /// The cursor style for removing a layer.
  final SystemMouseCursor removeCursor;

  /// The cursor style for editing a Text layer.
  final SystemMouseCursor editCursor;

  /// The cursor style for rotating or scaling a layer.
  final SystemMouseCursor rotateScaleCursor;

  /// The cursor style when hovering over a layer.
  final SystemMouseCursor hoverCursor;

  /// Specifies the style of the selected layer border.
  final LayerInteractionBorderStyle borderStyle;

  /// Indicates whether tooltips should be displayed for the layer.
  final bool showTooltips;

  /// Creates a new instance of [ThemeLayerInteraction].
  ///
  /// - The [buttonRadius] defaults to `10.0`.
  /// - The [strokeWidth] defaults to `1.2`.
  /// - The [borderElementWidth] defaults to `7.0`.
  /// - The [borderElementSpace] defaults to `5.0`.
  /// - The [borderColor] defaults to `blue`.
  /// - The [removeCursor] defaults to [SystemMouseCursors.click].
  /// - The [rotateScaleCursor] defaults to [SystemMouseCursors.click].
  /// - The [hoverCursor] defaults to [SystemMouseCursors.move].
  /// - The [borderStyle] defaults to [LayerInteractionBorderStyle.solid].
  /// - The [showTooltips] defaults to `false`.
  const ThemeLayerInteraction({
    this.buttonRadius = 10,
    this.strokeWidth = 1.2,
    this.borderElementWidth = 7,
    this.borderElementSpace = 5,
    this.borderColor = Colors.blue,
    this.removeCursor = SystemMouseCursors.click,
    this.rotateScaleCursor = SystemMouseCursors.click,
    this.editCursor = SystemMouseCursors.click,
    this.hoverCursor = SystemMouseCursors.move,
    this.borderStyle = LayerInteractionBorderStyle.solid,
    this.showTooltips = false,
  });
}

enum LayerInteractionBorderStyle {
  solid,
  dashed,
  dotted,
}
