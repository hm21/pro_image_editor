import 'dart:math' as math;
import 'dart:ui' show Offset, lerpDouble;

import 'package:flutter/foundation.dart' show immutable, listEquals, mergeSort;

import '/shared/utils/layer_animation_progress.dart';
import 'layer.dart';

/// How far apart a playback position and a keyframe may be for the keyframe
/// to count as at that position.
///
/// A seek lands on the frame the decoder delivers, which may be a few
/// milliseconds off the time asked for; without this, editing the layer there
/// would add a second keyframe right next to the one meant.
const Duration kLayerKeyframeTolerance = Duration(milliseconds: 10);

/// [keyframes] sorted by [LayerKeyframe.time], as a new list.
///
/// The sort is stable, so keyframes at the same time keep their order.
List<LayerKeyframe> sortLayerKeyframes(Iterable<LayerKeyframe> keyframes) {
  final sorted = keyframes.toList();
  mergeSort(sorted, compare: (a, b) => a.time.compareTo(b.time));
  return sorted;
}

/// Where a layer sits, how big it is, how far it is turned and how opaque it
/// is at one moment, measured like [Layer.offset], [Layer.scale],
/// [Layer.rotation] and [Layer.opacity].
@immutable
class LayerPlacement {
  /// Creates a [LayerPlacement].
  const LayerPlacement({
    required this.offset,
    this.scale = 1,
    this.rotation = 0,
    this.opacity = 1,
  });

  /// The layer's center, from the center of the canvas, like [Layer.offset].
  final Offset offset;

  /// The layer's scale, like [Layer.scale].
  final double scale;

  /// The layer's rotation in radians, clockwise, like [Layer.rotation].
  final double rotation;

  /// The layer's opacity, from 0 (invisible) to 1.
  final double opacity;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LayerPlacement &&
        other.offset == offset &&
        other.scale == scale &&
        other.rotation == rotation &&
        other.opacity == opacity;
  }

  @override
  int get hashCode => Object.hash(offset, scale, rotation, opacity);

  @override
  String toString() =>
      'LayerPlacement(offset: $offset, scale: $scale, rotation: $rotation, '
      'opacity: $opacity)';
}

/// A layer's placement at one point of its time range.
///
/// A layer with keyframes moves between them while the video plays: before
/// the first one it holds the first one's placement, after the last one the
/// last one's, and between two of them it travels from the earlier to the
/// later one along the earlier one's [curve]. On the way it can play
/// [effects], loop animations such as a wiggle, as a layer does with its own
/// [Layer.animations].
///
/// Mirrors the `ImageLayerKeyframe` of the sister package `pro_video_editor`,
/// so the preview moves the layer the way the export does.
@immutable
class LayerKeyframe {
  /// Creates a [LayerKeyframe].
  const LayerKeyframe({
    required this.time,
    required this.offset,
    this.scale = 1,
    this.rotation = 0,
    this.opacity = 1,
    this.curve = AnimationCurve.linear,
    this.effects = const [],
  });

  /// Creates a keyframe at [time] that holds [placement].
  LayerKeyframe.fromPlacement(
    LayerPlacement placement, {
    required Duration time,
    AnimationCurve curve = AnimationCurve.linear,
  }) : this(
         time: time,
         offset: placement.offset,
         scale: placement.scale,
         rotation: placement.rotation,
         opacity: placement.opacity,
         curve: curve,
       );

  /// Creates a [LayerKeyframe] from a map written by [toMap].
  factory LayerKeyframe.fromMap(Map<String, dynamic> map) {
    final curveName = map['curve'];
    return LayerKeyframe(
      time: Duration(microseconds: (map['timeUs'] as num?)?.toInt() ?? 0),
      offset: Offset(
        (map['x'] as num?)?.toDouble() ?? 0,
        (map['y'] as num?)?.toDouble() ?? 0,
      ),
      scale: (map['scale'] as num?)?.toDouble() ?? 1,
      rotation: (map['rotation'] as num?)?.toDouble() ?? 0,
      opacity: (map['opacity'] as num?)?.toDouble() ?? 1,
      curve: AnimationCurve.values.firstWhere(
        (curve) => curve.name == curveName,
        orElse: () => AnimationCurve.linear,
      ),
      effects: [
        for (final effect in map['effects'] as List? ?? const [])
          if (effect is Map)
            LayerAnimation.fromMap(Map<String, dynamic>.from(effect)),
      ],
    );
  }

