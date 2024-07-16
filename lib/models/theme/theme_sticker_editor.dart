// Dart imports:
import 'dart:ui';

// Project imports:
import 'theme_dragable_sheet.dart';
import 'types/theme_types.dart';

/// The `StickerEditorTheme` class defines the theme for the sticker editor in the image editor.
/// It includes properties such as colors for the background, category indicator, category icons, and more.
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
  /// Specifies whether a drag handle is shown on the bottomSheet.
  final bool showDragHandle;

  /// The background color of the bottom sheet.
  final Color bottomSheetBackgroundColor;

  final ThemeDraggableSheet themeDraggableSheet;

  /// Use this to build custom [BoxConstraints] that will be applied to
  /// the modal bottom sheet displaying the [StickerEditor].
  ///
  /// Otherwise, it falls back to
  /// [ProImageEditorConfigs.editorBoxConstraintsBuilder].
  final EditorBoxConstraintsBuilder? editorBoxConstraintsBuilder;

  /// Creates an instance of the `StickerEditorTheme` class with the specified theme properties.
  const StickerEditorTheme({
    this.showDragHandle = true,
    this.themeDraggableSheet = const ThemeDraggableSheet(),
    this.bottomSheetBackgroundColor = const Color(0xFFFFFFFF),
    this.editorBoxConstraintsBuilder,
  });
}
