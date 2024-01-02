import 'dart:math';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import '../models/editor_configs/emoji_editor_configs.dart';
import '../models/theme/theme.dart';
import '../models/i18n/i18n.dart';
import '../models/layer.dart';
import '../utils/design_mode.dart';

/// The `EmojiEditor` class is responsible for creating a widget that allows users to select emojis.
///
/// This widget provides an EmojiPicker that allows users to choose emojis, which are then returned
/// as `EmojiLayerData` containing the selected emoji text.
class EmojiEditor extends StatefulWidget {
  /// The internationalization (i18n) configuration for the editor.
  final I18n i18n;

  /// The design mode of the editor.
  final ImageEditorDesignModeE designMode;

  /// The theme configuration specific to the image editor.
  final ImageEditorTheme imageEditorTheme;

  /// The configuration for the EmojiPicker.
  ///
  /// This parameter allows you to customize the behavior and appearance of the EmojiPicker.
  final EmojiEditorConfigs configs;

  /// Creates an `EmojiEditor` widget.
  ///
  /// The [i18n] parameter is used for internationalization.
  ///
  /// The [designMode] parameter specifies the design mode of the editor.
  ///
  /// The [imageEditorTheme] parameter is the theme configuration specific to the image editor.
  const EmojiEditor({
    super.key,
    this.i18n = const I18n(),
    this.configs = const EmojiEditorConfigs(),
    this.imageEditorTheme = const ImageEditorTheme(),
    this.designMode = ImageEditorDesignModeE.material,
  });

  @override
  createState() => EmojiEditorState();
}

/// The state class for the `EmojiEditor` widget.
class EmojiEditorState extends State<EmojiEditor> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Closes the editor without applying changes.
  void close() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _buildEmojiPickerSizedBox(constraints, context);
          },
        ),
      ),
    );
  }

  /// Builds a SizedBox containing the EmojiPicker with dynamic sizing.
  Widget _buildEmojiPickerSizedBox(BoxConstraints constraints, BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
      child: SizedBox(
        height: max(
          50,
          min(320, constraints.maxHeight) - MediaQuery.of(context).padding.bottom,
        ),
        child: EmojiPicker(
          key: const ValueKey('Emoji-Picker'),
          textEditingController: _controller,
          onEmojiSelected: (category, emoji) => {Navigator.pop(context, EmojiLayerData(emoji: emoji.emoji))},
          config: _buildEmojiPickerConfig(constraints),
        ),
      ),
    );
  }

  /// Builds the configuration for the EmojiPicker.
  Config _buildEmojiPickerConfig(BoxConstraints constraints) {
    return Config(
      columns: _calculateColumns(constraints),
      emojiSizeMax: 32,
      skinToneDialogBgColor: widget.imageEditorTheme.emojiEditor.skinToneDialogBgColor,
      skinToneIndicatorColor: widget.imageEditorTheme.emojiEditor.skinToneIndicatorColor,
      bgColor: widget.imageEditorTheme.emojiEditor.background,
      indicatorColor: widget.imageEditorTheme.emojiEditor.indicatorColor,
      iconColorSelected: widget.imageEditorTheme.emojiEditor.iconColorSelected,
      iconColor: widget.imageEditorTheme.emojiEditor.iconColor,
      enableSkinTones: widget.configs.enableSkinTones,
      recentsLimit: widget.configs.recentsLimit,
      emojiTextStyle: widget.configs.textStyle,
      emojiSet: widget.configs.emojiSet,
      initCategory: widget.configs.initCategory,
      gridPadding: widget.configs.gridPadding,
      horizontalSpacing: widget.configs.horizontalSpacing,
      verticalSpacing: widget.configs.verticalSpacing,
      replaceEmojiOnLimitExceed: widget.configs.replaceEmojiOnLimitExceed,
      recentTabBehavior: widget.configs.recentTabBehavior,
      noRecents: const SizedBox.shrink(),
      tabIndicatorAnimDuration: kTabScrollDuration,
      categoryIcons: widget.configs.categoryIcons,
      buttonMode: widget.designMode == ImageEditorDesignModeE.cupertino ? ButtonMode.CUPERTINO : ButtonMode.MATERIAL,
      checkPlatformCompatibility: widget.configs.checkPlatformCompatibility,
      customSkinColorOverlayHorizontalOffset: widget.configs.customSkinColorOverlayHorizontalOffset,
      loadingIndicator: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Calculates the number of columns for the EmojiPicker.
  int _calculateColumns(BoxConstraints constraints) => max(1, 10 / 400 * constraints.maxWidth - 1).floor();
}
