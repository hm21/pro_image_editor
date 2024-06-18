// Project imports:
import 'package:pro_image_editor/models/editor_callbacks/standalone_editor_callbacks.dart';

/// A class representing callbacks for the sticker editor.
class StickerEditorCallbacks extends StandaloneEditorCallbacks {
  /// A callback triggered each time the search value changes.
  ///
  /// This callback is activated exclusively when the editor mode is set to 'WhatsApp'.
  final Function(String value)? onSearchChanged;

  /// Creates a new instance of [StickerEditorCallbacks].
  const StickerEditorCallbacks({
    this.onSearchChanged,
    super.onInit,
    super.onAfterViewInit,
  });
}
