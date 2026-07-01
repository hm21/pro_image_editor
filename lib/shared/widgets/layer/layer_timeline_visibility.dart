import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/rendering.dart' show RenderProxyBox;
import 'package:flutter/widgets.dart';

import '/core/models/editor_configs/video/layer_timeline_configs.dart';
import '/core/models/layers/layer.dart';
import '/shared/utils/parser/animation_curve_parser.dart';
import '/shared/utils/timeline_progress.dart';

/// Controls layer visibility based on [Layer.startTime] / [Layer.endTime]
/// relative to the current video time.
///
/// The animation progress is derived directly from the video position so that
/// seeking immediately reflects the correct transition state (e.g. seeking to
/// the middle of a 5 s fade-in shows the layer at 50 %).
///
/// When [Layer.animations] is not empty, the transition is phase-aware: each
/// animation drives a fade, slide, or scale during the layer's enter window
/// (`[startTime, startTime + duration]`) and/or exit window
/// (`[endTime - duration, endTime]`). Multiple animations are composed, so the
/// enter and leave phases can use distinct animation types — something the
/// single `(child, animation)` [LayerTimelineConfigs.transitionBuilder] cannot
/// express. The slide effect is edge-aware: using [canvasSize] and
/// [layerCenter] it pushes the layer just past the nearest canvas edge (rather
/// than by its own size), so even an off-center layer leaves the visible area
/// completely. The scale effect is anchored on the layer's visual center (via
/// [layerFractionalOffset]) so that a combined slide + scale enters straight
/// instead of drifting diagonally. When [Layer.animations] is empty, the
/// legacy fade convenience
/// driven by [Layer.enterDuration] / [Layer.exitDuration] and the
/// [LayerTimelineConfigs.transitionBuilder] is used instead.
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

  @override
  void initState() {
    super.initState();
    _frame = _computeFrame(widget.playTimeNotifier.value);
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
        !listEquals(oldWidget.layer.animations, widget.layer.animations);
    if (changed) {
      _frame = _computeFrame(widget.playTimeNotifier.value);
    }
  }

  @override
  void dispose() {
    widget.playTimeNotifier.removeListener(_onTimeChanged);
    super.dispose();
  }

  void _onTimeChanged() {
    final next = _computeFrame(widget.playTimeNotifier.value);
    if (next != _frame) {
      setState(() => _frame = next);
    }
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
  /// the exported result: each animation's progress is evaluated for its
  /// enter and/or exit phase, the most-visible (minimum) progress wins for an
  /// `animateInOut` animation, and the effects are composed (opacity
  /// multiplies, slide offsets accumulate, scale multiplies).
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

    if (layer.animations.isEmpty) {
      return _TimelineFrame.legacy(_computeLegacyProgress(currentTime));
    }

    final effectiveStart = start ?? Duration.zero;
    double opacity = 1;
    double scale = 1;
    Offset slideAbsolute = Offset.zero;
    Offset slideFractional = Offset.zero;

    for (final anim in layer.animations) {
      final durationUs = anim.duration.inMicroseconds;
      if (durationUs <= 0) continue;
      final curve = curveFromAnimationCurve(anim.curve);

      double? inProgress;
      double? outProgress;

      if (anim.phase == AnimationPhase.animateIn ||
          anim.phase == AnimationPhase.animateInOut) {
        final elapsed = (currentTime - effectiveStart).inMicroseconds;
        if (elapsed < durationUs) {
          inProgress = curve.transform((elapsed / durationUs).clamp(0.0, 1.0));
        }
      }

      if ((anim.phase == AnimationPhase.animateOut ||
              anim.phase == AnimationPhase.animateInOut) &&
          end != null) {
        final remaining = (end - currentTime).inMicroseconds;
        if (remaining < durationUs) {
          outProgress = curve.transform(
            (remaining / durationUs).clamp(0.0, 1.0),
          );
        }
      }

      final double? progress;
      if (inProgress != null && outProgress != null) {
        progress = math.min(inProgress, outProgress);
      } else {
        progress = inProgress ?? outProgress;
      }
      if (progress == null) continue;

      switch (anim.type) {
        case LayerAnimationType.fade:
          opacity *= progress;
        case LayerAnimationType.slide:
          final direction = anim.slideDirection;
          if (direction == null) break;
          final invP = 1.0 - progress;
          final center = widget.layerCenter;
          final canvas = widget.canvasSize;
          // Edge-aware displacement D = invP × (absolute + fractional), where
          // the absolute part is canvas pixels and the fractional part is ±0.5
          // of the layer's displayed size. Together they move the layer's
          // nearest edge exactly onto the canvas border. This must mirror the
          // native renderer in `pro_video_editor` (ApplyAnimation.kt/.swift).
          switch (direction) {
            case SlideDirection.left:
              slideAbsolute = slideAbsolute.translate(-center.dx * invP, 0);
              slideFractional = slideFractional.translate(-0.5 * invP, 0);
            case SlideDirection.right:
              slideAbsolute = slideAbsolute.translate(
                (canvas.width - center.dx) * invP,
                0,
              );
              slideFractional = slideFractional.translate(0.5 * invP, 0);
            case SlideDirection.top:
              slideAbsolute = slideAbsolute.translate(0, -center.dy * invP);
              slideFractional = slideFractional.translate(0, -0.5 * invP);
            case SlideDirection.bottom:
              slideAbsolute = slideAbsolute.translate(
                0,
                (canvas.height - center.dy) * invP,
              );
              slideFractional = slideFractional.translate(0, 0.5 * invP);
          }
        case LayerAnimationType.scale:
          final from = anim.scaleFrom ?? 0.0;
          scale *= from + (1.0 - from) * progress;
      }
    }

    return _TimelineFrame(
      opacity: opacity.clamp(0.0, 1.0),
      slideAbsolute: slideAbsolute,
      slideFractional: slideFractional,
      scale: math.max(0.0, scale),
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    final frame = _frame;

    if (frame.hidden) {
      return IgnorePointer(child: _InvisibleButPainted(child: child));
    }

    if (widget.layer.animations.isEmpty) {
      final progress = frame.legacyProgress;
      if (progress <= 0) {
        return IgnorePointer(child: _InvisibleButPainted(child: child));
      }
      final builder =
          widget.layer.transitionBuilder ?? widget.configs.transitionBuilder;
      return builder(child, AlwaysStoppedAnimation<double>(progress));
    }

    if (frame.opacity <= 0) {
      return IgnorePointer(child: _InvisibleButPainted(child: child));
    }

    Widget result = child;
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
    required this.slideFractional,
    required this.scale,
  }) : hidden = false,
       legacyProgress = 1;

  const _TimelineFrame.hidden()
    : hidden = true,
      opacity = 0,
      slideAbsolute = Offset.zero,
      slideFractional = Offset.zero,
      scale = 1,
      legacyProgress = 0;

  const _TimelineFrame.legacy(this.legacyProgress)
    : hidden = false,
      opacity = 1,
      slideAbsolute = Offset.zero,
      slideFractional = Offset.zero,
      scale = 1;

  /// Whether the layer is outside its visible time range and should be hidden.
  final bool hidden;

  /// The composed opacity (phase-aware path).
  final double opacity;

  /// The absolute (canvas-pixel) component of the composed slide offset
  /// (phase-aware path). Applied via [Transform.translate].
  final Offset slideAbsolute;

  /// The fractional component of the composed slide offset, expressed as a
  /// fraction of the layer's displayed (scaled) size (phase-aware path).
  /// Applied via [FractionalTranslation]. Together with [slideAbsolute] this
  /// pushes the layer's nearest edge exactly onto the canvas border.
  final Offset slideFractional;

  /// The composed scale factor (phase-aware path).
  final double scale;

  /// The curved progress (0–1) used by the legacy fade path.
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
        other.legacyProgress == legacyProgress;
  }

  @override
  int get hashCode => Object.hash(
    hidden,
    opacity,
    slideAbsolute,
    slideFractional,
    scale,
    legacyProgress,
  );
}

/// Renders its child into the render tree (so [RepaintBoundary.toImage] works)
/// but displays nothing on screen.
///
/// Unlike [Opacity] with alpha 0, which skips painting entirely, this widget
/// uses [PaintingContext.pushOpacity] directly which always paints the child
/// into an [OpacityLayer].
class _InvisibleButPainted extends SingleChildRenderObjectWidget {
  const _InvisibleButPainted({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderInvisibleButPainted();
}

class _RenderInvisibleButPainted extends RenderProxyBox {
  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    context.pushOpacity(offset, 0, super.paint);
  }
}
