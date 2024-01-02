/// Internationalization (i18n) settings for the Emoji Editor component.
class I18nEmojiEditor {
  /// Text for the bottom navigation bar item that opens the Emoji Editor.
  final String bottomNavigationBarText;

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
  /// )
  /// ```
  const I18nEmojiEditor({
    this.bottomNavigationBarText = 'Emoji',
  });
}
