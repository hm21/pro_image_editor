// Flutter imports:
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '/core/mixins/converted_configs.dart';
import '/core/mixins/editor_configs_mixin.dart';
import '/core/models/custom_widgets/utils/custom_widgets_typedef.dart';
import '/core/models/editor_callbacks/pro_image_editor_callbacks.dart';
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/layers/layer.dart';
import '/features/paint_editor/enums/paint_editor_enum.dart';
import '/plugins/defer_pointer/defer_pointer.dart';
import '/shared/widgets/reactive_widgets/reactive_custom_widget.dart';
import '../models/layer_item_interaction.dart';
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
    required this.layer,
    required this.child,
    required this.configs,
    this.onEditLayer,
    this.onRemoveLayer,
    this.onDuplicate,
    this.onScaleRotateDown,
    this.onScaleRotateUp,
    this.onGroupLayers,
    this.onUngroupLayers,
    this.selected = false,
    this.isInteractive = false,
    this.callbacks = const ProImageEditorCallbacks(),
    this.forceIgnoreGestures = false,
    this.enableVisibleOverlay = false,
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

  /// Callback triggered when a layer should be copied.
  final Function()? onDuplicate;

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

  /// Callback for grouping layers.
  ///
  /// This callback is triggered when the user wants to group the current
  /// layer with other selected layers, creating a group that will be
  /// selected together.
  final Function()? onGroupLayers;

  /// Callback for ungrouping layers.
  ///
  /// This callback is triggered when the user wants to ungroup the current
  /// layer, removing it from its current group.
  final Function()? onUngroupLayers;

  /// Data representing the layer's configuration and state.
  ///
  /// This data is used to determine the layer's appearance, behavior, and the
  /// interactions available to the user.
  final Layer layer;

  /// Indicates whether the layer is interactive.
  ///
  /// If true, the layer supports interactive features such as gestures and
  /// tooltips.
  final bool isInteractive;

  /// Determines whether gesture interactions should be forcibly ignored.
  ///
  /// When set to `true`, all gesture interactions with the associated widget
  /// will be ignored, regardless of other conditions. This can be useful in
  /// scenarios where you want to temporarily disable user interaction.
  final bool forceIgnoreGestures;

  /// Indicates whether the layer is selected.
  ///
  /// If true, the layer is highlighted, and interaction buttons are displayed.
  final bool selected;

  /// A flag to enable or disable the visibility of the overlay.
  final bool enableVisibleOverlay;

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
  final _rebuildStream = StreamController.broadcast();
  final _overlayCtrl = OverlayPortalController();
  final _isOverlayVisibleNotifier = ValueNotifier(false);

  Layer get _layer => widget.layer;

  @override
  void didUpdateWidget(covariant LayerInteractionHelperWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isOverlayVisibleNotifier.value = widget.selected;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.selected) {
        if (!_overlayCtrl.isShowing) _overlayCtrl.show();
      } else {
        if (_overlayCtrl.isShowing) _overlayCtrl.hide();
      }
    });
  }

  @override
  void dispose() {
    if (_overlayCtrl.isShowing) _overlayCtrl.hide();
    _rebuildStream.close();
    _isOverlayVisibleNotifier.dispose();
    super.dispose();
  }

  @override
  void setState(void Function() fn) {
    _rebuildStream.add(null);
    super.setState(fn);
  }

  double get _rotation {
    if (_layer.flipX) {
      return _layer.rotation;
    }
    return -_layer.rotation;
  }

  LayerItemInteractions get _layerInteractions {
    return LayerItemInteractions(
      duplicated: widget.onDuplicate ?? () {},
      edit: widget.onEditLayer ?? () {},
      remove: widget.onRemoveLayer ?? () {},
      scaleRotateDown: _handleScaleRotateDown,
      scaleRotateUp: _handleScaleRotateUp,
      group: widget.onGroupLayers ?? () {},
      ungroup: widget.onUngroupLayers ?? () {},
    );
  }

  void _handleScaleRotateDown(PointerDownEvent event) {
    widget.onScaleRotateDown?.call(event);
  }

  void _handleScaleRotateUp(PointerUpEvent event) {
    widget.onScaleRotateUp?.call(event);
  }

  bool _isLayerEditable() {
    if (!_layer.interaction.enableEdit) return false;

    if (_layer.isTextLayer) {
      return textEditorConfigs.enableEdit;
    } else if (_layer.isPaintLayer) {
      final paintMode = (_layer as PaintLayer).item.mode;

      return paintEditorConfigs.enableEdit &&
          paintMode != PaintMode.blur &&
          paintMode != PaintMode.pixelate;
    } else if (_layer.isWidgetLayer) {
      return widget.callbacks.stickerEditorCallbacks?.onTapEditSticker != null;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.forceIgnoreGestures) {
      return IgnorePointer(
          ignoring: widget.forceIgnoreGestures, child: widget.child);
    }

    String layerId = _layer.id;
    var deferManager = DeferManager.maybeOf(context);

    if (!widget.isInteractive) {
      // Return the child widget directly if the layer is not interactive.
      return widget.child;
    }

    Widget child = DeferPointer(
      key: ValueKey('Defer-${deferManager?.id ?? ''}-$layerId'),
      child: widget.child,
    );

    if (!widget.enableVisibleOverlay) {
      return child;
    }

    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _overlayCtrl,
      overlayChildBuilder: (context, info) {
        if (layerInteraction.widgets.overlayChildBuilder != null) {
          return ValueListenableBuilder(
              valueListenable: _isOverlayVisibleNotifier,
              builder: (_, isVisible, __) {
                if (!isVisible) return const SizedBox.shrink();
                return layerInteraction.widgets.overlayChildBuilder!(
                  _rebuildStream.stream,
                  info,
                  _layer,
                  _layerInteractions,
                );
              });
        }

        final Matrix4 transform = info.childPaintTransform.clone();

        // The child size
        final childWidth = info.childSize.width;
        final childHeight = info.childSize.height;

        // The new padded size
        final paddedWidth = childWidth;
        final paddedHeight = childHeight;

        return Positioned(
          width: paddedWidth,
          height: paddedHeight,
          left: 0,
          child: ValueListenableBuilder(
              valueListenable: _isOverlayVisibleNotifier,
              builder: (_, isVisible, __) {
                if (!isVisible) return const SizedBox.shrink();

                return Transform(
                  transform: transform,
                  alignment: Alignment.topLeft,
                  child: Transform.flip(
                    flipX: _layer.flipX,
                    flipY: _layer.flipY,
                    child: _buildSelectionOverlay(),
                  ),
                );
              }),
        );
      },
      child: DeferPointer(
        key: ValueKey('Defer-${deferManager?.id ?? ''}-$layerId'),
        child: child,
      ),
    );
  }

  Widget _buildSelectionOverlay() {
    List<LayerInteractionItem> children =
        layerInteraction.widgets.children ?? _buildDefaultInteractions();

    return TooltipVisibility(
      visible: layerInteraction.style.showTooltips,
      child: Stack(
        fit: StackFit.passthrough,
        alignment: Alignment.center,
        children: [
          layerInteraction.widgets.border?.call(widget.child, _layer) ??
              Padding(
                padding: EdgeInsets.all(
                  layerInteraction.style.buttonRadius +
                      layerInteraction.style.strokeWidth,
                ),
                child: CustomPaint(
                  foregroundPainter: LayerInteractionBorderPainter(
                    style: layerInteraction.style,
                  ),
                ),
              ),
          ...children.map(
            (item) => item.call(
              _rebuildStream.stream,
              _layer,
              _layerInteractions,
            ),
          ),
        ],
      ),
    );
  }

  List<LayerInteractionItem> _buildDefaultInteractions() {
    return [
      if (_isLayerEditable())
        (rebuildStream, layer, interactions) => ReactiveWidget(
              stream: rebuildStream,
              builder: (_) => _buildEditButton(interactions),
            ),
      (rebuildStream, layer, interactions) => ReactiveWidget(
            stream: rebuildStream,
            builder: (_) => _buildRemoveButton(interactions),
          ),
      (rebuildStream, layer, interactions) => ReactiveWidget(
            stream: rebuildStream,
            builder: (_) => _buildRotateScaleButton(interactions),
          ),
    ];
  }

  Widget _buildRotateScaleButton(LayerItemInteractions interactions) {
    return layerInteraction.widgets.rotateScaleButton?.call(
          _rebuildStream.stream,
          _handleScaleRotateDown,
          _handleScaleRotateUp,
          _rotation,
        ) ??
        Positioned(
          bottom: 0,
          right: 0,
          child: LayerInteractionButton(
            rotation: _rotation,
            onScaleRotateDown: interactions.scaleRotateDown,
            onScaleRotateUp: interactions.scaleRotateUp,
            buttonRadius: layerInteraction.style.buttonRadius,
            cursor: layerInteraction.style.rotateScaleCursor,
            icon: layerInteraction.icons.rotateScale,
            tooltip: i18n.layerInteraction.rotateScale,
            color: layerInteraction.style.buttonScaleRotateColor,
            background: layerInteraction.style.buttonScaleRotateBackground,
          ),
        );
  }

  Widget _buildEditButton(LayerItemInteractions interactions) {
    return layerInteraction.widgets.editButton?.call(
          _rebuildStream.stream,
          () => widget.onEditLayer?.call(),
          _rotation,
        ) ??
        Positioned(
          top: 0,
          right: 0,
          child: LayerInteractionButton(
            rotation: _rotation,
            onTap: interactions.edit,
            buttonRadius: layerInteraction.style.buttonRadius,
            cursor: layerInteraction.style.editCursor,
            icon: layerInteraction.icons.edit,
            tooltip: i18n.layerInteraction.edit,
            color: layerInteraction.style.buttonEditTextColor,
            background: layerInteraction.style.buttonEditTextBackground,
          ),
        );
  }

  Widget _buildRemoveButton(LayerItemInteractions interactions) {
    return layerInteraction.widgets.removeButton?.call(
          _rebuildStream.stream,
          () => widget.onRemoveLayer?.call(),
          _rotation,
        ) ??
        Positioned(
          top: 0,
          left: 0,
          child: LayerInteractionButton(
            rotation: _rotation,
            onTap: interactions.remove,
            buttonRadius: layerInteraction.style.buttonRadius,
            cursor: layerInteraction.style.removeCursor,
            icon: layerInteraction.icons.remove,
            tooltip: i18n.layerInteraction.remove,
            color: layerInteraction.style.buttonRemoveColor,
            background: layerInteraction.style.buttonRemoveBackground,
          ),
        );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties
      ..add(DiagnosticsProperty<Layer>('layer', widget.layer))
      ..add(DiagnosticsProperty<Widget>('child', widget.child))
      ..add(
        FlagProperty('selected', value: widget.selected, ifTrue: 'selected'),
      )
      ..add(FlagProperty('isInteractive',
          value: widget.isInteractive, ifTrue: 'interactive'))
      ..add(
        FlagProperty('forceIgnoreGestures',
            value: widget.forceIgnoreGestures, ifTrue: 'force ignore gestures'),
      )
      ..add(
        FlagProperty('enableVisibleOverlay',
            value: widget.enableVisibleOverlay,
            ifTrue: 'visible overlay enabled'),
      )
      ..add(
        ObjectFlagProperty<Function()>.has('onEditLayer', widget.onEditLayer),
      )
      ..add(
        ObjectFlagProperty<Function()>.has('onDuplicate', widget.onDuplicate),
      )
      ..add(ObjectFlagProperty<Function()>.has(
          'onRemoveLayer', widget.onRemoveLayer))
      ..add(ObjectFlagProperty<Function(PointerDownEvent)>.has(
          'onScaleRotateDown', widget.onScaleRotateDown))
      ..add(ObjectFlagProperty<Function(PointerUpEvent)>.has(
          'onScaleRotateUp', widget.onScaleRotateUp))
      ..add(ObjectFlagProperty<Function()>.has(
          'onGroupLayers', widget.onGroupLayers))
      ..add(ObjectFlagProperty<Function()>.has(
          'onUngroupLayers', widget.onUngroupLayers));
  }
}
