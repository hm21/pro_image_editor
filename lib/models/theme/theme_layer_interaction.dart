// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Represents the interaction settings for layers in the theme.
///
/// This class defines the visual interaction properties such as button radius,
/// stroke width, dash width, dash space, dash color, and cursor styles for
/// interacting with layers in the theme.
class ThemeLayerInteraction {
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
    this.removeAreaBackgroundActive = const Color(0xFFF44336),
    this.removeAreaBackgroundInactive = const Color(0xFF424242),
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
    this.buttonRemoveColor = Colors.black,
    this.buttonRemoveBackground = Colors.white,
    this.buttonEditTextColor = Colors.black,
    this.buttonEditTextBackground = Colors.white,
    this.buttonScaleRotateColor = Colors.black,
    this.buttonScaleRotateBackground = Colors.white,
  });

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

  /// The background color for the active removal area.
  ///
  /// This color is used for the background of the area where layers can be
  /// removed when it is active.
  final Color removeAreaBackgroundActive;

  /// The background color for the inactive removal area.
  ///
  /// This color is used for the background of the area where layers can be
  /// removed when it is inactive.
  final Color removeAreaBackgroundInactive;

  /// The color of the remove button.
  ///
  /// This value determines the color of the button used to remove layers,
  /// affecting its visibility and contrast.
  final Color buttonRemoveColor;

  /// The background color of the remove button.
  ///
  /// This value specifies the background color of the button used to remove
  /// layers, influencing its visual appearance.
  final Color buttonRemoveBackground;

  /// The color of the edit text button.
  ///
  /// This value determines the color of the button used to edit text layers,
  /// affecting its visibility and contrast.
  final Color buttonEditTextColor;

  /// The background color of the edit text button.
  ///
  /// This value specifies the background color of the button used to edit text
  /// layers, influencing its visual appearance.
  final Color buttonEditTextBackground;

  /// The color of the scale and rotate button.
  ///
  /// This value determines the color of the button used to scale and rotate
  /// layers, affecting its visibility and contrast.
  final Color buttonScaleRotateColor;

  /// The background color of the scale and rotate button.
  ///
  /// This value specifies the background color of the button used to scale and
  /// rotate layers, influencing its visual appearance.
  final Color buttonScaleRotateBackground;

  /// Creates a copy of this `ThemeLayerInteraction` object with the given
  /// fields replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [ThemeLayerInteraction] with some properties updated while keeping the
  /// others unchanged.
  ThemeLayerInteraction copyWith({
    double? buttonRadius,
    double? strokeWidth,
    double? borderElementWidth,
    double? borderElementSpace,
    Color? borderColor,
    SystemMouseCursor? removeCursor,
    SystemMouseCursor? editCursor,
    SystemMouseCursor? rotateScaleCursor,
    SystemMouseCursor? hoverCursor,
    LayerInteractionBorderStyle? borderStyle,
    bool? showTooltips,
    Color? removeAreaBackgroundActive,
    Color? removeAreaBackgroundInactive,
    Color? buttonRemoveColor,
    Color? buttonRemoveBackground,
    Color? buttonEditTextColor,
    Color? buttonEditTextBackground,
    Color? buttonScaleRotateColor,
    Color? buttonScaleRotateBackground,
  }) {
    return ThemeLayerInteraction(
      buttonRadius: buttonRadius ?? this.buttonRadius,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      borderElementWidth: borderElementWidth ?? this.borderElementWidth,
      borderElementSpace: borderElementSpace ?? this.borderElementSpace,
      borderColor: borderColor ?? this.borderColor,
      removeCursor: removeCursor ?? this.removeCursor,
      editCursor: editCursor ?? this.editCursor,
      rotateScaleCursor: rotateScaleCursor ?? this.rotateScaleCursor,
      hoverCursor: hoverCursor ?? this.hoverCursor,
      borderStyle: borderStyle ?? this.borderStyle,
      showTooltips: showTooltips ?? this.showTooltips,
      removeAreaBackgroundActive:
          removeAreaBackgroundActive ?? this.removeAreaBackgroundActive,
      removeAreaBackgroundInactive:
          removeAreaBackgroundInactive ?? this.removeAreaBackgroundInactive,
      buttonRemoveColor: buttonRemoveColor ?? this.buttonRemoveColor,
      buttonRemoveBackground:
          buttonRemoveBackground ?? this.buttonRemoveBackground,
      buttonEditTextColor: buttonEditTextColor ?? this.buttonEditTextColor,
      buttonEditTextBackground:
          buttonEditTextBackground ?? this.buttonEditTextBackground,
      buttonScaleRotateColor:
          buttonScaleRotateColor ?? this.buttonScaleRotateColor,
      buttonScaleRotateBackground:
          buttonScaleRotateBackground ?? this.buttonScaleRotateBackground,
    );
  }
}

/// An enumeration representing the style of the border for a selected layer.
///
/// This enum defines the different visual styles available for the border of a
/// selected layer, such as solid, dashed, or dotted.

enum LayerInteractionBorderStyle {
  /// A solid border style.
  solid,

  /// A dashed border style.
  dashed,

  /// A dotted border style.
  dotted,
}
