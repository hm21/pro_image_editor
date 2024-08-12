// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/plugins/defer_pointer/defer_pointer.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import '../../mixins/converted_configs.dart';
import '../../mixins/editor_configs_mixin.dart';
import 'layer_interaction_border_painter.dart';
import 'layer_interaction_button.dart';

/// A stateful widget that provides interactive controls for manipulating
/// layers in an image editor.
///
/// This widget is designed to enhance layer interaction by providing buttons
/// for actions like
/// editing, removing, and transforming layers. It displays interactive UI
/// elements based on the state of the layer (selected or interactive) and
/// enables user interactions through gestures and tooltips.

class LayerInteractionHelperWidget extends StatefulWidget
    with SimpleConfigsAccess {
  /// Creates a [LayerInteractionHelperWidget].
  ///
  /// This widget provides a layer manipulation interface, allowing for actions
  /// like editing, removing, and transforming layers in an image editing
  /// application.
  ///
  /// Example:
  /// ```
  /// LayerInteractionHelperWidget(
  ///   layerData: myLayerData,
  ///   child: ImageWidget(),
  ///   configs: myEditorConfigs,
  ///   onEditLayer: () {
  ///     // Handle edit layer action
  ///   },
  ///   onRemoveLayer: () {
  ///     // Handle remove layer action
  ///   },
  ///   isInteractive: true,
  ///   selected: true,
  /// )
  /// ```
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

  /// The configuration settings for the image editor.
  ///
  /// These settings determine various aspects of the editor's behavior and
  /// appearance, influencing how layer interactions are handled.
  @override
  final ProImageEditorConfigs configs;

  /// Callbacks for the image editor.
  ///
  /// These callbacks provide hooks for responding to various editor events
  /// and interactions, allowing for customized behavior.
  @override
  final ProImageEditorCallbacks callbacks;

  /// The widget representing the layer's visual content.
  ///
  /// This child widget displays the content that users will interact with
  /// using the layer manipulation controls.
  final Widget child;

  /// Callback for handling the edit layer action.
  ///
  /// This callback is triggered when the user selects the edit option for a
  /// layer, allowing for modifications to the layer's content.
  final Function()? onEditLayer;

  /// Callback for handling the remove layer action.
  ///
  /// This callback is triggered when the user selects the remove option for a
  /// layer, enabling the removal of the layer from the editor.
  final Function()? onRemoveLayer;

  /// Callback for handling pointer down events associated with scale and
  /// rotate gestures.
  ///
  /// This callback is triggered when the user presses down on the button for
  /// scaling or rotating, allowing for interaction tracking.
  final Function(PointerDownEvent)? onScaleRotateDown;

  /// Callback for handling pointer up events associated with scale and rotate
  /// gestures.
  ///
  /// This callback is triggered when the user releases the button after scaling
  /// or rotating, finalizing the interaction.
  final Function(PointerUpEvent)? onScaleRotateUp;

  /// Data representing the layer's configuration and state.
  ///
  /// This data is used to determine the layer's appearance, behavior, and the
  /// interactions available to the user.
  final Layer layerData;

  /// Indicates whether the layer is interactive.
  ///
  /// If true, the layer supports interactive features such as gestures and
  /// tooltips.
  final bool isInteractive;

  /// Indicates whether the layer is selected.
  ///
  /// If true, the layer is highlighted, and interaction buttons are displayed.
  final bool selected;

  @override
  State<LayerInteractionHelperWidget> createState() =>
      _LayerInteractionHelperWidgetState();
}

/// The state class for [LayerInteractionHelperWidget].
///
/// This class manages the interactive state of the layer, including visibility
/// of tooltips and the display of interaction buttons for layer manipulation.

class _LayerInteractionHelperWidgetState
    extends State<LayerInteractionHelperWidget>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  bool _tooltipVisible = true;

  @override
  Widget build(BuildContext context) {
    if (!widget.isInteractive) {
      // Return the child widget directly if the layer is not interactive.
      return widget.child;
    } else if (!widget.selected) {
      // Use a defer pointer if the layer is not selected, preventing
      // interaction.
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
                toggleTooltipVisibility: (val) =>
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
            if (widget.layerData.runtimeType == TextLayerData ||
                (widget.layerData.runtimeType == StickerLayerData &&
                    widget.callbacks.stickerEditorCallbacks?.onTapEditSticker !=
                        null))
              Positioned(
                top: 0,
                right: 0,
                child: LayerInteractionButton(
                  toggleTooltipVisibility: (val) =>
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
                toggleTooltipVisibility: (val) =>
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
