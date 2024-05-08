import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/utils/theme_functions.dart';
import 'package:rounded_background_text/rounded_background_text.dart';

import '../mixins/converted_configs.dart';
import '../mixins/editor_configs_mixin.dart';
import '../models/layer.dart';
import '../modules/paint_editor/utils/draw/draw_canvas.dart';
import '../modules/paint_editor/utils/paint_editor_enum.dart';
import 'layer_interaction_helper/layer_interaction_helper_widget.dart';
import 'pro_image_editor_desktop_mode.dart';

/// A widget representing a layer within a design canvas.
class LayerWidget extends StatefulWidget with SimpleConfigsAccess {
  @override
  final ProImageEditorConfigs configs;

  /// Data for the layer.
  final Layer layerData;

  /// Callback when a tap down event occurs.
  final Function() onTapDown;

  /// Callback when a tap up event occurs.
  final Function() onTapUp;

  /// Callback when a tap event occurs.
  final Function(Layer) onTap;

  /// Callback for removing the layer.
  final Function() onRemoveTap;

  /// Callback for editing the layer.
  final Function() onEditTap;

  final Function(PointerDownEvent, Size)? onScaleRotateDown;
  final Function(PointerUpEvent)? onScaleRotateUp;

  /// Padding for positioning the layer within the canvas.
  final EdgeInsets padding;

  /// Enables high-performance scaling for free-style drawing when set to `true`.
  ///
  /// When this option is enabled, it optimizes scaling for improved performance.
  /// By default, it's set to `true` on mobile devices and `false` on desktop devices.
  final bool freeStyleHighPerformanceScaling;

  /// Enables high-performance moving for free-style drawing when set to `true`.
  ///
  /// When this option is enabled, it optimizes moving for improved performance.
  /// By default, it's set to `true` only on mobile-web devices.
  final bool freeStyleHighPerformanceMoving;

  /// Enables or disables hit detection.
  /// When set to `true`, it allows detecting user interactions with the interface.
  final bool enableHitDetection;

  /// Indicates whether the layer is selected.
  final bool selected;

  /// Indicates whether the layer is interactive.
  final bool isInteractive;

  /// Creates a [LayerWidget] with the specified properties.
  const LayerWidget({
    super.key,
    this.onScaleRotateDown,
    this.onScaleRotateUp,
    required this.configs,
    required this.padding,
    required this.layerData,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTap,
    required this.onEditTap,
    required this.onRemoveTap,
    required this.enableHitDetection,
    required this.freeStyleHighPerformanceScaling,
    required this.freeStyleHighPerformanceMoving,
    this.selected = false,
    this.isInteractive = false,
  });

  @override
  createState() => _LayerWidgetState();
}

