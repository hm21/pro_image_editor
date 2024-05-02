import 'package:flutter/material.dart';

import 'editor_init_configs.dart';

class CropRotateEditorInitConfigs extends EditorInitConfigs {
  /// Determines whether to return the image as a Uint8List when closing the editor.
  final bool convertToUint8List;

  final Size imageSize;

  const CropRotateEditorInitConfigs({
    super.configs,
    super.transformConfigs,
    super.layers,
    super.onUpdateUI,
    super.imageSizeWithLayers,
    super.bodySizeWithLayers,
    required super.theme,
    required this.imageSize,
    this.convertToUint8List = false,
  });
}
