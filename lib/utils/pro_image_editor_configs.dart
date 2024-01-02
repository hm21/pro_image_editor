import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/custom_widgets.dart';
import '../models/editor_configs/crop_rotate_editor_configs.dart';
import '../models/editor_configs/emoji_editor_configs.dart';
import '../models/editor_configs/filter_editor_configs.dart';
import '../models/editor_configs/paint_editor_configs.dart';
import '../models/editor_configs/text_editor_configs.dart';
import '../models/helper_lines.dart';
import '../models/i18n/i18n.dart';
import '../models/icons/icons.dart';
import '../models/theme/theme.dart';
import 'design_mode.dart';

/// A class representing configuration options for the Image Editor.
class ProImageEditorConfigs {
  /// The theme to be used for the Image Editor.
  final ThemeData? theme;

  /// A unique hero tag for the Image Editor widget.
  final String heroTag;

  /// The editor currently supports only 'portraitUp' orientation. After closing the editor, it will revert to your default settings.
  final List<DeviceOrientation> activePreferredOrientations;

  /// Internationalization settings for the Image Editor.
  final I18n i18n;

  /// Configuration options for helper lines in the Image Editor.
  final HelperLines helperLines;

  /// Custom widgets to be used in the Image Editor.
  final ProImageEditorCustomWidgets customWidgets;

  /// Theme settings for the Image Editor.
  final ImageEditorTheme imageEditorTheme;

  /// Icons to be used in the Image Editor.
  final ImageEditorIcons icons;

  /// Configuration options for the Paint Editor.
  final PaintEditorConfigs paintEditorConfigs;

  /// Configuration options for the Text Editor.
  final TextEditorConfigs textEditorConfigs;

  /// Configuration options for the Crop and Rotate Editor.
  final CropRotateEditorConfigs cropRotateEditorConfigs;

  /// Configuration options for the Filter Editor.
  final FilterEditorConfigs filterEditorConfigs;

  /// Configuration options for the Emoji Editor.
  final EmojiEditorConfigs emojiEditorConfigs;

  /// The design mode for the Image Editor.
  final ImageEditorDesignModeE designMode;

  /// Creates an instance of [ProImageEditorConfigs].
  /// - The `theme` specifies the theme for the Image Editor.
  /// - The `heroTag` is a unique tag for the Image Editor widget. By default, it is 'Pro-Image-Editor-Hero'.
  /// - The `activePreferredOrientations` is a list of preferred device orientations. The editor currently supports only 'portraitUp' orientation. After closing the editor, it will revert to your default settings.
  /// - The `i18n` is used for internationalization settings. By default, it uses an empty `I18n` instance.
  /// - The `helperLines` configures helper lines in the Image Editor. By default, it uses an empty `HelperLines` instance.
  /// - The `customWidgets` specifies custom widgets to be used in the Image Editor. By default, it uses an empty `CustomWidgets` instance.
  /// - The `imageEditorTheme` sets the theme for the Image Editor. By default, it uses an empty `ImageEditorTheme` instance.
  /// - The `icons` specifies the icons to be used in the Image Editor. By default, it uses an empty `ImageEditorIcons` instance.
  /// - The `paintEditorConfigs` configures the Paint Editor. By default, it uses an empty `PaintEditorConfigs` instance.
  /// - The `textEditorConfigs` configures the Text Editor. By default, it uses an empty `TextEditorConfigs` instance.
  /// - The `cropRotateEditorConfigs` configures the Crop and Rotate Editor. By default, it uses an empty `CropRotateEditorConfigs` instance.
  /// - The `filterEditorConfigs` configures the Filter Editor. By default, it uses an empty `FilterEditorConfigs` instance.
  /// - The `emojiEditorConfigs` configures the Emoji Editor. By default, it uses an empty `EmojiEditorConfigs` instance.
  /// - The `designMode` specifies the design mode for the Image Editor. By default, it is `ImageEditorDesignMode.material`.
  const ProImageEditorConfigs({
    this.theme,
    this.heroTag = 'Pro-Image-Editor-Hero',
    this.activePreferredOrientations = const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ],
    this.i18n = const I18n(),
    this.helperLines = const HelperLines(),
    this.customWidgets = const ProImageEditorCustomWidgets(),
    this.imageEditorTheme = const ImageEditorTheme(),
    this.icons = const ImageEditorIcons(),
    this.paintEditorConfigs = const PaintEditorConfigs(),
    this.textEditorConfigs = const TextEditorConfigs(),
    this.cropRotateEditorConfigs = const CropRotateEditorConfigs(),
    this.filterEditorConfigs = const FilterEditorConfigs(),
    this.emojiEditorConfigs = const EmojiEditorConfigs(),
    this.designMode = ImageEditorDesignModeE.material,
  });
}
