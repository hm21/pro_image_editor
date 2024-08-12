// Project imports:
import 'package:pro_image_editor/models/editor_callbacks/standalone_editor_callbacks.dart';
import 'package:pro_image_editor/models/layer/layer.dart';
import 'package:pro_image_editor/modules/main_editor/main_editor.dart';

/// A class representing callbacks for the sticker editor.
class StickerEditorCallbacks extends StandaloneEditorCallbacks {
  /// Creates a new instance of [StickerEditorCallbacks].
  const StickerEditorCallbacks({
    this.onSearchChanged,
    this.onTapEditSticker,
    super.onInit,
    super.onAfterViewInit,
  });

  /// A callback function that is triggered when a sticker is tapped for
  /// editing.
  ///
  /// This function is called with the current editor state, the sticker data,
  /// and the index of the sticker within the list of layers. It allows the
  /// implementation to define custom behavior when a user taps on a sticker
  /// to initiate editing, such as opening a sticker editing interface or
  /// displaying additional options.
  ///
  /// The callback is optional and can be set to `null` if no action is
  /// required when a sticker is tapped.
  ///
  /// Parameters:
  /// - [editorState]: The current state of the image editor, providing access
  ///   to relevant editor properties and methods for modifying the editing
  ///   environment.
  /// - [sticker]: The `StickerLayerData` instance representing the sticker
  ///   that was tapped. This includes the sticker's properties such as its
  ///   widget, position, rotation, scale, and more.
  /// - [index]: The index of the sticker in the list of active layers, which
  ///   can be used to identify and manipulate the specific sticker layer.
  ///
  /// Example usage:
  /// ```dart
  /// onTapEditSticker: (editorState, sticker, index) {
  ///   // Implement custom editing logic here
  ///   state.replaceLayer(
  ///     index: index,
  ///     layer: sticker.copyWith(
  ///       sticker: Sticker(
  ///         index: newIndex,
  ///       ),
  ///     ),
  ///   );
  /// },
  /// ```
  final Function(
    ProImageEditorState editorState,
    StickerLayerData sticker,
    int index,
  )? onTapEditSticker;

  /// A callback triggered each time the search value changes.
  ///
  /// This callback is activated exclusively when the editor mode is set to
  /// 'WhatsApp'.
  final Function(String value)? onSearchChanged;
}
