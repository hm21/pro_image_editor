import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '/core/models/editor_configs/emoji_editor_configs.dart';

/// A widget responsible for preloading fonts for the main editor,
/// ensuring smooth rendering of text and emoji elements.
class MainEditorFontPreloader extends StatelessWidget {
  /// Creates a `MainEditorFontPreloader` with the provided emoji editor
  /// configurations.
  ///
  /// - [emojiEditorConfigs]: Configuration settings related to the emoji
  /// editor,
  ///   which include font settings and other necessary configurations.
  const MainEditorFontPreloader({
    super.key,
    required this.emojiEditorConfigs,
  });

  /// Configuration settings related to the emoji editor, including font
  /// details.
  final EmojiEditorConfigs emojiEditorConfigs;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && emojiEditorConfigs.enablePreloadWebFont) {
      return Offstage(
        child: Text('😀', style: emojiEditorConfigs.style.textStyle),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(FlagProperty(
      'isFontPreloaded',
      value: kIsWeb && emojiEditorConfigs.enablePreloadWebFont,
      ifTrue: 'enabled',
      ifFalse: 'disabled',
    ));
  }
}
