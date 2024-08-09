/// Internationalization (i18n) settings for the Text Editor component.
class I18nTextEditor {
  /// Creates an instance of [I18nTextEditor] with customizable
  /// internationalization settings.
  ///
  /// You can provide translations and messages for various components of the
  /// Text Editor in the Image Editor. Customize the text for input fields,
  /// buttons, and settings to suit your application's language and style.
  ///
  /// Example:
  ///
  /// ```dart
  /// I18nTextEditor(
  ///   inputHintText: 'Type your text here',
  ///   bottomNavigationBarText: 'Text',
  ///   done: 'Save',
  ///   back: 'Go Back',
  ///   textAlign: 'Text Alignment',
  ///   backgroundMode: 'Background Mode',
  /// )
  /// ```
  const I18nTextEditor({
    this.inputHintText = 'Enter text',
    this.bottomNavigationBarText = 'Text',
    this.back = 'Back',
    this.done = 'Done',
    this.textAlign = 'Align text',
    this.fontScale = 'Font scale',
    this.backgroundMode = 'Background mode',
    this.smallScreenMoreTooltip = 'More',
  });

  /// Placeholder text displayed in the text input field.
  final String inputHintText;

  /// Text for the bottom navigation bar item that opens the Text Editor.
  final String bottomNavigationBarText;

  /// Text for the "Done" button.
  final String done;

  /// Text for the "Back" button.
  final String back;

  /// Text for the "Align text" setting.
  final String textAlign;

  /// Text for the "Text scale" setting.
  final String fontScale;

  /// Text for the "Background mode" setting.
  final String backgroundMode;

  /// The tooltip text displayed for the "More" option on small screens.
  final String smallScreenMoreTooltip;
}
