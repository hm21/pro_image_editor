/// Internationalization (i18n) settings for the I18nStickerEditor Editor component.
class I18nStickerEditor {
  /// Text for the bottom navigation bar item that opens the I18nStickerEditor Editor.
  final String bottomNavigationBarText;

  /// Creates an instance of [I18nStickerEditor] with customizable internationalization settings.
  ///
  /// You can provide translations and messages specifically for the I18nStickerEditor Editor
  /// component of your application.
  ///
  /// Example:
  ///
  /// ```dart
  /// I18nStickerEditor(
  ///   bottomNavigationBarText: 'I18nStickerEditor',
  /// )
  /// ```
  const I18nStickerEditor({
    this.bottomNavigationBarText = 'Stickers',
  });
}
