// Flutter imports:
import 'package:flutter/widgets.dart';

/// A class representing the theme configuration for a sub-editor page.
class SubEditorPageTheme {
  /// Creates a [SubEditorPageTheme].
  ///
  /// The [enforceSizeFromMainEditor] defaults to `false`.
  /// The [barrierDismissible] defaults to `false`.
  const SubEditorPageTheme({
    this.enforceSizeFromMainEditor = false,
    this.barrierDismissible = false,
    this.borderRadius,
    this.positionTop,
    this.positionLeft,
    this.positionRight,
    this.positionBottom,
    this.barrierColor,
    this.transitionsBuilder,
  });

  /// Whether to enforce the size from the main editor.
  final bool enforceSizeFromMainEditor;

  /// Whether the barrier is dismissible.
  final bool barrierDismissible;

  /// The border radius of the sub-editor page.
  final BorderRadiusGeometry? borderRadius;

  /// The position from the top of the screen.
  final double? positionTop;

  /// The position from the left of the screen.
  final double? positionLeft;

  /// The position from the right of the screen.
  final double? positionRight;

  /// The position from the bottom of the screen.
  final double? positionBottom;

  /// The color of the barrier.
  final Color? barrierColor;

  /// The builder function for transitions.
  ///
  /// This function takes [BuildContext], [Animation<double>],
  /// [Animation<double>], and [Widget] as parameters and returns a Widget
  /// representing the transition.
  final Widget Function(
          BuildContext, Animation<double>, Animation<double>, Widget)?
      transitionsBuilder;

  /// Checks if repositioning is required based on the presence of certain
  /// properties.
  bool get requireReposition {
    return positionTop != null ||
        positionLeft != null ||
        positionRight != null ||
        positionBottom != null ||
        borderRadius != null ||
        enforceSizeFromMainEditor;
  }

  /// Creates a copy of this `SubEditorPageTheme` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [SubEditorPageTheme] with some properties updated while keeping the
  /// others unchanged.
  SubEditorPageTheme copyWith({
    bool? enforceSizeFromMainEditor,
    bool? barrierDismissible,
    BorderRadiusGeometry? borderRadius,
    double? positionTop,
    double? positionLeft,
    double? positionRight,
    double? positionBottom,
    Color? barrierColor,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transitionsBuilder,
  }) {
    return SubEditorPageTheme(
      enforceSizeFromMainEditor:
          enforceSizeFromMainEditor ?? this.enforceSizeFromMainEditor,
      barrierDismissible: barrierDismissible ?? this.barrierDismissible,
      borderRadius: borderRadius ?? this.borderRadius,
      positionTop: positionTop ?? this.positionTop,
      positionLeft: positionLeft ?? this.positionLeft,
      positionRight: positionRight ?? this.positionRight,
      positionBottom: positionBottom ?? this.positionBottom,
      barrierColor: barrierColor ?? this.barrierColor,
      transitionsBuilder: transitionsBuilder ?? this.transitionsBuilder,
    );
  }
}
