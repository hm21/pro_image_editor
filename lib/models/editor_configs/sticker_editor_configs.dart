import 'package:flutter/widgets.dart';

import '../../pro_image_editor.dart';

/// Configuration options for a sticker editor.
///
/// `StickerEditorConfigs` allows you to define various settings for a sticker
/// editor. You can configure features like enabling/disabling the editor,
/// initial sticker width, and a custom method to build stickers.
///
/// Example usage:
/// ```dart
/// StickerEditorConfigs(
///   enabled: false,
///   initWidth: 150,
///   buildStickers: (setLayer) {
///     return Container(); // Replace with your builder to load and display stickers.
///   },
/// );
/// ```
class StickerEditorConfigs {
  /// Indicates whether the sticker editor is enabled.
  ///
  /// When set to `true`, the sticker editor is active and users can interact with it.
  /// If `false`, the editor is disabled and does not respond to user inputs.
  final bool enabled;

  /// The initial width of the stickers in the editor.
  ///
  /// Specifies the starting width of the stickers when they are first placed
  /// in the editor. This value is in logical pixels.
  final double initWidth;

  /// A callback that builds the stickers.
  ///
  /// This typedef is a function that takes a function as a parameter and
  /// returns a Widget. The function parameter `setLayer` is used to set a
  /// layer in the editor. This callback allows for customizing the appearance
  /// and behavior of stickers in the editor.
  final BuildStickers buildStickers;

  /// A callback triggered each time the search value changes.
  ///
  /// This callback is activated exclusively when the editor mode is set to 'WhatsApp'.
  final Function(String value)? onSearchChanged;

  /// Use this to build custom [BoxConstraints] that will be applied to
  /// the modal bottom sheet displaying the [StickerEditor].
  ///
  /// Otherwise, it falls back to
  /// [ProImageEditorConfigs.editorBoxConstraintsBuilder].
  final EditorBoxConstraintsBuilder? editorBoxConstraintsBuilder;

  /// Use this to build custom [BoxConstraints] that will be applied to
  /// the modal bottom sheet displaying the [WhatsAppStickerPage].
  ///
  /// Otherwise, it falls back to either [editorBoxConstraintsBuilder] or
  /// [ProImageEditorConfigs.editorBoxConstraintsBuilder] in that order.
  final EditorBoxConstraintsBuilder? whatsAppEditorBoxConstraintsBuilder;

  /// Creates an instance of StickerEditorConfigs with optional settings.
  ///
  /// By default, the editor is disabled (if not specified), and other properties
  /// are set to reasonable defaults.
  const StickerEditorConfigs({
    required this.buildStickers,
    this.onSearchChanged,
    this.initWidth = 100,
    this.enabled = false,
    this.editorBoxConstraintsBuilder,
    this.whatsAppEditorBoxConstraintsBuilder,
  });
}

typedef BuildStickers = Widget Function(Function(Widget) setLayer);
