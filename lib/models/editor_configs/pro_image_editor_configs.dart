// Flutter imports:
import 'package:flutter/material.dart';
import 'package:pro_image_editor/common/editor_various_constants.dart';

// Project imports:
import '../../utils/design_mode.dart';
import '../i18n/i18n.dart';
import 'blur_editor_configs.dart';
import 'crop_rotate_editor_configs.dart';
import 'dialog_configs.dart';
import 'emoji_editor_configs.dart';
import 'filter_editor_configs.dart';
import 'helper_lines_configs.dart';
import 'image_generation_configs/image_generation_configs.dart';
import 'layer_interaction_configs.dart';
import 'main_editor_configs.dart';
import 'paint_editor_configs.dart';
import 'progress_indicator_configs.dart';
import 'state_history_configs.dart';
import 'sticker_editor_configs.dart';
import 'text_editor_configs.dart';
import 'tune_editor_configs.dart';

export '../../utils/design_mode.dart';
export '../../utils/pro_image_editor_mode.dart';
export '../crop_rotate_editor/aspect_ratio_item.dart';
export '../i18n/i18n.dart';
export '../layer/layer_background_mode.dart';
export 'blur_editor_configs.dart';
export 'crop_rotate_editor_configs.dart';
export 'dialog_configs.dart';
export 'emoji_editor_configs.dart';
export 'filter_editor_configs.dart';
export 'helper_lines_configs.dart';
export 'image_generation_configs/image_generation_configs.dart';
export 'layer_interaction_configs.dart';
export 'main_editor_configs.dart';
export 'paint_editor_configs.dart';
export 'progress_indicator_configs.dart';
export 'state_history_configs.dart';
export 'sticker_editor_configs.dart';
export 'text_editor_configs.dart';
export 'tune_editor_configs.dart';

/// A class representing configuration options for the Image Editor.
class ProImageEditorConfigs {
  /// Creates an instance of [ProImageEditorConfigs].
  ///
  /// - The `theme` specifies the theme for the Image Editor.
  /// - The `heroTag` is a unique tag for the Image Editor widget. By default,
  ///   it is 'Pro-Image-Editor-Hero'.
  /// - The `i18n` is used for internationalization settings. By default, it
  ///   uses an empty `I18n` instance.
  /// - The `helperLines` configures helper lines in the Image Editor. By
  ///   default, it uses an empty `HelperLines` instance.
  /// - The `layerInteraction` specifies options for the layer interaction
  ///   behavior.
  /// - The `mainEditorConfigs` configures the Main Editor. By default, it
  ///   uses an empty `MainEditorConfigs` instance.
  /// - The `paintEditorConfigs` configures the Paint Editor. By default, it
  ///   uses an empty `PaintEditorConfigs` instance.
  /// - The `textEditorConfigs` configures the Text Editor. By default, it
  ///   uses an empty `TextEditorConfigs` instance.
  /// - The `cropRotateEditorConfigs` configures the Crop and Rotate Editor.
  ///   By default, it uses an empty `CropRotateEditorConfigs` instance.
  /// - The `filterEditorConfigs` configures the Filter Editor. By default,
  ///   it uses an empty `FilterEditorConfigs` instance.
  /// - The `blurEditorConfigs` configures the Blur Editor. By default, it
  ///   uses an empty `BlurEditorConfigs` instance.
  /// - The `emojiEditorConfigs` configures the Emoji Editor. By default, it
  ///   uses an empty `EmojiEditorConfigs` instance.
  /// - The `stickerEditorConfigs` configures the Sticker Editor. By default,
  ///   it uses an empty `StickerEditorConfigs` instance.
  /// - The `designMode` specifies the design mode for the Image Editor. By
  ///   default, it is `ImageEditorDesignModeE.material`.
  /// - The `stateHistoryConfigs` holds the configurations related to state
  ///   history management. By default, it uses an empty `StateHistoryConfigs`
  ///   instance.
  /// - The `imageGenerationConfigs` holds the configurations related to
  ///   image generation. By default, it uses an empty `imageGenerationConfigs`
  ///   instance.
  /// - The `editorBoxConstraintsBuilder` configures global [BoxConstraints]
  ///   to use when opening editors in modal bottom sheets.
  const ProImageEditorConfigs({
    this.theme,
    this.heroTag = kImageEditorHeroTag,
    this.i18n = const I18n(),
    this.mainEditor = const MainEditorConfigs(),
    this.paintEditor = const PaintEditorConfigs(),
    this.textEditor = const TextEditorConfigs(),
    this.cropRotateEditor = const CropRotateEditorConfigs(),
    this.filterEditor = const FilterEditorConfigs(),
    this.tuneEditor = const TuneEditorConfigs(),
    this.blurEditor = const BlurEditorConfigs(),
    this.emojiEditor = const EmojiEditorConfigs(),
    this.stickerEditor = const StickerEditorConfigs(),
    this.stateHistory = const StateHistoryConfigs(),
    this.imageGeneration = const ImageGenerationConfigs(),
    this.helperLines = const HelperLineConfigs(),
    this.layerInteraction = const LayerInteractionConfigs(),
    this.dialogConfigs = const DialogConfigs(),
    this.progressIndicatorConfigs = const ProgressIndicatorConfigs(),
    this.designMode = ImageEditorDesignModeE.material,
  });

