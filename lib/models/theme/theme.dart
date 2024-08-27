// Flutter imports:
import 'package:flutter/services.dart';
// Project imports:
import 'package:pro_image_editor/models/theme/theme_sticker_editor.dart';

import 'theme_adaptive_dialog.dart';
import 'theme_blur_editor.dart';
import 'theme_crop_rotate_editor.dart';
import 'theme_emoji_editor.dart';
import 'theme_filter_editor.dart';
import 'theme_helper_lines.dart';
import 'theme_layer_interaction.dart';
import 'theme_loading_dialog.dart';
import 'theme_painting_editor.dart';
import 'theme_shared_values.dart';
import 'theme_sub_editor_page.dart';
import 'theme_text_editor.dart';
import 'types/theme_types.dart';

export 'theme_adaptive_dialog.dart';
export 'theme_blur_editor.dart';
export 'theme_crop_rotate_editor.dart';
export 'theme_emoji_editor.dart';
export 'theme_filter_editor.dart';
export 'theme_helper_lines.dart';
export 'theme_layer_interaction.dart';
export 'theme_loading_dialog.dart';
export 'theme_painting_editor.dart';
export 'theme_shared_values.dart';
export 'theme_sticker_editor.dart';
export 'theme_sub_editor_page.dart';
export 'theme_text_editor.dart';

