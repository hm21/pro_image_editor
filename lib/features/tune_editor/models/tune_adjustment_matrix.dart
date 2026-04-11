import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

import '/core/constants/int_constants.dart';
import '/shared/extensions/num_extension.dart';
import '/shared/utils/parser/curve_parser.dart';
import '/shared/utils/parser/double_parser.dart';

/// A class representing the adjustment matrix for a tune adjustment item.
///
/// This class holds the adjustment [id], the [value] of the adjustment, and
/// the corresponding transformation [matrix] that applies the adjustment.
class TuneAdjustmentMatrix {
  /// Creates a [TuneAdjustmentMatrix] instance from a [Map] representation.
  ///
  /// This factory constructor extracts [id], [value], and [matrix] from the
  /// provided [map].
  factory TuneAdjustmentMatrix.fromMap(Map<String, dynamic> map) {
    return TuneAdjustmentMatrix(
      id: map['id']?.toString() ?? '-',
      value: safeParseDouble(map['value']?.toString()),
      matrix: (map['matrix'] as List?)?.map(safeParseDouble).toList() ?? [],
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

  /// Creates a [TuneAdjustmentMatrix] with the given [id], [value], and
  /// [matrix].
  ///
  /// - [id] is the unique identifier for the adjustment.
  /// - [value] is the adjustment value.
  /// - [matrix] is a list of doubles representing the matrix transformation.
  TuneAdjustmentMatrix({
    required this.id,
    required this.value,
    required this.matrix,
    this.startTime,
    this.endTime,
    this.enterDuration,
    this.exitDuration,
    this.enterCurve,
    this.exitCurve,
    this.meta = const {},
  });

  /// The unique identifier for the tune adjustment.
  final String id;

  /// The value of the tune adjustment.
  final double value;

  /// The transformation matrix associated with the tune adjustment.
  final List<double> matrix;

  /// The time at which this adjustment becomes active.
  ///
  /// Only used in the video editor. When `null`, always active.
  final Duration? startTime;

  /// The time at which this adjustment becomes inactive.
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

  /// User-defined metadata that can be attached to this tune adjustment.
  final Map<String, dynamic> meta;

  /// Converts this [TuneAdjustmentMatrix] instance into a [Map] representation.
  ///
  /// The map contains the [id], [value], and [matrix] as key-value pairs.
  Map<String, dynamic> toMap({int maxDecimalPlaces = kMaxSafeDecimalPlaces}) {
    return {
      'id': id,
      'value': value.roundSmart(maxDecimalPlaces),
      'matrix': matrix
          .map((value) => value.roundSmart(maxDecimalPlaces))
          .toList(),
      if (startTime != null) 'startTime': startTime!.inMilliseconds,
      if (endTime != null) 'endTime': endTime!.inMilliseconds,
      if (enterDuration != null) 'enterDuration': enterDuration!.inMilliseconds,
      if (exitDuration != null) 'exitDuration': exitDuration!.inMilliseconds,
      if (enterCurve != null) 'enterCurve': curveToString(enterCurve!),
      if (exitCurve != null) 'exitCurve': curveToString(exitCurve!),
      if (meta.isNotEmpty) 'meta': meta,
    };
  }

  /// Creates a copy of this [TuneAdjustmentMatrix] instance with the same
  /// values.
  ///
  /// The [copy] method allows duplicating the matrix with identical properties.
  TuneAdjustmentMatrix copy() {
    return TuneAdjustmentMatrix(
      id: id,
      value: value,
      matrix: [...matrix],
      startTime: startTime,
      endTime: endTime,
      enterDuration: enterDuration,
      exitDuration: exitDuration,
      enterCurve: enterCurve,
      exitCurve: exitCurve,
      meta: {...meta},
    );
  }

  /// Creates a copy of this instance with the given fields replaced.
  TuneAdjustmentMatrix copyWith({
    String? id,
    double? value,
    List<double>? matrix,
    Duration? startTime,
    Duration? endTime,
    Duration? enterDuration,
    Duration? exitDuration,
    Curve? enterCurve,
    Curve? exitCurve,
    Map<String, dynamic>? meta,
  }) {
    return TuneAdjustmentMatrix(
      id: id ?? this.id,
      value: value ?? this.value,
      matrix: matrix ?? [...this.matrix],
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      enterDuration: enterDuration ?? this.enterDuration,
      exitDuration: exitDuration ?? this.exitDuration,
      enterCurve: enterCurve ?? this.enterCurve,
      exitCurve: exitCurve ?? this.exitCurve,
      meta: meta ?? {...this.meta},
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TuneAdjustmentMatrix &&
        other.id == id &&
        other.value == value &&
        listEquals(other.matrix, matrix) &&
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
      id.hashCode ^
      value.hashCode ^
      matrix.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      enterDuration.hashCode ^
      exitDuration.hashCode ^
      enterCurve.hashCode ^
      exitCurve.hashCode ^
      meta.hashCode;
}
