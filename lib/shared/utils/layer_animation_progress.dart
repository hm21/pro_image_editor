import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '/core/models/layers/layer_animation.dart';

/// Eases [t] (0–1) with [curve] exactly as the native renderer in
/// `pro_video_editor` does (`applyEasing` in ApplyAnimation.kt/.swift).
///
/// Flutter's own [Curves] are close but not the same — its ease curves are
/// cubic Béziers and its elastic curves swing with another period — so the
/// timeline preview uses this instead, and shows what the export renders.
double applyLayerAnimationCurve(AnimationCurve curve, double t) {
  switch (curve) {
    case AnimationCurve.linear:
      return t;
    case AnimationCurve.easeIn:
      return t * t;
    case AnimationCurve.easeOut:
      return t * (2 - t);
    case AnimationCurve.easeInOut:
      return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
    case AnimationCurve.easeInCubic:
      return t * t * t;
    case AnimationCurve.easeOutCubic:
      final p = 1 - t;
      return 1 - p * p * p;
    case AnimationCurve.easeInOutCubic:
      return t < 0.5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3) / 2;
    case AnimationCurve.bounceIn:
      return 1 - _bounceOut(1 - t);
    case AnimationCurve.bounceOut:
      return _bounceOut(t);
    case AnimationCurve.bounceInOut:
      return t < 0.5
          ? (1 - _bounceOut(1 - 2 * t)) / 2
          : (1 + _bounceOut(2 * t - 1)) / 2;
    case AnimationCurve.elasticIn:
      return 1 - _elasticOut(1 - t);
    case AnimationCurve.elasticOut:
      return _elasticOut(t);
    case AnimationCurve.elasticInOut:
      return t < 0.5
          ? (1 - _elasticOut(1 - 2 * t)) / 2
          : (1 + _elasticOut(2 * t - 1)) / 2;
  }
}

double _bounceOut(double t) {
  if (t < 1 / 2.75) return 7.5625 * t * t;
  if (t < 2 / 2.75) {
    final t2 = t - 1.5 / 2.75;
    return 7.5625 * t2 * t2 + 0.75;
  }
  if (t < 2.5 / 2.75) {
    final t2 = t - 2.25 / 2.75;
    return 7.5625 * t2 * t2 + 0.9375;
  }
  final t2 = t - 2.625 / 2.75;
  return 7.5625 * t2 * t2 + 0.984375;
}

double _elasticOut(double t) {
  if (t == 0 || t == 1) return t;
  return math.pow(2, -10 * t).toDouble() *
          math.sin((t - 0.075) * (2 * math.pi) / 0.3) +
      1;
}

/// How far an animation has brought a layer back to rest at one moment.
@immutable
class LayerAnimationProgress {
  /// Creates a progress of [value], tilting a wiggle to [swing].
  const LayerAnimationProgress(this.value, {this.swing = 1});

  /// `1` at rest and `0` fully away (faded out, at the edge, tilted all the
  /// way). An elastic or bounce curve can overshoot either end.
  final double value;

  /// The side a [LayerAnimationType.wiggle] tilts to: `-1` in the second half
  /// of a loop cycle, `1` otherwise.
  final double swing;

  @override
  bool operator ==(Object other) =>
      other is LayerAnimationProgress &&
      other.value == value &&
      other.swing == swing;

  @override
  int get hashCode => Object.hash(value, swing);

  @override
  String toString() => 'LayerAnimationProgress($value, swing: $swing)';
}

/// The progress of [animation] at [time] into the video, or `null` when it
/// does not play then.
///
/// [start] and [end] are the layer's time range (`null` = the start / the
/// end of the video): an in-animation plays over the first
/// [LayerAnimation.duration] of it and an out-animation over the last. With
/// [AnimationPhase.animateInOut] both apply and the one further from rest
/// wins.
///
/// A [AnimationPhase.loop] plays over the whole range, one cycle per duration
/// counted from [start]: the eased value runs from rest to fully away at half
/// a cycle and back. A wiggle runs that twice per cycle, once to each side
/// (see [LayerAnimationProgress.swing]).
///
/// Mirrors `animationProgress` in the native renderer of `pro_video_editor`,
/// down to the whole microseconds the cycle position is taken from.
LayerAnimationProgress? layerAnimationProgress(
  LayerAnimation animation,
  Duration time, {
  required Duration? start,
  required Duration? end,
}) {
  final durationUs = animation.duration.inMicroseconds;
  if (durationUs <= 0) return null;

  final startUs = (start ?? Duration.zero).inMicroseconds;
  final curve = animation.curve;

  if (animation.phase == AnimationPhase.loop) {
    final elapsed = math.max(0, time.inMicroseconds - startUs);
    final inCycle = elapsed % durationUs;
    if (animation.type == LayerAnimationType.wiggle) {
      // Each half of the cycle is one swing out and back.
      final inSwing = (2 * inCycle) % durationUs;
      final x = (1 - 2 * inSwing / durationUs).abs();
      return LayerAnimationProgress(
        applyLayerAnimationCurve(curve, x),
        swing: 2 * inCycle < durationUs ? 1 : -1,
      );
    }
    final x = (1 - 2 * inCycle / durationUs).abs();
    return LayerAnimationProgress(applyLayerAnimationCurve(curve, x));
  }

  double? inProgress;
  double? outProgress;

  if (animation.phase == AnimationPhase.animateIn ||
      animation.phase == AnimationPhase.animateInOut) {
    final elapsed = time.inMicroseconds - startUs;
    if (elapsed < durationUs) {
      inProgress = applyLayerAnimationCurve(
        curve,
        (elapsed / durationUs).clamp(0.0, 1.0),
      );
    }
  }

  if ((animation.phase == AnimationPhase.animateOut ||
          animation.phase == AnimationPhase.animateInOut) &&
      end != null) {
    final remaining = end.inMicroseconds - time.inMicroseconds;
    if (remaining < durationUs) {
      outProgress = applyLayerAnimationCurve(
        curve,
        (remaining / durationUs).clamp(0.0, 1.0),
      );
    }
  }

  // The animation further from rest wins.
  if (inProgress != null && outProgress != null) {
    return LayerAnimationProgress(math.min(inProgress, outProgress));
  }
  final progress = inProgress ?? outProgress;
  return progress == null ? null : LayerAnimationProgress(progress);
}
