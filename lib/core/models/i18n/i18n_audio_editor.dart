/// Internationalization (i18n) settings for the Audio Editor component.
class I18nAudioEditor {
  /// Creates an instance of [I18nAudioEditor] with customizable
  /// internationalization settings.
  const I18nAudioEditor({
    this.bottomNavigationBarText = 'Audio',
    this.done = 'Done',
    this.back = 'Back',
  });

  /// Text for the bottom navigation bar item that opens the Editor.
  final String bottomNavigationBarText;

  /// Text for the "Done" button.
  final String done;

  /// Text for the "Back" button.
  final String back;

  /// Creates a copy of this instance with the given parameters overridden.
  I18nAudioEditor copyWith({
    String? bottomNavigationBarText,
    String? done,
    String? back,
  }) {
    return I18nAudioEditor(
      bottomNavigationBarText:
          bottomNavigationBarText ?? this.bottomNavigationBarText,
      done: done ?? this.done,
      back: back ?? this.back,
    );
  }
}
