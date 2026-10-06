import 'package:flutter/foundation.dart';

import 'exported_layer.dart';
import 'layer.dart';

/// One stretch of a [TextLayer]'s time range over which it shows the same
/// [state].
@immutable
class TextLayerTimelineSpan {
  /// Creates a span showing [state] from [startTime] until [endTime].
  const TextLayerTimelineSpan({
    required this.startTime,
    required this.endTime,
    required this.state,
  });

  /// Where the span starts, or `null` when it starts with the video.
  final Duration? startTime;

  /// Where the span ends, or `null` when it lasts until the video ends.
  final Duration? endTime;

  /// What the layer shows throughout the span.
  final ExportedTextState state;
}

/// How often a text reveal is sampled to find the moments it takes a step.
const Duration textRevealSampling = Duration(milliseconds: 1);

/// The stretches of [layer]'s time range over which it shows the same thing,
/// in order and without gaps, merged where neighbours show the same.
///
/// [highlights] cuts at the edges of [TextLayer.highlights] and fills in
/// [ExportedTextState.highlightIndex]; [reveals] cuts where a
/// [LayerAnimationType.typewriter] or [LayerAnimationType.wordByWord]
/// animation takes a step and fills in [ExportedTextState.revealedLength].
///
/// A reveal's steps follow its easing curve, which an elastic or bounce
/// curve can make go back and forth, so they are found by sampling the
/// reveal every [textRevealSampling] rather than by solving for them. A
/// [AnimationPhase.loop] reveal is only sampled when the layer has an end.
///
/// The `ExportedLayer.frames` of a captured text layer follow these spans,
/// and the capture records an image for each state they need.
List<TextLayerTimelineSpan> textLayerTimeline(
  TextLayer layer, {
  required bool highlights,
  required bool reveals,
}) {
  final start = layer.startTime;
  final end = layer.endTime;
  // A layer without a start begins with the video, at zero.
  final origin = start ?? Duration.zero;

  final cuts = <Duration>{
    if (highlights)
      for (final highlight in layer.highlights)
        if (highlight.isValid) ...[
          origin + highlight.startTime,
          origin + highlight.endTime,
        ],
    if (reveals) ..._revealCuts(layer),
  }.where((cut) => cut > origin && (end == null || cut < end)).toList()..sort();

  ExportedTextState stateAt(Duration time) => ExportedTextState(
    revealedLength: reveals ? layer.revealedLengthAt(time) : null,
    highlightIndex: highlights ? layer.highlightIndexAt(time) : null,
  );

  final bounds = <Duration?>[start, ...cuts, end];
  final spans = <TextLayerTimelineSpan>[];
  for (var i = 0; i < bounds.length - 1; i++) {
    final from = bounds[i];
    final to = bounds[i + 1];
    final state = stateAt(from ?? origin);
    if (spans.isNotEmpty && spans.last.state == state) {
      spans.last = TextLayerTimelineSpan(
        startTime: spans.last.startTime,
        endTime: to,
        state: state,
      );
    } else {
      spans.add(
        TextLayerTimelineSpan(startTime: from, endTime: to, state: state),
      );
    }
  }
  return spans;
}

/// The moments [layer]'s revealed text changes, found by sampling every
/// window in which one of its reveals plays.
Set<Duration> _revealCuts(TextLayer layer) {
  final start = layer.startTime ?? Duration.zero;
  final end = layer.endTime;

  final windows = <(Duration, Duration)>[];
  for (final animation in layer.animations) {
    if (!animation.isTextReveal || animation.duration <= Duration.zero) {
      continue;
    }
    final duration = animation.duration;
    switch (animation.phase) {
      case AnimationPhase.animateIn:
        windows.add((start, start + duration));
      case AnimationPhase.animateOut:
        if (end != null) windows.add((end - duration, end));
      case AnimationPhase.animateInOut:
        windows.add((start, start + duration));
        if (end != null) windows.add((end - duration, end));
      case AnimationPhase.loop:
        if (end != null) windows.add((start, end));
    }
  }
  if (windows.isEmpty) return const {};

  final step = textRevealSampling.inMicroseconds;
  final samples = <int>{
    for (final (from, to) in windows) ...[
      for (var us = from.inMicroseconds; us < to.inMicroseconds; us += step) us,
      to.inMicroseconds,
    ],
  }.toList()..sort();

  final cuts = <Duration>{};
  int? previous;
  var first = true;
  for (final us in samples) {
    final time = Duration(microseconds: us);
    final revealed = layer.revealedLengthAt(time);
    if (first || revealed != previous) cuts.add(time);
    previous = revealed;
    first = false;
  }
  return cuts;
}
