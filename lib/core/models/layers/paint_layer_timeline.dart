import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'layer.dart';

/// One stretch of a [PaintLayer]'s time range over which it shows its
/// drawing equally far drawn.
@immutable
class PaintLayerTimelineSpan {
  /// Creates a span showing the drawing [drawnFraction] of the way drawn from
  /// [startTime] until [endTime].
  const PaintLayerTimelineSpan({
    required this.startTime,
    required this.endTime,
    required this.drawnFraction,
  });

  /// Where the span starts, or `null` when it starts with the video.
  final Duration? startTime;

  /// Where the span ends, or `null` when it lasts until the video ends.
  final Duration? endTime;

  /// How much of the drawing shows throughout the span, see
  /// [PaintLayer.drawnFractionAt], or `null` when all of it does.
  final double? drawnFraction;
}

/// The stretches of [layer]'s time range over which its drawing is drawn
/// equally far, in order and without gaps, merged where neighbours show the
/// same.
///
/// A [LayerAnimationType.drawOn] draws continuously, so it is cut at the
/// frames of a video at [frameRate]: at `n * 1000000 ~/ frameRate`
/// microseconds, the time a renderer that rounds down to the microsecond
/// draws frame `n` at. Each span shows the drawing as it is at its start, so
/// every frame shows exactly what the editor previews at that time. The edges
/// of the windows the animations play in are cuts as well.
///
/// A [AnimationPhase.loop] on a layer without an end never ends, so it is
/// left out and the drawing shows whole while it would loop; on a layer with
/// an end it is cut over the whole range.
///
/// The `ExportedLayer.frames` of a captured paint layer follow these spans,
/// and the capture records an image for each fraction they need.
List<PaintLayerTimelineSpan> paintLayerTimeline(
  PaintLayer layer, {
  required int frameRate,
}) {
  assert(frameRate > 0, 'frameRate must be greater than 0');
  final start = layer.startTime;
  final end = layer.endTime;
  // A layer without a start begins with the video, at zero.
  final origin = start ?? Duration.zero;

  bool isEndlessLoop(LayerAnimation animation) =>
      end == null &&
      animation.isDrawOn &&
      animation.phase == AnimationPhase.loop;
  final drawing = !layer.animations.any(isEndlessLoop)
      ? layer
      : layer.copyWith(
          animations: [
            for (final animation in layer.animations)
              if (!isEndlessLoop(animation)) animation,
          ],
        );

  final cuts = _drawOnCuts(
    drawing,
    frameRate: frameRate,
  ).where((cut) => cut > origin && (end == null || cut < end)).toList()..sort();

  final bounds = <Duration?>[start, ...cuts, end];
  final spans = <PaintLayerTimelineSpan>[];
  for (var i = 0; i < bounds.length - 1; i++) {
    final from = bounds[i];
    final to = bounds[i + 1];
    final drawn = drawing.drawnFractionAt(from ?? origin);
    if (spans.isNotEmpty && spans.last.drawnFraction == drawn) {
      spans.last = PaintLayerTimelineSpan(
        startTime: spans.last.startTime,
        endTime: to,
        drawnFraction: drawn,
      );
    } else {
      spans.add(
        PaintLayerTimelineSpan(
          startTime: from,
          endTime: to,
          drawnFraction: drawn,
        ),
      );
    }
  }
  return spans;
}

/// The edges of every window in which one of [layer]'s draw-on animations
/// plays, and the frames at [frameRate] within them.
Set<Duration> _drawOnCuts(PaintLayer layer, {required int frameRate}) {
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
    if (!animation.isDrawOn || animation.duration <= Duration.zero) continue;
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

  int frameTime(int frame) =>
      frame * Duration.microsecondsPerSecond ~/ frameRate;

  final cuts = <Duration>{};
  for (final (from, to) in windows) {
    cuts
      ..add(Duration(microseconds: from))
      ..add(Duration(microseconds: to));
    var frame = from * frameRate ~/ Duration.microsecondsPerSecond;
    while (frameTime(frame) <= from) {
      frame++;
    }
    for (var time = frameTime(frame); time < to; time = frameTime(++frame)) {
      cuts.add(Duration(microseconds: time));
    }
  }
  return cuts;
}
