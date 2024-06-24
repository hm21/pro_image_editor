/// Configuration options for a main editor.
class MainEditorConfigs {
  /// Indicates whether the editor supports zoom functionality.
  ///
  /// When set to `true`, the editor allows users to zoom in and out, providing
  /// enhanced accessibility and usability, especially on smaller screens or for
  /// users with visual impairments. If set to `false`, the zoom functionality
  /// is disabled, and the editor's content remains at a fixed scale.
  ///
  /// Default value is `false`.
  final bool editorIsZoomable;

  /// The minimum scale factor for the editor.
  ///
  /// This value determines the lowest level of zoom that can be applied to the
  /// editor content. It only has an effect when [editorIsZoomable] is set to `true`.
  /// If [editorIsZoomable] is `false`, this value is ignored.
  ///
  /// Default value is 1.0.
  final double editorMinScale;

  /// The maximum scale factor for the editor.
  ///
  /// This value determines the highest level of zoom that can be applied to the
  /// editor content. It only has an effect when [editorIsZoomable] is set to `true`.
  /// If [editorIsZoomable] is `false`, this value is ignored.
  ///
  /// Default value is 5.0.
  final double editorMaxScale;

  /// Creates an instance of MainEditorConfigs with optional settings.
  const MainEditorConfigs({
    this.editorIsZoomable = false,
    this.editorMinScale = 1.0,
    this.editorMaxScale = 5.0,
  });
}
