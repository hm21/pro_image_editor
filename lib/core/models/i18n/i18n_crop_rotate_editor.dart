/// Internationalization (i18n) settings for the Crop and Rotate Editor
/// component.
class I18nCropRotateEditor {
  /// Creates an instance of [I18nCropRotateEditor] with customizable
  /// internationalization settings.
  ///
  /// You can provide translations and messages for various components of the
  /// Crop and Rotate Editor in the Image Editor. Customize the text for
  /// buttons, options, and messages to suit your application's language and
  /// style.
  ///
  /// Example:
  ///
  /// ```dart
  /// I18nCropRotateEditor(
  ///   bottomNavigationBarText: 'Crop & Rotate',
  ///   rotate: 'Rotate',
  ///   ratio: 'Ratio',
  ///   back: 'Back',
  ///   done: 'Done',
  /// )
  /// ```
  const I18nCropRotateEditor({
    this.bottomNavigationBarText = 'Crop/ Rotate',
    this.rotate = 'Rotate',
    this.flip = 'Flip',
    this.ratio = 'Ratio',
    this.back = 'Back',
    this.done = 'Done',
    this.cancel = 'Cancel',
    this.undo = 'Undo',
    this.redo = 'Redo',
    this.smallScreenMoreTooltip = 'More',
    this.reset = 'Reset',
  });

  /// Text for the bottom navigation bar item that opens the Crop and Rotate
  /// Editor.
  final String bottomNavigationBarText;

  /// Text for the "Rotate" tooltip.
  final String rotate;

  /// Text for the "Flip" tooltip.
  final String flip;

  /// Text for the "Ratio" tooltip.
  final String ratio;

  /// Text for the "Back" button.
  final String back;

  /// Text for the "Cancel" button.
  final String cancel;

  /// Text for the "Done" button.
  final String done;

  /// Text for the "Reset" button.
  final String reset;

  /// Text for the "Undo" button.
  final String undo;

  /// Text for the "Redo" button.
  final String redo;

  /// The tooltip text displayed for the "More" option on small screens.
  final String smallScreenMoreTooltip;

  /// Creates a copy of this `I18nCropRotateEditor` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [I18nCropRotateEditor] with some properties updated while keeping the
  /// others unchanged.
  I18nCropRotateEditor copyWith({
    String? bottomNavigationBarText,
    String? rotate,
    String? flip,
    String? ratio,
    String? back,
    String? cancel,
    String? done,
    String? reset,
    String? undo,
    String? redo,
    String? smallScreenMoreTooltip,
  }) {
    return I18nCropRotateEditor(
      bottomNavigationBarText:
          bottomNavigationBarText ?? this.bottomNavigationBarText,
      rotate: rotate ?? this.rotate,
      flip: flip ?? this.flip,
      ratio: ratio ?? this.ratio,
      back: back ?? this.back,
      cancel: cancel ?? this.cancel,
      done: done ?? this.done,
      reset: reset ?? this.reset,
      undo: undo ?? this.undo,
      redo: redo ?? this.redo,
      smallScreenMoreTooltip:
          smallScreenMoreTooltip ?? this.smallScreenMoreTooltip,
    );
  }
}
