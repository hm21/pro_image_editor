// Project imports:
import 'editor_init_configs.dart';

/// Configuration class for initializing the filter editor.
///
/// This class extends [EditorInitConfigs] and adds a parameter to determine
/// whether to return the image as a Uint8List when closing the editor.
class FilterEditorInitConfigs extends EditorInitConfigs {
  /// Creates a new instance of [FilterEditorInitConfigs].
  ///
  /// The [theme] parameter specifies the theme data for the editor.
  /// The [convertToUint8List] parameter determines whether to return the image
  /// as a Uint8List when closing the editor.
  /// The other parameters are inherited from [EditorInitConfigs].
  const FilterEditorInitConfigs({
    super.transformConfigs,
    super.configs,
    super.callbacks,
    super.mainImageSize,
    super.mainBodySize,
    super.layers,
    super.appliedFilters,
    super.appliedTuneAdjustments,
    super.appliedBlurFactor,
    super.onCloseEditor,
    super.onImageEditingComplete,
    super.onImageEditingStarted,
    super.convertToUint8List,
    required super.theme,
  });
}
