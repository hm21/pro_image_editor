import 'blur_editor_callbacks.dart';
import 'crop_rotate_editor_callbacks.dart';
import 'editor_callbacks_typedef.dart';
import 'emoji_editor_callbacks.dart';
import 'filter_editor_callbacks.dart';
import 'main_editor_callbacks.dart';
import 'paint_editor_callbacks.dart';
import 'sticker_editor_callbacks.dart';
import 'text_editor_callbacks.dart';

export 'blur_editor_callbacks.dart';
export 'crop_rotate_editor_callbacks.dart';
export 'editor_callbacks_typedef.dart';
export 'filter_editor_callbacks.dart';
export 'main_editor_callbacks.dart';
export 'paint_editor_callbacks.dart';
export 'sticker_editor_callbacks.dart';
export 'text_editor_callbacks.dart';
export 'utils/sub_editors_name.dart';

/// A class representing callbacks for the Image Editor.
class ProImageEditorCallbacks {
  /// Creates a new instance of [ProImageEditorCallbacks].
  const ProImageEditorCallbacks({
    this.onImageEditingComplete,
    this.onThumbnailGenerated,
    this.onImageEditingStarted,
    this.onCloseEditor,
    this.mainEditorCallbacks,
    this.paintEditorCallbacks,
    this.textEditorCallbacks,
    this.cropRotateEditorCallbacks,
    this.filterEditorCallbacks,
    this.blurEditorCallbacks,
    this.emojiEditorCallbacks,
    this.stickerEditorCallbacks,
  });

  /// A callback function that is triggered when the image generation is
  /// started.
  final Function()? onImageEditingStarted;

  /// A callback function that will be called when the editing is done,
  /// and it returns the edited image as a `Uint8List` with the format `jpg`.
  ///
  /// The edited image is provided as a Uint8List to the
  /// [onImageEditingComplete] function when the editing is completed.
  ///
  /// <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/schema_callbacks.jpeg?raw=true" alt="Schema" height="500px"/>
  final ImageEditingCompleteCallback? onImageEditingComplete;

  /// A callback function that is called when the editing is complete and the
  /// thumbnail image is generated, along with capturing the original image as
  /// a raw `ui.Image`.
  ///
  /// This callback is particularly useful if you have a high-resolution image
  /// that typically takes a long time to generate. It allows you to display
  /// the thumbnail quickly while the conversion of the original image runs in
  /// the background. When you use this callback, it will disable the
  /// `onImageEditingComplete` callback.
  ///
  /// - [thumbnailBytes]: The bytes of the generated thumbnail image.
  /// - [rawImage]: The raw `ui.Image` object of the original image.
  ///
  /// Example usage:
  /// ```dart
  /// onThumbnailGenerated:
  /// (Uint8List thumbnailBytes, ui.Image rawImage) async {
  ///   // Perform operations with the thumbnail bytes and raw image
  /// };
  /// ```
  final ThumbnailGeneratedCallback? onThumbnailGenerated;

  /// A callback function that will be called before the image editor will
  /// close.
  ///
  /// <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/schema_callbacks.jpeg?raw=true" alt="Schema" height="500px" />
  final ImageEditingEmptyCallback? onCloseEditor;

  /// Callbacks from the main editor.
  final MainEditorCallbacks? mainEditorCallbacks;

  /// Callbacks from the paint editor.
  final PaintEditorCallbacks? paintEditorCallbacks;

  /// Callbacks from the text editor.
  final TextEditorCallbacks? textEditorCallbacks;

  /// Callbacks from the crop-rotate editor.
  final CropRotateEditorCallbacks? cropRotateEditorCallbacks;

  /// Callbacks from the filter editor.
  final FilterEditorCallbacks? filterEditorCallbacks;

  /// Callbacks from the blur editor.
  final BlurEditorCallbacks? blurEditorCallbacks;

  /// Callbacks from the emoji editor.
  final EmojiEditorCallbacks? emojiEditorCallbacks;

  /// Callbacks from the sticker editor.
  final StickerEditorCallbacks? stickerEditorCallbacks;
}