/// The `ImageEditorTheme` class defines the overall theme for the image editor
/// in your Flutter application. It includes themes for various editor
/// components such as helper lines, painting editor, text editor, crop &
/// rotate editor, filter editor, emoji editor, and more.
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
///   blurEditor: BlurEditorTheme(),
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
/// - `blurEditor`: Theme for the blur editor.
///
/// - `emojiEditor`: Theme for the emoji editor.
///
/// - `stickerEditor`: Theme for the sticker editor.
///
/// - `background`: Background color for the image editor.
///
/// - `loadingDialogTextColor`: Text color for loading dialogs.
///
/// - `uiOverlayStyle`: Defines the system UI overlay style for the image
///   editor.
///
/// - `loadingDialogTheme`: Theme for the loading dialog.
///
/// - `adaptiveDialogTheme`: Theme for the adaptive dialog.
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
/// Please refer to the documentation of individual theme classes for more
/// details.
class ImageEditorTheme {
  /// Creates an instance of the `ImageEditorTheme` class with the specified
  /// theme properties.
  const ImageEditorTheme({
    this.editorBoxConstraintsBuilder,
    this.outsideCaptureAreaLayerOpacity = 0.5,
    this.layerInteraction = const ThemeLayerInteraction(),
    this.helperLine = const HelperLineTheme(),
    this.paintingEditor = const PaintingEditorTheme(),
    this.textEditor = const TextEditorTheme(),
    this.cropRotateEditor = const CropRotateEditorTheme(),
    this.filterEditor = const FilterEditorTheme(),
    this.blurEditor = const BlurEditorTheme(),
    this.emojiEditor = const EmojiEditorTheme(),
    this.stickerEditor = const StickerEditorTheme(),
    this.loadingDialogTheme = const LoadingDialogTheme(),
    this.adaptiveDialogTheme = const AdaptiveDialogTheme(),
    this.subEditorPage = const SubEditorPageTheme(),
    this.background = imageEditorBackgroundColor,
    this.bottomBarBackgroundColor = const Color(0xFF000000),
    this.appBarForegroundColor = const Color(0xFFFFFFFF),
    this.appBarBackgroundColor = const Color(0xFF000000),
    this.uiOverlayStyle = const SystemUiOverlayStyle(
      statusBarColor: Color(0x42000000),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF000000),
    ),
  });

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

  /// Theme for the blur editor.
  final BlurEditorTheme blurEditor;

  /// Theme for the emoji editor.
  final EmojiEditorTheme emojiEditor;

  /// Theme for the sticker editor.
  final StickerEditorTheme stickerEditor;

  /// If this opacity is greater than 0, it will paint a transparent overlay
  /// over all layers that are drawn outside the background image area. The
  /// overlay will have the specified opacity level.
  ///
  /// Note: This opacity only takes effect if the
  /// `captureOnlyBackgroundImageArea` flag in the generation configuration is
  /// set to `true`.
  final double outsideCaptureAreaLayerOpacity;

  /// The theme configuration for the sub-editor page.
  final SubEditorPageTheme subEditorPage;

  /// Background color for the image editor in the overview.
  final Color background;

  /// Background color for the BottomBar in the overview.
  final Color bottomBarBackgroundColor;

  /// Background color for the AppBar in the overview.
  final Color appBarBackgroundColor;

  /// Background color for the AppBar in the overview.
  final Color appBarForegroundColor;

  /// Theme for the loading dialog.
  final LoadingDialogTheme loadingDialogTheme;

  /// Theme for the adaptive dialog.
  final AdaptiveDialogTheme adaptiveDialogTheme;

  /// Defines the system UI overlay style for the image editor.
  final SystemUiOverlayStyle uiOverlayStyle;

  /// Theme for the layer interaction settings.
  final ThemeLayerInteraction layerInteraction;

  /// Use this to build custom [BoxConstraints] that will be applied
  /// globally to the modal bottom sheet when opening various editors
  /// from this library.
  final EditorBoxConstraintsBuilder? editorBoxConstraintsBuilder;

  /// Creates a copy of this `ImageEditorTheme` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [ImageEditorTheme] with some properties updated while keeping the
  /// others unchanged.
  ImageEditorTheme copyWith({
    HelperLineTheme? helperLine,
    PaintingEditorTheme? paintingEditor,
    TextEditorTheme? textEditor,
    CropRotateEditorTheme? cropRotateEditor,
    FilterEditorTheme? filterEditor,
    BlurEditorTheme? blurEditor,
    EmojiEditorTheme? emojiEditor,
    StickerEditorTheme? stickerEditor,
    double? outsideCaptureAreaLayerOpacity,
    SubEditorPageTheme? subEditorPage,
    Color? background,
    Color? bottomBarBackgroundColor,
    Color? appBarBackgroundColor,
    Color? appBarForegroundColor,
    LoadingDialogTheme? loadingDialogTheme,
    AdaptiveDialogTheme? adaptiveDialogTheme,
    SystemUiOverlayStyle? uiOverlayStyle,
    ThemeLayerInteraction? layerInteraction,
    EditorBoxConstraintsBuilder? editorBoxConstraintsBuilder,
  }) {
    return ImageEditorTheme(
      helperLine: helperLine ?? this.helperLine,
      paintingEditor: paintingEditor ?? this.paintingEditor,
      textEditor: textEditor ?? this.textEditor,
      cropRotateEditor: cropRotateEditor ?? this.cropRotateEditor,
      filterEditor: filterEditor ?? this.filterEditor,
      blurEditor: blurEditor ?? this.blurEditor,
      emojiEditor: emojiEditor ?? this.emojiEditor,
      stickerEditor: stickerEditor ?? this.stickerEditor,
      outsideCaptureAreaLayerOpacity:
          outsideCaptureAreaLayerOpacity ?? this.outsideCaptureAreaLayerOpacity,
      subEditorPage: subEditorPage ?? this.subEditorPage,
      background: background ?? this.background,
      bottomBarBackgroundColor:
          bottomBarBackgroundColor ?? this.bottomBarBackgroundColor,
      appBarBackgroundColor:
          appBarBackgroundColor ?? this.appBarBackgroundColor,
      appBarForegroundColor:
          appBarForegroundColor ?? this.appBarForegroundColor,
      loadingDialogTheme: loadingDialogTheme ?? this.loadingDialogTheme,
      adaptiveDialogTheme: adaptiveDialogTheme ?? this.adaptiveDialogTheme,
      uiOverlayStyle: uiOverlayStyle ?? this.uiOverlayStyle,
      layerInteraction: layerInteraction ?? this.layerInteraction,
      editorBoxConstraintsBuilder:
          editorBoxConstraintsBuilder ?? this.editorBoxConstraintsBuilder,
    );
  }
}
