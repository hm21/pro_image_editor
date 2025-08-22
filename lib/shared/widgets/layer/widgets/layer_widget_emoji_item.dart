import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '/core/enums/design_mode.dart';
import '/core/models/editor_configs/emoji_editor_configs.dart';
import '/core/models/editor_configs/text_editor_configs.dart';
import '/core/models/layers/emoji_layer.dart';
import '/shared/styles/platform_text_styles.dart';

/// A widget representing an emoji layer in the sticker editor.
class LayerWidgetEmojiItem extends StatelessWidget {
  /// Creates a [LayerWidgetEmojiItem] with the given emoji layer and editor
  /// configurations.
  const LayerWidgetEmojiItem({
    super.key,
    required this.layer,
    required this.emojiEditorConfigs,
    required this.textEditorConfigs,
    required this.designMode,
  });

  /// The emoji layer represented by this widget.
  final EmojiLayer layer;

  /// Configuration settings for the emoji editor.
  final EmojiEditorConfigs emojiEditorConfigs;

  /// Configuration settings for the text editor.
  final TextEditorConfigs textEditorConfigs;

  /// Defines the design mode for the image editor.
  final ImageEditorDesignMode designMode;

  @override
  Widget build(BuildContext context) {
    return Material(
      // Prevents hero animation bugs by using a transparent material.
      type: MaterialType.transparency,
      textStyle: platformTextStyle(context, designMode),
      child: Text(
        layer.emoji.toString(),
        textAlign: TextAlign.center,
        style: emojiEditorConfigs.style.textStyle.copyWith(
          fontSize: textEditorConfigs.initFontSize * layer.scale,
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    layer.debugFillProperties(properties);
  }
}
