import 'package:flutter/foundation.dart';

import 'filter_addons.dart';

/// The kinds of step a filter is built from, one per [ColorFilterAddons]
/// method.
enum ColorFilterStepType {
  /// [ColorFilterAddons.colorOverlay]: red, green, blue and scale.
  colorOverlay(4),

  /// [ColorFilterAddons.rgbScale]: the red, green and blue factors.
  rgbScale(3),

  /// [ColorFilterAddons.addictiveColor]: the red, green and blue offsets.
  addictiveColor(3),

  /// [ColorFilterAddons.temperature]: one value.
  temperature(1),

  /// [ColorFilterAddons.grayscale]: no value.
  grayscale(0),

  /// [ColorFilterAddons.sepia]: one value.
  sepia(1),

  /// [ColorFilterAddons.invert]: no value.
  invert(0),

  /// [ColorFilterAddons.brightness]: one value.
  brightness(1),

  /// [ColorFilterAddons.contrast]: one value.
  contrast(1),

  /// [ColorFilterAddons.hue]: one value.
  hue(1),

  /// [ColorFilterAddons.saturation]: one value.
  saturation(1),

  /// [ColorFilterAddons.exposure]: one value.
  exposure(1),

  /// [ColorFilterAddons.fade]: one value.
  fade(1),

  /// [ColorFilterAddons.tint]: one value.
  tint(1);

  const ColorFilterStepType(this.valueCount);

  /// How many values a step of this type takes.
  final int valueCount;
}

/// One step of a filter's recipe: the [ColorFilterAddons] method it calls
/// and the [values] it calls it with.
///
/// A [FilterModel] built with `FilterModel.fromSteps` keeps its steps, so an
/// app can show a preset's values, let people change them and rebuild the
/// filter from the changed steps.
@immutable
class ColorFilterStep {
  /// Creates a step of [type] with [values], as many as
  /// [ColorFilterStepType.valueCount] says.
  ColorFilterStep(this.type, List<double> values)
    : assert(
        values.length == type.valueCount,
        '${type.name} takes ${type.valueCount} values, not ${values.length}',
      ),
      values = List.unmodifiable(values);

  /// A [ColorFilterAddons.colorOverlay] step.
  ColorFilterStep.colorOverlay(double r, double g, double b, double scale)
    : this(ColorFilterStepType.colorOverlay, [r, g, b, scale]);

  /// A [ColorFilterAddons.rgbScale] step.
  ColorFilterStep.rgbScale(double r, double g, double b)
    : this(ColorFilterStepType.rgbScale, [r, g, b]);

  /// A [ColorFilterAddons.addictiveColor] step.
  ColorFilterStep.addictiveColor(double r, double g, double b)
    : this(ColorFilterStepType.addictiveColor, [r, g, b]);

  /// A [ColorFilterAddons.temperature] step.
  ColorFilterStep.temperature(double value)
    : this(ColorFilterStepType.temperature, [value]);

  /// A [ColorFilterAddons.grayscale] step.
  ColorFilterStep.grayscale() : this(ColorFilterStepType.grayscale, const []);

  /// A [ColorFilterAddons.sepia] step.
  ColorFilterStep.sepia(double value)
    : this(ColorFilterStepType.sepia, [value]);

  /// A [ColorFilterAddons.invert] step.
  ColorFilterStep.invert() : this(ColorFilterStepType.invert, const []);

  /// A [ColorFilterAddons.brightness] step.
  ColorFilterStep.brightness(double value)
    : this(ColorFilterStepType.brightness, [value]);

  /// A [ColorFilterAddons.contrast] step.
  ColorFilterStep.contrast(double value)
    : this(ColorFilterStepType.contrast, [value]);

  /// A [ColorFilterAddons.hue] step.
  ColorFilterStep.hue(double value) : this(ColorFilterStepType.hue, [value]);

  /// A [ColorFilterAddons.saturation] step.
  ColorFilterStep.saturation(double value)
    : this(ColorFilterStepType.saturation, [value]);

  /// A [ColorFilterAddons.exposure] step.
  ColorFilterStep.exposure(double value)
    : this(ColorFilterStepType.exposure, [value]);

  /// A [ColorFilterAddons.fade] step.
  ColorFilterStep.fade(double value) : this(ColorFilterStepType.fade, [value]);

  /// A [ColorFilterAddons.tint] step.
  ColorFilterStep.tint(double value) : this(ColorFilterStepType.tint, [value]);

  /// Creates a step from the map [toMap] writes.
  ///
  /// Throws a [FormatException] when the type is unknown or the number of
  /// values does not match it.
  factory ColorFilterStep.fromMap(Map<String, dynamic> map) {
    final typeName = map['type'];
    final type = ColorFilterStepType.values.asNameMap()[typeName];
    if (type == null) {
      throw FormatException('Unknown color filter step type', typeName);
    }
    final rawValues = map['values'];
    final values = rawValues is List
        ? [
            for (final value in rawValues)
              if (value is num) value.toDouble(),
          ]
        : const <double>[];
    if (rawValues is List && values.length != rawValues.length ||
        values.length != type.valueCount) {
      throw FormatException(
        '${type.name} takes ${type.valueCount} numbers',
        rawValues,
      );
    }
    return ColorFilterStep(type, values);
  }

  /// The [ColorFilterAddons] method this step calls.
  final ColorFilterStepType type;

  /// The values this step calls its method with, in the order of the
  /// method's parameters.
  final List<double> values;

  /// The color matrix this step applies.
  List<double> get matrix => switch (type) {
    ColorFilterStepType.colorOverlay => ColorFilterAddons.colorOverlay(
      values[0],
      values[1],
      values[2],
      values[3],
    ),
    ColorFilterStepType.rgbScale => ColorFilterAddons.rgbScale(
      values[0],
      values[1],
      values[2],
    ),
    ColorFilterStepType.addictiveColor => ColorFilterAddons.addictiveColor(
      values[0],
      values[1],
      values[2],
    ),
    ColorFilterStepType.temperature => ColorFilterAddons.temperature(values[0]),
    ColorFilterStepType.grayscale => ColorFilterAddons.grayscale(),
    ColorFilterStepType.sepia => ColorFilterAddons.sepia(values[0]),
    ColorFilterStepType.invert => ColorFilterAddons.invert(),
    ColorFilterStepType.brightness => ColorFilterAddons.brightness(values[0]),
    ColorFilterStepType.contrast => ColorFilterAddons.contrast(values[0]),
    ColorFilterStepType.hue => ColorFilterAddons.hue(values[0]),
    ColorFilterStepType.saturation => ColorFilterAddons.saturation(values[0]),
    ColorFilterStepType.exposure => ColorFilterAddons.exposure(values[0]),
    ColorFilterStepType.fade => ColorFilterAddons.fade(values[0]),
    ColorFilterStepType.tint => ColorFilterAddons.tint(values[0]),
  };

  /// A step of the same [type] with [values].
  ColorFilterStep copyWith({List<double>? values}) =>
      ColorFilterStep(type, values ?? this.values);

  /// Converts this step into a map [ColorFilterStep.fromMap] reads.
  Map<String, dynamic> toMap() => {'type': type.name, 'values': values};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorFilterStep &&
          other.type == type &&
          listEquals(other.values, values);

  @override
  int get hashCode => Object.hash(type, Object.hashAll(values));

  @override
  String toString() => 'ColorFilterStep(${type.name}, $values)';
}
