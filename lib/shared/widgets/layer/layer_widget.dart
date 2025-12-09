// Dart imports:
import 'dart:async';
import 'dart:math';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '/core/constants/editor_various_constants.dart';
import '/core/mixins/converted_configs.dart';
import '/core/mixins/editor_configs_mixin.dart';
import '/core/models/editor_callbacks/pro_image_editor_callbacks.dart';
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/layers/layer.dart';
import '/core/services/gesture_manager.dart';
import '/features/main_editor/services/layer_interaction_manager.dart';
import '/features/main_editor/services/main_editor_layers_service.dart';
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
    required this.editorBodySize,
    required this.configs,
    required this.layer,
    this.layersService,
    this.layerInteractionManager,
    this.onContextMenuToggled,
    this.onDuplicate,
    this.isInteractive = false,
    this.enableMouseCursor = true,
    this.callbacks = const ProImageEditorCallbacks(),
  });
  @override
  final ProImageEditorConfigs configs;

  @override
  final ProImageEditorCallbacks callbacks;

  /// Service for managing editor layers such as adding, removing, or
  /// updating them.
  final MainEditorLayersService? layersService;

  /// Handles user interactions with layers, like selecting or dragging them.
  final LayerInteractionManager? layerInteractionManager;

  /// The size of the editor's body area in logical pixels.
  final Size editorBodySize;

  /// Data for the layer.
  final Layer layer;

  /// Callback when the context menu open/close
  final Function(bool isOpen)? onContextMenuToggled;

  /// Callback triggered when a layer should be copied.
  final Function()? onDuplicate;

  /// Indicates whether the layer is interactive.
  final bool isInteractive;

  /// A flag indicating whether the mouse cursor should be enabled for this
  /// widget.
  final bool enableMouseCursor;

  @override
  createState() => _LayerWidgetState();
}

