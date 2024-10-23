// Flutter imports:
import 'package:flutter/material.dart';

/// A configuration class for defining icons used in the Tune Editor.
///
/// This class holds the [IconData] for various tune adjustment options,
/// including brightness, contrast, saturation, exposure, and more.
class IconsTuneEditor {
  /// Creates an [IconsTuneEditor] instance with customizable icons for each
  /// tune adjustment option.
  ///
  /// Each parameter represents the icon used for a specific control in the
  /// Tune Editor interface.
  const IconsTuneEditor({
    this.bottomNavBar = Icons.tune_rounded,
    this.brightness = Icons.brightness_4_outlined,
    this.contrast = Icons.contrast,
    this.saturation = Icons.water_drop_outlined,
    this.exposure = Icons.exposure,
    this.hue = Icons.color_lens_outlined,
    this.temperature = Icons.thermostat_outlined,
    this.sharpness = Icons.shutter_speed,
    this.fade = Icons.blur_off_outlined,
    this.luminance = Icons.light_mode_outlined,
  });

  /// Icon for the bottom navigation bar item that opens the Tune Editor.
  final IconData bottomNavBar;

  /// Icon for the "Brightness" adjustment control.
  final IconData brightness;

  /// Icon for the "Contrast" adjustment control.
  final IconData contrast;

  /// Icon for the "Saturation" adjustment control.
  final IconData saturation;

  /// Icon for the "Exposure" adjustment control.
  final IconData exposure;

  /// Icon for the "Hue" adjustment control.
  final IconData hue;

  /// Icon for the "Temperature" adjustment control.
  final IconData temperature;

  /// Icon for the "Sharpness" adjustment control.
  final IconData sharpness;

  /// Icon for the "Fade" adjustment control.
  final IconData fade;

  /// Icon for the "Luminance" adjustment control.
  final IconData luminance;

  /// Creates a copy of this [IconsTuneEditor] object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [IconsTuneEditor] with some properties updated while keeping the
  /// others unchanged.
  ///
  /// - [bottomNavBar] updates the icon for the bottom navigation bar item.
  /// - [brightness], [contrast], [saturation], [exposure], [hue],
  ///   [temperature], [sharpness],
  ///   [fade], and [luminance] update the icons for the respective tune
  ///   adjustment controls.
  IconsTuneEditor copyWith({
    IconData? bottomNavBar,
    IconData? brightness,
    IconData? contrast,
    IconData? saturation,
    IconData? exposure,
    IconData? hue,
    IconData? temperature,
    IconData? sharpness,
    IconData? fade,
    IconData? luminance,
  }) {
    return IconsTuneEditor(
      bottomNavBar: bottomNavBar ?? this.bottomNavBar,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      exposure: exposure ?? this.exposure,
      hue: hue ?? this.hue,
      temperature: temperature ?? this.temperature,
      sharpness: sharpness ?? this.sharpness,
      fade: fade ?? this.fade,
      luminance: luminance ?? this.luminance,
    );
  }
}
