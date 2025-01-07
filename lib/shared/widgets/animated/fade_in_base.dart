import 'dart:async';
import 'package:flutter/material.dart';

/// An abstract base widget that applies a fade-in and slide-in animation
/// to its child.
///
/// The [FadeInBase] class is intended to be extended by specific animation
/// widgets that define the direction of the slide (e.g., slide in from the
/// left, right, up, or down). The child widget is first rendered offscreen
/// at an initial offset position and then slides into view while fading in.
///
/// ## Parameters:
///
/// * [child] - The widget that will be animated.
/// * [duration] - The duration of the fade and slide animation. By default,
///   it is 220 milliseconds.
/// * [delay] - An optional delay before the animation starts. Default is no
/// delay.
/// * [offset] - The distance (as a percentage of the screen) that the widget
///   will initially be offset before animating into its final position.
///   The default value is 30.0 (30% of the screen).
///
/// This base class should be extended by specific widgets that define the
/// direction of the slide animation.
abstract class FadeInBase extends StatefulWidget {
  /// Creates a [FadeInBase] widget with configurable animation parameters.
  ///
  /// [child] is required and represents the widget that will be animated.
  /// Optional parameters include [duration], [delay], and [offset].
  const FadeInBase({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 220),
    this.delay = const Duration(milliseconds: 0),
    this.offset = 30.0,
  });

  /// The widget to be animated.
  final Widget child;

  /// The duration of the animation, including both fading and sliding.
  final Duration duration;

  /// The delay before the animation starts.
  final Duration delay;

  /// The distance (in percentage of the screen) that the child will initially
  /// be offset before sliding into its final position.
  final double offset;
}

/// The base state class that manages the fade-in and slide-in animation.
///
/// The [FadeInBaseState] provides the core logic for animating the child
/// widget by combining both a fade and a slide. Subclasses of this state
/// class should override [buildInitialOffsetPosition] to define the initial
/// position of the widget before it slides into view.
///
/// This class uses an [AnimationController] to manage the animation, and the
/// actual fade and slide are implemented with [FadeTransition] and
/// [SlideTransition], respectively.
abstract class FadeInBaseState<T extends FadeInBase> extends State<T>
    with SingleTickerProviderStateMixin {
  /// The controller that manages the fade-in and slide-in animations.
  late AnimationController controller;

  /// The animation that controls the opacity (fade effect) of the widget.
  late Animation<double> opacityAnimation;

  /// The animation that controls the position (slide effect) of the widget.
  late Animation<Offset> offsetAnimation;

  /// An optional timer that delays the start of the animation.
  Timer? _delayTimer;

  /// Builds the initial offset position for the slide-in animation.
  Offset buildInitialOffsetPosition();

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller with the provided duration.
    controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Configure the opacity animation from invisible (0.0) to fully visible
    // (1.0).
    opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );

    // Configure the offset animation to slide in from the initial offset to
    //the final position (Offset.zero).
    offsetAnimation =
        Tween<Offset>(begin: buildInitialOffsetPosition(), end: Offset.zero)
            .animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animation after the specified delay.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _delayTimer = Timer(widget.delay, () {
        if (!mounted) return;
        controller.forward();
      });
    });
  }

  @override
  void dispose() {
    // Dispose of the animation controller and timer.
    controller.dispose();
    _delayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build the fade and slide animation.
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: opacityAnimation,
          child: SlideTransition(
            position: offsetAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}
