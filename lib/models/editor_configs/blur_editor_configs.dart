import 'utils/editor_safe_area.dart';

/// Configuration options for a blur editor.
///
/// `BlurEditorConfigs` allows you to define settings for a blur editor,
/// including whether the editor is enabled and a list of blur generators.
///
/// Example usage:
/// ```dart
/// BlurEditorConfigs(
///   enabled: true,
///   maxBlur: 5.0,
/// );
/// ```
class BlurEditorConfigs {
  /// Creates an instance of BlurEditorConfigs with optional settings.
  ///
  /// By default, the editor is enabled, and max blur is 5.0.
  const BlurEditorConfigs({
    this.enabled = true,
    this.showLayers = true,
    this.maxBlur = 5.0,
    this.safeArea = const EditorSafeArea(),
  }) : assert(maxBlur > 0, 'maxBlur must be positive');

  /// Indicates whether the blur editor is enabled.
  final bool enabled;

  /// Show also layers in the editor.
  final bool showLayers;

  /// Maximum blur value.
  final double maxBlur;

  /// Defines the safe area configuration for the editor.
  final EditorSafeArea safeArea;

  /// Creates a copy of this `BlurEditorConfigs` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [BlurEditorConfigs] with some properties updated while keeping the
  /// others unchanged.
  BlurEditorConfigs copyWith({
    bool? enabled,
    bool? showLayers,
    double? maxBlur,
    EditorSafeArea? safeArea,
  }) {
    return BlurEditorConfigs(
      safeArea: safeArea ?? this.safeArea,
      enabled: enabled ?? this.enabled,
      showLayers: showLayers ?? this.showLayers,
      maxBlur: maxBlur ?? this.maxBlur,
    );
  }
}
