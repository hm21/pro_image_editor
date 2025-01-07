/// Internationalization (i18n) settings for layer interaction components.
///
/// This class provides customizable internationalization settings for various
/// layer interaction actions such as removing, editing, and rotating/scaling
/// layers. By supplying translations for these actions, you can ensure a
/// consistent and user-friendly experience across different languages and
/// regions.
class I18nLayerInteraction {
  /// Creates an instance of [I18nLayerInteraction] with customizable
  /// internationalization settings for layer interactions.
  ///
  /// You can provide translations for the actions related to layer
  /// interactions, ensuring a consistent experience in the user's preferred
  /// language.
  ///
  /// Example:
  ///
  /// ```dart
  /// I18nLayerInteraction(
  ///   remove: 'Remove',
  ///   edit: 'Edit',
  ///   rotateScale: 'Rotate and Scale',
  /// )
  /// ```
  const I18nLayerInteraction({
    this.remove = 'Remove',
    this.edit = 'Edit',
    this.rotateScale = 'Rotate and Scale',
  });

  /// Text for the remove action.
  ///
  /// This text is displayed as the label for the action to remove a layer,
  /// customizable to match the language and style of your application.
  final String remove;

  /// Text for the edit action.
  ///
  /// This text is displayed as the label for the action to edit a layer,
  /// customizable to match the language and style of your application.
  final String edit;

  /// Text for the rotate and scale action.
  ///
  /// This text is displayed as the label for the action to rotate and scale
  /// a layer, customizable to match the language and style of your application.
  final String rotateScale;
}
