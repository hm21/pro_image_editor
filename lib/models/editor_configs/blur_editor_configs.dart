/// Configuration options for a blur editor.
///
/// `BlurEditorConfigs` allows you to define settings for a blur editor,
/// including whether the editor is enabled and a list of blur generators.
///
/// Example usage:
/// ```dart
/// BlurEditorConfigs(
///   enabled: true,
///   maxBlur: 2.0,
/// );
/// ```
class BlurEditorConfigs {
  /// Indicates whether the blur editor is enabled.
  final bool enabled;

  /// Show also layers in the editor.
  final bool showLayers;

  /// Maximum blur value.
  final double maxBlur;

  /// Creates an instance of BlurEditorConfigs with optional settings.
  ///
  /// By default, the editor is enabled, and max blur is 2.0.
  const BlurEditorConfigs({
    this.enabled = true,
    this.showLayers = true,
    this.maxBlur = 2.0,
  });
}
