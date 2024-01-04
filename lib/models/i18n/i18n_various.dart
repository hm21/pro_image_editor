/// Internationalization (i18n) settings for various components.
class I18nVarious {
  /// Text for the loading dialog message.
  final String loadingDialogMsg;
  final String closeEditorWarningTitle;
  final String closeEditorWarningMessage;
  final String closeEditorWarningConfirmBtn;
  final String closeEditorWarningCancelBtn;

  /// Creates an instance of [I18nVarious] with customizable internationalization settings.
  ///
  /// You can provide translations and messages for various components of your
  /// application to ensure a consistent and user-friendly experience for your
  /// users. Customize the text for loading dialogs, messages, and other
  /// miscellaneous components to match your application's language and style.
  ///
  /// Example:
  ///
  /// ```dart
  /// I18nVarious(
  ///   loadingDialogMsg: 'Please wait while loading...',
  /// )
  /// ```
  const I18nVarious({
    this.loadingDialogMsg = 'Please wait...',
    this.closeEditorWarningTitle = 'Close Image Editor?',
    this.closeEditorWarningMessage =
        'Are you sure you want to close the Image Editor? Your changes will not be saved.',
    this.closeEditorWarningConfirmBtn = 'OK',
    this.closeEditorWarningCancelBtn = 'Cancel',
  });
}
