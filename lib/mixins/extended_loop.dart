// Project imports:
import 'package:pro_image_editor/utils/transition_timing.dart';

/// A mixin that provides an extended loop with transition timing for
/// animations.
///
/// This mixin allows classes to perform an animation loop with a specified
/// transition function, enabling smooth animations over a given duration.
mixin ExtendedLoop {
  /// Performs a loop with transition timing for animations.
  ///
  /// This function executes a loop that runs a given function with a transition
  /// over a specified duration, allowing for smooth animations. It uses a
  /// transition function to calculate the curve of the animation.
  ///
  /// Parameters:
  /// - [function]: The function to execute in the loop, receiving a curve value
  ///   between 0.0 and 1.0.
  /// - [duration]: The total duration of the loop.
  /// - [mounted]: A boolean indicating if the widget is still mounted. The loop
  ///   will terminate if this is false.
  /// - [transitionFunction]: A function that calculates the transition curve.
  ///   Defaults to a linear function.
  /// - [onDone]: An optional callback function that is called when the loop
  ///   completes.
  ///
  /// Example:
  /// ```
  /// loopWithTransitionTiming(
  ///   (curveT) {
  ///     // Perform animation step with curveT
  ///   },
  ///   duration: Duration(seconds: 2),
  ///   mounted: isMounted,
  ///   transitionFunction: easeInOut,
  ///   onDone: () {
  ///     // Animation completed
  ///   },
  /// );
  /// ```
  loopWithTransitionTiming(
    void Function(double curveT) function, {
    required Duration duration,
    required bool mounted,
    double Function(double t) transitionFunction = linear,
    Function()? onDone,
  }) async {
    int frameRate = 1000 ~/ 60;
    double fullTime = duration.inMilliseconds.toDouble();
    double startTime = DateTime.now().millisecondsSinceEpoch.toDouble();
    double endTime = startTime + fullTime;

    if (duration.inMilliseconds != 0) {
      while (DateTime.now().millisecondsSinceEpoch < endTime && mounted) {
        double t =
            (DateTime.now().millisecondsSinceEpoch - startTime) / fullTime;

        function(transitionFunction(t));

        await Future.delayed(Duration(milliseconds: frameRate));
      }
    }
    function(1.0);
    onDone?.call();
  }
}
