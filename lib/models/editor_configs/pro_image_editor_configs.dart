// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../utils/design_mode.dart';
import '../custom_widgets/custom_widgets.dart';
import '../i18n/i18n.dart';
import '../icons/icons.dart';
import '../theme/theme.dart';
import 'blur_editor_configs.dart';
import 'crop_rotate_editor_configs.dart';
import 'emoji_editor_configs.dart';
import 'filter_editor_configs.dart';
import 'helper_lines_configs.dart';
import 'image_generation_configs/image_generation_configs.dart';
import 'layer_interaction_configs.dart';
import 'main_editor_configs.dart';
import 'paint_editor_configs.dart';
import 'state_history_configs.dart';
import 'sticker_editor_configs.dart';
import 'text_editor_configs.dart';
import 'tune_editor_configs.dart';

export '../../utils/design_mode.dart';
export '../../utils/pro_image_editor_mode.dart';
export '../crop_rotate_editor/aspect_ratio_item.dart';
export '../custom_widgets/custom_widgets.dart';
export '../i18n/i18n.dart';
export '../icons/icons.dart';
export '../layer/layer_background_mode.dart';
export '../theme/theme.dart';
export 'blur_editor_configs.dart';
export 'crop_rotate_editor_configs.dart';
export 'emoji_editor_configs.dart';
export 'filter_editor_configs.dart';
export 'helper_lines_configs.dart';
export 'image_generation_configs/image_generation_configs.dart';
export 'layer_interaction_configs.dart';
export 'paint_editor_configs.dart';
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
  /// - The `customWidgets` specifies custom widgets to be used in the Image
  ///   Editor. By default, it uses an empty `CustomWidgets` instance.
  /// - The `imageEditorTheme` sets the theme for the Image Editor. By
  ///   default, it uses an empty `ImageEditorTheme` instance.
  /// - The `icons` specifies the icons to be used in the Image Editor. By
  ///   default, it uses an empty `ImageEditorIcons` instance.
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
    this.heroTag = 'Pro-Image-Editor-Hero',
    this.i18n = const I18n(),
    this.helperLines = const HelperLines(),
    this.layerInteraction = const LayerInteraction(),
    this.customWidgets = const ImageEditorCustomWidgets(),
    this.imageEditorTheme = const ImageEditorTheme(),
    this.icons = const ImageEditorIcons(),
    this.stateHistoryConfigs = const StateHistoryConfigs(),
    this.imageGenerationConfigs = const ImageGenerationConfigs(),
    this.mainEditorConfigs = const MainEditorConfigs(),
    this.paintEditorConfigs = const PaintEditorConfigs(),
    this.textEditorConfigs = const TextEditorConfigs(),
    this.cropRotateEditorConfigs = const CropRotateEditorConfigs(),
    this.filterEditorConfigs = const FilterEditorConfigs(),
    this.tuneEditorConfigs = const TuneEditorConfigs(),
    this.blurEditorConfigs = const BlurEditorConfigs(),
    this.emojiEditorConfigs = const EmojiEditorConfigs(),
    this.stickerEditorConfigs,
    this.designMode = ImageEditorDesignModeE.material,
  });

  /// The theme to be used for the Image Editor.
  final ThemeData? theme;

  /// A unique hero tag for the Image Editor widget.
  final String heroTag;

  /// Internationalization settings for the Image Editor.
  final I18n i18n;

  /// Configuration options for helper lines in the Image Editor.
  final HelperLines helperLines;

  /// Configuration options for the layer interaction behavior.
  final LayerInteraction layerInteraction;

  /// Custom widgets to be used in the Image Editor.
  final ImageEditorCustomWidgets customWidgets;

  /// Theme settings for the Image Editor.
  final ImageEditorTheme imageEditorTheme;

  /// Icons to be used in the Image Editor.
  final ImageEditorIcons icons;

  /// Configuration options for the main Editor.
  final MainEditorConfigs mainEditorConfigs;

  /// Configuration options for the Paint Editor.
  final PaintEditorConfigs paintEditorConfigs;

  /// Configuration options for the Text Editor.
  final TextEditorConfigs textEditorConfigs;

  /// Configuration options for the Crop and Rotate Editor.
  final CropRotateEditorConfigs cropRotateEditorConfigs;

  /// Configuration options for the Filter Editor.
  final FilterEditorConfigs filterEditorConfigs;

  /// Configuration options for the tune Editor.
  final TuneEditorConfigs tuneEditorConfigs;

  /// Configuration options for the Blur Editor.
  final BlurEditorConfigs blurEditorConfigs;

  /// Configuration options for the Emoji Editor.
  final EmojiEditorConfigs emojiEditorConfigs;

  /// Configuration options for the Sticker Editor.
  final StickerEditorConfigs? stickerEditorConfigs;

  /// The design mode for the Image Editor.
  final ImageEditorDesignModeE designMode;

  /// Holds the configurations related to state history management.
  final StateHistoryConfigs stateHistoryConfigs;

  /// Holds the configurations related to image generation.
  final ImageGenerationConfigs imageGenerationConfigs;

  /// Creates a copy of this `ProImageEditorConfigs` object with the given
  /// fields replaced with new values.
  ProImageEditorConfigs copyWith({
    ThemeData? theme,
    String? heroTag,
    I18n? i18n,
    HelperLines? helperLines,
    LayerInteraction? layerInteraction,
    ImageEditorCustomWidgets? customWidgets,
    ImageEditorTheme? imageEditorTheme,
    ImageEditorIcons? icons,
    StateHistoryConfigs? stateHistoryConfigs,
    ImageGenerationConfigs? imageGenerationConfigs,
    MainEditorConfigs? mainEditorConfigs,
    PaintEditorConfigs? paintEditorConfigs,
    TextEditorConfigs? textEditorConfigs,
    CropRotateEditorConfigs? cropRotateEditorConfigs,
    FilterEditorConfigs? filterEditorConfigs,
    TuneEditorConfigs? tuneEditorConfigs,
    BlurEditorConfigs? blurEditorConfigs,
    EmojiEditorConfigs? emojiEditorConfigs,
    StickerEditorConfigs? stickerEditorConfigs,
    ImageEditorDesignModeE? designMode,
  }) {
    return ProImageEditorConfigs(
      theme: theme ?? this.theme,
      heroTag: heroTag ?? this.heroTag,
      i18n: i18n ?? this.i18n,
      helperLines: helperLines ?? this.helperLines,
      layerInteraction: layerInteraction ?? this.layerInteraction,
      customWidgets: customWidgets ?? this.customWidgets,
      imageEditorTheme: imageEditorTheme ?? this.imageEditorTheme,
      icons: icons ?? this.icons,
      stateHistoryConfigs: stateHistoryConfigs ?? this.stateHistoryConfigs,
      imageGenerationConfigs:
          imageGenerationConfigs ?? this.imageGenerationConfigs,
      mainEditorConfigs: mainEditorConfigs ?? this.mainEditorConfigs,
      paintEditorConfigs: paintEditorConfigs ?? this.paintEditorConfigs,
      textEditorConfigs: textEditorConfigs ?? this.textEditorConfigs,
      cropRotateEditorConfigs:
          cropRotateEditorConfigs ?? this.cropRotateEditorConfigs,
      filterEditorConfigs: filterEditorConfigs ?? this.filterEditorConfigs,
      tuneEditorConfigs: tuneEditorConfigs ?? this.tuneEditorConfigs,
      blurEditorConfigs: blurEditorConfigs ?? this.blurEditorConfigs,
      emojiEditorConfigs: emojiEditorConfigs ?? this.emojiEditorConfigs,
      stickerEditorConfigs: stickerEditorConfigs ?? this.stickerEditorConfigs,
      designMode: designMode ?? this.designMode,
    );
  }
}
