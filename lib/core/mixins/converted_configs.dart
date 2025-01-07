import '../models/editor_configs/pro_image_editor_configs.dart';

/// A mixin providing access to converted configurations from
/// [ProImageEditorConfigs].
mixin ImageEditorConvertedConfigs {
  /// Returns the main configuration options for the editor.
  ProImageEditorConfigs get configs;

  /// Returns the configuration options for the main editor.
  MainEditorConfigs get mainEditorConfigs => configs.mainEditor;

  /// Returns the configuration options for the paint editor.
  PaintEditorConfigs get paintEditorConfigs => configs.paintEditor;

  /// Returns the configuration options for the text editor.
  TextEditorConfigs get textEditorConfigs => configs.textEditor;

  /// Returns the configuration options for the crop and rotate editor.
  CropRotateEditorConfigs get cropRotateEditorConfigs =>
      configs.cropRotateEditor;

  /// Returns the configuration options for the filter editor.
  FilterEditorConfigs get filterEditorConfigs => configs.filterEditor;

  /// Returns the configuration options for the tune editor.
  TuneEditorConfigs get tuneEditorConfigs => configs.tuneEditor;

  /// Returns the configuration options for the blur editor.
  BlurEditorConfigs get blurEditorConfigs => configs.blurEditor;

  /// Returns the configuration options for the emoji editor.
  EmojiEditorConfigs get emojiEditorConfigs => configs.emojiEditor;

  /// Returns the configuration options for the sticker editor.
  StickerEditorConfigs get stickerEditorConfigs => configs.stickerEditor;

  /// Returns the design mode for the image editor.
  ImageEditorDesignMode get designMode => configs.designMode;

  /// Returns the internationalization settings for the image editor.
  I18n get i18n => configs.i18n;

  /// Returns helper lines configurations for the image editor.
  HelperLineConfigs get helperLines => configs.helperLines;

  /// Returns layerInteraction configurations for the image editor.
  LayerInteractionConfigs get layerInteraction => configs.layerInteraction;

  /// Gets the configurations related to state history management.
  StateHistoryConfigs get stateHistoryConfigs => configs.stateHistory;

  /// Gets the configurations related to image generation.
  ImageGenerationConfigs get imageGenerationConfigs => configs.imageGeneration;

  /// Returns the hero tag used in the image editor.
  String get heroTag => configs.heroTag;

  /// Indicates if the design mode is material. Otherwise the design mode is
  /// cupertino.
  bool get isMaterial => configs.designMode == ImageEditorDesignMode.material;
}
