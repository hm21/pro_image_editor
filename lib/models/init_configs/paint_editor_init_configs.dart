import 'package:flutter/material.dart';

import 'editor_init_configs.dart';

/// Configuration class for initializing the paint editor.
///
/// This class extends [EditorInitConfigs] and adds specific parameters related to painting functionality.
class PaintEditorInitConfigs extends EditorInitConfigs {
  /// The size of the image.
  final Size imageSize;

  /// Additional padding for the editor.
  final EdgeInsets? paddingHelper;

  /// Creates a new instance of [PaintEditorInitConfigs].
  ///
  /// The [theme] parameter specifies the theme data for the editor.
  /// The [imageSize] parameter specifies the size of the image.
  /// The [paddingHelper] parameter specifies additional padding for the editor.
  /// The other parameters are inherited from [EditorInitConfigs].
  const PaintEditorInitConfigs({
    super.configs,
    super.onUpdateUI,
    super.transformConfigs,
    super.layers,
    super.imageSizeWithLayers,
    super.bodySizeWithLayers,
    super.appliedFilters,
    super.appliedBlurFactor,
    required super.theme,
    required this.imageSize,
    this.paddingHelper,
  });
}
