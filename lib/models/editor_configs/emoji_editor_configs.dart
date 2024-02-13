import 'package:emoji_picker_flutter/emoji_picker_flutter.dart'
    show
        BottomActionBarConfig,
        CategoryEmoji,
        CategoryViewConfig,
        DefaultEmojiTextStyle,
        EmojiViewConfig,
        SearchViewConfig,
        SkinToneConfig,
        defaultEmojiSet;
import 'package:flutter/widgets.dart';

import '../theme/theme_shared_values.dart';

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
///   textStyle: TextStyle(fontSize: 16, color: Colors.black),
///   checkPlatformCompatibility: true,
///   emojiSet: customEmojiSet,
///   searchViewConfig: SearchViewConfig(...),
///   categoryViewConfig: CategoryViewConfig(...),
///   emojiViewConfig: EmojiViewConfig(...),
///   skinToneConfig: SkinToneConfig(...),
///   bottomActionBarConfig: BottomActionBarConfig(...),
///   swapCategoryAndBottomBar: true,
/// );
/// ```
class EmojiEditorConfigs {
  /// Indicates whether the emoji editor is enabled.
  final bool enabled;

  /// The initial scale for displaying emojis.
  final double initScale;

  /// Custom emoji text style to apply to emoji characters in the grid.
  ///
  /// If you define a custom fontFamily or use GoogleFonts to set this property,
  /// be sure to set [checkPlatformCompatibility] to false. It will improve
  /// initialization performance and prevent technically supported glyphs from
  /// being filtered out.
  final TextStyle textStyle;

  /// Verify that emoji glyph is supported by the platform (Android only)
  final bool checkPlatformCompatibility;

  /// Custom emojis; if set, overrides default emojis provided by the library.
  final List<CategoryEmoji> emojiSet;

  /// Configuration for the search view.
  ///
  /// This configures the appearance and behavior of the search view.
  final SearchViewConfig? searchViewConfig;

  /// Configuration for the category view.
  ///
  /// This configures the appearance and behavior of the category view.
  final CategoryViewConfig? categoryViewConfig;

  /// Configuration for the emoji view.
  ///
  /// This configures the appearance and behavior of the emoji view.
  final EmojiViewConfig? emojiViewConfig;

  /// Configuration for the skin tone.
  ///
  /// This configures the appearance and behavior of the skin tone for emojis.
  final SkinToneConfig skinToneConfig;

  /// Configuration for the bottom action bar.
  ///
  /// This configures the appearance and behavior of the bottom action bar.
  final BottomActionBarConfig bottomActionBarConfig;

  /// Determines whether to swap the positions of the category view and the bottom action bar.
  ///
  /// If true, the category view will be displayed at the bottom and the bottom action bar at the top.
  /// If false, the category view will be displayed at the top and the bottom action bar at the bottom.
  final bool swapCategoryAndBottomBar;

  /// Creates an instance of EmojiEditorConfigs with optional settings.
  ///
  /// By default, the editor is enabled, and other properties are set to
  /// reasonable defaults.
  const EmojiEditorConfigs({
    this.enabled = true,
    this.initScale = 5.0,
    this.textStyle = DefaultEmojiTextStyle,
    this.checkPlatformCompatibility = true,
    this.emojiSet = defaultEmojiSet,
    this.searchViewConfig,
    this.bottomActionBarConfig = const BottomActionBarConfig(
      buttonIconColor: imageEditorTextColor,
      backgroundColor: imageEditorBackgroundColor,
      buttonColor: imageEditorBackgroundColor,
      showBackspaceButton: false,
    ),
    this.categoryViewConfig,
    this.skinToneConfig = const SkinToneConfig(
      enabled: true,
      dialogBackgroundColor: Color(0xFF252728),
      indicatorColor: Color(0xFF9E9E9E),
    ),
    this.swapCategoryAndBottomBar = true,
    this.emojiViewConfig,
  });
}
