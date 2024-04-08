import 'package:flutter/material.dart';

import '../models/editor_configs/pro_image_editor_configs.dart';
import '../models/layer.dart';
import '../widgets/layer_widget.dart';

class LayerStack extends StatefulWidget {
  final ProImageEditorConfigs configs;
  final List<Layer> layers;

  final EdgeInsets? paddingHelper;

  const LayerStack({
    super.key,
    required this.configs,
    required this.layers,
    this.paddingHelper,
  });

  @override
  State<LayerStack> createState() => _LayerStackState();
}

class _LayerStackState extends State<LayerStack> {
  @override
  Widget build(BuildContext context) {
    // TODO: fix animation bug => layers on main page have full screen size and transform after that down
    return IgnorePointer(
      child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: widget.layers.map((layerItem) {
            return LayerWidget(
              designMode: widget.configs.designMode,
              layerHoverCursor: widget.configs.imageEditorTheme.layerHoverCursor,
              padding: widget.paddingHelper ?? EdgeInsets.zero,
              layerData: layerItem,
              textFontSize: widget.configs.textEditorConfigs.initFontSize,
              emojiTextStyle: widget.configs.emojiEditorConfigs.textStyle,
              stickerInitWidth: widget.configs.stickerEditorConfigs?.initWidth ?? 100,
              onTap: (layerData) async {},
              onTapUp: () {},
              onTapDown: () {},
              onRemoveTap: () {},
              i18n: widget.configs.i18n,
              enableHitDetection: false,
              freeStyleHighPerformanceScaling: false,
              freeStyleHighPerformanceMoving: false,
            );
          }).toList()),
    );
  }
}
