/// Internationalization (i18n) settings for the Crop and Rotate Editor component.
class I18nCropRotateEditor {
  /// Text for the bottom navigation bar item that opens the Crop and Rotate Editor.
  final String bottomNavigationBarText;

  /// Text for the "Rotate" tooltip.
  final String rotate;

  /// Text for the "Ratio" tooltip.
  final String ratio;

  /// Text for the "Back" button.
  final String back;

  /// Text for the "Cancel" button. Only available when the theme is set to `WhatsApp`.
  final String cancel;

  /// Text for the "Done" button.
  final String done;

  /// Text for the "Reset" button. Only available when the theme is set to `WhatsApp`.
  final String reset;

  /// Text for the message displayed during the application of changes.
  final String applyChangesDialogMsg;

  /// Text for the message displayed when preparing the image.
  final String prepareImageDialogMsg;

  /// The tooltip text displayed for the "More" option on small screens.
  final String smallScreenMoreTooltip;

  /// Creates an instance of [I18nCropRotateEditor] with customizable internationalization settings.
  ///
  /// You can provide translations and messages for various components of the
  /// Crop and Rotate Editor in the Image Editor. Customize the text for buttons,
  /// options, and messages to suit your application's language and style.
  ///
  /// Example:
  ///
  /// ```dart
  /// I18nCropRotateEditor(
  ///   bottomNavigationBarText: 'Crop & Rotate',
  ///   rotate: 'Rotate',
  ///   ratio: 'Aspect Ratio',
  ///   back: 'Go Back',
  ///   done: 'Apply',
  ///   applyChangesDialogMsg: 'Please wait while applying changes...',
  ///   prepareImageDialogMsg: 'Please wait while preparing the image...',
  /// )
  /// ```
  const I18nCropRotateEditor({
    this.bottomNavigationBarText = 'Crop/ Rotate',
    this.rotate = 'Rotate',
    this.ratio = 'Ratio',
    this.back = 'Back',
    this.done = 'Done',
    this.cancel = 'Cancel',
    this.prepareImageDialogMsg = 'Please wait',
    this.applyChangesDialogMsg = 'Please wait',
    this.smallScreenMoreTooltip = 'More',
    this.reset = 'Reset',
  });
}
