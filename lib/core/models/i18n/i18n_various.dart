/// Internationalization (i18n) settings for various components.
class I18nVarious {
  /// Creates an instance of [I18nVarious] with customizable
  /// internationalization settings.
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
        'Are you sure you want to close the Image Editor? Your changes will '
            'not be saved.',
    this.closeEditorWarningConfirmBtn = 'OK',
    this.closeEditorWarningCancelBtn = 'Cancel',
  });

  /// Text for the loading dialog message.
  ///
  /// This text is displayed in the loading dialog to inform the user that
  /// a loading process is in progress. You can customize this text to provide
  /// a more specific or friendly message to the user.
  final String loadingDialogMsg;

  /// Title for the close editor warning dialog.
  ///
  /// This text is displayed as the title in the warning dialog when the user
  /// attempts to close the image editor, alerting them about unsaved changes.
  final String closeEditorWarningTitle;

  /// Message for the close editor warning dialog.
  ///
  /// This text is displayed in the warning dialog when the user attempts to
  /// close the image editor, informing them that their changes will not be
  /// saved if they proceed.
  final String closeEditorWarningMessage;

  /// Text for the confirmation button in the close editor warning dialog.
  ///
  /// This text is displayed on the button used to confirm the action of
  /// closing the image editor, allowing users to proceed with their decision.
  final String closeEditorWarningConfirmBtn;

  /// Text for the cancel button in the close editor warning dialog.
  ///
  /// This text is displayed on the button used to cancel the action of closing
  /// the image editor, allowing users to return to editing.
  final String closeEditorWarningCancelBtn;

  /// Creates a copy of this `I18nVarious` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [I18nVarious] with some properties updated while keeping the
  /// others unchanged.
  I18nVarious copyWith({
    String? loadingDialogMsg,
    String? closeEditorWarningTitle,
    String? closeEditorWarningMessage,
    String? closeEditorWarningConfirmBtn,
    String? closeEditorWarningCancelBtn,
  }) {
    return I18nVarious(
      loadingDialogMsg: loadingDialogMsg ?? this.loadingDialogMsg,
      closeEditorWarningTitle:
          closeEditorWarningTitle ?? this.closeEditorWarningTitle,
      closeEditorWarningMessage:
          closeEditorWarningMessage ?? this.closeEditorWarningMessage,
      closeEditorWarningConfirmBtn:
          closeEditorWarningConfirmBtn ?? this.closeEditorWarningConfirmBtn,
      closeEditorWarningCancelBtn:
          closeEditorWarningCancelBtn ?? this.closeEditorWarningCancelBtn,
    );
  }
}
