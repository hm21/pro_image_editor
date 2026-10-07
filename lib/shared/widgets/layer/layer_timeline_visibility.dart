import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/rendering.dart' show BoxHitTestResult, RenderProxyBox;
import 'package:flutter/widgets.dart';

import '/core/models/editor_configs/video/layer_timeline_configs.dart';
import '/core/models/layers/layer.dart';
import '/shared/utils/layer_animation_progress.dart';
import '/shared/utils/timeline_progress.dart';
import 'widgets/invisible_but_painted.dart';

/// Controls layer visibility based on [Layer.startTime] / [Layer.endTime]
/// relative to the current video time.
///
/// The animation progress is derived directly from the video position so that
/// seeking immediately reflects the correct transition state (e.g. seeking to
/// the middle of a 5 s fade-in shows the layer at 50 %).
///
/// When [Layer.animations] is not empty, the transition is phase-aware: each
/// animation drives a fade, slide, scale, wiggle or bounce during the layer's
/// enter window (`[startTime, startTime + duration]`) and/or exit window
/// (`[endTime - duration, endTime]`). Multiple animations are composed, so the
/// enter and leave phases can use distinct animation types — something the
/// single `(child, animation)` [LayerTimelineConfigs.transitionBuilder] cannot
/// express. The slide effect is edge-aware: using [canvasSize] and
/// [layerCenter] it pushes the layer just past the nearest canvas edge (rather
/// than by its own size), so even an off-center layer leaves the visible area
/// completely. A [LayerAnimation.slideFrom] point replaces that edge with a
/// start position of the caller's own, measured like [Layer.offset]. The scale
/// effect is anchored on the layer's visual center (via
/// [layerFractionalOffset]) so that a combined slide + scale enters straight
/// instead of drifting diagonally. A wiggle tilts the layer around the same
/// center, and a bounce lifts it by a multiple of its height, measured on the
/// box around the rotated layer as the exported image is. A
/// [AnimationPhase.loop] repeats for as long as the layer is visible. Text
/// reveals are drawn by the text layer itself. When [Layer.animations] is
/// empty, the legacy fade convenience driven by [Layer.enterDuration] /
/// [Layer.exitDuration] and the [LayerTimelineConfigs.transitionBuilder] is
/// used instead.
///
/// [Layer.keyframes] place the layer at every point of its time range. The
/// widget's child is laid out at the layer's own placement, so the keyframed
/// one is applied as the difference to it: the layer turns and scales around
/// its visual center and moves by the difference in offset, and its opacity
/// is the keyframes' own. The animations are composed on top of that, as the
/// native renderer composes them on the keyframed placement, and so are the
/// [LayerKeyframe.effects] between two keyframes while the playhead is there.
class LayerTimelineVisibility extends StatefulWidget {
  /// Creates a [LayerTimelineVisibility].
  const LayerTimelineVisibility({
    super.key,
    required this.layer,
    required this.playTimeNotifier,
    required this.configs,
    required this.canvasSize,
    required this.layerCenter,
    this.layerFractionalOffset = const Offset(-0.5, -0.5),
    required this.child,
  });

  /// The layer whose time range is evaluated.
  final Layer layer;

  /// Notifier that provides the current video playback position.
  final ValueNotifier<Duration> playTimeNotifier;

  /// Animation configuration for the enter/exit transition.
  final LayerTimelineConfigs configs;

  /// The size of the editor canvas (in canvas coordinates, origin top-left).
  ///
  /// Used by the edge-aware slide animation to push the layer fully off the
  /// canvas regardless of where the layer is positioned.
  final Size canvasSize;

  /// The layer's center in canvas coordinates (origin top-left).
  ///
  /// Combined with [canvasSize] this lets the slide animation translate the
  /// layer just far enough for its edge to leave (or enter from) the canvas.
  final Offset layerCenter;

  /// The fractional offset used to position the layer content within its
  /// layout box (defaults to `Offset(-0.5, -0.5)`, centering the content).
  ///
  /// The [child] paints its visible content shifted by this fraction, so the
  /// layer's visual center is *not* the layout box center. The scale animation
  /// uses this to anchor scaling on the visual center; otherwise scaling would
  /// pull the layer toward the box center (down-right for the default offset),
  /// making a combined slide + scale drift in diagonally instead of straight.
  final Offset layerFractionalOffset;

