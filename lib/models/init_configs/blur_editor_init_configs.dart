// Project imports:
import 'editor_init_configs.dart';

/// Configuration class for initializing the blur editor.
///
/// This class extends [EditorInitConfigs] and adds parameters for the image
/// size and whether to return the image as a Uint8List when closing the editor.
class BlurEditorInitConfigs extends EditorInitConfigs {
  /// Creates a new instance of [BlurEditorInitConfigs].
  ///
  /// The [theme] parameter specifies the theme data for the editor.
  /// The [imageSize] parameter specifies the size of the image.
  /// The [convertToUint8List] parameter determines whether to return the image
  /// as a Uint8List when closing the editor.
  /// The other parameters are inherited from [EditorInitConfigs].
  const BlurEditorInitConfigs({
    super.configs,
    super.transformConfigs,
    super.layers,
    super.callbacks,
    super.mainImageSize,
    super.mainBodySize,
    super.appliedFilters,
    super.appliedBlurFactor,
    super.onCloseEditor,
    super.onImageEditingComplete,
    super.onImageEditingStarted,
    super.convertToUint8List,
    required super.theme,
  });
}
