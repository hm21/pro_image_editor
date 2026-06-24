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
/// express. When [Layer.animations] is empty, the legacy fade convenience
/// driven by [Layer.enterDuration] / [Layer.exitDuration] and the
/// [LayerTimelineConfigs.transitionBuilder] is used instead.
class LayerTimelineVisibility extends StatefulWidget {
  /// Creates a [LayerTimelineVisibility].
  const LayerTimelineVisibility({
    super.key,
    required this.layer,
    required this.playTimeNotifier,
    required this.configs,
    required this.child,
  });

  /// The layer whose time range is evaluated.
  final Layer layer;

  /// Notifier that provides the current video playback position.
  final ValueNotifier<Duration> playTimeNotifier;

  /// Animation configuration for the enter/exit transition.
  final LayerTimelineConfigs configs;

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
    Offset slide = Offset.zero;

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
          switch (direction) {
            case SlideDirection.left:
              slide = slide.translate(-invP, 0);
            case SlideDirection.right:
              slide = slide.translate(invP, 0);
            case SlideDirection.top:
              slide = slide.translate(0, -invP);
            case SlideDirection.bottom:
              slide = slide.translate(0, invP);
          }
        case LayerAnimationType.scale:
          final from = anim.scaleFrom ?? 0.0;
          scale *= from + (1.0 - from) * progress;
      }
    }

    return _TimelineFrame(
      opacity: opacity.clamp(0.0, 1.0),
      slide: slide,
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
      result = Transform.scale(scale: frame.scale, child: result);
    }
    if (frame.slide != Offset.zero) {
      result = FractionalTranslation(translation: frame.slide, child: result);
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
    required this.slide,
    required this.scale,
  }) : hidden = false,
       legacyProgress = 1;

  const _TimelineFrame.hidden()
    : hidden = true,
      opacity = 0,
      slide = Offset.zero,
      scale = 1,
      legacyProgress = 0;

  const _TimelineFrame.legacy(this.legacyProgress)
    : hidden = false,
      opacity = 1,
      slide = Offset.zero,
      scale = 1;

  /// Whether the layer is outside its visible time range and should be hidden.
  final bool hidden;

  /// The composed opacity (phase-aware path).
  final double opacity;

  /// The composed slide offset as a fraction of the layer's own size
  /// (phase-aware path).
  final Offset slide;

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
        other.slide == slide &&
        other.scale == scale &&
        other.legacyProgress == legacyProgress;
  }

  @override
  int get hashCode =>
      Object.hash(hidden, opacity, slide, scale, legacyProgress);
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
