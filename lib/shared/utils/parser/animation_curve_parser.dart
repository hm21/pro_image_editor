import 'package:flutter/animation.dart';

import '/core/models/layers/layer_animation.dart';

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
