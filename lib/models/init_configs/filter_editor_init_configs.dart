import 'editor_init_configs.dart';

/// Configuration class for initializing the filter editor.
///
/// This class extends [EditorInitConfigs] and adds a parameter to determine whether to return the image as a Uint8List when closing the editor.
class FilterEditorInitConfigs extends EditorInitConfigs {
  /// Determines whether to return the image as a Uint8List when closing the editor.
  final bool convertToUint8List;

  /// Creates a new instance of [FilterEditorInitConfigs].
  ///
  /// The [theme] parameter specifies the theme data for the editor.
  /// The [convertToUint8List] parameter determines whether to return the image as a Uint8List when closing the editor.
  /// The other parameters are inherited from [EditorInitConfigs].
  const FilterEditorInitConfigs({
    super.transformConfigs,
    super.configs,
    super.onUpdateUI,
    super.imageSizeWithLayers,
    super.bodySizeWithLayers,
    super.layers,
    super.appliedFilters,
    super.appliedBlurFactor,
    required super.theme,
    this.convertToUint8List = false,
  });
}
