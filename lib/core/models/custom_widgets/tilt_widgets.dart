import 'package:flutter/widgets.dart';

/// A set of customizable widgets used in the tilt editor.
///
/// Provides builders and overrides for the ruler, tick marks,
/// indicator, and bottom bar. This allows you to style or replace
/// specific UI elements without rewriting the tilt logic.
class TiltWidgets {
  /// Creates a [TiltWidgets] configuration.
  const TiltWidgets({
    this.ruler,
    this.tickMark,
    this.indicator,
    this.bottomBar,
  });

  /// Builder for the tilt ruler.
  ///
  /// - [value]: The current tilt value.
  /// - [onChangeUpdate]: Called while the value is changing.
  /// - [onChangeEnd]: Called when the tilt interaction ends.
  final Widget Function(
    double value,
    ValueChanged<double> onChangeUpdate,
    ValueChanged<double> onChangeEnd,
  )?
  ruler;

  /// Widget displayed as the center indicator (the knob).
  final Widget? indicator;

  /// Builder for tick marks on the ruler.
  ///
  /// - [isBig]: Whether the tick mark is a major tick.
  /// - [isZero]: Whether the tick mark is at the zero position.
  final Widget Function(bool isBig, bool isZero)? tickMark;

  /// Widget displayed as the bottom bar below the tilt controls.
  final Widget? bottomBar;

  /// Returns a copy of this [TiltWidgets] with the given fields
  /// replaced by new values.
  TiltWidgets copyWith({
    Widget Function(
      double value,
      ValueChanged<double> onChangeUpdate,
      ValueChanged<double> onChangeEnd,
    )?
    ruler,
    Widget? indicator,
    Widget Function(bool isBig, bool isZero)? tickMark,
    Widget? bottomBar,
  }) {
    return TiltWidgets(
      ruler: ruler ?? this.ruler,
      indicator: indicator ?? this.indicator,
      tickMark: tickMark ?? this.tickMark,
      bottomBar: bottomBar ?? this.bottomBar,
    );
  }
}
