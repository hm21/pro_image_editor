// Project imports:
import '../../pro_image_editor.dart';

export 'package:emoji_picker_flutter/emoji_picker_flutter.dart'
    show CategoryEmoji, defaultEmojiSet;

/// Configuration options for an emoji editor.
///
/// `EmojiEditorConfigs` allows you to define various settings for an emoji
/// editor. You can configure features like enabling/disabling the editor,
/// setting the initial scale, defining behavior for the recent tab, enabling
/// skin tones, customizing text style, and more.
///
/// Example usage:
/// ```dart
/// EmojiEditorConfigs(
///   enabled: true,
///   initScale: 5.0,
///   checkPlatformCompatibility: true,
///   emojiSet: customEmojiSet,
/// );
/// ```
class EmojiEditorConfigs {
  /// Indicates whether the emoji editor is enabled.
  final bool enabled;

  /// The initial scale for displaying emojis.
  final double initScale;

  /// Verify that emoji glyph is supported by the platform (Android only)
  final bool checkPlatformCompatibility;

  /// Custom emojis; if set, overrides default emojis provided by the library.
  final List<CategoryEmoji> emojiSet;

  /// The minimum scale factor from the layer.
  final double minScale;

  /// The maximum scale factor from the layer.
  final double maxScale;

  /// Creates an instance of EmojiEditorConfigs with optional settings.
  ///
  /// By default, the editor is enabled, and other properties are set to
  /// reasonable defaults.
  const EmojiEditorConfigs({
    this.enabled = true,
    this.initScale = 5.0,
    this.minScale = double.negativeInfinity,
    this.maxScale = double.infinity,
    this.checkPlatformCompatibility = true,
    this.emojiSet = defaultEmojiSet,
  })  : assert(initScale > 0, 'initScale must be positive'),
        assert(maxScale >= minScale,
            'maxScale must be greater than or equal to minScale');
}
