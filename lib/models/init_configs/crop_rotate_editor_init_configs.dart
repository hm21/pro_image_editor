import 'package:flutter/material.dart';

import 'editor_init_configs.dart';

class CropRotateEditorInitConfigs extends EditorInitConfigs {
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
  });
}
