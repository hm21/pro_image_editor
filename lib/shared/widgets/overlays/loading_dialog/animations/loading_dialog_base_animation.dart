import 'package:flutter/widgets.dart';

/// An abstract class representing a loading dialog overlay animation.
/// Intended to be subclassed for specific animation implementations.
abstract class LoadingDialogOverlayAnimation extends StatefulWidget {
  /// A widget that provides an overlay animation for a loading dialog.
  const LoadingDialogOverlayAnimation({
    super.key,
    required this.child,
    required this.onAnimationDone,
  });

  /// The child widget to be animated.
  final Widget child;

  /// Callback function called when the animation is done.
  final Function() onAnimationDone;
}

/// State class for handling animation logic.
/// Must be subclassed to provide specific animation details.
abstract class LoadingDialogOverlayAnimationState
    extends State<LoadingDialogOverlayAnimation>
    with SingleTickerProviderStateMixin {
  /// Animation controller for managing animation lifecycle.
  @protected
  late AnimationController controller;

  /// Animation object for controlling the animation value.
  @protected
  late Animation<double> animation;

  /// Initiates hiding of the dialog with a reverse animation.
  void hide() {
    controller.reverse().whenComplete(widget.onAnimationDone);
  }

  /// Disposes the animation controller to free resources.
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// Builds the widget tree.
  @override
  Widget build(BuildContext context);
}
