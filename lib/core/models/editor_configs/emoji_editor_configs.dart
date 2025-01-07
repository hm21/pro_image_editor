// Project imports:

import 'dart:ui';

import 'emoji_editor_configs.dart';

export 'package:emoji_picker_flutter/emoji_picker_flutter.dart'
    show CategoryEmoji, defaultEmojiSet;
export '../icons/emoji_editor_icons.dart';
export '../styles/emoji_editor_style.dart';

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
  /// Creates an instance of EmojiEditorConfigs with optional settings.
  ///
  /// By default, the editor is enabled, and other properties are set to
  /// reasonable defaults.
  const EmojiEditorConfigs({
    this.enabled = true,
    this.enablePreloadWebFont = true,
    this.initScale = 5.0,
    this.minScale = double.negativeInfinity,
    this.maxScale = double.infinity,
    this.checkPlatformCompatibility = true,
    this.emojiSet,
    this.locale = const Locale('en'),
    this.style = const EmojiEditorStyle(),
    this.icons = const EmojiEditorIcons(),
  })  : assert(initScale > 0, 'initScale must be positive'),
        assert(maxScale >= minScale,
            'maxScale must be greater than or equal to minScale');

  /// Indicates whether the emoji editor is enabled.
  final bool enabled;

  /// Indicates whether the web font should be preloaded on web platforms.
  ///
  /// Default: true
  final bool enablePreloadWebFont;

  /// The initial scale for displaying emojis.
  final double initScale;

  /// Verify that emoji glyph is supported by the platform (Android only)
  final bool checkPlatformCompatibility;

  /// Useful to provide a customized list of Emoji or add/remove the support
  /// for specific locales
  /// (create similar method as in default_emoji_set_locale.dart). If not
  /// provided, the default emoji set will be used based on the locales that
  /// are available in the package.
  final List<CategoryEmoji> Function(Locale)? emojiSet;

  /// Locale to choose the fitting language for the emoji set This will affect
  /// the emoji search results
  ///
  /// The package currently supports following languages:
  /// en, de, es, fr, hi, it, ja, pt, ru, zh.
  ///
  /// Default: const Locale('en')
  final Locale locale;

  /// The minimum scale factor from the layer.
  final double minScale;

  /// The maximum scale factor from the layer.
  final double maxScale;

  /// Style configuration for the emoji editor.
  final EmojiEditorStyle style;

  /// Icons used in the emoji editor.
  final EmojiEditorIcons icons;

  /// Creates a copy of this `EmojiEditorConfigs` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [EmojiEditorConfigs] with some properties updated while keeping the
  /// others unchanged.
  EmojiEditorConfigs copyWith({
    bool? enabled,
    double? initScale,
    bool? checkPlatformCompatibility,
    List<CategoryEmoji> Function(Locale)? emojiSet,
    double? minScale,
    double? maxScale,
    EmojiEditorStyle? style,
    EmojiEditorIcons? icons,
  }) {
    return EmojiEditorConfigs(
      enabled: enabled ?? this.enabled,
      initScale: initScale ?? this.initScale,
      checkPlatformCompatibility:
          checkPlatformCompatibility ?? this.checkPlatformCompatibility,
      emojiSet: emojiSet ?? this.emojiSet,
      minScale: minScale ?? this.minScale,
      maxScale: maxScale ?? this.maxScale,
      style: style ?? this.style,
      icons: icons ?? this.icons,
    );
  }
}
