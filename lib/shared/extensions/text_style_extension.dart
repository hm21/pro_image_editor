import 'package:flutter/painting.dart';

/// Scales the parts of a text layer's style that are measured at a font
/// scale and layer scale of 1.
extension TextLayerStyleScale on TextStyle {
  /// This style with its shadows, letter spacing and word spacing grown by
  /// [factor], so they keep their size relative to a font grown by the same
  /// factor.
  TextStyle scaleLayerEffects(double factor) {
    if (factor == 1) return this;
    final letterSpacing = this.letterSpacing;
    final wordSpacing = this.wordSpacing;
    return copyWith(
      shadows: shadows?.map((shadow) => shadow.scale(factor)).toList(),
      letterSpacing: letterSpacing == null ? null : letterSpacing * factor,
      wordSpacing: wordSpacing == null ? null : wordSpacing * factor,
    );
  }
}
