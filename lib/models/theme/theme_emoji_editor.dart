import 'package:emoji_picker_flutter/emoji_picker_flutter.dart'
    show
        BottomActionBarConfig,
        CategoryViewConfig,
        DefaultEmojiTextStyle,
        EmojiViewConfig,
        SearchViewConfig,
        SkinToneConfig;
import 'package:flutter/widgets.dart';

import '../theme/theme_shared_values.dart';

export 'package:emoji_picker_flutter/emoji_picker_flutter.dart'
    show
        BottomActionBarConfig,
        CategoryViewConfig,
        DefaultEmojiTextStyle,
        EmojiViewConfig,
        SearchViewConfig,
        SkinToneConfig;

/// The `EmojiEditorTheme` class defines the theme for the emoji editor in the image editor.
///
/// Usage:
///
/// ```dart
/// EmojiEditorTheme emojiEditorTheme = EmojiEditorTheme();
/// ```
///
/// ```
class EmojiEditorTheme {
  /// Configuration for the skin tone.
  ///
  /// This configures the appearance and behavior of the skin tone for emojis.
  final SkinToneConfig skinToneConfig;

  /// Configuration for the bottom action bar.
  ///
  /// This configures the appearance and behavior of the bottom action bar.
  final BottomActionBarConfig bottomActionBarConfig;

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

  /// Custom emoji text style to apply to emoji characters in the grid.
  ///
  /// If you define a custom fontFamily or use GoogleFonts to set this property,
  /// be sure to set [checkPlatformCompatibility] to false. It will improve
  /// initialization performance and prevent technically supported glyphs from
  /// being filtered out.
  final TextStyle textStyle;

  /// Determines whether to swap the positions of the category view and the bottom action bar.
  ///
  /// If true, the category view will be displayed at the bottom and the bottom action bar at the top.
  /// If false, the category view will be displayed at the top and the bottom action bar at the bottom.
  final bool swapCategoryAndBottomBar;

  /// Creates an instance of the `EmojiEditorTheme` class with the specified theme properties.
  const EmojiEditorTheme({
    this.bottomActionBarConfig = const BottomActionBarConfig(
      buttonIconColor: imageEditorTextColor,
      backgroundColor: imageEditorBackgroundColor,
      buttonColor: imageEditorBackgroundColor,
      showBackspaceButton: false,
    ),
    this.skinToneConfig = const SkinToneConfig(
      enabled: true,
      dialogBackgroundColor: Color(0xFF252728),
      indicatorColor: Color(0xFF9E9E9E),
    ),
    this.searchViewConfig,
    this.categoryViewConfig,
    this.emojiViewConfig,
    this.textStyle = DefaultEmojiTextStyle,
    this.swapCategoryAndBottomBar = true,
  });
}
