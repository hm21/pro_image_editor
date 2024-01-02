import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' show RecentTabBehavior, CategoryIcons, Category, CategoryEmoji;
import 'package:flutter/widgets.dart';

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
///   recentTabBehavior: RecentTabBehavior.RECENT,
///   enableSkinTones: true,
///   recentsLimit: 28,
///   textStyle: TextStyle(fontSize: 16.0),
///   emojiSet: myCustomEmojiSet,
///   verticalSpacing: 4.0,
///   horizontalSpacing: 4.0,
///   gridPadding: EdgeInsets.all(8.0),
///   initCategory: Category.SMILEYS,
///   replaceEmojiOnLimitExceed: false,
///   categoryIcons: CategoryIcons(
///     smileys: Icons.tag_faces,
///     animals: Icons.pets,
///   ),
///   customSkinColorOverlayHorizontalOffset: 12.0,
/// );
/// ```
class EmojiEditorConfigs {
  /// Indicates whether the emoji editor is enabled.
  final bool enabled;

  /// The initial scale for displaying emojis.
  final double initScale;

  /// Defines the behavior of the recent tab (Recent, Popular).
  final RecentTabBehavior recentTabBehavior;

  /// Enables the feature to select skin tones for certain emojis.
  final bool enableSkinTones;

  /// Limits the number of recently used emojis that will be saved.
  final int recentsLimit;

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
  final List<CategoryEmoji>? emojiSet;

  /// The initial [Category] that will be selected. The corresponding category
  /// button in the bottom bar will be darkened.
  final Category initCategory;

  /// Vertical spacing between emojis.
  final double verticalSpacing;

  /// Horizontal spacing between emojis.
  final double horizontalSpacing;

  /// The padding of the GridView, default is [EdgeInsets.zero].
  final EdgeInsets gridPadding;

  /// Determines whether to replace the latest emoji in the recents list when
  /// the limit is exceeded.
  final bool replaceEmojiOnLimitExceed;

  /// Determines the icons to display for each [Category].
  final CategoryIcons categoryIcons;

  /// Customize skin color overlay horizontal offset, especially useful when
  /// EmojiPicker is not aligned to the left border of the screen.
  final double? customSkinColorOverlayHorizontalOffset;

  /// Creates an instance of EmojiEditorConfigs with optional settings.
  ///
  /// By default, the editor is enabled, and other properties are set to
  /// reasonable defaults.
  const EmojiEditorConfigs({
    this.enabled = true,
    this.initScale = 5.0,
    this.recentTabBehavior = RecentTabBehavior.RECENT,
    this.enableSkinTones = true,
    this.recentsLimit = 28,
    this.textStyle = const TextStyle(fontFamilyFallback: ['Apple Color Emoji']),
    this.checkPlatformCompatibility = true,
    this.emojiSet,
    this.verticalSpacing = 0,
    this.horizontalSpacing = 0,
    this.gridPadding = EdgeInsets.zero,
    this.initCategory = Category.RECENT,
    this.replaceEmojiOnLimitExceed = false,
    this.categoryIcons = const CategoryIcons(),
    this.customSkinColorOverlayHorizontalOffset,
  });
}
