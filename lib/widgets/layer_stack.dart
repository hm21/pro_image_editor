// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/editor_configs/pro_image_editor_configs.dart';
import '../models/layer.dart';
import '../models/transform_helper.dart';
import '../widgets/layer_widget.dart';

class LayerStack extends StatefulWidget {
  final ProImageEditorConfigs configs;
  final List<Layer> layers;

  final Clip clipBehavior;

  final TransformHelper transformHelper;

  const LayerStack({
    super.key,
    required this.configs,
    required this.layers,
    this.transformHelper = const TransformHelper(
      editorBodySize: Size.zero,
      mainBodySize: Size.zero,
      mainImageSize: Size.zero,
    ),
    this.clipBehavior = Clip.hardEdge,
  });

  @override
  State<LayerStack> createState() => _LayerStackState();
}

class _LayerStackState extends State<LayerStack> {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Transform.scale(
        scale: widget.transformHelper.scale,
        child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            clipBehavior: widget.clipBehavior,
            children: widget.layers.map((layerItem) {
              return LayerWidget(
                configs: widget.configs,
                editorBodySize: widget.transformHelper.editorBodySize,
                layerData: layerItem,
              );
            }).toList()),
      ),
    );
  }
}