class _LayerWidgetState extends State<LayerWidget>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  final _layerKey = GlobalKey();

  /// The type of layer being represented.
  late _LayerType _layerType;

  /// Flag to control the display of a move cursor.
  bool _showMoveCursor = false;

  @override
  void initState() {
    switch (widget.layerData.runtimeType) {
      case const (TextLayerData):
        _layerType = _LayerType.text;
        break;
      case const (EmojiLayerData):
        _layerType = _LayerType.emoji;
        break;
      case const (StickerLayerData):
        _layerType = _LayerType.sticker;
        break;
      case const (PaintingLayerData):
        _layerType = _LayerType.canvas;
        break;
      default:
        _layerType = _LayerType.unknown;
        break;
    }

    super.initState();
  }

  /// Handles a secondary tap up event, typically for showing a context menu.
  void _onSecondaryTapUp(TapUpDetails details) {
    if (_checkHitIsOutsideInCanvas()) return;
    final Offset clickPosition = details.globalPosition;

    // Show a popup menu at the click position
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        clickPosition.dx,
        clickPosition.dy,
        clickPosition.dx + 1.0, // Adding a small value to avoid zero width
        clickPosition.dy + 1.0, // Adding a small value to avoid zero height
      ),
      items: <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'remove',
          child: Row(
            children: [
              Icon(Icons.delete_outline),
              SizedBox(width: 4),
              Text('Remove'),
            ],
          ),
        ),
      ],
    ).then((String? selectedValue) {
      if (selectedValue != null) {
        widget.onRemoveTap();
      }
    });
  }

  /// Handles a tap event on the layer.
  void _onTap() {
    if (_checkHitIsOutsideInCanvas()) return;
    widget.onTap(_layer);
  }

  /// Handles a pointer down event on the layer.
  void _onPointerDown(PointerDownEvent event) {
    if (_checkHitIsOutsideInCanvas()) return;
    if (!isDesktop || event.buttons != kSecondaryMouseButton) {
      widget.onTapDown();
    }
  }

  /// Handles a pointer up event on the layer.
  void _onPointerUp(PointerUpEvent event) {
    widget.onTapUp();
  }

  /// Checks if the hit is outside the canvas for certain types of layers.
  bool _checkHitIsOutsideInCanvas() {
    return _layerType == _LayerType.canvas &&
        !(_layer as PaintingLayerData).item.hit;
  }

  /// Calculates the transformation matrix for the layer's position and rotation.
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
  double get offsetX => _layer.offset.dx + widget.padding.left;

  /// Calculates the vertical offset for the layer.
  double get offsetY => _layer.offset.dy + widget.padding.top;

  @override
  Widget build(BuildContext context) {
    // Position the widget with specified padding
    return Positioned(
      top: offsetY,
      left: offsetX,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: _buildPosition(), // Build the widget content
      ),
    );
  }

  /// Build the content with possible transformations
  Widget _buildPosition() {
    Matrix4 transformMatrix = _calcTransformMatrix();
    return Hero(
      key: _layerKey,
      createRectTween: (begin, end) => RectTween(begin: begin, end: end),
      tag: widget.layerData.hashCode,
      child: Transform(
        transform: transformMatrix,
        alignment: Alignment.center,
        child: Stack(
          children: [
            LayerInteractionHelperWidget(
              layerData: widget.layerData,
              configs: configs,
              selected: widget.selected,
              onEditLayer: widget.onEditTap,
              isInteractive: widget.isInteractive,
              onScaleRotateDown: (details) {
                widget.onScaleRotateDown
                    ?.call(details, context.size ?? Size.zero);
              },
              onScaleRotateUp: widget.onScaleRotateUp,
              onRemoveLayer: widget.onRemoveTap,
              child: MouseRegion(
                hitTestBehavior: HitTestBehavior.translucent,
                cursor: _showMoveCursor
                    ? imageEditorTheme.layerInteraction.hoverCursor
                    : MouseCursor.defer,
                onEnter: (event) {
                  if (_layerType != _LayerType.canvas) {
                    setState(() {
                      _showMoveCursor = true;
                    });
                  }
                },
                onExit: (event) {
                  if (_layerType == _LayerType.canvas) {
                    (widget.layerData as PaintingLayerData).item.hit = false;
                  } else {
                    setState(() {
                      _showMoveCursor = false;
                    });
                  }
                },
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onSecondaryTapUp: isDesktop ? _onSecondaryTapUp : null,
                  onTap: _onTap,
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
                ),
              ),
            ),
            /*     Positioned(
              bottom: imageEditorTheme.layerInteraction.buttonRadius + imageEditorTheme.layerInteraction.strokeWidth * 2,
              right: imageEditorTheme.layerInteraction.buttonRadius + imageEditorTheme.layerInteraction.strokeWidth * 2,
              child: Container(
                width: 105.7,
                height: 115,
                color: Colors.amber,
              ),
            ),
            Positioned(
              top: imageEditorTheme.layerInteraction.buttonRadius + imageEditorTheme.layerInteraction.strokeWidth * 2,
              left: imageEditorTheme.layerInteraction.buttonRadius + imageEditorTheme.layerInteraction.strokeWidth * 2,
              child: Container(
                width: 105.7,
                height: 115,
                color: Colors.deepOrange,
              ),
            ), */
          ],
        ),
      ),
    );
  }

  /// Builds the content widget based on the type of layer being displayed.
  Widget _buildContent() {
    switch (_layerType) {
      case _LayerType.emoji:
        return _buildEmoji();
      case _LayerType.text:
        return _buildText();
      case _LayerType.sticker:
        return _buildSticker();
      case _LayerType.canvas:
        return _buildCanvas();
      default:
        return const SizedBox.shrink();
    }
  }

  double getLineHeight(TextStyle style) {
    final span = TextSpan(text: 'X', style: style);
    final painter = TextPainter(
      text: span,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    painter.layout();
    return painter.preferredLineHeight;
  }

  /// Build the text widget
  Widget _buildText() {
    var fontSize = textEditorConfigs.initFontSize * _layer.scale;
    var layer = _layer as TextLayerData;
    var style = TextStyle(
      fontSize: fontSize * layer.fontScale,
      fontWeight: FontWeight.w400,
      color: layer.color,
      overflow: TextOverflow.ellipsis,
    );

    double height = getLineHeight(style);
    const horizontalPaddingFactor = 0.3;

    return Container(
      // Fix Hit-Box
      padding: EdgeInsets.only(
        left: height * horizontalPaddingFactor,
        right: height * horizontalPaddingFactor,
        bottom: height * 0.175 / 2,
      ),
      child: RoundedBackgroundText(
        layer.text.toString(),
        backgroundColor: layer.background,
        textAlign: layer.align,
        style: layer.textStyle?.copyWith(
              fontSize: style.fontSize,
              fontWeight: style.fontWeight,
              color: style.color,
              fontFamily: style.fontFamily,
            ) ??
            style,
      ),
    );
  }

  /// Build the emoji widget
  Widget _buildEmoji() {
    var layer = _layer as EmojiLayerData;
    return Material(
      // Prevent hero animation bug
      type: MaterialType.transparency,
      textStyle: platformTextStyle(context, designMode),
      child: Text(
        layer.emoji.toString(),
        textAlign: TextAlign.center,
        style: imageEditorTheme.emojiEditor.textStyle.copyWith(
          fontSize: textEditorConfigs.initFontSize * _layer.scale,
        ),
      ),
    );
  }

  /// Build the sticker widget
  Widget _buildSticker() {
    var layer = _layer as StickerLayerData;
    return SizedBox(
      width: (stickerEditorConfigs?.initWidth ?? 100) * layer.scale,
      child: FittedBox(
        fit: BoxFit.contain,
        child: layer.sticker,
      ),
    );
  }

  /// Build the canvas widget
  Widget _buildCanvas() {
    var layer = _layer as PaintingLayerData;
    return Padding(
      // Better hit detection for mobile devices
      padding: EdgeInsets.all(isDesktop ? 0 : 15),
      child: CustomPaint(
        size: layer.size,
        willChange: true,
        isComplex: layer.item.mode == PaintModeE.freeStyle,
        painter: DrawCanvas(
          item: layer.item,
          scale: widget.layerData.scale,
          enabledHitDetection: widget.enableHitDetection,
          freeStyleHighPerformanceScaling:
              widget.freeStyleHighPerformanceScaling,
          freeStyleHighPerformanceMoving: widget.freeStyleHighPerformanceMoving,
        ),
      ),
    );
  }
}

// ignore: camel_case_types
enum _LayerType { emoji, text, sticker, canvas, unknown }

/// Enumeration for controlling the background color mode of the text layer.
enum LayerBackgroundColorModeE {
  background,
  backgroundAndColor,
  backgroundAndColorWithOpacity,
  onlyColor,
}
