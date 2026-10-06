import 'dart:ui' show Offset;

import '/shared/utils/parser/offset_parser.dart';
import 'layer.dart';

/// The type of animation to apply to a [Layer].
///
/// Every type moves the layer away from its resting state by an amount that
/// follows the animation's progress: fully away at the start of an
/// [AnimationPhase.animateIn], at rest once it ends, and back again over an
/// [AnimationPhase.animateOut]. [AnimationPhase.loop] swings between the two
/// over and over.
enum LayerAnimationType {
  /// Fade opacity from 0 to 1 (in) or 1 to 0 (out).
  fade,

  /// Slide the layer in/out from a direction.
  slide,

  /// Scale the layer from small to full size (in) or full to small (out).
  scale,

  /// Tilt the layer around its center by up to [LayerAnimation.wiggleAngle].
  ///
  /// In and out, the layer turns between the tilted and the upright position;
  /// an elastic or bounce [AnimationCurve] makes it wobble into place. In a
  /// [AnimationPhase.loop] it tilts to one side and then to the other within
  /// every cycle, so it wiggles for as long as it is visible.
  wiggle,

  /// Lift the layer by [LayerAnimation.bounceHeight] times its height.
  ///
  /// The height is that of the box the layer is drawn in, which for a
  /// rotated layer is the box around it, as the exported image is. In, the
  /// layer drops onto its resting place, out it rises from it; a bounce
  /// [AnimationCurve] makes it bounce on landing. In a [AnimationPhase.loop]
  /// it hops up and lands once per cycle.
  bounce,

  /// Reveal the text of a text layer letter by letter (in), or take it away
  /// from the last letter back (out).
  ///
  /// Spaces and line breaks take no step of their own. The text keeps its
  /// size and line breaks from the start, and its background, if any, grows
  /// with the part that is revealed. Other layers ignore this type.
  ///
  /// A video renderer draws a layer as a fixed image, so an exported layer
  /// carries an image per step; `ExportedLayer.frames` says which one shows
  /// when.
  typewriter,

  /// Reveal the text of a text layer word by word (in), or take it away from
  /// the last word back (out). Works like [typewriter] otherwise.
  wordByWord,
}

/// Slide direction for slide animations.
enum SlideDirection {
  /// Slide from/to the left edge.
  left,

  /// Slide from/to the right edge.
  right,

  /// Slide from/to the top edge.
  top,

  /// Slide from/to the bottom edge.
  bottom,
}

/// Easing curve for animation timing.
enum AnimationCurve {
  /// Constant speed from start to end.
  linear,

  /// Starts slow, accelerates (quadratic).
  easeIn,

  /// Starts fast, decelerates (quadratic).
  easeOut,

  /// Starts slow, accelerates, then decelerates (quadratic).
  easeInOut,

  /// Starts slow, accelerates (cubic – smoother than [easeIn]).
  easeInCubic,

  /// Starts fast, decelerates (cubic – smoother than [easeOut]).
  easeOutCubic,

  /// Starts slow, accelerates, then decelerates (cubic).
  easeInOutCubic,

  /// Bounces at the start before settling.
  bounceIn,

  /// Bounces at the end like a ball hitting the ground.
  bounceOut,

  /// Bounces at both the start and end.
  bounceInOut,

  /// Overshoots at the start and springs forward.
  elasticIn,

  /// Overshoots the target and springs back.
  elasticOut,

  /// Elastic spring effect at both start and end.
  elasticInOut,
}

/// Whether the animation plays at the start, end, or both ends of the layer's
/// time range, or repeats throughout it.
enum AnimationPhase {
  /// Animation plays at the beginning of the layer's visible range.
  animateIn,

  /// Animation plays at the end of the layer's visible range.
  animateOut,

  /// Animation plays at both the beginning and end using the same duration.
  animateInOut,

  /// Animation repeats for as long as the layer is visible, one cycle every
  /// [LayerAnimation.duration], counted from the layer's start.
  ///
  /// Each cycle leaves the resting state and comes back to it: halfway
  /// through, a fade has the layer invisible, a scale has it at
  /// [LayerAnimation.scaleFrom] and a slide has it at the edge or the
  /// [LayerAnimation.slideFrom] point. A [LayerAnimationType.wiggle] tilts to
  /// one side in the first half of the cycle and to the other in the second.
  ///
  /// The [LayerAnimation.curve] shapes the way out like an [animateOut] and
  /// the way back like an [animateIn]: with [AnimationCurve.easeIn] the layer
  /// moves fastest at rest and slowest at the turning point, like a pendulum
  /// or a hop.
  loop,
}