  /// The layer widget to show/hide.
  final Widget child;

  @override
  State<LayerTimelineVisibility> createState() =>
      _LayerTimelineVisibilityState();
}

class _LayerTimelineVisibilityState extends State<LayerTimelineVisibility> {
  late _TimelineFrame _frame;

  /// The geometry [_frame] was computed from, so [_geometryChanged] can tell
  /// when the cached frame went stale.
  late Offset _framedLayerOffset;
  late double _framedLayerScale;
  late double _framedLayerRotation;
  late bool _framedLayerMirrored;
  late List<LayerKeyframe> _framedKeyframes;
  late Offset _framedLayerCenter;
  late Size _framedCanvasSize;

  /// Whether the geometry the keyframes and the slide animation read has
  /// moved since [_frame] was computed.
  ///
  /// [Layer] is mutable and is mutated in place while it is dragged, so
  /// `oldWidget.layer.offset != widget.layer.offset` never fires — both
  /// widgets hold the same instance. The recorded values are compared instead.
  ///
  /// The keyframes are replaced, never changed in place, so a new list is a
  /// change and the same list is none.
  bool get _geometryChanged =>
      _framedLayerOffset != widget.layer.offset ||
      _framedLayerScale != widget.layer.scale ||
      _framedLayerRotation != widget.layer.rotation ||
      _framedLayerMirrored != _isMirrored(widget.layer) ||
      !identical(_framedKeyframes, widget.layer.keyframes) ||
      _framedLayerCenter != widget.layerCenter ||
      _framedCanvasSize != widget.canvasSize;

  @override
  void initState() {
    super.initState();
    _frame = _frameFor(widget.playTimeNotifier.value);
    widget.playTimeNotifier.addListener(_onTimeChanged);
  }

