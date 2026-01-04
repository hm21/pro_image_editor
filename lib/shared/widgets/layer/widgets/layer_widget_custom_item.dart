import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '/core/models/editor_configs/sticker_editor_configs.dart';
import '/core/models/layers/widget_layer.dart';

/// A custom widget item representing a layer in the sticker editor.
class LayerWidgetCustomItem extends StatelessWidget {
  /// Creates a [LayerWidgetCustomItem] with the given layer and editor
  /// configurations.
  const LayerWidgetCustomItem({
    super.key,
    required this.layer,
    required this.stickerEditorConfigs,
  });

  /// The widget layer that this item represents.
  final WidgetLayer layer;

  /// Configuration settings for the sticker editor.
  final StickerEditorConfigs stickerEditorConfigs;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (layer.width ?? stickerEditorConfigs.initWidth) * layer.scale,
      child: FittedBox(
        fit: BoxFit.contain,
        child: layer.widget,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    layer.debugFillProperties(properties);
  }
}
