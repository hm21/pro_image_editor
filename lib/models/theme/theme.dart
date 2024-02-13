import 'package:flutter/services.dart';
import 'package:pro_image_editor/models/theme/theme_sticker_editor.dart';

import 'theme_crop_rotate_editor.dart';
import 'theme_emoji_editor.dart';
import 'theme_filter_editor.dart';
import 'theme_helper_lines.dart';
import 'theme_painting_editor.dart';
import 'theme_shared_values.dart';
import 'theme_text_editor.dart';

export 'theme_emoji_editor.dart';
export 'theme_painting_editor.dart';
export 'theme_filter_editor.dart';
export 'theme_text_editor.dart';
export 'theme_crop_rotate_editor.dart';
export 'theme_helper_lines.dart';
export 'theme_sticker_editor.dart';

/// The `ImageEditorTheme` class defines the overall theme for the image editor
/// in your Flutter application. It includes themes for various editor components
/// such as helper lines, painting editor, text editor, crop & rotate editor, filter editor,
/// emoji editor, and more.
///
/// Usage:
///
/// ```dart
/// ImageEditorTheme editorTheme = ImageEditorTheme(
///   helperLine: HelperLineTheme(),
///   paintingEditor: PaintingEditorTheme(),
///   textEditor: TextEditorTheme(),
///   cropRotateEditor: CropRotateEditorTheme(),
///   filterEditor: FilterEditorTheme(),
///   emojiEditor: EmojiEditorTheme(),
///   stickerEditor: StickerEditorTheme(),
/// );
/// ```
///
/// Properties:
///
/// - `helperLine`: Theme for helper lines in the image editor.
///
/// - `paintingEditor`: Theme for the painting editor.
///
/// - `textEditor`: Theme for the text editor.
///
/// - `cropRotateEditor`: Theme for the crop & rotate editor.
///
/// - `filterEditor`: Theme for the filter editor.
///
/// - `emojiEditor`: Theme for the emoji editor.
///
/// - `stickerEditor`: Theme for the sticker editor.
///
/// - `background`: Background color for the image editor.
///
/// - `loadingDialogTextColor`: Text color for loading dialogs.
///
/// - `uiOverlayStyle`: Defines the system UI overlay style for the image editor.
///
/// Example Usage:
///
/// ```dart
/// ImageEditorTheme editorTheme = ImageEditorTheme(
///   background: Colors.black,
///   loadingDialogTextColor: Colors.white,
/// );
///
/// HelperLineTheme helperLineTheme = editorTheme.helperLine;
/// PaintingEditorTheme paintingEditorTheme = editorTheme.paintingEditor;
/// // Access other theme properties...
/// ```
///
/// Please refer to the documentation of individual theme classes for more details.
class ImageEditorTheme {
  /// Theme for helper lines in the image editor.
  final HelperLineTheme helperLine;

  /// Theme for the painting editor.
  final PaintingEditorTheme paintingEditor;

  /// Theme for the text editor.
  final TextEditorTheme textEditor;

  /// Theme for the crop & rotate editor.
  final CropRotateEditorTheme cropRotateEditor;

  /// Theme for the filter editor.
  final FilterEditorTheme filterEditor;

  /// Theme for the emoji editor.
  final EmojiEditorTheme emojiEditor;

  /// Theme for the sticker editor.
  final StickerEditorTheme stickerEditor;

  /// Background color for the image editor.
  final Color background;

  /// Text color for loading dialogs.
  final Color loadingDialogTextColor;

  /// Defines the system UI overlay style for the image editor.
  final SystemUiOverlayStyle uiOverlayStyle;

  /// The cursor style when hovering over a layer.
  final SystemMouseCursor layerHoverCursor;

  /// Creates an instance of the `ImageEditorTheme` class with the specified theme properties.
  const ImageEditorTheme({
    this.layerHoverCursor = SystemMouseCursors.move,
    this.helperLine = const HelperLineTheme(),
    this.paintingEditor = const PaintingEditorTheme(),
    this.textEditor = const TextEditorTheme(),
    this.cropRotateEditor = const CropRotateEditorTheme(),
    this.filterEditor = const FilterEditorTheme(),
    this.emojiEditor = const EmojiEditorTheme(),
    this.stickerEditor = const StickerEditorTheme(),
    this.background = imageEditorBackgroundColor,
    this.loadingDialogTextColor = imageEditorTextColor,
    this.uiOverlayStyle = const SystemUiOverlayStyle(
      statusBarColor: Color(0x42000000),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF000000),
    ),
  });
}