  @override
  void didUpdateWidget(covariant LayerTimelineVisibility oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playTimeNotifier != widget.playTimeNotifier) {
      oldWidget.playTimeNotifier.removeListener(_onTimeChanged);
      widget.playTimeNotifier.addListener(_onTimeChanged);
    }
    final changed =
        oldWidget.layer.startTime != widget.layer.startTime ||
        oldWidget.layer.endTime != widget.layer.endTime ||
        oldWidget.layer.enterDuration != widget.layer.enterDuration ||
        oldWidget.layer.exitDuration != widget.layer.exitDuration ||
        oldWidget.layer.enterCurve != widget.layer.enterCurve ||
        oldWidget.layer.exitCurve != widget.layer.exitCurve ||
        !listEquals(oldWidget.layer.animations, widget.layer.animations) ||
        !listEquals(oldWidget.layer.keyframes, widget.layer.keyframes) ||
        _geometryChanged;
    if (changed) {
      _frame = _frameFor(widget.playTimeNotifier.value);
    }
  }

  @override
  void dispose() {
    widget.playTimeNotifier.removeListener(_onTimeChanged);
    super.dispose();
  }

  void _onTimeChanged() {
    final next = _frameFor(widget.playTimeNotifier.value);
    if (next != _frame) {
      setState(() => _frame = next);
    }
  }

  /// Whether [layer] is flipped on one axis only. It is mirrored after its own
  /// rotation, which turns it the other way on screen, so a keyframed turn
  /// has to turn the other way as well.
  static bool _isMirrored(Layer layer) => layer.flipX != layer.flipY;

  /// Computes the frame for [currentTime] and records the geometry it used.
  _TimelineFrame _frameFor(Duration currentTime) {
    _framedLayerOffset = widget.layer.offset;
    _framedLayerScale = widget.layer.scale;
    _framedLayerRotation = widget.layer.rotation;
    _framedLayerMirrored = _isMirrored(widget.layer);
    _framedKeyframes = widget.layer.keyframes;
    _framedLayerCenter = widget.layerCenter;
    _framedCanvasSize = widget.canvasSize;
    return _computeFrame(currentTime);
  }

  /// Computes a curved progress value (0.0 – 1.0) for the legacy fade path.
  double _computeLegacyProgress(Duration currentTime) {
    return computeTimelineProgress(
      currentTime: currentTime,
      startTime: widget.layer.startTime,
      endTime: widget.layer.endTime,
      enterDuration: widget.layer.enterDuration,
      exitDuration: widget.layer.exitDuration,
      defaultEnterCurve: widget.configs.enterCurve,
      defaultExitCurve: widget.configs.exitCurve,
      enterCurve: widget.layer.enterCurve,
      exitCurve: widget.layer.exitCurve,
    );
  }

  /// Computes the visual transform for [currentTime].
  ///
  /// Mirrors the native renderer in `pro_video_editor` so the preview matches
  /// the exported result: the keyframed placement comes first, then each
  /// animation's progress is evaluated for its enter and/or exit phase, the
  /// most-visible (minimum) progress wins for an `animateInOut` animation, and
  /// the effects are composed on the placement (opacity multiplies, slide
  /// offsets accumulate, scale multiplies, wiggle angles and bounce lifts add
  /// up).
  _TimelineFrame _computeFrame(Duration currentTime) {
    final layer = widget.layer;
    final start = layer.startTime;
    final end = layer.endTime;

    final outside =
        (start != null && currentTime < start) ||
        (end != null && currentTime > end);
    if (outside) {
      return const _TimelineFrame.hidden();
    }

    // The keyframed placement, as the difference to the placement the child
    // is laid out with.
    final placement = layer.keyframePlacementAt(currentTime);
    final keyframeOffset = placement == null
        ? Offset.zero
        : placement.offset - layer.offset;
    final keyframeScale = placement == null || layer.scale == 0
        ? 1.0
        : placement.scale / layer.scale;
    final keyframeRotation = placement == null
        ? 0.0
        : (placement.rotation - layer.rotation) * (_isMirrored(layer) ? -1 : 1);
    final keyframeOpacity = placement?.opacity ?? 1.0;

    // The layer's own animations count over its time range, the keyframe
    // effects over the stretch between their two keyframes.
    final animations = <(LayerAnimation, Duration?, Duration?)>[
      for (final anim in layer.animations) (anim, start, end),
      for (final effect in layer.keyframeEffects)
        if (effect.playsAt(currentTime))
          (effect.animation, effect.start, effect.end),
    ];

    if (animations.isEmpty) {
      return _TimelineFrame(
        opacity: keyframeOpacity,
        slideAbsolute: keyframeOffset,
        scale: math.max(0.0, keyframeScale),
        rotation: keyframeRotation,
        legacyProgress: _computeLegacyProgress(currentTime),
      );
    }

    double opacity = keyframeOpacity;
    double scale = keyframeScale;
    double rotation = keyframeRotation;
    double lift = 0;
    Offset slideAbsolute = keyframeOffset;
    Offset slideFractional = Offset.zero;

    for (final (anim, from, until) in animations) {
      final progress = layerAnimationProgress(
        anim,
        currentTime,
        start: from,
        end: until,
      );
      if (progress == null) continue;
      final p = progress.value;

      switch (anim.type) {
        case LayerAnimationType.fade:
          opacity *= p;
        case LayerAnimationType.slide:
          final invP = 1.0 - p;
          final from = anim.slideFrom;
          if (from != null) {
            // A start point of the caller's own wins over the edge the
            // direction would otherwise pick. Both the point and the layer's
            // keyframed place are measured like [Layer.offset], so their
            // difference is the distance travelled — the layer's own size
            // cancels out and no fractional part is needed.
            slideAbsolute += (from - layer.offset - keyframeOffset) * invP;
            break;
          }
          final direction = anim.slideDirection;
          if (direction == null) break;
          final center = widget.layerCenter + keyframeOffset;
          final canvas = widget.canvasSize;
          // Edge-aware displacement D = invP × (absolute + fractional), where
          // the absolute part is canvas pixels and the fractional part is ±0.5
          // of the layer's displayed size: its laid-out size, grown or shrunk
          // by the keyframes. Together they move the layer's nearest edge
          // exactly onto the canvas border. This must mirror the native
          // renderer in `pro_video_editor` (ApplyAnimation.kt/.swift).
          final half = 0.5 * invP * keyframeScale;
          switch (direction) {
            case SlideDirection.left:
              slideAbsolute = slideAbsolute.translate(-center.dx * invP, 0);
              slideFractional = slideFractional.translate(-half, 0);
            case SlideDirection.right:
              slideAbsolute = slideAbsolute.translate(
                (canvas.width - center.dx) * invP,
                0,
              );
              slideFractional = slideFractional.translate(half, 0);
            case SlideDirection.top:
              slideAbsolute = slideAbsolute.translate(0, -center.dy * invP);
              slideFractional = slideFractional.translate(0, -half);
            case SlideDirection.bottom:
              slideAbsolute = slideAbsolute.translate(
                0,
                (canvas.height - center.dy) * invP,
              );
              slideFractional = slideFractional.translate(0, half);
          }
        case LayerAnimationType.scale:
          final from = anim.scaleFrom ?? 0.0;
          scale *= from + (1.0 - from) * p;
        case LayerAnimationType.wiggle:
          rotation +=
              progress.swing *
              (1.0 - p) *
              (anim.wiggleAngle ?? LayerAnimation.defaultWiggleAngle);
        case LayerAnimationType.bounce:
          // The hop grows and shrinks with the layer's keyframed size.
          lift +=
              (1.0 - p) *
              (anim.bounceHeight ?? LayerAnimation.defaultBounceHeight) *
              keyframeScale;
        case LayerAnimationType.typewriter:
        case LayerAnimationType.wordByWord:
          // The text layer reveals its own text (LayerWidgetTextItem).
          break;
      }
    }

    return _TimelineFrame(
      opacity: opacity.clamp(0.0, 1.0),
      slideAbsolute: slideAbsolute,
      slideFractional: slideFractional,
      scale: math.max(0.0, scale),
      rotation: rotation,
      lift: lift,
      // Keyframe effects alone leave the legacy fade of a layer without
      // animations in place.
      legacyProgress: layer.animations.isEmpty
          ? _computeLegacyProgress(currentTime)
          : 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    final frame = _frame;

    if (frame.hidden || frame.opacity <= 0 || frame.legacyProgress <= 0) {
      return IgnorePointer(child: InvisibleButPainted(child: child));
    }

    Widget result = child;
    if (widget.layer.animations.isEmpty) {
      final builder =
          widget.layer.transitionBuilder ?? widget.configs.transitionBuilder;
      result = builder(
        child,
        AlwaysStoppedAnimation<double>(frame.legacyProgress),
      );
    }
    // The keyframes and the wiggle turn the layer before anything else moves
    // it, around the same visual center the scale below is anchored on (see
    // there). Turning and scaling around one point commute, so the order
    // between the two does not matter; the native renderer turns first as
    // well.
    if (frame.rotation != 0.0) {
      final fo = widget.layerFractionalOffset;
      result = Transform.rotate(
        angle: frame.rotation,
        alignment: Alignment(2 * fo.dx, 2 * fo.dy),
        child: result,
      );
    }
    if (frame.scale != 1.0) {
      // Anchor scaling on the layer's visual center rather than the layout
      // box center. The child paints its content shifted by
      // [layerFractionalOffset], so a fraction of (0.5 + fo) maps to
      // Alignment(2 * fo). Without this the scale would drag the layer toward
      // the box center as it shrinks.
      final fo = widget.layerFractionalOffset;
      result = Transform.scale(
        scale: frame.scale,
        alignment: Alignment(2 * fo.dx, 2 * fo.dy),
        child: result,
      );
    }
    // The fractional part is applied outside the scale, so it translates by a
    // fraction of the layer's base (unscaled) size. This mirrors the native
    // renderer, which derives the slide from the unscaled layer half-size
    // (`halfNormW`/`halfNormH` in ApplyAnimation) and applies scale
    // independently. The absolute part is a plain pixel translation on top.
    if (frame.slideFractional != Offset.zero) {
      result = FractionalTranslation(
        translation: frame.slideFractional,
        child: result,
      );
    }
    if (frame.lift != 0.0) {
      result = _Lift(
        lift: frame.lift,
        layerRotation: widget.layer.rotation,
        child: result,
      );
    }
    if (frame.slideAbsolute != Offset.zero) {
      result = Transform.translate(offset: frame.slideAbsolute, child: result);
    }
    if (frame.opacity < 1.0) {
      result = Opacity(opacity: frame.opacity, child: result);
    }
    return result;
  }
}

