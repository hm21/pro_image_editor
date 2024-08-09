import 'package:flutter/widgets.dart';
import 'package:pro_image_editor/widgets/overlays/loading_dialog/animations/loading_dialog_base_animation.dart';

/// A widget that provides an animated opacity transition for overlays.
///
/// The animation is controlled by an [AnimationController].
class OpacityOverlayAnimation extends LoadingDialogOverlayAnimation {
  /// Creates an [OpacityOverlayAnimation] widget.
  ///
  /// The [child] and [onAnimationDone] parameters must not be null.
  const OpacityOverlayAnimation({
    super.key,
    required super.child,
    required super.onAnimationDone,
  });

  @override
  OpacityOverlayAnimationState createState() => OpacityOverlayAnimationState();
}

/// The state class for [OpacityOverlayAnimation].
///
/// It manages the animation controller and the opacity transition.
class OpacityOverlayAnimationState extends LoadingDialogOverlayAnimationState {
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: widget.child,
        );
      },
    );
  }
}
