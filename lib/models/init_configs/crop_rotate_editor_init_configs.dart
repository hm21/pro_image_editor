import 'editor_init_configs.dart';

class CropRotateEditorInitConfigs extends EditorInitConfigs {
  /// Determines whether to return the image as a Uint8List when closing the editor.
  final bool convertToUint8List;

  const CropRotateEditorInitConfigs({
    super.configs,
    super.transformConfigs,
    super.layers,
    super.onUpdateUI,
    super.imageSizeWithLayers,
    super.bodySizeWithLayers,
    required super.imageSize,
    required super.theme,
    this.convertToUint8List = false,
  });
}
