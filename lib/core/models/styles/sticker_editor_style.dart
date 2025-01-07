// Dart imports:
import 'dart:ui';

// Project imports:
import 'draggable_sheet_style.dart';
import 'types/style_types.dart';

/// The `StickerEditorStyle` class defines the style for the sticker editor in
/// the image editor.
/// It includes properties such as colors for the background, category
/// indicator, category icons, and more.
///
/// Usage:
///
/// ```dart
/// StickerEditorStyle StickerEditorStyle = StickerEditorStyle(
/// );
/// ```
///
/// Properties:
///
/// Example Usage:
///
/// ```dart
/// StickerEditorStyle StickerEditorStyle = StickerEditorStyle(
/// );
///
/// ```
class StickerEditorStyle {
  /// Creates an instance of the `StickerEditorStyle` class with the specified
  /// style properties.
  const StickerEditorStyle({
    this.showDragHandle = true,
    this.draggableSheetStyle = const DraggableSheetStyle(),
    this.bottomSheetBackgroundColor = const Color(0xFFFFFFFF),
    this.editorBoxConstraintsBuilder,
  });

  /// Specifies whether a drag handle is shown on the bottomSheet.
  final bool showDragHandle;

  /// The background color of the bottom sheet.
  final Color bottomSheetBackgroundColor;

  /// Configuration settings for a draggable bottom sheet component.
  final DraggableSheetStyle draggableSheetStyle;

  /// Use this to build custom [BoxConstraints] that will be applied to
  /// the modal bottom sheet displaying the [StickerEditor].
  ///
  /// Otherwise, it falls back to
  /// [ProImageEditorConfigs.editorBoxConstraintsBuilder].
  final EditorBoxConstraintsBuilder? editorBoxConstraintsBuilder;

  /// Creates a copy of this `StickerEditorStyle` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [StickerEditorStyle] with some properties updated while keeping the
  /// others unchanged.
  StickerEditorStyle copyWith({
    bool? showDragHandle,
    Color? bottomSheetBackgroundColor,
    DraggableSheetStyle? draggableSheetStyle,
    EditorBoxConstraintsBuilder? editorBoxConstraintsBuilder,
  }) {
    return StickerEditorStyle(
      showDragHandle: showDragHandle ?? this.showDragHandle,
      bottomSheetBackgroundColor:
          bottomSheetBackgroundColor ?? this.bottomSheetBackgroundColor,
      draggableSheetStyle: draggableSheetStyle ?? this.draggableSheetStyle,
      editorBoxConstraintsBuilder:
          editorBoxConstraintsBuilder ?? this.editorBoxConstraintsBuilder,
    );
  }
}
