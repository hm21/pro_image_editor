import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '/core/constants/int_constants.dart';
import '/shared/extensions/color_extension.dart';
import '/shared/extensions/num_extension.dart';
import '/shared/utils/parser/double_parser.dart';
import '/shared/utils/parser/int_parser.dart';

/// A linear color gradient that fills the glyphs of a `TextLayer` in place of
/// its single `TextLayer.color`.
///
/// The gradient spans the whole text: it runs across the box around all of
/// its lines, so a short line shows only the part of the gradient it covers,
/// and a text that types itself out keeps each letter in the color it has
/// once the whole text shows.
@immutable
class TextGradient {
  /// Creates a gradient through [colors], running in the direction of
  /// [angle].
  ///
  /// It needs at least two [colors], and [stops], when given, one for each
  /// color; a gradient that is not [isValid] is not drawn.
  const TextGradient({required this.colors, this.stops, this.angle = 0});

  /// Creates a [TextGradient] from a map written by [toMap].
  ///
  /// Values that do not parse fall back to the defaults, and [isValid]
  /// reports whether the result can be drawn, so hand-edited data never
  /// throws.
  factory TextGradient.fromMap(Map<String, dynamic> map) {
    final colors = map['colors'];
    final stops = map['stops'];
    return TextGradient(
      colors: colors is List
          ? [for (final color in colors) Color(safeParseInt(color))]
          : const [],
      stops: stops is List
          ? [for (final stop in stops) safeParseDouble(stop)]
          : null,
      angle: safeParseDouble(map['angle']),
    );
  }

  /// The colors the gradient runs through, from its start to its end.
  final List<Color> colors;

  /// Where each of [colors] sits along the gradient, from `0` at its start to
  /// `1` at its end, in ascending order; `null` spaces them evenly.
  final List<double>? stops;

  /// The direction the colors run in, clockwise from left to right, in
  /// radians: `0` runs from left to right, `pi / 2` from top to bottom.
  final double angle;

  /// Whether the gradient can be drawn: it has at least two [colors] and, if
  /// it has [stops], one for each color.
  bool get isValid =>
      colors.length >= 2 && (stops == null || stops!.length == colors.length);

  /// A shader that paints the gradient across [rect].
  ///
  /// The gradient starts and ends where lines at a right angle to [angle]
  /// touch the corners of [rect], so its first and last colors reach the
  /// corners whatever the direction.
  ui.Shader createShader(Rect rect) {
    final direction = Offset(math.cos(angle), math.sin(angle));
    final halfLength =
        (rect.width * direction.dx.abs() + rect.height * direction.dy.abs()) /
        2;
    final reach = direction * halfLength;
    return ui.Gradient.linear(
      rect.center - reach,
      rect.center + reach,
      colors,
      // The engine only spaces two colors by itself.
      stops ??
          [for (var i = 0; i < colors.length; i++) i / (colors.length - 1)],
    );
  }

  /// Converts the gradient to a map, readable by [TextGradient.fromMap], with
  /// its numbers rounded to [maxDecimalPlaces].
  Map<String, dynamic> toMap({
    int maxDecimalPlaces = kMaxSafeDecimalPlaces,
  }) => <String, dynamic>{
    'colors': [for (final color in colors) color.toHex()],
    if (stops case final stops?)
      'stops': [for (final stop in stops) stop.roundSmart(maxDecimalPlaces)],
    'angle': angle.roundSmart(maxDecimalPlaces),
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// [stops] cannot be removed this way; create a new gradient instead.
  TextGradient copyWith({
    List<Color>? colors,
    List<double>? stops,
    double? angle,
  }) {
    return TextGradient(
      colors: colors ?? this.colors,
      stops: stops ?? this.stops,
      angle: angle ?? this.angle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TextGradient &&
        listEquals(other.colors, colors) &&
        listEquals(other.stops, stops) &&
        other.angle == angle;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(colors),
    stops == null ? null : Object.hashAll(stops!),
    angle,
  );

  @override
  String toString() =>
      'TextGradient(colors: $colors, stops: $stops, angle: $angle)';
}
