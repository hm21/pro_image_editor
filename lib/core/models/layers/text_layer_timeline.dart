import 'dart:math' as math;

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
/// [AnimationPhase.loop] reveal on a layer without an end never ends, so it
/// is left out and the text shows whole while it would loop.
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

  bool isEndlessLoop(LayerAnimation animation) =>
      end == null &&
      animation.isTextReveal &&
      animation.phase == AnimationPhase.loop;
  final revealing = !reveals || !layer.animations.any(isEndlessLoop)
      ? layer
      : layer.copyWith(
          animations: [
            for (final animation in layer.animations)
              if (!isEndlessLoop(animation)) animation,
          ],
        );

  final cuts = <Duration>{
    if (highlights)
      for (final highlight in layer.highlights)
        if (highlight.isValid) ...[
          origin + highlight.startTime,
          origin + highlight.endTime,
        ],
    if (reveals) ..._revealCuts(revealing),
  }.where((cut) => cut > origin && (end == null || cut < end)).toList()..sort();

  ExportedTextState stateAt(Duration time) => ExportedTextState(
    revealedLength: reveals ? revealing.revealedLengthAt(time) : null,
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
///
/// It may also return moments the text does not change at, such as the start
/// of a window; [textLayerTimeline] merges the spans on either side of them.
Set<Duration> _revealCuts(TextLayer layer) {
  final start = (layer.startTime ?? Duration.zero).inMicroseconds;
  final end = layer.endTime?.inMicroseconds;

  // The windows in microseconds, cut to the layer's range.
  final windows = <(int, int)>[];
  void addWindow(int from, int to) {
    from = math.max(from, start);
    if (end != null) to = math.min(to, end);
    if (from < to) windows.add((from, to));
  }

  for (final animation in layer.animations) {
    if (!animation.isTextReveal || animation.duration <= Duration.zero) {
      continue;
    }
    final duration = animation.duration.inMicroseconds;
    final phase = animation.phase;
    if (phase == AnimationPhase.loop) {
      if (end != null) addWindow(start, end);
      continue;
    }
    if (phase != AnimationPhase.animateOut) {
      addWindow(start, start + duration);
    }
    if (phase != AnimationPhase.animateIn && end != null) {
      addWindow(end - duration, end);
    }
  }
  if (windows.isEmpty) return const {};

  // Overlapping windows are sampled once.
  windows.sort((a, b) => a.$1.compareTo(b.$1));
  final merged = <(int, int)>[windows.first];
  for (final (from, to) in windows.skip(1)) {
    final (lastFrom, lastTo) = merged.last;
    if (from <= lastTo) {
      merged.last = (lastFrom, math.max(lastTo, to));
    } else {
      merged.add((from, to));
    }
  }

  final step = textRevealSampling.inMicroseconds;
  final cuts = <Duration>{};
  for (final (from, to) in merged) {
    cuts.add(Duration(microseconds: from));
    var previous = layer.revealedLengthAt(Duration(microseconds: from));
    for (var us = from + step; ; us += step) {
      if (us > to) us = to;
      final time = Duration(microseconds: us);
      final revealed = layer.revealedLengthAt(time);
      if (revealed != previous) cuts.add(time);
      previous = revealed;
      if (us == to) break;
    }
  }
  return cuts;
}
