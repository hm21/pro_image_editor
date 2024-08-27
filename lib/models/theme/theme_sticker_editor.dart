// Dart imports:
import 'dart:ui';

// Project imports:
import 'theme_draggable_sheet.dart';
import 'types/theme_types.dart';

/// The `StickerEditorTheme` class defines the theme for the sticker editor in
/// the image editor.
/// It includes properties such as colors for the background, category
/// indicator, category icons, and more.
///
/// Usage:
///
/// ```dart
/// StickerEditorTheme stickerEditorTheme = StickerEditorTheme(
/// );
/// ```
///
/// Properties:
///
/// Example Usage:
///
/// ```dart
/// StickerEditorTheme stickerEditorTheme = StickerEditorTheme(
/// );
///
/// ```
class StickerEditorTheme {
  /// Creates an instance of the `StickerEditorTheme` class with the specified
  /// theme properties.
  const StickerEditorTheme({
    this.showDragHandle = true,
    this.themeDraggableSheet = const ThemeDraggableSheet(),
    this.bottomSheetBackgroundColor = const Color(0xFFFFFFFF),
    this.editorBoxConstraintsBuilder,
  });

  /// Specifies whether a drag handle is shown on the bottomSheet.
  final bool showDragHandle;

  /// The background color of the bottom sheet.
  final Color bottomSheetBackgroundColor;

  /// Configuration settings for a draggable bottom sheet component.
  final ThemeDraggableSheet themeDraggableSheet;

  /// Use this to build custom [BoxConstraints] that will be applied to
  /// the modal bottom sheet displaying the [StickerEditor].
  ///
  /// Otherwise, it falls back to
  /// [ProImageEditorConfigs.editorBoxConstraintsBuilder].
  final EditorBoxConstraintsBuilder? editorBoxConstraintsBuilder;

  /// Creates a copy of this `StickerEditorTheme` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [StickerEditorTheme] with some properties updated while keeping the
  /// others unchanged.
  StickerEditorTheme copyWith({
    bool? showDragHandle,
    Color? bottomSheetBackgroundColor,
    ThemeDraggableSheet? themeDraggableSheet,
    EditorBoxConstraintsBuilder? editorBoxConstraintsBuilder,
  }) {
    return StickerEditorTheme(
      showDragHandle: showDragHandle ?? this.showDragHandle,
      bottomSheetBackgroundColor:
          bottomSheetBackgroundColor ?? this.bottomSheetBackgroundColor,
      themeDraggableSheet: themeDraggableSheet ?? this.themeDraggableSheet,
      editorBoxConstraintsBuilder:
          editorBoxConstraintsBuilder ?? this.editorBoxConstraintsBuilder,
    );
  }
}
