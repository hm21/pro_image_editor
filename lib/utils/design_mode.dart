/// Enum representing design modes for an image editor.
///
/// The `ImageEditorDesignMode` enum defines two design modes: Material and Cupertino. These design modes determine the visual style and user interface elements used in an image editor.
///
/// - `material`: Represents the Material Design style, which is a modern design language developed by Google. It typically includes bold colors and shadows.
/// - `cupertino`: Represents the Cupertino Design style, which is Apple's design language known for its clean and minimalistic appearance with rounded elements.
///
/// Example Usage:
/// ```dart
/// // Use the Material design mode for the image editor.
/// ImageEditorDesignMode designMode = ImageEditorDesignMode.material;
///
/// // Use the Cupertino design mode for the image editor.
/// ImageEditorDesignMode designMode = ImageEditorDesignMode.cupertino;
/// ```
enum ImageEditorDesignModeE {
  /// Represents the Material Design style.
  material,

  /// Represents the Cupertino Design style.
  cupertino,
}