/// The composed visual state of a layer at a single point in video time.
class _TimelineFrame {
  const _TimelineFrame({
    required this.opacity,
    required this.slideAbsolute,
    this.slideFractional = Offset.zero,
    required this.scale,
    this.rotation = 0,
    this.lift = 0,
    this.legacyProgress = 1,
  }) : hidden = false;

  const _TimelineFrame.hidden()
    : hidden = true,
      opacity = 0,
      slideAbsolute = Offset.zero,
      slideFractional = Offset.zero,
      scale = 1,
      rotation = 0,
      lift = 0,
      legacyProgress = 0;

  /// Whether the layer is outside its visible time range and should be hidden.
  final bool hidden;

  /// The composed opacity.
  final double opacity;

  /// The absolute (canvas-pixel) component of the composed slide offset
  /// (phase-aware path). Applied via [Transform.translate].
  final Offset slideAbsolute;

  /// The fractional component of the composed slide offset, expressed as a
  /// fraction of the layer's displayed (scaled) size (phase-aware path).
  /// Applied via [FractionalTranslation]. Together with [slideAbsolute] this
  /// pushes the layer's nearest edge exactly onto the canvas border.
  final Offset slideFractional;

  /// The composed scale factor: the keyframed scale relative to the laid-out
  /// one, times any scale animation.
  final double scale;

