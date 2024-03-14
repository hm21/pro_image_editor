/// Internationalization (i18n) settings for the Blur Editor component.
class I18nBlurEditor {
  /// Text to display when a blur is being applied.
  final String applyBlurDialogMsg;

  /// Text for the bottom navigation bar item that opens the Blur Editor.
  final String bottomNavigationBarText;

  /// Text for the "Back" button in the Blur Editor.
  final String back;

  /// Text for the "Done" button in the Blur Editor.
  final String done;

  /// Creates an instance of [I18nBlurEditor] with customizable internationalization settings.
  ///
  /// You can provide translations and messages specifically for the Blur Editor
  /// component of your application. Customize the text for the bottom navigation bar,
  /// messages such as "Blur is being applied,"
  ///
  /// Example:
  ///
  /// ```dart
  /// I18nBlurEditor(
  ///   applyBlurDialogMsg: 'Blur is being applied.',
  ///   bottomNavigationBarText: 'Blur',
  ///   done: 'Apply',
  ///   back: 'Cancel',
  /// )
  /// ```
  const I18nBlurEditor({
    this.applyBlurDialogMsg = 'Blur is being applied.',
    this.bottomNavigationBarText = 'Blur',
    this.back = 'Back',
    this.done = 'Done',
  });
}
