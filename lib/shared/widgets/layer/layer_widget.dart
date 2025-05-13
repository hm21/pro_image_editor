// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '/core/mixins/converted_configs.dart';
import '/core/mixins/editor_configs_mixin.dart';
import '/core/models/editor_callbacks/pro_image_editor_callbacks.dart';
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/layers/layer.dart';
import '/features/paint_editor/enums/paint_editor_enum.dart';
import '/shared/widgets/layer/enums/layer_widget_type_enum.dart';
import '/shared/widgets/layer/services/layer_widget_context_menu.dart';
import '/shared/widgets/layer/widgets/layer_widget_censor_item.dart';
import '/shared/widgets/layer/widgets/layer_widget_emoji_item.dart';
import '/shared/widgets/layer/widgets/layer_widget_paint_item.dart';
import '/shared/widgets/layer/widgets/layer_widget_text_item.dart';
import 'interaction_helper/layer_interaction_helper_widget.dart';
import 'widgets/layer_widget_custom_item.dart';

/// A widget representing a layer within a design canvas.
class LayerWidget extends StatefulWidget with SimpleConfigsAccess {
  /// Creates a [LayerWidget] with the specified properties.
  const LayerWidget({
    super.key,
    this.onScaleRotateDown,
    this.onScaleRotateUp,
    required this.editorCenterX,
    required this.editorCenterY,
    required this.configs,
    required this.layerData,
    this.onContextMenuToggled,
    this.onTapDown,
    this.onTapUp,
    this.onTap,
    this.onEditTap,
    this.onRemoveTap,
    this.highPerformanceMode = false,
    this.enableHitDetection = false,
    this.selected = false,
    this.isInteractive = false,
    this.callbacks = const ProImageEditorCallbacks(),
  });
  @override
  final ProImageEditorConfigs configs;

  @override
  final ProImageEditorCallbacks callbacks;

  /// The x-coordinate of the editor's center.
  ///
  /// This parameter specifies the horizontal center of the editor's body in
  /// logical pixels, used to position and transform layers relative to the
  /// editor's center.
  final double editorCenterX;

  /// The y-coordinate of the editor's center.
  ///
  /// This parameter specifies the vertical center of the editor's body in
  /// logical pixels,  used to position and transform layers relative to the
  /// editor's center.
  final double editorCenterY;

  /// Data for the layer.
  final Layer layerData;

  /// Callback when the context menu open/close
  final Function(bool isOpen)? onContextMenuToggled;

  /// Callback when a tap down event occurs.
  final Function()? onTapDown;

  /// Callback when a tap up event occurs.
  final Function()? onTapUp;

  /// Callback when a tap event occurs.
  final Function(Layer)? onTap;

  /// Callback for removing the layer.
  final Function()? onRemoveTap;

  /// Callback for editing the layer.
  final Function()? onEditTap;

  /// Callback for handling pointer down events associated with scale and rotate
  /// gestures.
  ///
  /// This callback is triggered when the user presses down on the widget to
  /// begin a scaling or rotating gesture. It provides both the pointer event
  /// and the size of the widget being interacted with, allowing for precise
  /// manipulation.
  ///
  /// - Parameters:
  ///   - event: The [PointerDownEvent] containing details about the pointer
  ///     interaction, such as position and device type.
  ///   - size: The [Size] of the widget being manipulated, useful for
  ///     calculating scaling and rotation transformations relative to the
  ///     widget's dimensions.
  final Function(PointerDownEvent, Size)? onScaleRotateDown;

  /// Callback for handling pointer up events associated with scale and rotate
  /// gestures.
  ///
  /// This callback is triggered when the user releases the widget after a
  /// scaling or rotating gesture. It allows for finalizing the interaction and
  /// making any necessary updates or state changes based on the completed
  /// gesture.
  ///
  /// - Parameter event: The [PointerUpEvent] containing details about the
  ///   pointer release, such as position and device type.
  final Function(PointerUpEvent)? onScaleRotateUp;

  /// Controls high-performance for free-style drawing.
  final bool highPerformanceMode;

  /// Enables or disables hit detection.
  /// When set to `true`, it allows detecting user interactions with the
  /// interface.
  final bool enableHitDetection;

