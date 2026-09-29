import 'package:flutter/foundation.dart';

import 'layer.dart';

/// A part of a [TextLayer]'s text that is highlighted while the video plays
/// through it, such as the word of a caption that is being spoken.
///
/// [start] and [end] are UTF-16 offsets into [TextLayer.text], like a
/// [TextRange]; [end] is exclusive.
///
/// [startTime] and [endTime] are measured from the layer's [Layer.startTime],
/// or from the start of the video when the layer has none, so a highlight
/// keeps its place in the text when the layer is moved along the timeline.
/// The highlight is active from [startTime] up to, but not including,
/// [endTime].
@immutable
class TextHighlight {
  /// Creates a highlight of the text between [start] and [end], active from
  /// [startTime] until [endTime].
  ///
  /// A highlight whose [endTime] is not after its [startTime] is never active;
  /// [isValid] reports it.
  const TextHighlight({
    required this.start,
    required this.end,
    required this.startTime,
    required this.endTime,
  }) : assert(start >= 0, 'start must not be negative'),
       assert(end > start, 'end must be after start');

  /// Creates a [TextHighlight] from a map produced by [toMap].
  ///
  /// Missing values fall back to zero, so a highlight from hand-edited data
  /// degrades to an empty one instead of throwing. [isValid] reports whether
  /// the result can ever show.
  factory TextHighlight.fromMap(Map<String, dynamic> map) {
    return TextHighlight._unchecked(
      start: (map['start'] as num?)?.toInt() ?? 0,
      end: (map['end'] as num?)?.toInt() ?? 0,
      startTime: Duration(
        milliseconds: (map['startTime'] as num?)?.toInt() ?? 0,
      ),
      endTime: Duration(milliseconds: (map['endTime'] as num?)?.toInt() ?? 0),
    );
  }

  const TextHighlight._unchecked({
    required this.start,
    required this.end,
    required this.startTime,
    required this.endTime,
  });

  /// The offset of the first highlighted UTF-16 code unit.
  final int start;

  /// The offset after the last highlighted UTF-16 code unit.
  final int end;

  /// When the highlight turns on, measured from the layer's start.
  final Duration startTime;

  /// When the highlight turns off again, measured from the layer's start.
  final Duration endTime;

  /// Whether this highlight covers some text and some time.
  bool get isValid => start >= 0 && end > start && endTime > startTime;

  /// Whether the highlight is on [elapsed] after the layer's start.
  bool isActiveAt(Duration elapsed) =>
      isValid && elapsed >= startTime && elapsed < endTime;

  /// Serializes this highlight to a map.
  ///
  /// Times are stored in milliseconds, like [Layer.startTime].
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'start': start,
      'end': end,
      'startTime': startTime.inMilliseconds,
      'endTime': endTime.inMilliseconds,
    };
  }

  /// Creates a copy of this highlight with the given fields replaced.
  TextHighlight copyWith({
    int? start,
    int? end,
    Duration? startTime,
    Duration? endTime,
  }) {
    return TextHighlight(
      start: start ?? this.start,
      end: end ?? this.end,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  @override
  String toString() {
    return 'TextHighlight(start: $start, end: $end, '
        'startTime: $startTime, endTime: $endTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TextHighlight &&
        other.start == start &&
        other.end == end &&
        other.startTime == startTime &&
        other.endTime == endTime;
  }

  @override
  int get hashCode => Object.hash(start, end, startTime, endTime);
}