  /// The theme to be used for the Image Editor.
  final ThemeData? theme;

  /// A unique hero tag for the Image Editor widget.
  final String heroTag;

  /// Internationalization settings for the Image Editor.
  final I18n i18n;

  /// Configuration options for helper lines in the Image Editor.
  final HelperLineConfigs helperLines;

  /// Configuration options for the layer interaction behavior.
  final LayerInteractionConfigs layerInteraction;

  /// Configuration options for the main Editor.
  final MainEditorConfigs mainEditor;

  /// Configuration options for the Paint Editor.
  final PaintEditorConfigs paintEditor;

  /// Configuration options for the Text Editor.
  final TextEditorConfigs textEditor;

  /// Configuration options for the Crop and Rotate Editor.
  final CropRotateEditorConfigs cropRotateEditor;

  /// Configuration options for the Filter Editor.
  final FilterEditorConfigs filterEditor;

  /// Configuration options for the tune Editor.
  final TuneEditorConfigs tuneEditor;

  /// Configuration options for the Blur Editor.
  final BlurEditorConfigs blurEditor;

  /// Configuration options for the Emoji Editor.
  final EmojiEditorConfigs emojiEditor;

  /// Configuration options for the Sticker Editor.
  final StickerEditorConfigs stickerEditor;

  /// The design mode for the Image Editor.
  final ImageEditorDesignModeE designMode;

  /// Holds the configurations related to state history management.
  final StateHistoryConfigs stateHistory;

  /// Holds the configurations related to image generation.
  final ImageGenerationConfigs imageGeneration;

  /// Configuration for the loading dialog used in the editor.
  final DialogConfigs dialogConfigs;

  /// Configuration for customizing progress indicators.
  final ProgressIndicatorConfigs progressIndicatorConfigs;

  /// Creates a copy of this `ProImageEditorConfigs` object with the given
  /// fields replaced with new values.
  ProImageEditorConfigs copyWith({
    ThemeData? theme,
    String? heroTag,
    I18n? i18n,
    HelperLineConfigs? helperLines,
    LayerInteractionConfigs? layerInteraction,
    StateHistoryConfigs? stateHistory,
    ImageGenerationConfigs? imageGeneration,
    MainEditorConfigs? mainEditor,
    PaintEditorConfigs? paintEditor,
    TextEditorConfigs? textEditor,
    CropRotateEditorConfigs? cropRotateEditor,
    FilterEditorConfigs? filterEditor,
    TuneEditorConfigs? tuneEditor,
    BlurEditorConfigs? blurEditor,
    EmojiEditorConfigs? emojiEditor,
    StickerEditorConfigs? stickerEditor,
    ImageEditorDesignModeE? designMode,
    DialogConfigs? dialogConfigs,
    ProgressIndicatorConfigs? progressIndicatorConfigs,
  }) {
    return ProImageEditorConfigs(
      theme: theme ?? this.theme,
      heroTag: heroTag ?? this.heroTag,
      i18n: i18n ?? this.i18n,
      helperLines: helperLines ?? this.helperLines,
      layerInteraction: layerInteraction ?? this.layerInteraction,
      stateHistory: stateHistory ?? this.stateHistory,
      imageGeneration: imageGeneration ?? this.imageGeneration,
      mainEditor: mainEditor ?? this.mainEditor,
      paintEditor: paintEditor ?? this.paintEditor,
      textEditor: textEditor ?? this.textEditor,
      cropRotateEditor: cropRotateEditor ?? this.cropRotateEditor,
      filterEditor: filterEditor ?? this.filterEditor,
      tuneEditor: tuneEditor ?? this.tuneEditor,
      blurEditor: blurEditor ?? this.blurEditor,
      emojiEditor: emojiEditor ?? this.emojiEditor,
      stickerEditor: stickerEditor ?? this.stickerEditor,
      designMode: designMode ?? this.designMode,
      dialogConfigs: dialogConfigs ?? this.dialogConfigs,
      progressIndicatorConfigs:
          progressIndicatorConfigs ?? this.progressIndicatorConfigs,
    );
  }
}