  /// The keyframed turn relative to the laid-out one plus the wiggle tilt,
  /// clockwise on screen, in radians.
  final double rotation;

  /// How far a bounce lifts the layer, as a multiple of its height
  /// (phase-aware path). See [_Lift].
  final double lift;

  /// The curved progress (0–1) the legacy fade path, which only a layer
  /// without animations takes, hands to the transition builder. The rest of
  /// the frame then only carries the keyframed placement.
  final double legacyProgress;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _TimelineFrame &&
        other.hidden == hidden &&
        other.opacity == opacity &&
        other.slideAbsolute == slideAbsolute &&
        other.slideFractional == slideFractional &&
        other.scale == scale &&
        other.rotation == rotation &&
        other.lift == lift &&
        other.legacyProgress == legacyProgress;
  }

  @override
  int get hashCode => Object.hash(
    hidden,
    opacity,
    slideAbsolute,
    slideFractional,
    scale,
    rotation,
    lift,
    legacyProgress,
  );
}

/// Moves its child up by [lift] times the height of the box around the layer
/// when it is turned by [layerRotation].
///
/// The child is laid out unrotated — the layer's rotation is a paint-time
/// transform inside it — while the video export captures the rotated layer
/// into an image as tall as the box around it. Measuring the lift on that box
/// keeps a bounce on a rotated layer as high as the exported one. Like
/// [FractionalTranslation], it moves hit tests along with the paint.
class _Lift extends SingleChildRenderObjectWidget {
  const _Lift({
    required this.lift,
    required this.layerRotation,
    required super.child,
  });

  final double lift;
  final double layerRotation;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderLift(lift, layerRotation);

  @override
  void updateRenderObject(BuildContext context, _RenderLift renderObject) {
    renderObject
      ..lift = lift
      ..layerRotation = layerRotation;
  }
}

class _RenderLift extends RenderProxyBox {
  _RenderLift(this._lift, this._layerRotation);

  double _lift;
  set lift(double value) {
    if (value == _lift) return;
    _lift = value;
    markNeedsPaint();
  }

  double _layerRotation;
  set layerRotation(double value) {
    if (value == _layerRotation) return;
    _layerRotation = value;
    markNeedsPaint();
  }

  Offset get _offset {
    final height =
        size.width * math.sin(_layerRotation).abs() +
        size.height * math.cos(_layerRotation).abs();
    return Offset(0, -_lift * height);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    return result.addWithPaintOffset(
      offset: _offset,
      position: position,
      hitTest: (result, transformed) =>
          super.hitTest(result, position: transformed),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset + _offset);
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final offset = _offset;
    transform.translateByDouble(offset.dx, offset.dy, 0, 1);
  }
}
