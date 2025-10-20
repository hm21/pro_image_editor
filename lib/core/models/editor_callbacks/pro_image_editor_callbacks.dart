import '../../enums/editor_mode.dart';
import 'audio_editor_callbacks.dart';
import 'blur_editor_callbacks.dart';
import 'clips_editor_callbacks.dart';
import 'crop_rotate_editor_callbacks.dart';
import 'editor_callbacks_typedef.dart';
import 'emoji_editor_callbacks.dart';
import 'filter_editor_callbacks.dart';
import 'main_editor/main_editor_callbacks.dart';
import 'paint_editor_callbacks.dart';
import 'sticker_editor_callbacks.dart';
import 'text_editor_callbacks.dart';
import 'tune_editor_callbacks.dart';
import 'video_editor_callbacks.dart';

export '../../enums/sub_editors_name.dart';
export 'audio_editor_callbacks.dart';
export 'blur_editor_callbacks.dart';
export 'clips_editor_callbacks.dart';
export 'crop_rotate_editor_callbacks.dart';
export 'editor_callbacks_typedef.dart';
export 'emoji_editor_callbacks.dart';
export 'filter_editor_callbacks.dart';
export 'main_editor/main_editor_callbacks.dart';
export 'paint_editor_callbacks.dart';
export 'sticker_editor_callbacks.dart';
export 'text_editor_callbacks.dart';
export 'tune_editor_callbacks.dart';
export 'video_editor_callbacks.dart';

/// A class representing callbacks for the Image Editor.
class ProImageEditorCallbacks {
  /// Creates a new instance of [ProImageEditorCallbacks].
  const ProImageEditorCallbacks({
    this.onImageEditingComplete,
    this.onCompleteWithParameters,
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
    this.tuneEditorCallbacks,
    this.videoEditorCallbacks,
    this.audioEditorCallbacks,
    this.clipsEditorCallbacks,
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
  /// <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/schema_capture_image.jpeg?raw=true" alt="Schema" height="500px"/>
  final ImageEditingCompleteCallback? onImageEditingComplete;

  /// A callback that runs when export completes with full parameters.
  ///
  /// Provides access to all transformation, filter, and timing values used
  /// during the export process.
  ///
  /// The order in which the changes are applied is as follows:
  /// 1. Rotate
  /// 2. Flip
  /// 3. Crop
  /// 4. Scale
  /// 5. Offset
  final CompleteWidthParametersCallback? onCompleteWithParameters;

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
  /// <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/schema_capture_image.jpeg?raw=true" alt="Schema" height="500px" />
  final Function(EditorMode editorMode)? onCloseEditor;

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

  /// Callbacks from the tune editor.
  final TuneEditorCallbacks? tuneEditorCallbacks;

  /// Callbacks from the video editor.
  final VideoEditorCallbacks? videoEditorCallbacks;

  /// Callbacks from the audio editor.
  final AudioEditorCallbacks? audioEditorCallbacks;

  /// Callbacks from the clips editor.
  final ClipsEditorCallbacks? clipsEditorCallbacks;

  /// Creates a copy with modified editor callbacks.
  ProImageEditorCallbacks copyWith({
    Function()? onImageEditingStarted,
    ImageEditingCompleteCallback? onImageEditingComplete,
    CompleteWidthParametersCallback? onCompleteWithParameters,
    ThumbnailGeneratedCallback? onThumbnailGenerated,
    Function(EditorMode editorMode)? onCloseEditor,
    MainEditorCallbacks? mainEditorCallbacks,
    PaintEditorCallbacks? paintEditorCallbacks,
    TextEditorCallbacks? textEditorCallbacks,
    CropRotateEditorCallbacks? cropRotateEditorCallbacks,
    FilterEditorCallbacks? filterEditorCallbacks,
    BlurEditorCallbacks? blurEditorCallbacks,
    EmojiEditorCallbacks? emojiEditorCallbacks,
    StickerEditorCallbacks? stickerEditorCallbacks,
    TuneEditorCallbacks? tuneEditorCallbacks,
    VideoEditorCallbacks? videoEditorCallbacks,
    AudioEditorCallbacks? audioEditorCallbacks,
    ClipsEditorCallbacks? clipsEditorCallbacks,
  }) {
    return ProImageEditorCallbacks(
      onImageEditingStarted:
          onImageEditingStarted ?? this.onImageEditingStarted,
      onImageEditingComplete:
          onImageEditingComplete ?? this.onImageEditingComplete,
      onCompleteWithParameters:
          onCompleteWithParameters ?? this.onCompleteWithParameters,
      onThumbnailGenerated: onThumbnailGenerated ?? this.onThumbnailGenerated,
      onCloseEditor: onCloseEditor ?? this.onCloseEditor,
      mainEditorCallbacks: mainEditorCallbacks ?? this.mainEditorCallbacks,
      paintEditorCallbacks: paintEditorCallbacks ?? this.paintEditorCallbacks,
      textEditorCallbacks: textEditorCallbacks ?? this.textEditorCallbacks,
      cropRotateEditorCallbacks:
          cropRotateEditorCallbacks ?? this.cropRotateEditorCallbacks,
      filterEditorCallbacks:
          filterEditorCallbacks ?? this.filterEditorCallbacks,
      blurEditorCallbacks: blurEditorCallbacks ?? this.blurEditorCallbacks,
      emojiEditorCallbacks: emojiEditorCallbacks ?? this.emojiEditorCallbacks,
      stickerEditorCallbacks:
          stickerEditorCallbacks ?? this.stickerEditorCallbacks,
      tuneEditorCallbacks: tuneEditorCallbacks ?? this.tuneEditorCallbacks,
      videoEditorCallbacks: videoEditorCallbacks ?? this.videoEditorCallbacks,
      audioEditorCallbacks: audioEditorCallbacks ?? this.audioEditorCallbacks,
      clipsEditorCallbacks: clipsEditorCallbacks ?? this.clipsEditorCallbacks,
    );
  }
}
