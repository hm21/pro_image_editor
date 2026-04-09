import 'package:flutter/widgets.dart';

/// Signature for a builder that wraps a layer widget with an animated
/// transition driven by [animation].
///
/// The [child] is the layer widget, and [animation] progresses from 0 → 1
/// when the layer enters and 1 → 0 when it exits.
typedef LayerTimelineTransitionBuilder =
    Widget Function(Widget child, Animation<double> animation);

/// Configuration for how layers with [Layer.startTime] / [Layer.endTime]
/// are shown and hidden on the video timeline.
///
/// The per-layer [Layer.enterDuration] and [Layer.exitDuration] represent
/// durations in **video time**, not real time. For example, if
/// `enterDuration` is 2 s and the layer starts at 3 s, the transition runs
/// from 3 s → 5 s of video playback. Seeking to 4 s will show the animation
/// at 50 %.
///
/// Only evaluated when the video editor is active. In image-editor mode this
/// config is entirely ignored to avoid any performance overhead.
class LayerTimelineConfigs {
  /// Creates a [LayerTimelineConfigs] instance.
  const LayerTimelineConfigs({
    this.enterCurve = Curves.easeIn,
    this.exitCurve = Curves.easeOut,
    this.transitionBuilder = defaultFadeTransition,
  });

  /// The curve applied to the fade-in animation.
  final Curve enterCurve;

  /// The curve applied to the fade-out animation.
  final Curve exitCurve;

  /// A builder that wraps the layer widget with an animated transition.
  ///
  /// Defaults to a simple [FadeTransition].
  final LayerTimelineTransitionBuilder transitionBuilder;

  /// The default transition – a simple fade.
  static Widget defaultFadeTransition(
    Widget child,
    Animation<double> animation,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }

  /// Creates a copy with the given values overridden.
  LayerTimelineConfigs copyWith({
    Curve? enterCurve,
    Curve? exitCurve,
    LayerTimelineTransitionBuilder? transitionBuilder,
  }) {
    return LayerTimelineConfigs(
      enterCurve: enterCurve ?? this.enterCurve,
      exitCurve: exitCurve ?? this.exitCurve,
      transitionBuilder: transitionBuilder ?? this.transitionBuilder,
    );
  }
}
