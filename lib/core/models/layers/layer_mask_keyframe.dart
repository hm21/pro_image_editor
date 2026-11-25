import 'dart:math' as math;
import 'dart:ui' show Offset, Size, lerpDouble;

import 'package:flutter/foundation.dart' show immutable, mergeSort;

import '/shared/utils/layer_animation_progress.dart';
import 'layer.dart';

/// Where a [LayerMask]'s shape sits, how big it is, how far it is turned and
/// how soft its edge is at one point of the masked item's time range.
///
/// A mask with keyframes changes between them while the video plays, on its
/// own and on top of the item's own motion: before the first one it holds the
/// first one's geometry, after the last one the last one's, and between two of
/// them it travels from the earlier to the later one along the earlier one's
/// [curve]. Its [LayerMask.shape], [LayerMask.cornerRadius] and
/// [LayerMask.invert] do not change.
///
/// Everything is measured like the fields of [LayerMask], in fractions of the
/// masked item's box, so the shape still moves, grows and turns with the item
/// and its [Layer.keyframes] as well.
///
/// Mirrors the shape mask keyframes of the sister package `pro_video_editor`,
/// so the preview changes the mask the way the export does.
@immutable
class LayerMaskKeyframe {
  /// Creates a [LayerMaskKeyframe].
  const LayerMaskKeyframe({
    required this.time,
    this.center = const Offset(0.5, 0.5),
    this.size = const Size(0.5, 0.5),
    this.rotation = 0,
    this.feather = 0,
    this.curve = AnimationCurve.linear,
  }) : assert(feather >= 0, '[feather] must not be negative');

  /// Creates a keyframe at [time] that holds the geometry of [mask].
  LayerMaskKeyframe.fromMask(
    LayerMask mask, {
    required Duration time,
    AnimationCurve curve = AnimationCurve.linear,
  }) : this(
         time: time,
         center: mask.center,
         size: mask.size,
         rotation: mask.rotation,
         feather: mask.feather,
         curve: curve,
       );

  /// Creates a [LayerMaskKeyframe] from a map written by [toMap].
  factory LayerMaskKeyframe.fromMap(Map<String, dynamic> map) {
    final curveName = map['curve'];
    return LayerMaskKeyframe(
      time: Duration(microseconds: (map['timeUs'] as num?)?.toInt() ?? 0),
      center: Offset(
        (map['x'] as num?)?.toDouble() ?? 0.5,
        (map['y'] as num?)?.toDouble() ?? 0.5,
      ),
      size: Size(
        (map['width'] as num?)?.toDouble() ?? 0.5,
        (map['height'] as num?)?.toDouble() ?? 0.5,
      ),
      rotation: (map['rotation'] as num?)?.toDouble() ?? 0,
      feather: math.max(0, (map['feather'] as num?)?.toDouble() ?? 0),
      curve: AnimationCurve.values.firstWhere(
        (curve) => curve.name == curveName,
        orElse: () => AnimationCurve.linear,
      ),
    );
  }

  /// When the keyframe applies, measured from the start of the masked item:
  /// for a layer from its [Layer.keyframeOrigin], as [LayerKeyframe.time] is.
  ///
  /// Keyframes travel with the item when it is moved along the timeline.
  final Duration time;

  /// The centre of the shape, like [LayerMask.center].
  final Offset center;

  /// The size of the shape's box before it is turned, like [LayerMask.size].
  final Size size;

  /// How far the shape is turned, like [LayerMask.rotation].
  ///
  /// The shape turns the whole difference to the next keyframe, so going from
  /// `0` to `2 * pi` is a full turn rather than staying still.
  final double rotation;

  /// How soft the edge is, like [LayerMask.feather].
  final double feather;

  /// How the mask travels from this keyframe to the next one.
  final AnimationCurve curve;

