/// Internationalization (i18n) settings for the Audio Editor component.
class I18nAudioEditor {
  /// Creates an instance of [I18nAudioEditor] with customizable
  /// internationalization settings.
  const I18nAudioEditor({
    this.bottomNavigationBarText = 'Audio',
    this.done = 'Done',
    this.back = 'Back',
    this.balanceLabelOriginal = 'Original',
    this.balanceLabelOverlay = 'Overlay',
    this.balanceLabelBalanced = 'Balanced',
    this.confirmChanges = 'Confirm',
    this.editTrack = 'Edit Track',
  });

  /// Text for the bottom navigation bar item that opens the Audio Editor.
  final String bottomNavigationBarText;

  /// Text for the "Done" button, used to confirm and exit editing.
  final String done;

  /// Text for the "Back" button, used to return to the previous screen.
  final String back;

  /// Label for the "Original" audio balance option.
  final String balanceLabelOriginal;

  /// Label for the "Overlay" audio balance option.
  final String balanceLabelOverlay;

  /// Label for the "Balanced" audio option.
  final String balanceLabelBalanced;

  /// Text for the button or dialog action that confirms applied changes.
  final String confirmChanges;

  /// Text for the button or label that initiates track editing.
  final String editTrack;

  /// Creates a copy of this instance with the given parameters overridden.
  I18nAudioEditor copyWith({
    String? bottomNavigationBarText,
    String? done,
    String? back,
    String? balanceLabelOriginal,
    String? balanceLabelOverlay,
    String? balanceLabelBalanced,
    String? confirmChanges,
    String? editTrack,
  }) {
    return I18nAudioEditor(
      bottomNavigationBarText:
          bottomNavigationBarText ?? this.bottomNavigationBarText,
      done: done ?? this.done,
      back: back ?? this.back,
      balanceLabelOriginal: balanceLabelOriginal ?? this.balanceLabelOriginal,
      balanceLabelOverlay: balanceLabelOverlay ?? this.balanceLabelOverlay,
      balanceLabelBalanced: balanceLabelBalanced ?? this.balanceLabelBalanced,
      confirmChanges: confirmChanges ?? this.confirmChanges,
      editTrack: editTrack ?? this.editTrack,
    );
  }
}
