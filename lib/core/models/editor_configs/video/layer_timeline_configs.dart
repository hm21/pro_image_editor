import 'package:flutter/widgets.dart';

import '/core/models/layers/layer_animation.dart';

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
    this.enableScaleSnapshot = true,
  });

  /// The curve applied to the fade-in animation.
  final Curve enterCurve;

  /// The curve applied to the fade-out animation.
  final Curve exitCurve;

  /// A builder that wraps the layer widget with an animated transition.
  ///
  /// Defaults to a simple [FadeTransition].
  final LayerTimelineTransitionBuilder transitionBuilder;

  /// Whether a layer is frozen into a single raster while a
  /// [LayerAnimationType.scale] transition is running.
  ///
  /// A changing scale invalidates the cached raster of its layer on every
  /// frame, so an expensive layer - a freestyle drawing holding thousands of
  /// points - is rasterized anew 60 times a second. Painting a snapshot
  /// instead keeps that off the raster thread. Measured with 20 full-canvas
  /// freestyle layers on macOS, the raster time of a scale transition drops
  /// from 21.4ms to about 1ms per frame; fade and slide reuse the cached
  /// raster anyway and are left untouched.
  ///
  /// The snapshot is taken at the device pixel ratio and only while the layer
  /// is scaled *down*, so it always holds at least as many pixels as reach the
  /// screen, and it is dropped again the moment the transition ends. Turn this
  /// off if you capture frames at a much higher pixel ratio while a scale
  /// transition is mid-flight and need them pixel-exact.
  final bool enableScaleSnapshot;

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
    bool? enableScaleSnapshot,
  }) {
    return LayerTimelineConfigs(
      enterCurve: enterCurve ?? this.enterCurve,
      exitCurve: exitCurve ?? this.exitCurve,
      transitionBuilder: transitionBuilder ?? this.transitionBuilder,
      enableScaleSnapshot: enableScaleSnapshot ?? this.enableScaleSnapshot,
    );
  }
}
