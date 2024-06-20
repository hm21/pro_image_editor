// Flutter imports:
import 'package:flutter/widgets.dart';

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

  /// The minimum scale factor from the layer.
  final double minScale;

  /// The maximum scale factor from the layer.
  final double maxScale;

  /// Creates an instance of StickerEditorConfigs with optional settings.
  ///
  /// By default, the editor is disabled (if not specified), and other properties
  /// are set to reasonable defaults.
  const StickerEditorConfigs({
    required this.buildStickers,
    this.initWidth = 100,
    this.minScale = double.negativeInfinity,
    this.maxScale = double.infinity,
    this.enabled = false,
  })  : assert(initWidth > 0, 'initWidth must be positive'),
        assert(maxScale >= minScale,
            'maxScale must be greater than or equal to minScale');
}

typedef BuildStickers = Widget Function(
    Function(Widget) setLayer, ScrollController scrollController);
