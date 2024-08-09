/// Configuration options for a main editor.
class MainEditorConfigs {
  /// Creates an instance of MainEditorConfigs with optional settings.
  const MainEditorConfigs({
    this.enableZoom = false,
    this.editorIsZoomable,
    this.editorMinScale = 1.0,
    this.editorMaxScale = 5.0,
  });

  /// {@template enableZoom}
  /// Indicates whether the editor supports zoom functionality.
  ///
  /// When set to `true`, the editor allows users to zoom in and out, providing
  /// enhanced accessibility and usability, especially on smaller screens or for
  /// users with visual impairments. If set to `false`, the zoom functionality
  /// is disabled, and the editor's content remains at a fixed scale.
  ///
  /// Default value is `false`.
  /// {@endtemplate}
  final bool enableZoom;

  /// {@macro enableZoom}
  ///
  /// **Deprecated**: Use [enableZoom] instead.
  @Deprecated('Use enableZoom instead')
  final bool? editorIsZoomable;

  /// The minimum scale factor for the editor.
  ///
  /// This value determines the lowest level of zoom that can be applied to the
  /// editor content. It only has an effect when [enableZoom] is set to
  /// `true`.
  /// If [enableZoom] is `false`, this value is ignored.
  ///
  /// Default value is 1.0.
  final double editorMinScale;

  /// The maximum scale factor for the editor.
  ///
  /// This value determines the highest level of zoom that can be applied to the
  /// editor content. It only has an effect when [enableZoom] is set to
  /// `true`.
  /// If [enableZoom] is `false`, this value is ignored.
  ///
  /// Default value is 5.0.
  final double editorMaxScale;
}
