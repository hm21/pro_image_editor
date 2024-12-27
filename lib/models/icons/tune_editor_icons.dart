// Flutter imports:
import 'package:flutter/material.dart';

/// A configuration class for defining icons used in the Tune Editor.
///
/// This class holds the [IconData] for various tune adjustment options,
/// including brightness, contrast, saturation, exposure, and more.
class TuneEditorIcons {
  /// Creates an [TuneEditorIcons] instance with customizable icons for each
  /// tune adjustment option.
  ///
  /// Each parameter represents the icon used for a specific control in the
  /// Tune Editor interface.
  const TuneEditorIcons({
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
    this.applyChanges = Icons.done,
    this.backButton = Icons.arrow_back,
    this.undoAction = Icons.undo,
    this.redoAction = Icons.redo,
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

  /// The icon for the back button.
  final IconData backButton;

  /// The icon for applying changes in the editor.
  final IconData applyChanges;

  /// The icon for undoing the last action.
  final IconData undoAction;

  /// The icon for redoing the last undone action.
  final IconData redoAction;

  /// Creates a copy of this [TuneEditorIcons] object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [TuneEditorIcons] with some properties updated while keeping the
  /// others unchanged.
  ///
  /// - [bottomNavBar] updates the icon for the bottom navigation bar item.
  /// - [brightness], [contrast], [saturation], [exposure], [hue],
  ///   [temperature], [sharpness],
  ///   [fade], and [luminance] update the icons for the respective tune
  ///   adjustment controls.
  TuneEditorIcons copyWith({
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
    IconData? backButton,
    IconData? undoAction,
    IconData? redoAction,
    IconData? applyChanges,
  }) {
    return TuneEditorIcons(
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
      backButton: backButton ?? this.backButton,
      undoAction: undoAction ?? this.undoAction,
      redoAction: redoAction ?? this.redoAction,
      applyChanges: applyChanges ?? this.applyChanges,
    );
  }
}
