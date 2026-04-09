import 'package:flutter/animation.dart';

/// Computes a visibility progress value (0.0 – 1.0) for a timeline item
/// based on the current video position.
///
/// - Before [startTime] → 0.0
/// - During enter ([startTime] → [startTime] + [enterDuration]) → 0.0…1.0
/// - Fully visible region → 1.0
/// - During exit ([endTime] - [exitDuration] → [endTime]) → 1.0…0.0
/// - After [endTime] → 0.0
/// - If both [startTime] and [endTime] are `null` → always 1.0
double computeTimelineProgress({
  required Duration currentTime,
  required Duration? startTime,
  required Duration? endTime,
  required Duration? enterDuration,
  required Duration? exitDuration,
  required Curve defaultEnterCurve,
  required Curve defaultExitCurve,
  Curve? enterCurve,
  Curve? exitCurve,
}) {
  if (startTime != null && currentTime < startTime) return 0.0;
  if (endTime != null && currentTime > endTime) return 0.0;

  if (startTime != null &&
      enterDuration != null &&
      enterDuration > Duration.zero) {
    final fadeInEnd = startTime + enterDuration;
    if (currentTime < fadeInEnd) {
      final elapsed = (currentTime - startTime).inMicroseconds;
      final total = enterDuration.inMicroseconds;
      final t = (elapsed / total).clamp(0.0, 1.0);
      return (enterCurve ?? defaultEnterCurve).transform(t);
    }
  }

  if (endTime != null && exitDuration != null && exitDuration > Duration.zero) {
    final fadeOutStart = endTime - exitDuration;
    if (currentTime > fadeOutStart) {
      final remaining = (endTime - currentTime).inMicroseconds;
      final total = exitDuration.inMicroseconds;
      final t = (remaining / total).clamp(0.0, 1.0);
      return (exitCurve ?? defaultExitCurve).transform(t);
    }
  }

  return 1.0;
}
