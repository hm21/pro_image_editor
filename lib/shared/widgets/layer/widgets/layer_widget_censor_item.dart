import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '/core/models/editor_configs/paint_editor/censor_configs.dart';
import '/core/models/layers/paint_layer.dart';
import '/features/paint_editor/enums/paint_editor_enum.dart';
import '/shared/widgets/censor/blur_area_item.dart';
import '/shared/widgets/censor/pixelate_area_item.dart';

/// A widget representing a censor layer in the sticker editor.
///
/// This widget applies a pixelation or blur effect based on the paint mode.
class LayerWidgetCensorItem extends StatelessWidget {
  /// Creates a [LayerWidgetCensorItem] with the given censor configurations
  /// and paint layer.
  const LayerWidgetCensorItem({
    super.key,
    required this.censorConfigs,
    required this.layer,
  });

  /// The configuration settings for the censor effect.
  final CensorConfigs censorConfigs;

  /// The paint layer that determines the censor effect.
  final PaintLayer layer;

  @override
  Widget build(BuildContext context) {
    switch (layer.item.mode) {
      case PaintMode.pixelate:
        return PixelateAreaItem(
          censorConfigs: censorConfigs,
          size: layer.size,
        );
      case PaintMode.blur:
        return BlurAreaItem(
          censorConfigs: censorConfigs,
          size: layer.size,
        );
      default:
        throw UnimplementedError();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    layer.debugFillProperties(properties);
  }
}
