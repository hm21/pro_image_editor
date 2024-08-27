import 'package:emoji_picker_flutter/emoji_picker_flutter.dart'
    show
        BottomActionBarConfig,
        CategoryViewConfig,
        DefaultEmojiTextStyle,
        EmojiViewConfig,
        SearchViewConfig,
        SkinToneConfig;

// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../theme/theme_shared_values.dart';
import 'theme_draggable_sheet.dart';
import 'types/theme_types.dart';

export 'package:emoji_picker_flutter/emoji_picker_flutter.dart'
    show
        BottomActionBarConfig,
        CategoryViewConfig,
        DefaultEmojiTextStyle,
        ButtonMode,
        EmojiViewConfig,
        SearchViewConfig,
        SkinToneConfig;

/// The `EmojiEditorTheme` class defines the theme for the emoji editor in the
/// image editor.
///
/// Usage:
///
/// ```dart
/// EmojiEditorTheme emojiEditorTheme = EmojiEditorTheme();
/// ```
class EmojiEditorTheme {
  /// Creates an instance of the `EmojiEditorTheme` class with the specified
  /// theme properties.
  ///
  /// Example:
  ///
  /// ```dart
  /// EmojiEditorTheme(
  ///   bottomActionBarConfig: BottomActionBarConfig(...),
  ///   skinToneConfig: SkinToneConfig(...),
  ///   ...
  /// )
  /// ```
  const EmojiEditorTheme({
    this.editorBoxConstraintsBuilder,
    this.backgroundColor = const Color(0xFF121B22),
    this.scrollToDuration = Duration.zero,
    this.themeDraggableSheet = const ThemeDraggableSheet(
      minChildSize: 0.4,
      maxChildSize: 0.4,
      initialChildSize: 0.4,
    ),
    this.showDragHandle = true,
    this.bottomActionBarConfig = const BottomActionBarConfig(
      buttonIconColor: imageEditorTextColor,
      backgroundColor: Color(0xFF121B22),
      buttonColor: Color(0xFF121B22),
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
    this.categoryTitlePadding = const EdgeInsets.only(left: 10),
    this.categoryTitleStyle = const TextStyle(
      color: Color(0xFF86959C),
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
  });

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

  /// Determines whether to swap the positions of the category view and the
  /// bottom action bar.
  ///
  /// If true, the category view will be displayed at the bottom and the bottom
  /// action bar at the top.
  /// If false, the category view will be displayed at the top and the bottom
  /// action bar at the bottom.
  final bool swapCategoryAndBottomBar;

  /// Specifies whether a drag handle is shown on the bottom sheet.
  final bool showDragHandle;

  /// Configuration settings for the draggable bottom sheet component.
  final ThemeDraggableSheet themeDraggableSheet;

  /// Padding for the category title.
  final EdgeInsets categoryTitlePadding;

  /// Text style for the category title.
  final TextStyle categoryTitleStyle;

  /// Background color for the emoji editor.
  final Color backgroundColor;

  /// Duration for the scroll animation.
  final Duration scrollToDuration;

  /// Use this to build custom [BoxConstraints] that will be applied to
  /// the modal bottom sheet displaying the [EmojiEditor].
  ///
  /// Otherwise, it falls back to
  /// [ProImageEditorConfigs.editorBoxConstraintsBuilder].
  final EditorBoxConstraintsBuilder? editorBoxConstraintsBuilder;

  /// Creates a copy of this `EmojiEditorTheme` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [EmojiEditorTheme] with some properties updated while keeping the
  /// others unchanged.
  EmojiEditorTheme copyWith({
    SkinToneConfig? skinToneConfig,
    BottomActionBarConfig? bottomActionBarConfig,
    SearchViewConfig? searchViewConfig,
    CategoryViewConfig? categoryViewConfig,
    EmojiViewConfig? emojiViewConfig,
    TextStyle? textStyle,
    bool? swapCategoryAndBottomBar,
    bool? showDragHandle,
    ThemeDraggableSheet? themeDraggableSheet,
    EdgeInsets? categoryTitlePadding,
    TextStyle? categoryTitleStyle,
    Color? backgroundColor,
    Duration? scrollToDuration,
    EditorBoxConstraintsBuilder? editorBoxConstraintsBuilder,
  }) {
    return EmojiEditorTheme(
      skinToneConfig: skinToneConfig ?? this.skinToneConfig,
      bottomActionBarConfig:
          bottomActionBarConfig ?? this.bottomActionBarConfig,
      searchViewConfig: searchViewConfig ?? this.searchViewConfig,
      categoryViewConfig: categoryViewConfig ?? this.categoryViewConfig,
      emojiViewConfig: emojiViewConfig ?? this.emojiViewConfig,
      textStyle: textStyle ?? this.textStyle,
      swapCategoryAndBottomBar:
          swapCategoryAndBottomBar ?? this.swapCategoryAndBottomBar,
      showDragHandle: showDragHandle ?? this.showDragHandle,
      themeDraggableSheet: themeDraggableSheet ?? this.themeDraggableSheet,
      categoryTitlePadding: categoryTitlePadding ?? this.categoryTitlePadding,
      categoryTitleStyle: categoryTitleStyle ?? this.categoryTitleStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      scrollToDuration: scrollToDuration ?? this.scrollToDuration,
      editorBoxConstraintsBuilder:
          editorBoxConstraintsBuilder ?? this.editorBoxConstraintsBuilder,
    );
  }
}