/// A single animation applied to a [Layer] on the video timeline.
///
/// Multiple animations can be combined on one layer, e.g. a
/// [LayerAnimationType.fade] in together with a [LayerAnimationType.slide] in
/// from the left. This model mirrors the `LayerAnimation` model in the sister
/// package `pro_video_editor`, so the in-editor video timeline preview matches
/// the exported result.
///
/// Example:
/// ```dart
/// WidgetLayer(
///   widget: myWidget,
///   startTime: Duration.zero,
///   endTime: const Duration(seconds: 10),
///   animations: const [
///     LayerAnimation(
///       type: LayerAnimationType.slide,
///       phase: AnimationPhase.animateIn,
///       duration: Duration(milliseconds: 400),
///       slideDirection: SlideDirection.left,
///       curve: AnimationCurve.easeOut,
///     ),
///     LayerAnimation(
///       type: LayerAnimationType.fade,
///       phase: AnimationPhase.animateOut,
///       duration: Duration(milliseconds: 300),
///     ),
///   ],
/// )
/// ```
///
/// A slide can start from a point of your own instead of a canvas edge — the
/// layer below comes in diagonally from beyond the top-left corner:
///
/// ```dart
/// LayerAnimation(
///   type: LayerAnimationType.slide,
///   phase: AnimationPhase.animateIn,
///   duration: Duration(milliseconds: 600),
///   slideFrom: Offset(-400, -400),
///   curve: AnimationCurve.easeOutCubic,
/// )
/// ```
class LayerAnimation {
  /// Creates a [LayerAnimation].
  const LayerAnimation({
    required this.type,
    required this.phase,
    required this.duration,
    this.curve = AnimationCurve.linear,
    this.slideDirection,
    this.slideFrom,
    this.scaleFrom,
    this.wiggleAngle,
    this.bounceHeight,
  }) : assert(
         type != LayerAnimationType.slide ||
             slideDirection != null ||
             slideFrom != null,
         'slide animations need either a slideDirection or a slideFrom point',
       );

  /// Creates a [LayerAnimation] from a serialized [map].
  ///
  /// Parsing is lenient: unknown or missing enum names fall back to a sensible
  /// default ([LayerAnimationType.fade], [AnimationPhase.animateIn],
  /// [AnimationCurve.linear]) and a missing `durationUs` becomes
  /// [Duration.zero], so importing data produced by a newer version (or
  /// hand-edited JSON) degrades gracefully instead of throwing.
  factory LayerAnimation.fromMap(Map<String, dynamic> map) {
    return LayerAnimation(
      type:
          _enumByName(LayerAnimationType.values, map['type']) ??
          LayerAnimationType.fade,
      phase:
          _enumByName(AnimationPhase.values, map['phase']) ??
          AnimationPhase.animateIn,
      duration: Duration(
        microseconds: (map['durationUs'] as num?)?.toInt() ?? 0,
      ),
      curve:
          _enumByName(AnimationCurve.values, map['curve']) ??
          AnimationCurve.linear,
      slideDirection: _enumByName(SlideDirection.values, map['slideDirection']),
      slideFrom: map['slideFrom'] is Map
          ? safeParseOffset(Map<String, dynamic>.from(map['slideFrom'] as Map))
          : null,
      scaleFrom: (map['scaleFrom'] as num?)?.toDouble(),
      wiggleAngle: (map['wiggleAngle'] as num?)?.toDouble(),
      bounceHeight: (map['bounceHeight'] as num?)?.toDouble(),
    );
  }

  /// How far a [LayerAnimationType.wiggle] tilts when [wiggleAngle] is not
  /// set: 10°, in radians.
  static const double defaultWiggleAngle = 0.17453292519943295;

  /// How high a [LayerAnimationType.bounce] lifts the layer when
  /// [bounceHeight] is not set: half its height.
  static const double defaultBounceHeight = 0.5;

  /// Returns the enum value from [values] whose name matches [name], or `null`
  /// when [name] is not a [String] or has no match.
  static T? _enumByName<T extends Enum>(List<T> values, Object? name) {
    if (name is! String) return null;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }

  /// The kind of animation (fade, slide, scale, wiggle, bounce, ...).
  final LayerAnimationType type;

  /// Whether this animation plays at the start, end, or both ends of the
  /// layer's visible range, or repeats throughout it.
  final AnimationPhase phase;

  /// How long the animation lasts in **video time**, or one cycle of a
  /// [AnimationPhase.loop].
  final Duration duration;

  /// The easing curve for the animation.
  ///
  /// Defaults to [AnimationCurve.linear].
  final AnimationCurve curve;

  /// The direction for [LayerAnimationType.slide] animations.
  ///
  /// The layer travels between its resting place and the canvas edge in this
  /// direction, far enough to sit completely outside the canvas.
  ///
  /// Required when [type] is [LayerAnimationType.slide], unless [slideFrom]
  /// names a start point instead.
  final SlideDirection? slideDirection;

