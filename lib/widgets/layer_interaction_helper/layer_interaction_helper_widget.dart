// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/plugins/defer_pointer/defer_pointer.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import '../../mixins/converted_configs.dart';
import '../../mixins/editor_configs_mixin.dart';
import 'layer_interaction_border_painter.dart';
import 'layer_interaction_button.dart';

class LayerInteractionHelperWidget extends StatefulWidget
    with SimpleConfigsAccess {
  @override
  final ProImageEditorConfigs configs;

  @override
  final ProImageEditorCallbacks callbacks;
  final Widget child;

  final Function()? onEditLayer;
  final Function()? onRemoveLayer;
  final Function(PointerDownEvent)? onScaleRotateDown;
  final Function(PointerUpEvent)? onScaleRotateUp;

  /// Data for the layer.
  final Layer layerData;

  final bool isInteractive;
  final bool selected;

  const LayerInteractionHelperWidget({
    super.key,
    required this.layerData,
    required this.child,
    required this.configs,
    this.onEditLayer,
    this.onRemoveLayer,
    this.onScaleRotateDown,
    this.onScaleRotateUp,
    this.selected = false,
    this.isInteractive = false,
    this.callbacks = const ProImageEditorCallbacks(),
  });

  @override
  State<LayerInteractionHelperWidget> createState() =>
      _LayerInteractionHelperWidgetState();
}

class _LayerInteractionHelperWidgetState
    extends State<LayerInteractionHelperWidget>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  bool _tooltipVisible = true;

  @override
  Widget build(BuildContext context) {
    if (!widget.isInteractive) {
      return widget.child;
    } else if (!widget.selected) {
      return DeferPointer(child: widget.child);
    }
    return TooltipVisibility(
      visible:
          _tooltipVisible && imageEditorTheme.layerInteraction.showTooltips,
      child: DeferPointer(
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.all(
                imageEditorTheme.layerInteraction.buttonRadius +
                    imageEditorTheme.layerInteraction.strokeWidth * 2,
              ),
              child: CustomPaint(
                foregroundPainter: LayerInteractionBorderPainter(
                  theme: imageEditorTheme.layerInteraction,
                  borderStyle: imageEditorTheme.layerInteraction.borderStyle,
                ),
                child: widget.child,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: LayerInteractionButton(
                toogleTooltipVisibility: (val) =>
                    setState(() => _tooltipVisible = val),
                rotation: -widget.layerData.rotation,
                onTap: widget.onRemoveLayer,
                buttonRadius: imageEditorTheme.layerInteraction.buttonRadius,
                cursor: imageEditorTheme.layerInteraction.removeCursor,
                icon: icons.layerInteraction.remove,
                tooltip: i18n.layerInteraction.remove,
                color: imageEditorTheme.layerInteraction.buttonRemoveColor,
                background:
                    imageEditorTheme.layerInteraction.buttonRemoveBackground,
              ),
            ),
            if (widget.layerData.runtimeType == TextLayerData)
              Positioned(
                top: 0,
                right: 0,
                child: LayerInteractionButton(
                  toogleTooltipVisibility: (val) =>
                      setState(() => _tooltipVisible = val),
                  rotation: -widget.layerData.rotation,
                  onTap: widget.onEditLayer,
                  buttonRadius: imageEditorTheme.layerInteraction.buttonRadius,
                  cursor: imageEditorTheme.layerInteraction.editCursor,
                  icon: icons.layerInteraction.edit,
                  tooltip: i18n.layerInteraction.edit,
                  color: imageEditorTheme.layerInteraction.buttonEditTextColor,
                  background: imageEditorTheme
                      .layerInteraction.buttonEditTextBackground,
                ),
              ),
            Positioned(
              bottom: 0,
              right: 0,
              child: LayerInteractionButton(
                toogleTooltipVisibility: (val) =>
                    setState(() => _tooltipVisible = val),
                rotation: -widget.layerData.rotation,
                onScaleRotateDown: widget.onScaleRotateDown,
                onScaleRotateUp: widget.onScaleRotateUp,
                buttonRadius: imageEditorTheme.layerInteraction.buttonRadius,
                cursor: imageEditorTheme.layerInteraction.rotateScaleCursor,
                icon: icons.layerInteraction.rotateScale,
                tooltip: i18n.layerInteraction.rotateScale,
                color: imageEditorTheme.layerInteraction.buttonScaleRotateColor,
                background: imageEditorTheme
                    .layerInteraction.buttonScaleRotateBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
