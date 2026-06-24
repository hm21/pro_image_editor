import 'package:flutter/animation.dart';

import '/core/models/layers/layer_animation.dart';

/// Maps an [AnimationCurve] enum value to the equivalent Flutter [Curve].
///
/// Used to drive the in-editor video-timeline preview with the same easing the
/// exported result uses.
Curve curveFromAnimationCurve(AnimationCurve curve) {
  switch (curve) {
    case AnimationCurve.linear:
      return Curves.linear;
    case AnimationCurve.easeIn:
      return Curves.easeIn;
    case AnimationCurve.easeOut:
      return Curves.easeOut;
    case AnimationCurve.easeInOut:
      return Curves.easeInOut;
    case AnimationCurve.easeInCubic:
      return Curves.easeInCubic;
    case AnimationCurve.easeOutCubic:
      return Curves.easeOutCubic;
    case AnimationCurve.easeInOutCubic:
      return Curves.easeInOutCubic;
    case AnimationCurve.bounceIn:
      return Curves.bounceIn;
    case AnimationCurve.bounceOut:
      return Curves.bounceOut;
    case AnimationCurve.bounceInOut:
      return Curves.bounceInOut;
    case AnimationCurve.elasticIn:
      return Curves.elasticIn;
    case AnimationCurve.elasticOut:
      return Curves.elasticOut;
    case AnimationCurve.elasticInOut:
      return Curves.elasticInOut;
  }
}

/// Maps a Flutter [Curve] back to the closest [AnimationCurve] enum value.
///
/// Returns [AnimationCurve.linear] for `null` or any curve without a direct
/// [AnimationCurve] equivalent.
AnimationCurve animationCurveFromCurve(Curve? curve) {
  if (curve == Curves.easeIn) return AnimationCurve.easeIn;
  if (curve == Curves.easeOut) return AnimationCurve.easeOut;
  if (curve == Curves.easeInOut) return AnimationCurve.easeInOut;
  if (curve == Curves.easeInCubic) return AnimationCurve.easeInCubic;
  if (curve == Curves.easeOutCubic) return AnimationCurve.easeOutCubic;
  if (curve == Curves.easeInOutCubic) return AnimationCurve.easeInOutCubic;
  if (curve == Curves.bounceIn) return AnimationCurve.bounceIn;
  if (curve == Curves.bounceOut) return AnimationCurve.bounceOut;
  if (curve == Curves.bounceInOut) return AnimationCurve.bounceInOut;
  if (curve == Curves.elasticIn) return AnimationCurve.elasticIn;
  if (curve == Curves.elasticOut) return AnimationCurve.elasticOut;
  if (curve == Curves.elasticInOut) return AnimationCurve.elasticInOut;
  return AnimationCurve.linear;
}