  /// A custom start point for [LayerAnimationType.slide] animations, in
  /// canvas pixels.
  ///
  /// Uses the same coordinate system as [Layer.offset]: the layer's anchor
  /// point measured from the center of the editor canvas. The layer starts
  /// here and slides to its resting [Layer.offset]
  /// ([AnimationPhase.animateIn]), or leaves its resting place for this point
  /// ([AnimationPhase.animateOut]). With [AnimationPhase.animateInOut] the
  /// point is both: the layer enters from it and leaves back towards it.
  ///
  /// Values may sit outside the canvas — on a 400×800 canvas
  /// `Offset(-400, 0)` starts the layer 200px past the left edge.
  ///
  /// Only the distance between this point and [Layer.offset] is used, so the
  /// layer's own size, rotation and scale play no part — exactly how the
  /// native renderer in `pro_video_editor` computes it. That package measures
  /// its own `slideFrom` from the video frame's top-left corner, matching its
  /// layer offsets, so an exporter bridging to it must convert this point
  /// through the very same transform it applies to [Layer.offset] (canvas
  /// origin *and* export scale). Converting one but not the other leaves the
  /// layer resting correctly while travelling the wrong distance.
  ///
  /// Overrides [slideDirection] when both are set.
  final Offset? slideFrom;

  /// The starting scale factor for [LayerAnimationType.scale] animations.
  ///
  /// Defaults to `0.0` (invisible) when not set. A value of `0.5` means the
  /// layer starts at half size.
  final double? scaleFrom;

  /// How far a [LayerAnimationType.wiggle] tilts the layer, in **radians**.
  ///
  /// Positive values tilt clockwise first, like [Layer.rotation]. Defaults to
  /// [defaultWiggleAngle] when not set.
  final double? wiggleAngle;

  /// How high a [LayerAnimationType.bounce] lifts the layer, as a multiple of
  /// its height: `0.5` lifts it by half its height.
  ///
  /// Defaults to [defaultBounceHeight] when not set.
  final double? bounceHeight;

  /// Whether this animation reveals the text of a text layer rather than
  /// moving the layer: [LayerAnimationType.typewriter] or
  /// [LayerAnimationType.wordByWord].
  bool get isTextReveal =>
      type == LayerAnimationType.typewriter ||
      type == LayerAnimationType.wordByWord;

  /// Serializes this animation to a map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type.name,
      'phase': phase.name,
      'durationUs': duration.inMicroseconds,
      'curve': curve.name,
      'slideDirection': slideDirection?.name,
      'slideFrom': slideFrom != null
          ? {'dx': slideFrom!.dx, 'dy': slideFrom!.dy}
          : null,
      'scaleFrom': scaleFrom,
      'wiggleAngle': wiggleAngle,
      'bounceHeight': bounceHeight,
    };
  }

  /// Creates a copy of this [LayerAnimation] with the given fields replaced.
  LayerAnimation copyWith({
    LayerAnimationType? type,
    AnimationPhase? phase,
    Duration? duration,
    AnimationCurve? curve,
    SlideDirection? slideDirection,
    Offset? slideFrom,
    double? scaleFrom,
    double? wiggleAngle,
    double? bounceHeight,
  }) {
    return LayerAnimation(
      type: type ?? this.type,
      phase: phase ?? this.phase,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      slideDirection: slideDirection ?? this.slideDirection,
      slideFrom: slideFrom ?? this.slideFrom,
      scaleFrom: scaleFrom ?? this.scaleFrom,
      wiggleAngle: wiggleAngle ?? this.wiggleAngle,
      bounceHeight: bounceHeight ?? this.bounceHeight,
    );
  }

  @override
  String toString() {
    return 'LayerAnimation(type: $type, phase: $phase, '
        'duration: $duration, curve: $curve'
        '${slideDirection != null ? ', slideDirection: $slideDirection' : ''}'
        '${slideFrom != null ? ', slideFrom: $slideFrom' : ''}'
        '${scaleFrom != null ? ', scaleFrom: $scaleFrom' : ''}'
        '${wiggleAngle != null ? ', wiggleAngle: $wiggleAngle' : ''}'
        '${bounceHeight != null ? ', bounceHeight: $bounceHeight' : ''})';
  }

  @override
  bool operator ==(covariant LayerAnimation other) {
    if (identical(this, other)) return true;
    return other.type == type &&
        other.phase == phase &&
        other.duration == duration &&
        other.curve == curve &&
        other.slideDirection == slideDirection &&
        other.slideFrom == slideFrom &&
        other.scaleFrom == scaleFrom &&
        other.wiggleAngle == wiggleAngle &&
        other.bounceHeight == bounceHeight;
  }

  @override
  int get hashCode {
    return type.hashCode ^
        phase.hashCode ^
        duration.hashCode ^
        curve.hashCode ^
        slideDirection.hashCode ^
        slideFrom.hashCode ^
        scaleFrom.hashCode ^
        wiggleAngle.hashCode ^
        bounceHeight.hashCode;
  }
}