  /// Converts this keyframe to a map.
  Map<String, dynamic> toMap() => <String, dynamic>{
    'timeUs': time.inMicroseconds,
    'x': center.dx,
    'y': center.dy,
    'width': size.width,
    'height': size.height,
    'rotation': rotation,
    'feather': feather,
    'curve': curve.name,
  };

  /// Creates a copy with the given fields replaced.
  LayerMaskKeyframe copyWith({
    Duration? time,
    Offset? center,
    Size? size,
    double? rotation,
    double? feather,
    AnimationCurve? curve,
  }) {
    return LayerMaskKeyframe(
      time: time ?? this.time,
      center: center ?? this.center,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
      feather: feather ?? this.feather,
      curve: curve ?? this.curve,
    );
  }

  /// A copy that holds the geometry of [mask] instead of its own.
  LayerMaskKeyframe withGeometryOf(LayerMask mask) => copyWith(
    center: mask.center,
    size: mask.size,
    rotation: mask.rotation,
    feather: mask.feather,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LayerMaskKeyframe &&
        other.time == time &&
        other.center == center &&
        other.size == size &&
        other.rotation == rotation &&
        other.feather == feather &&
        other.curve == curve;
  }

  @override
  int get hashCode => Object.hash(time, center, size, rotation, feather, curve);

  @override
  String toString() =>
      'LayerMaskKeyframe(time: $time, center: $center, size: $size, '
      'rotation: $rotation, feather: $feather, curve: $curve)';
}

/// [keyframes] sorted by [LayerMaskKeyframe.time], as a new unmodifiable list.
///
/// The sort is stable, so keyframes at the same time keep their order.
List<LayerMaskKeyframe> sortLayerMaskKeyframes(
  Iterable<LayerMaskKeyframe> keyframes,
) {
  final sorted = keyframes.toList();
  mergeSort(sorted, compare: (a, b) => a.time.compareTo(b.time));
  return List.unmodifiable(sorted);
}

/// The geometry [keyframes] give a mask [time] after the time they are
/// measured from, as a keyframe at [time] whose [LayerMaskKeyframe.curve] is
/// the earlier keyframe's, or `null` when there are none.
///
/// [keyframes] must be sorted by [LayerMaskKeyframe.time]. Between two
/// keyframes the eased progress mixes their values; an elastic or bounce curve
/// may overshoot either of them, as it does in an animation. Only the size and
/// the softness are kept at 0 or more.
///
/// Mirrors the shape mask keyframes in the native renderer of
/// `pro_video_editor`.
LayerMaskKeyframe? layerMaskKeyframeAt(
  List<LayerMaskKeyframe> keyframes,
  Duration time,
) {
  if (keyframes.isEmpty) return null;
  final first = keyframes.first;
  if (time <= first.time) return first.copyWith(time: time);
  final last = keyframes.last;
  if (time >= last.time) return last.copyWith(time: time);

  // The last keyframe at or before [time]; the checks above rule out both
  // ends, so a later one always exists.
  var index = 0;
  for (var i = 1; i < keyframes.length; i++) {
    if (keyframes[i].time > time) break;
    index = i;
  }
  final from = keyframes[index];
  final to = keyframes[index + 1];
  final span = (to.time - from.time).inMicroseconds;
  if (span <= 0) return to.copyWith(time: time);

  final t = (time - from.time).inMicroseconds / span;
  final eased = applyLayerAnimationCurve(from.curve, t);
  double mix(double a, double b) => lerpDouble(a, b, eased)!;
  return LayerMaskKeyframe(
    time: time,
    center: Offset(
      mix(from.center.dx, to.center.dx),
      mix(from.center.dy, to.center.dy),
    ),
    size: Size(
      math.max(0, mix(from.size.width, to.size.width)),
      math.max(0, mix(from.size.height, to.size.height)),
    ),
    rotation: mix(from.rotation, to.rotation),
    feather: math.max(0, mix(from.feather, to.feather)),
    curve: from.curve,
  );
}
