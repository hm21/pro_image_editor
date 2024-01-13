import 'package:flutter/material.dart';

import '../models/editor_configs/sticker_editor_configs.dart';
import '../models/theme/theme.dart';
import '../models/i18n/i18n.dart';
import '../models/layer.dart';
import '../utils/design_mode.dart';

/// The `StickerEditor` class is responsible for creating a widget that allows users to select emojis.
///
/// This widget provides an EmojiPicker that allows users to choose emojis, which are then returned
/// as `EmojiLayerData` containing the selected emoji text.
class StickerEditor extends StatefulWidget {
  /// The internationalization (i18n) configuration for the editor.
  final I18n i18n;

  /// The design mode of the editor.
  final ImageEditorDesignModeE designMode;

  /// The theme configuration specific to the image editor.
  final ImageEditorTheme imageEditorTheme;

  /// The configuration for the EmojiPicker.
  ///
  /// This parameter allows you to customize the behavior and appearance of the EmojiPicker.
  final StickerEditorConfigs configs;

  /// Creates an `StickerEditor` widget.
  ///
  /// The [i18n] parameter is used for internationalization.
  ///
  /// The [designMode] parameter specifies the design mode of the editor.
  ///
  /// The [imageEditorTheme] parameter is the theme configuration specific to the image editor.
  const StickerEditor({
    super.key,
    required this.configs,
    this.i18n = const I18n(),
    this.imageEditorTheme = const ImageEditorTheme(),
    this.designMode = ImageEditorDesignModeE.material,
  });

  @override
  createState() => StickerEditorState();
}

/// The state class for the `StickerEditor` widget.
class StickerEditorState extends State<StickerEditor> {
  /// Closes the editor without applying changes.
  void close() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return widget.configs.buildStickers(setLayer);
  }

  void setLayer(Widget sticker) {
    Navigator.of(context).pop(
      StickerLayerData(sticker: sticker),
    );
  }
}
