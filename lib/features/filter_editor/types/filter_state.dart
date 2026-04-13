import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

import '/shared/utils/parser/curve_parser.dart';

import 'filter_matrix.dart';

/// Extension on a list of [FilterState] objects to conveniently access
/// all combined filter matrices.
extension FilterStateListExtension on List<FilterState> {
  /// Returns all [FilterMatrix] entries from every [FilterState] in the list,
  /// flattened into a single [FilterMatrix].
  FilterMatrix get allMatrices => expand((f) => f.matrices).toList();
}

/// Wraps a [FilterMatrix] together with optional video-timeline metadata.
///
/// When used outside the video editor every timeline field stays `null` and
/// the filter simply applies unconditionally.
class FilterState {
  /// Creates a [FilterState] instance from a [Map] representation.
  factory FilterState.fromMap(Map<String, dynamic> map) {
    return FilterState(
      name: map['name'] as String? ?? '',
      matrices:
          (map['matrices'] as List?)
              ?.map(
                (e) => (e as List).map((v) => (v as num).toDouble()).toList(),
              )
              .toList() ??
          [],
      startTime: map['startTime'] != null
          ? Duration(milliseconds: map['startTime'] as int)
          : null,
      endTime: map['endTime'] != null
          ? Duration(milliseconds: map['endTime'] as int)
          : null,
      enterDuration: map['enterDuration'] != null
          ? Duration(milliseconds: map['enterDuration'] as int)
          : null,
      exitDuration: map['exitDuration'] != null
          ? Duration(milliseconds: map['exitDuration'] as int)
          : null,
      enterCurve: parseCurve(map['enterCurve'] as String?),
      exitCurve: parseCurve(map['exitCurve'] as String?),
      meta: (map['meta'] as Map<String, dynamic>?) ?? const {},
    );
  }

  /// Creates a [FilterState] with the given fields.
  const FilterState({
    required this.name,
    this.matrices = const [],
    this.startTime,
    this.endTime,
    this.enterDuration,
    this.exitDuration,
    this.enterCurve,
    this.exitCurve,
    this.meta = const {},
  });

  /// The name of the filter.
  final String name;

  /// The color-filter matrices that make up this filter effect.
  final FilterMatrix matrices;

  /// The time at which this filter becomes active.
  ///
  /// Only used in the video editor. When `null`, always active.
  final Duration? startTime;

  /// The time at which this filter becomes inactive.
  ///
  /// Only used in the video editor. When `null`, always active.
  final Duration? endTime;

  /// How long the enter transition lasts in **video time**.
  final Duration? enterDuration;

  /// How long the exit transition lasts in **video time**.
  final Duration? exitDuration;

  /// The curve applied to the enter transition.
  final Curve? enterCurve;

  /// The curve applied to the exit transition.
  final Curve? exitCurve;

  /// User-defined metadata that can be attached to this filter state.
  final Map<String, dynamic> meta;

  /// Whether [matrices] contains at least one matrix.
  bool get isNotEmpty => matrices.isNotEmpty;

  /// Whether [matrices] is empty.
  bool get isEmpty => matrices.isEmpty;

  /// Converts this instance into a [Map] representation.
  Map<String, dynamic> toMap() {
    return {
      if (name.isNotEmpty) 'name': name,
      'matrices': matrices,
      if (startTime != null) 'startTime': startTime!.inMilliseconds,
      if (endTime != null) 'endTime': endTime!.inMilliseconds,
      if (enterDuration != null) 'enterDuration': enterDuration!.inMilliseconds,
      if (exitDuration != null) 'exitDuration': exitDuration!.inMilliseconds,
      if (enterCurve != null) 'enterCurve': curveToString(enterCurve!),
      if (exitCurve != null) 'exitCurve': curveToString(exitCurve!),
      if (meta.isNotEmpty) 'meta': meta,
    };
  }

  /// Creates a copy of this instance with the given fields replaced.
  FilterState copyWith({
    String? name,
    FilterMatrix? matrices,
    Duration? startTime,
    Duration? endTime,
    Duration? enterDuration,
    Duration? exitDuration,
    Curve? enterCurve,
    Curve? exitCurve,
    Map<String, dynamic>? meta,
  }) {
    return FilterState(
      name: name ?? this.name,
      matrices: matrices ?? this.matrices.map((row) => [...row]).toList(),
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      enterDuration: enterDuration ?? this.enterDuration,
      exitDuration: exitDuration ?? this.exitDuration,
      enterCurve: enterCurve ?? this.enterCurve,
      exitCurve: exitCurve ?? this.exitCurve,
      meta: meta ?? {...this.meta},
    );
  }

  /// Creates a deep copy of this instance.
  FilterState copy() {
    return FilterState(
      name: name,
      matrices: matrices.map((row) => [...row]).toList(),
      startTime: startTime,
      endTime: endTime,
      enterDuration: enterDuration,
      exitDuration: exitDuration,
      enterCurve: enterCurve,
      exitCurve: exitCurve,
      meta: {...meta},
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FilterState) return false;

    if (matrices.length != other.matrices.length) return false;
    for (var i = 0; i < matrices.length; i++) {
      if (!listEquals(matrices[i], other.matrices[i])) return false;
    }

    return other.name == name &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.enterDuration == enterDuration &&
        other.exitDuration == exitDuration &&
        other.enterCurve == enterCurve &&
        other.exitCurve == exitCurve &&
        mapEquals(other.meta, meta);
  }

  @override
  int get hashCode =>
      name.hashCode ^
      matrices.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      enterDuration.hashCode ^
      exitDuration.hashCode ^
      enterCurve.hashCode ^
      exitCurve.hashCode ^
      meta.hashCode;
}
