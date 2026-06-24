/// The type of animation to apply to a [Layer].
enum LayerAnimationType {
  /// Fade opacity from 0 to 1 (in) or 1 to 0 (out).
  fade,

  /// Slide the layer in/out from a direction.
  slide,

  /// Scale the layer from small to full size (in) or full to small (out).
  scale,
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
/// time range.
enum AnimationPhase {
  /// Animation plays at the beginning of the layer's visible range.
  animateIn,

  /// Animation plays at the end of the layer's visible range.
  animateOut,

  /// Animation plays at both the beginning and end using the same duration.
  animateInOut,
}

/// A single animation applied to a [Layer] on the video timeline.
///
/// Multiple animations can be combined on one layer, e.g. a [fade] in together
/// with a [slide] in from the left. This model mirrors the `LayerAnimation`
/// model in the sister package `pro_video_editor`, so the in-editor video
/// timeline preview matches the exported result.
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
class LayerAnimation {
  /// Creates a [LayerAnimation].
  const LayerAnimation({
    required this.type,
    required this.phase,
    required this.duration,
    this.curve = AnimationCurve.linear,
    this.slideDirection,
    this.scaleFrom,
  }) : assert(
         type != LayerAnimationType.slide || slideDirection != null,
         'slideDirection is required for slide animations',
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
      scaleFrom: (map['scaleFrom'] as num?)?.toDouble(),
    );
  }

  /// Returns the enum value from [values] whose name matches [name], or `null`
  /// when [name] is not a [String] or has no match.
  static T? _enumByName<T extends Enum>(List<T> values, Object? name) {
    if (name is! String) return null;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }

  /// The kind of animation (fade, slide, scale).
  final LayerAnimationType type;

  /// Whether this animation plays at the start, end, or both ends of the
  /// layer's visible range.
  final AnimationPhase phase;

  /// How long the animation lasts in **video time**.
  final Duration duration;

  /// The easing curve for the animation.
  ///
  /// Defaults to [AnimationCurve.linear].
  final AnimationCurve curve;

  /// The direction for [LayerAnimationType.slide] animations.
  ///
  /// Required when [type] is [LayerAnimationType.slide].
  final SlideDirection? slideDirection;

  /// The starting scale factor for [LayerAnimationType.scale] animations.
  ///
  /// Defaults to `0.0` (invisible) when not set. A value of `0.5` means the
  /// layer starts at half size.
  final double? scaleFrom;

  /// Serializes this animation to a map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type.name,
      'phase': phase.name,
      'durationUs': duration.inMicroseconds,
      'curve': curve.name,
      'slideDirection': slideDirection?.name,
      'scaleFrom': scaleFrom,
    };
  }

  /// Creates a copy of this [LayerAnimation] with the given fields replaced.
  LayerAnimation copyWith({
    LayerAnimationType? type,
    AnimationPhase? phase,
    Duration? duration,
    AnimationCurve? curve,
    SlideDirection? slideDirection,
    double? scaleFrom,
  }) {
    return LayerAnimation(
      type: type ?? this.type,
      phase: phase ?? this.phase,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      slideDirection: slideDirection ?? this.slideDirection,
      scaleFrom: scaleFrom ?? this.scaleFrom,
    );
  }

  @override
  String toString() {
    return 'LayerAnimation(type: $type, phase: $phase, '
        'duration: $duration, curve: $curve'
        '${slideDirection != null ? ', slideDirection: $slideDirection' : ''}'
        '${scaleFrom != null ? ', scaleFrom: $scaleFrom' : ''})';
  }

  @override
  bool operator ==(covariant LayerAnimation other) {
    if (identical(this, other)) return true;
    return other.type == type &&
        other.phase == phase &&
        other.duration == duration &&
        other.curve == curve &&
        other.slideDirection == slideDirection &&
        other.scaleFrom == scaleFrom;
  }

  @override
  int get hashCode {
    return type.hashCode ^
        phase.hashCode ^
        duration.hashCode ^
        curve.hashCode ^
        slideDirection.hashCode ^
        scaleFrom.hashCode;
  }
}
