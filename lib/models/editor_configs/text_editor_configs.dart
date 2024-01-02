import 'package:flutter/widgets.dart';

import '../../widgets/layer_widget.dart';

/// Configuration options for a text editor.
///
/// `TextEditorConfigs` allows you to define settings for a text editor,
/// including whether the editor is enabled, which text formatting options
/// are available, and the initial font size.
///
/// Example usage:
/// ```dart
/// TextEditorConfigs(
///   enabled: true,
///   canToggleTextAlign: true,
///   canToggleBackgroundMode: true,
///   initFontSize: 24.0,
/// );
/// ```
class TextEditorConfigs {
  /// Indicates whether the text editor is enabled.
  final bool enabled;

  /// Determines if the text alignment options can be toggled.
  final bool canToggleTextAlign;

  /// Determines if the background mode can be toggled.
  final bool canToggleBackgroundMode;

  /// The initial font size for text.
  final double initFontSize;

  /// The initial text alignment for the layer.
  final TextAlign initialTextAlign;

  /// The initial background color mode for the layer.
  final LayerBackgroundColorModeE initialBackgroundColorMode;

  /// Creates an instance of TextEditorConfigs with optional settings.
  ///
  /// By default, the text editor is enabled, and most text formatting options
  /// are enabled. The initial font size is set to 24.0.
  const TextEditorConfigs({
    this.enabled = true,
    this.canToggleTextAlign = true,
    this.canToggleBackgroundMode = true,
    this.initFontSize = 24.0,
    this.initialTextAlign = TextAlign.center,
    this.initialBackgroundColorMode = LayerBackgroundColorModeE.backgroundAndColor,
  });
}
