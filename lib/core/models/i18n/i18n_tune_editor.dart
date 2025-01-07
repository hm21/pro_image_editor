/// Internationalization (i18n) settings for the Tune Editor component.
class I18nTuneEditor {
  /// Creates an instance of [I18nTuneEditor] with customizable text
  /// for various UI elements in the Tune Editor.
  ///
  /// Each parameter represents the text used for a specific control or
  /// label in the Tune Editor interface.
  const I18nTuneEditor({
    this.bottomNavigationBarText = 'Tune',
    this.back = 'Back',
    this.done = 'Done',
    this.brightness = 'Brightness',
    this.contrast = 'Contrast',
    this.saturation = 'Saturation',
    this.exposure = 'Exposure',
    this.hue = 'Hue',
    this.temperature = 'Temperature',
    this.sharpness = 'Sharpness',
    this.fade = 'Fade',
    this.luminance = 'Luminance',
    this.undo = 'Undo',
    this.redo = 'Redo',
  });

  /// Text for the bottom navigation bar item that opens the Tune Editor.
  final String bottomNavigationBarText;

  /// Text for the "Back" button in the Tune Editor.
  final String back;

  /// Text for the "Done" button in the Tune Editor.
  final String done;

  /// Text for the "Undo" button.
  final String undo;

  /// Text for the "Redo" button.
  final String redo;

  /// Text for the "Brightness" adjustment control.
  final String brightness;

  /// Text for the "Contrast" adjustment control.
  final String contrast;

  /// Text for the "Saturation" adjustment control.
  final String saturation;

  /// Text for the "Exposure" adjustment control.
  final String exposure;

  /// Text for the "Hue" adjustment control.
  final String hue;

  /// Text for the "Temperature" adjustment control.
  final String temperature;

  /// Text for the "Sharpness" adjustment control.
  final String sharpness;

  /// Text for the "Fade" adjustment control.
  final String fade;

  /// Text for the "Luminance" adjustment control.
  final String luminance;

  /// Creates a copy of this [I18nTuneEditor] object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [I18nTuneEditor] with some properties updated while keeping the others
  /// unchanged.
  ///
  /// - [bottomNavigationBarText] updates the text for the bottom navigation
  ///   bar item.
  /// - [back] updates the text for the "Back" button.
  /// - [done] updates the text for the "Done" button.
  /// - [brightness], [contrast], [saturation], [exposure], [hue],
  ///   [temperature], [sharpness],
  ///   [fade], and [luminance] update the corresponding tune adjustment labels.
  /// - [undo] updates the text for the "Undo" button.
  /// - [redo] updates the text for the "Redo" button.
  I18nTuneEditor copyWith({
    String? bottomNavigationBarText,
    String? back,
    String? done,
    String? undo,
    String? redo,
    String? brightness,
    String? contrast,
    String? saturation,
    String? exposure,
    String? hue,
    String? temperature,
    String? sharpness,
    String? fade,
    String? luminance,
  }) {
    return I18nTuneEditor(
      bottomNavigationBarText:
          bottomNavigationBarText ?? this.bottomNavigationBarText,
      back: back ?? this.back,
      done: done ?? this.done,
      undo: undo ?? this.undo,
      redo: redo ?? this.redo,
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
