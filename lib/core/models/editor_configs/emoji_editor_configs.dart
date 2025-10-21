import 'dart:ui';

import 'emoji_editor_configs.dart';
import 'utils/base_editor_layer_configs.dart';
import 'utils/base_sub_editor_configs.dart';

export '/plugins/emoji_picker_flutter/emoji_picker_flutter.dart'
    show
        CategoryEmoji,
        emojiSetChinese,
        emojiSetEnglish,
        emojiSetFrance,
        emojiSetGerman,
        emojiSetHindi,
        emojiSetItalian,
        emojiSetJapanese,
        emojiSetPortuguese,
        emojiSetRussian,
        emojiSetSpanish;

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
class EmojiEditorConfigs
    implements BaseEditorLayerConfigs, BaseSubEditorConfigs {
  /// Creates an instance of EmojiEditorConfigs with optional settings.
  ///
  /// By default, the editor is enabled, and other properties are set to
  /// reasonable defaults.
  const EmojiEditorConfigs({
    this.layerFractionalOffset = const Offset(-0.5, -0.5),
    this.enableGesturePop = true,
    this.enablePreloadWebFont = true,
    this.initScale = 5.0,
    this.minScale = double.negativeInfinity,
    this.maxScale = double.infinity,
    this.checkPlatformCompatibility = true,
    this.emojiSet,
    this.style = const EmojiEditorStyle(),
    this.icons = const EmojiEditorIcons(),
  })  : assert(initScale > 0, 'initScale must be positive'),
        assert(maxScale >= minScale,
            'maxScale must be greater than or equal to minScale');

  /// {@macro layerFractionalOffset}
  @override
  final Offset layerFractionalOffset;

  /// {@macro enableGesturePop}
  @override
  final bool enableGesturePop;

  /// Indicates whether the web font should be preloaded on web platforms.
  ///
  /// Default: true
  final bool enablePreloadWebFont;

  /// The initial scale for displaying emojis.
  final double initScale;

  /// Verify that emoji glyph is supported by the platform (Android only)
  final bool checkPlatformCompatibility;

  /// Allows customization of the emoji list by adding or removing support
  /// for specific locales.
  ///
  /// If you need a specific translation while maintaining the same emojis,
  /// it is recommended to define it here.
  ///
  /// *Example:*
  /// ```dart
  /// emojiEditor: EmojiEditorConfigs(
  ///    emojiSet: (locale) => emojiSetEnglish,
  /// )
  /// ```
  ///
  /// *Predefined translations:*
  /// - `emojiSetGerman`
  /// - `emojiSetEnglish`
  /// - `emojiSetSpanish`
  /// - `emojiSetFrench`
  /// - `emojiSetHindi`
  /// - `emojiSetItalian`
  /// - `emojiSetJapanese`
  /// - `emojiSetPortuguese`
  /// - `emojiSetRussian`
  /// - `emojiSetChinese`
  final List<CategoryEmoji> Function(Locale locale)? emojiSet;

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
    Offset? layerFractionalOffset,
    bool? enableGesturePop,
    bool? enablePreloadWebFont,
    double? initScale,
    bool? checkPlatformCompatibility,
    List<CategoryEmoji> Function(Locale locale)? emojiSet,
    double? minScale,
    double? maxScale,
    EmojiEditorStyle? style,
    EmojiEditorIcons? icons,
  }) {
    return EmojiEditorConfigs(
      layerFractionalOffset:
          layerFractionalOffset ?? this.layerFractionalOffset,
      enableGesturePop: enableGesturePop ?? this.enableGesturePop,
      enablePreloadWebFont: enablePreloadWebFont ?? this.enablePreloadWebFont,
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
