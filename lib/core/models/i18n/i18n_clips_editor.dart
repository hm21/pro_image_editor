/// Internationalization (i18n) settings for the Clips Editor component.
class I18nClipsEditor {
  /// Creates an instance of [I18nClipsEditor] with customizable
  /// internationalization settings.
  const I18nClipsEditor({
    this.bottomNavigationBarText = 'Clips',
    this.done = 'Done',
    this.back = 'Back',
    this.remove = 'Remove',
    this.addVideoClip = 'Add Video-Clip',
    this.processingClips = 'Processing clips...',
  });

  /// Text for the bottom navigation bar item that opens the Editor.
  final String bottomNavigationBarText;

  /// Text for the "Done" button.
  final String done;

  /// Text for the "Remove" button.
  final String remove;

  /// Text for the "Back" button.
  final String back;

  /// Text for the "Add Video-Clip" button.
  final String addVideoClip;

  /// Text shown while clips are being merged.
  final String processingClips;
}