  /// When the keyframe applies, measured from the layer's [Layer.startTime],
  /// or from the start of the video when the layer has none.
  ///
  /// Keyframes travel with the layer when it is moved along the timeline.
  final Duration time;

  /// The layer's center, from the center of the canvas, like [Layer.offset].
  final Offset offset;

  /// The layer's scale, like [Layer.scale].
  final double scale;

  /// The layer's rotation in radians, clockwise, like [Layer.rotation].
  ///
  /// The layer turns the whole difference to the next keyframe, so going from
  /// `0` to `2 * pi` is a full turn rather than staying still.
  final double rotation;

  /// The layer's opacity, from 0 (invisible) to 1.
  final double opacity;

  /// How the layer travels from this keyframe to the next one.
  final AnimationCurve curve;

  /// Loop animations the layer plays from this keyframe to the next one, on
  /// top of the motion between the two.
  ///
  /// Only [AnimationPhase.loop] animations play. Each one's cycle is fitted to
  /// the stretch: the whole number of [LayerAnimation.duration] cycles closest
  /// to its length, at least one, spread evenly over it, so the layer is at
  /// rest on both keyframes. The last keyframe's effects never play, having
  /// no next keyframe. See [layerKeyframeEffects].
  final List<LayerAnimation> effects;

  /// The placement this keyframe holds.
  LayerPlacement get placement => LayerPlacement(
    offset: offset,
    scale: scale,
    rotation: rotation,
    opacity: opacity,
  );

  /// Converts this keyframe to a map.
  Map<String, dynamic> toMap() => <String, dynamic>{
    'timeUs': time.inMicroseconds,
    'x': offset.dx,
    'y': offset.dy,
    'scale': scale,
    'rotation': rotation,
    'opacity': opacity,
    'curve': curve.name,
    if (effects.isNotEmpty)
      'effects': [for (final effect in effects) effect.toMap()],
  };

  /// Creates a copy with the given fields replaced.
  LayerKeyframe copyWith({
    Duration? time,
    Offset? offset,
    double? scale,
    double? rotation,
    double? opacity,
    AnimationCurve? curve,
    List<LayerAnimation>? effects,
  }) {
    return LayerKeyframe(
      time: time ?? this.time,
      offset: offset ?? this.offset,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
      curve: curve ?? this.curve,
      effects: effects ?? this.effects,
    );
  }

  /// A copy that holds [placement] instead of this keyframe's placement.
  LayerKeyframe withPlacement(LayerPlacement placement) => copyWith(
    offset: placement.offset,
    scale: placement.scale,
    rotation: placement.rotation,
    opacity: placement.opacity,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LayerKeyframe &&
        other.time == time &&
        other.offset == offset &&
        other.scale == scale &&
        other.rotation == rotation &&
        other.opacity == opacity &&
        other.curve == curve &&
        listEquals(other.effects, effects);
  }

  @override
  int get hashCode => Object.hash(
    time,
    offset,
    scale,
    rotation,
    opacity,
    curve,
    Object.hashAll(effects),
  );

  @override
  String toString() =>
      'LayerKeyframe(time: $time, offset: $offset, scale: $scale, '
      'rotation: $rotation, opacity: $opacity, curve: $curve, '
      'effects: $effects)';
}

/// A loop animation a layer plays between two of its keyframes, see
/// [LayerKeyframe.effects].
@immutable
class LayerKeyframeEffect {
  /// Creates a [LayerKeyframeEffect].
  const LayerKeyframeEffect({
    required this.animation,
    required this.start,
    required this.end,
    required this.cycles,
  });

  /// The effect, with its [LayerAnimation.duration] fitted to the stretch:
  /// [cycles] of it fill the time from [start] to [end].
  final LayerAnimation animation;

  /// The time of the keyframe the effect starts on, on the video's timeline.
  /// The effect counts its cycles from here.
  final Duration start;

