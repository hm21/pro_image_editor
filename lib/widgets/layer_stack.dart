// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/models/crop_rotate_editor/transform_factors.dart';
import 'package:pro_image_editor/modules/crop_rotate_editor/utils/crop_layer_painter.dart';
import '../models/editor_configs/pro_image_editor_configs.dart';
import '../models/layer/layer.dart';
import '../models/transform_helper.dart';
import '../widgets/layer_widget.dart';

/// A stateful widget that represents a stack of layers in an image editing
/// application.
///
/// This widget manages the display and transformation of multiple layers,
/// allowing for complex image editing operations such as cropping, rotating,
/// and layering effects.
class LayerStack extends StatefulWidget {
  /// Creates a [LayerStack].
  ///
  /// This widget is responsible for rendering a collection of layers within a
  /// stack, applying transformations and managing interactions based on the
  /// provided configurations.
  ///
  /// Example:
  /// ```
  /// LayerStack(
  ///   configs: myEditorConfigs,
  ///   layers: myLayers,
  ///   cutOutsideImageArea: true,
  ///   freeStyleHighPerformance: true,
  ///   transformHelper: myTransformHelper,
  /// )
  /// ```
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

  /// The configuration settings for the image editor.
  ///
  /// These settings influence the behavior and appearance of the layer stack,
  /// such as rendering options and transformation parameters.
  final ProImageEditorConfigs configs;

  /// The list of layers to be displayed within the stack.
  ///
  /// Each layer is represented by a [Layer] object, allowing for individual
  /// customization and manipulation of its content.
  final List<Layer> layers;

  /// The clipping behavior applied to the layer stack.
  ///
  /// This determines how the contents of the stack are clipped to the widget's
  /// bounds.
  final Clip clipBehavior;

  /// A helper object providing transformation configurations for the layer
  /// stack.
  ///
  /// This includes parameters such as scale, rotation, and translation,
  /// affecting how layers are displayed and manipulated.
  final TransformHelper transformHelper;

  /// Determines whether to cut content outside the image area.
  ///
  /// This option allows for capturing only the background image area, ignoring
  /// content that extends beyond the boundaries.
  final bool? cutOutsideImageArea;

  /// Controls high-performance mode for free-style drawing.
  ///
  /// Enabling this option may improve performance when drawing free-style
  /// elements on the canvas, at the potential cost of rendering quality.
  final bool freeStyleHighPerformance;

  @override
  State<LayerStack> createState() => _LayerStackState();
}

/// The state class for [LayerStack].
///
/// This class manages the rendering and transformation of layers within the
/// stack, applying configurations and handling initialization logic.

class _LayerStackState extends State<LayerStack> {
  late final bool _cutOutsideImageArea;

  @override
  void initState() {
    // Determine whether to cut content outside the image area based on widget
    // settings.
    _cutOutsideImageArea = widget.cutOutsideImageArea ??
        widget.configs.imageGenerationConfigs.captureOnlyBackgroundImageArea;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve transformation configurations, if available.
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