  /// Indicates whether the layer is selected.
  final bool selected;

  /// Indicates whether the layer is interactive.
  final bool isInteractive;

  @override
  createState() => _LayerWidgetState();
}

class _LayerWidgetState extends State<LayerWidget>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  /// The type of layer being represented.
  late LayerWidgetType _layerType;

  /// Flag to control the display of a move cursor.
  final _showMoveCursor = ValueNotifier(false);
  final _lastHitState = ValueNotifier(false);

  late final _contextManager = LayerWidgetContextMenu(
    i18nLayerInteraction: i18n.layerInteraction,
    layerInteractionIcons: layerInteraction.icons,
    onContextMenuToggled: widget.onContextMenuToggled,
    onEditTap: widget.onEditTap,
    onRemoveTap: widget.onRemoveTap,
  );

  @override
  void initState() {
    super.initState();
    switch (widget.layerData.runtimeType) {
      case const (TextLayer):
        _layerType = LayerWidgetType.text;
        break;
      case const (EmojiLayer):
        _layerType = LayerWidgetType.emoji;
        break;
      case const (WidgetLayer):
        _layerType = LayerWidgetType.widget;
        break;
      case const (PaintLayer):
        var layer = widget.layerData as PaintLayer;
        _layerType = layer.item.mode == PaintMode.blur ||
                layer.item.mode == PaintMode.pixelate
            ? LayerWidgetType.censor
            : LayerWidgetType.canvas;
        break;
      default:
        _layerType = LayerWidgetType.unknown;
        break;
    }
  }

  @override
  void dispose() {
    _lastHitState.dispose();
    _showMoveCursor.dispose();
    super.dispose();
  }

  /// Handles a secondary tap up event, typically for showing a context menu.
  void _onSecondaryTapUp(TapUpDetails details) {
    if (_isOutsideHitBox()) return;

    _contextManager.open(
      context: context,
      details: details,
      enableEditButton: _layerType == LayerWidgetType.text &&
          widget.layerData.interaction.enableEdit,
      enableRemoveButton: true,
    );
  }

  /// Handles a tap event on the layer.
  void _onTap() {
    if (_isOutsideHitBox()) return;
    widget.onTap?.call(_layer);
  }

  /// Handles a pointer down event on the layer.
  void _onPointerDown(PointerDownEvent event) {
    if (_isOutsideHitBox()) return;
    if (!isDesktop || event.buttons != kSecondaryMouseButton) {
      widget.onTapDown?.call();
    }
  }

  /// Handles a pointer up event on the layer.
  void _onPointerUp(PointerUpEvent event) {
    widget.onTapUp?.call();
  }

  bool _isOutsideHitBox() {
    return _isHitOutsideInCanvas() || _isHitOutsideInText();
  }

  /// Checks if the hit is outside the canvas for certain types of layers.
  bool _isHitOutsideInCanvas() {
    return _layerType == LayerWidgetType.canvas &&
        !(_layer as PaintLayer).item.hit;
  }

  /// Checks if the hit is outside the canvas for certain types of layers.
  bool _isHitOutsideInText() {
    return _layerType == LayerWidgetType.text && !(_layer as TextLayer).hit;
  }

  /// Calculates the transformation matrix for the layer's position and
  /// rotation.
  Matrix4 _calcTransformMatrix() {
    return Matrix4.identity()
      ..setEntry(3, 2, 0.001) // Add a small z-offset to avoid rendering issues
      ..rotateX(_layer.flipY ? pi : 0)
      ..rotateY(_layer.flipX ? pi : 0)
      ..rotateZ(_layer.rotation);
  }

  /// Returns the current layer being displayed.
  Layer get _layer => widget.layerData;

  /// Calculates the horizontal offset for the layer.
  double get offsetX => _layer.offset.dx + widget.editorCenterX;

  /// Calculates the vertical offset for the layer.
  double get offsetY => _layer.offset.dy + widget.editorCenterY;

  void _onHoverEnter() {
    if (_layerType != LayerWidgetType.canvas &&
        _layerType != LayerWidgetType.text) {
      _showMoveCursor.value = true;
    }
  }

  void _onHoverLeave() {
    switch (_layerType) {
      case LayerWidgetType.canvas:
        (widget.layerData as PaintLayer).item.hit = false;
        break;
      case LayerWidgetType.text:
        (widget.layerData as TextLayer).hit = false;
        break;
      default:
    }
    _showMoveCursor.value = false;
    _lastHitState.value = false;
  }

  @override
  Widget build(BuildContext context) {
    Matrix4 transformMatrix = _calcTransformMatrix();

    return Positioned(
      top: offsetY,
      left: offsetX,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Hero(
          // Important that hero is above transform
          createRectTween: (begin, end) => RectTween(begin: begin, end: end),
          tag: widget.layerData.id,
          child: Transform(
            transform: transformMatrix,
            alignment: Alignment.center,
            child: _buildInteractionHandlers(),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractionHandlers() {
    var interaction = widget.layerData.interaction;
    return LayerInteractionHelperWidget(
      layerData: widget.layerData,
      configs: configs,
      callbacks: callbacks,
      selected: widget.selected,
      onEditLayer: widget.onEditTap,
      isInteractive: widget.isInteractive,
      onScaleRotateDown: (details) {
        widget.onScaleRotateDown?.call(details, context.size ?? Size.zero);
      },
      onScaleRotateUp: widget.onScaleRotateUp,
      onRemoveLayer: widget.onRemoveTap,
      child: _buildCursor(
        child: ValueListenableBuilder(
            valueListenable: _lastHitState,
            builder: (_, __, ___) {
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onSecondaryTapUp: isDesktop ? _onSecondaryTapUp : null,
                onTap:
                    (interaction.enableSelection || interaction.enableEdit) &&
                            !_isOutsideHitBox()
                        ? _onTap
                        : null,
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: _onPointerDown,
                  onPointerUp: _onPointerUp,
                  child: Padding(
                    padding: EdgeInsets.all(widget.selected ? 7.0 : 0),
                    child: FittedBox(
                      child: _buildContent(),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }

  Widget _buildCursor({
    required Widget child,
  }) {
    return ValueListenableBuilder(
        valueListenable: _showMoveCursor,
        builder: (_, showCursor, __) {
          return MouseRegion(
            hitTestBehavior: HitTestBehavior.translucent,
            cursor: showCursor && widget.layerData.interaction.enableMove
                ? layerInteraction.style.hoverCursor
                : MouseCursor.defer,
            onEnter: (event) => _onHoverEnter(),
            onExit: (event) => _onHoverLeave(),
            child: child,
          );
        });
  }

  /// Builds the content widget based on the type of layer being displayed.
  Widget _buildContent() {
    Widget? content;
    switch (_layerType) {
      case LayerWidgetType.emoji:
        content = LayerWidgetEmojiItem(
          layer: _layer as EmojiLayer,
          emojiEditorConfigs: emojiEditorConfigs,
          textEditorConfigs: textEditorConfigs,
          designMode: designMode,
        );
      case LayerWidgetType.text:
        content = LayerWidgetTextItem(
          layer: _layer as TextLayer,
          textEditorConfigs: textEditorConfigs,
          showMoveCursor: _showMoveCursor,
          onHitChanged: (state) {
            _lastHitState.value = state;
          },
        );
      case LayerWidgetType.widget:
        content = LayerWidgetCustomItem(
          layer: _layer as WidgetLayer,
          stickerEditorConfigs: stickerEditorConfigs,
        );
      case LayerWidgetType.canvas:
        content = LayerWidgetPaintItem(
          layer: _layer as PaintLayer,
          scale: widget.layerData.scale,
          isSelected: widget.selected,
          enableHitDetection: widget.enableHitDetection,
          isHighPerformanceMode: widget.highPerformanceMode,
          onHitChanged: (state) {
            _lastHitState.value = state;
          },
        );
      case LayerWidgetType.censor:
        content = LayerWidgetCensorItem(
          layer: _layer as PaintLayer,
          censorConfigs: paintEditorConfigs.censorConfigs,
        );
      default:
        return const SizedBox.shrink();
    }

    if (_layer.boxConstraints != null) {
      content = ConstrainedBox(
        constraints: _layer.boxConstraints!,
        child: content,
      );
    }

    return content;
  }
}