  /// The time of the next keyframe, where the effect stops.
  final Duration end;

  /// How many cycles fill the stretch.
  ///
  /// A renderer that times the video differently, such as an export that
  /// shortens it at clip transitions, keeps this count over its own stretch
  /// so the layer still comes to rest on the keyframes.
  final int cycles;

  /// Whether the effect plays at [time] on the video's timeline.
  bool playsAt(Duration time) => time >= start && time < end;

  @override
  bool operator ==(Object other) =>
      other is LayerKeyframeEffect &&
      other.animation == animation &&
      other.start == start &&
      other.end == end &&
      other.cycles == cycles;

  @override
  int get hashCode => Object.hash(animation, start, end, cycles);

  @override
  String toString() =>
      'LayerKeyframeEffect($animation, start: $start, end: $end, '
      'cycles: $cycles)';
}

/// The [LayerKeyframe.effects] of [keyframes], each placed on the stretch to
/// the next keyframe with its cycle fitted to it.
///
/// [keyframes] must be sorted by [LayerKeyframe.time] and are measured from
/// [origin] (see [Layer.keyframeOrigin]). Effects that are not loops, have no
/// duration, or sit on a stretch without length are left out.
List<LayerKeyframeEffect> layerKeyframeEffects(
  List<LayerKeyframe> keyframes, {
  required Duration origin,
}) {
  final result = <LayerKeyframeEffect>[];
  for (var i = 0; i < keyframes.length - 1; i++) {
    final from = keyframes[i];
    if (from.effects.isEmpty) continue;
    final start = origin + from.time;
    final end = origin + keyframes[i + 1].time;
    final spanUs = (end - start).inMicroseconds;
    if (spanUs <= 0) continue;
    for (final effect in from.effects) {
      final cycleUs = effect.duration.inMicroseconds;
      if (effect.phase != AnimationPhase.loop || cycleUs <= 0) continue;
      final cycles = math.max(1, (spanUs / cycleUs).round());
      result.add(
        LayerKeyframeEffect(
          animation: effect.copyWith(
            duration: Duration(microseconds: spanUs ~/ cycles),
          ),
          start: start,
          end: end,
          cycles: cycles,
        ),
      );
    }
  }
  return result;
}

/// The placement [keyframes] give a layer [time] after the time they are
/// measured from (see [LayerKeyframe.time]), or `null` when there are none.
///
/// [keyframes] must be sorted by [LayerKeyframe.time]. Between two keyframes
/// the eased progress mixes their values; an elastic or bounce curve may
/// overshoot either of them, as it does in an animation. Only the opacity is
/// kept within 0–1 and the scale at 0 or more.
///
/// Mirrors `keyframePlacement` in the native renderer of `pro_video_editor`.
LayerPlacement? layerKeyframePlacementAt(
  List<LayerKeyframe> keyframes,
  Duration time,
) {
  if (keyframes.isEmpty) return null;
  final first = keyframes.first;
  if (time <= first.time) return first.placement;
  final last = keyframes.last;
  if (time >= last.time) return last.placement;

  // The last keyframe at or before [time]; the loop above rules out both
  // ends, so a later one always exists.
  var index = 0;
  for (var i = 1; i < keyframes.length; i++) {
    if (keyframes[i].time > time) break;
    index = i;
  }
  final from = keyframes[index];
  final to = keyframes[index + 1];
  final span = (to.time - from.time).inMicroseconds;
  if (span <= 0) return to.placement;

  final t = (time - from.time).inMicroseconds / span;
  final eased = applyLayerAnimationCurve(from.curve, t);
  return LayerPlacement(
    offset: Offset(
      lerpDouble(from.offset.dx, to.offset.dx, eased)!,
      lerpDouble(from.offset.dy, to.offset.dy, eased)!,
    ),
    scale: math.max(0, lerpDouble(from.scale, to.scale, eased)!),
    rotation: lerpDouble(from.rotation, to.rotation, eased)!,
    opacity: lerpDouble(from.opacity, to.opacity, eased)!.clamp(0.0, 1.0),
  );
}
