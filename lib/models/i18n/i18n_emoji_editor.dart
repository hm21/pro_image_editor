/// Internationalization (i18n) settings for the Emoji Editor component.
class I18nEmojiEditor {
  /// Text for the bottom navigation bar item that opens the Emoji Editor.
  final String bottomNavigationBarText;

  /// Text which show there are now recent selected emojis.
  final String noRecents;

  /// Hint text in the search field.
  final String search;

  /// Creates an instance of [I18nEmojiEditor] with customizable internationalization settings.
  ///
  /// You can provide translations and messages specifically for the Emoji Editor
  /// component of your application.
  ///
  /// Example:
  ///
  /// ```dart
  /// I18nEmojiEditor(
  ///   bottomNavigationBarText: 'Emojis',
  ///   search: 'Search',
  ///   noRecents: 'No Recents',
  /// )
  /// ```
  const I18nEmojiEditor({
    this.bottomNavigationBarText = 'Emoji',
    this.search = 'Search',
    this.noRecents = 'No Recents',
  });
}