class _LayerWidgetState extends State<LayerWidget>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  late LayerWidgetType _layerType;

  late final _layersService = widget.layersService;
  late final _layerInteractionManager = widget.layerInteractionManager;

  /// Indicates whether the layer is selected.
  bool get _isSelected =>
      _layerInteractionManager?.selectedLayerIds.contains(_layer.id) ?? false;

  /// Flag to control the display of a move cursor.
  final _showMoveCursor = ValueNotifier(false);
  final _lastHitState = ValueNotifier(false);

  late final _contextManager = LayerWidgetContextMenu(
    i18nLayerInteraction: i18n.layerInteraction,
    layerInteractionIcons: layerInteraction.icons,
    onContextMenuToggled: widget.onContextMenuToggled,
    onEditTap: () => _layersService?.handleEditTap(_layer),
    onRemoveTap: () => _layersService?.handleRemoveLayer(_layer),
  );

  late final Offset _fractionalOffset;

  PointerEvent? _lastDownEvent;
  Offset? _lastLayerOffset;
  int? _temporaryLayerHash;

  DateTime _tapDownTimestamp = DateTime.now();
  Timer? _longPressTimer;
  final Duration _longPressThreshold = const Duration(milliseconds: 500);

  /// Returns the current layer being displayed.
  Layer get _layer => widget.layer;

  Size get _halfBodySize => widget.editorBodySize / 2;

  /// Calculates the horizontal offset for the layer.
  double get offsetX => _layer.offset.dx + _halfBodySize.width;

  /// Calculates the vertical offset for the layer.
  double get offsetY => _layer.offset.dy + _halfBodySize.height;

  bool get _enableVisibleOverlay =>
      _layerInteractionManager?.layersAreSelectable(widget.configs) ?? false;

  @override
  void initState() {
    super.initState();

    if (_layer.isTextLayer) {
      _layerType = LayerWidgetType.text;
      _fractionalOffset = configs.textEditor.layerFractionalOffset;
    } else if (_layer.isEmojiLayer) {
      _layerType = LayerWidgetType.emoji;
      _fractionalOffset = configs.emojiEditor.layerFractionalOffset;
    } else if (_layer.isWidgetLayer) {
      _layerType = LayerWidgetType.widget;
      _fractionalOffset = configs.stickerEditor.layerFractionalOffset;
    } else if (_layer.isPaintLayer) {
      var layer = _layer as PaintLayer;
      _layerType = layer.item.mode == PaintMode.blur ||
              layer.item.mode == PaintMode.pixelate
          ? LayerWidgetType.censor
          : LayerWidgetType.canvas;
      _fractionalOffset = configs.paintEditor.layerFractionalOffset;
    } else {
      _layerType = LayerWidgetType.unknown;
      _fractionalOffset = const Offset(-0.5, -0.5);
    }
  }

  @override
  void dispose() {
    _lastHitState.dispose();
    _showMoveCursor.dispose();
    _longPressTimer?.cancel();
    super.dispose();
  }

  /// Handles a secondary tap up event, typically for showing a context menu.
  void _onSecondaryTapUp(TapUpDetails details) {
    if (_isOutsideHitBox() || GestureManager.instance.isBlocked) return;

    _contextManager.open(
      context: context,
      details: details,
      enableEditButton:
          _layerType == LayerWidgetType.text && _layer.interaction.enableEdit,
      enableRemoveButton: true,
    );
  }

  /// Handles a pointer down event on the layer.
  void _onPointerDown(PointerDownEvent event) {
    if (GestureManager.instance.isBlocked) return;
    bool isLayerSelected = _isSelected;

    _lastDownEvent = event;
    _lastLayerOffset = _layer.offset;
    _temporaryLayerHash = _layer.hashCode;
    _tapDownTimestamp = DateTime.now();

    if (_isOutsideHitBox()) return;
    if (!isDesktop || event.buttons != kSecondaryMouseButton) {
      _layersService?.handleTapDown(_layer, event);
    }
    // Start long press detection
    _longPressTimer?.cancel();
    _longPressTimer = Timer(_longPressThreshold, () {
      if (_lastDownEvent == null ||
          _lastLayerOffset == null ||
          _temporaryLayerHash != _layer.hashCode) {
        return;
      }

      final offsetDistance = (_layer.offset - _lastLayerOffset!).distance;

      if (offsetDistance <= 0 && _layer.interaction.enableSelection) {
        _layersService?.handleLongPress(
          _layer,
          isSelected: isLayerSelected,
          areLayersSelectable: _enableVisibleOverlay,
        );
      }
    });
  }

  /// Handles a pointer up event on the layer.
  void _onPointerUp(PointerUpEvent event) {
    _longPressTimer?.cancel();
    if (GestureManager.instance.isBlocked) return;
    // Notify optional onTapUp callback
    _layersService?.handleTapUp(_layer);

    /// Important: To avoid gesture conflicts, we need to create our own
    /// onTap event using the Listener widget instead of GestureDetector.
    /// Below is a minimal example of how this can work. If anyone has
    /// issues with this, please open a new issue.

    // Cancel if down position is not set
    if (_lastDownEvent == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final interaction = _layer.interaction;
      final offsetDistance =
          (event.position - _lastDownEvent!.position).distance;
      final timeElapsed =
          DateTime.now().difference(_tapDownTimestamp).inMilliseconds;

      // Ignore if pointer moved too much (exceeds tap slop)
      if (offsetDistance >= tapSlop) return;

      // Ignore if tap took too long (not a quick tap)
      if (timeElapsed > tapTimeElapsed) return;

      // Fire onTap only if selection/edit is enabled and pointer is inside hit box
      final bool canSelect = interaction.enableSelection;
      final bool canEdit = interaction.enableEdit;
      final bool insideHitBox = !_isOutsideHitBox();
      final bool isStylus = event.kind == PointerDeviceKind.stylus;
      final bool isTextLayer = _layerType == LayerWidgetType.text;

      if (!(canSelect || canEdit)) {
        return;
      }

      // For stylus on TEXT layers only, bypass hit box check since it has
      // precision issues with stylus input
      // For paint layers: always use hit box validation (no bypass)
      // to ensure taps on empty space inside shapes don't trigger edit.
      final bool stylusTextBypass = isStylus && isTextLayer;

      if (insideHitBox || stylusTextBypass) {
        _layersService?.handleLayerTap(_layer, _lastDownEvent!);
      }
    });
  }

  bool _isOutsideHitBox() {
    final bool hitOutsideCanvas = _isHitOutsideInCanvas();
    final bool hitOutsideText = _isHitOutsideInText();
    final bool isCensor = _layerType == LayerWidgetType.censor;
    final bool isSelected = _isSelected;

    return ((hitOutsideCanvas || hitOutsideText) && !isCensor) && !isSelected;
  }

  /// Checks if the hit is outside the canvas for certain types of layers.
  bool _isHitOutsideInCanvas() {
    return _layer.isPaintLayer && !(_layer as PaintLayer).item.hit;
  }

  /// Checks if the hit is outside the canvas for certain types of layers.
  bool _isHitOutsideInText() {
    return _layer.isTextLayer && !(_layer as TextLayer).hit;
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

  void _onHoverEnter() {
    if (((!_layer.isPaintLayer || _layerType == LayerWidgetType.censor) &&
            !_layer.isTextLayer) ||
        _isSelected) {
      _showMoveCursor.value = true;
    }
  }

  void _onHoverLeave() {
    if (_layer.isPaintLayer) {
      (_layer as PaintLayer).item.hit = false;
    } else if (_layer.isTextLayer) {
      (_layer as TextLayer).hit = false;
    }
    _showMoveCursor.value = false;
    _lastHitState.value = false;
  }

  @override
  Widget build(BuildContext context) {
    Matrix4 transformMatrix = _calcTransformMatrix();

    final overlayPadding =
        _isSelected ? layerInteraction.style.overlayPadding : EdgeInsets.zero;

    final adjustedLeft =
        offsetX - overlayPadding.horizontal * (_fractionalOffset.dx + 0.5);
    final adjustedTop =
        offsetY - overlayPadding.vertical * (_fractionalOffset.dy + 0.5);

    return Positioned(
      left: adjustedLeft,
      top: adjustedTop,
      child: RepaintBoundary(
        child: FractionalTranslation(
          translation: _fractionalOffset,
          child: Hero(
            // Important that hero is above transform
            createRectTween: (begin, end) => RectTween(begin: begin, end: end),
            tag: _layer.id,
            child: Transform(
              transform: transformMatrix,
              alignment: Alignment.center,
              child: _buildInteractionHandlers(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractionHandlers() {
    var interaction = _layer.interaction;
    return LayerInteractionHelperWidget(
      layer: _layer,
      configs: configs,
      callbacks: callbacks,
      selected: _isSelected,
      onEditLayer: () => _layersService?.handleEditTap(_layer),
      forceIgnoreGestures:
          !(interaction.enableSelection || interaction.enableEdit),
      isInteractive: widget.isInteractive,
      enableVisibleOverlay: _enableVisibleOverlay,
      onScaleRotateDown: (details) => _layersService?.handleScaleRotateDown(
          context.size ?? Size.zero, _layer),
      onScaleRotateUp: (_) => _layersService?.handleScaleRotateUp(),
      onRemoveLayer: () => _layersService?.handleRemoveLayer(_layer),
      onDuplicate: widget.onDuplicate,
      onGroupLayers: _layersService?.handleGroupLayers,
      onUngroupLayers: () => _layersService?.handleUngroupLayers(_layer),
      child: _buildCursor(
        child: ValueListenableBuilder(
            valueListenable: _lastHitState,
            builder: (_, __, ___) {
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onSecondaryTapUp: isDesktop ? _onSecondaryTapUp : null,
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: _onPointerDown,
                  onPointerUp: _onPointerUp,
                  child: Padding(
                    padding: !_isSelected
                        ? EdgeInsets.zero
                        : layerInteraction.style.overlayPadding,
                    child: FittedBox(
                      key: _layer.keyInternalSize,
                      child: _buildContent(),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }

  Widget _buildCursor({required Widget child}) {
    return ValueListenableBuilder(
        valueListenable: _showMoveCursor,
        builder: (_, showCursor, __) {
          return MouseRegion(
            hitTestBehavior: HitTestBehavior.translucent,
            cursor: showCursor &&
                    _layer.interaction.enableMove &&
                    widget.enableMouseCursor
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
          isSelected: _isSelected,
          enableHitDetection:
              _layerInteractionManager?.enabledHitDetection ?? false,
          onHitChanged: (state) {
            _lastHitState.value = state;
          },
          paintEditorConfigs: widget.configs.paintEditor,
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    _layer.debugFillProperties(properties);
  }
}
