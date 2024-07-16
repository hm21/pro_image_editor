// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/models/crop_rotate_editor/transform_factors.dart';
import 'package:pro_image_editor/modules/crop_rotate_editor/utils/crop_layer_painter.dart';
import '../models/editor_configs/pro_image_editor_configs.dart';
import '../models/layer/layer.dart';
import '../models/transform_helper.dart';
import '../widgets/layer_widget.dart';

class LayerStack extends StatefulWidget {
  final ProImageEditorConfigs configs;
  final List<Layer> layers;

  final Clip clipBehavior;

  final TransformHelper transformHelper;

  final bool? cutOutsideImageArea;

  /// Controls high-performance for free-style drawing.
  final bool freeStyleHighPerformance;

  const LayerStack({
    super.key,
    required this.configs,
    required this.layers,
    this.cutOutsideImageArea,
    this.freeStyleHighPerformance = false,
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
  late final bool _cutOutsideImageArea;

  @override
  void initState() {
    _cutOutsideImageArea = widget.cutOutsideImageArea ??
        widget.configs.imageGenerationConfigs.captureOnlyBackgroundImageArea;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TransformConfigs? transformConfigs =
        widget.transformHelper.transformConfigs != null &&
                widget.transformHelper.transformConfigs!.isNotEmpty
            ? widget.transformHelper.transformConfigs
            : null;

    return Stack(
      children: [
        IgnorePointer(
          child: Transform.scale(
            scale: widget.transformHelper.scale,
            child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                clipBehavior: widget.clipBehavior,
                children: widget.layers.map((layerItem) {
                  return LayerWidget(
                    configs: widget.configs,
                    highPerformanceMode: widget.freeStyleHighPerformance,
                    editorCenterX:
                        widget.transformHelper.editorBodySize.width / 2,
                    editorCenterY:
                        widget.transformHelper.editorBodySize.height / 2,
                    layerData: layerItem,
                  );
                }).toList()),
          ),
        ),
        if (widget
            .configs.imageGenerationConfigs.captureOnlyBackgroundImageArea)
          RepaintBoundary(
            child: Hero(
              tag: 'crop_layer_painter_hero',
              child: CustomPaint(
                foregroundPainter: _cutOutsideImageArea
                    ? CropLayerPainter(
                        opacity: widget.configs.imageEditorTheme
                            .outsideCaptureAreaLayerOpacity,
                        backgroundColor:
                            widget.configs.imageEditorTheme.background,
                        imgRatio: transformConfigs?.cropRect.size.aspectRatio ??
                            widget.transformHelper.mainImageSize.aspectRatio,
                        isRoundCropper:
                            widget.configs.cropRotateEditorConfigs.roundCropper,
                        is90DegRotated:
                            transformConfigs?.is90DegRotated ?? false,
                      )
                    : null,
                child: const SizedBox.expand(),
              ),
            ),
          ),
      ],
    );
  }
}
