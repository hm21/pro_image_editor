// Project imports:
import 'package:pro_image_editor/utils/transition_timing.dart';

mixin ExtendedLoop {
  loopWithTransitionTiming(
    Function(double curveT) function, {
    required Duration duration,
    required bool mounted,
    Function(double t) transitionFunction = linear,
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
