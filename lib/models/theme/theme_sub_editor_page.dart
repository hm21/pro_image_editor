// Flutter imports:
import 'package:flutter/widgets.dart';

/// A class representing the theme configuration for a sub-editor page.
class SubEditorPageTheme {
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
  /// This function takes [BuildContext], [Animation<double>], [Animation<double>], and [Widget] as parameters
  /// and returns a Widget representing the transition.
  final Widget Function(
          BuildContext, Animation<double>, Animation<double>, Widget)?
      transitionsBuilder;

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

  bool get requireReposition {
    return positionTop != null ||
        positionLeft != null ||
        positionRight != null ||
        positionBottom != null ||
        borderRadius != null ||
        enforceSizeFromMainEditor;
  }
}
