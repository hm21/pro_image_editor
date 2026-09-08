import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '/core/models/custom_widgets/layer_interaction_widgets.dart';
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/layers/layer.dart';
import '/features/main_editor/main_editor.dart';
import '../models/float_select_configs.dart';
import '../painter/float_select_border_painter.dart';
import 'float_select_resize_handler.dart';
import 'float_select_toolbar.dart';

/// Overlay with selection border, toolbar, and resize handlers
class FloatSelectionOverlay extends StatefulWidget {
  /// Creates an overlay for the selected layer
  const FloatSelectionOverlay({
    super.key,
    required this.info,
    required this.layer,
    required this.interactions,
    required this.editorKey,
    this.configs = const FloatSelectConfigs(),
    this.safeArea = EdgeInsets.zero,
  });

  /// Layout info from the editor's layer overlay
  final OverlayChildLayoutInfo info;

  /// The selected layer to decorate
  final Layer layer;

  /// Interaction callbacks for this layer
  final LayerItemInteractions interactions;

  /// Reference to the editor widget
  final GlobalKey<ProImageEditorState> editorKey;

  /// UI configs including style, i18n, and widgets
  final FloatSelectConfigs configs;

  /// The padding values that define the safe area insets for the overlay,
  /// typically used to avoid system UI intrusions such as notches, status bars,
  /// or navigation bars.
  final EdgeInsets safeArea;

  @override
  State<FloatSelectionOverlay> createState() => _FloatSelectionOverlayState();
}

/// State for [FloatSelectionOverlay]
class _FloatSelectionOverlayState extends State<FloatSelectionOverlay> {
  final _overlayCtrl = OverlayPortalController();

  final _transformedLayerKey = GlobalKey();
  final _stackKey = GlobalKey();
  final _toolbarKey = GlobalKey();

  final _positions = const [
    _Position(bottom: 0, left: 0),
    _Position(top: 0, left: 0),
    _Position(top: 0, right: 0),
    _Position(bottom: 0, right: 0),
  ];

  FloatSelectWidgets get _widgets => widget.configs.widgets;
  FloatSelectStyle get _style => widget.configs.style;
  OverlayChildLayoutInfo get _info => widget.info;

  double get _handlerLength =>
      _style.handlerLength ?? (!isDesktop ? 36.0 : 20.0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _overlayCtrl.show();
      // Ensure toolbar bounding-box is calculated.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    if (_overlayCtrl.isShowing) _overlayCtrl.hide();
    super.dispose();
  }

  /// Calculates the toolbar offset with clamping to the visible area
  Offset _calculateToolbarOffset() {
    final renderBox = _transformedLayerKey.currentContext?.findRenderObject();
    final parentBox = _stackKey.currentContext?.findRenderObject();
    final toolbarBox = _toolbarKey.currentContext?.findRenderObject();

    if (renderBox is! RenderBox ||
        parentBox is! RenderBox ||
        !renderBox.hasSize ||
        !parentBox.hasSize) {
      return Offset.zero;
    }

    final layerSize = renderBox.size;
    final parentSize = parentBox.size;

    // Convert corners of the layer to local coordinates
    final topLeft = parentBox.globalToLocal(
      renderBox.localToGlobal(Offset.zero),
    );
    final topRight = parentBox.globalToLocal(
      renderBox.localToGlobal(Offset(layerSize.width, 0)),
    );
    final bottomLeft = parentBox.globalToLocal(
      renderBox.localToGlobal(Offset(0, layerSize.height)),
    );
    final bottomRight = parentBox.globalToLocal(
      renderBox.localToGlobal(Offset(layerSize.width, layerSize.height)),
    );

    // Get bounds and center
    final allX = [topLeft.dx, topRight.dx, bottomLeft.dx, bottomRight.dx];
    final allY = [topLeft.dy, topRight.dy, bottomLeft.dy, bottomRight.dy];
    final minX = allX.reduce(min);
    final maxX = allX.reduce(max);
    final minY = allY.reduce(min);
    final centerX = (minX + maxX) / 2;

    // Toolbar size
    double toolboxWidth = 0;
    double toolboxHeight = 0;
    if (toolbarBox is RenderBox) {
      toolboxWidth = toolbarBox.size.width;
      toolboxHeight = toolbarBox.size.height;
    }

    // Final clamped position
    final dx = (centerX + _style.offset.dx).clamp(
      toolboxWidth / 2 + widget.safeArea.left,
      parentSize.width - toolboxWidth / 2 - widget.safeArea.right,
    );
    final dy = (minY + _style.offset.dy).clamp(
      toolboxHeight + widget.safeArea.top,
      parentSize.height - widget.safeArea.bottom,
    );

    return Offset(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    final padding = _style.selectionPadding;
    final Matrix4 transform = _info.childPaintTransform.clone();
    final childWidth = _info.childSize.width;
    final childHeight = _info.childSize.height;

    final paddedWidth = childWidth + padding.horizontal;
    final paddedHeight = childHeight + padding.vertical;

    transform.translateByDouble(-padding.left, -padding.top, 0.0, 1.0);

    return OverlayPortal(
      controller: _overlayCtrl,
      overlayChildBuilder: (context) {
        if (_widgets.overlayToolbar != null) return _widgets.overlayToolbar!;

        final offset = _calculateToolbarOffset();
        return Positioned(
          top: offset.dy,
          left: offset.dx,
          child: FractionalTranslation(
            translation: const Offset(-0.5, -1),
            child: SizedBox(
              key: _toolbarKey,
              child:
                  _widgets.toolbar ??
                  FloatSelectToolbar(
                    layer: widget.layer,
                    interactions: widget.interactions,
                    editorKey: widget.editorKey,
                    configs: widget.configs,
                  ),
            ),
          ),
        );
      },
      child: Stack(
        key: _stackKey,
        children: [
          Positioned(
            width: paddedWidth,
            height: paddedHeight,
            child: Transform(
              transform: transform,
              child: Transform.flip(
                key: _transformedLayerKey,
                flipX: widget.layer.flipX,
                flipY: widget.layer.flipY,
                child: _buildSelectionOverlay(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the selection UI with border and corner handlers
  Widget _buildSelectionOverlay() {
    return Stack(
      fit: StackFit.passthrough,
      alignment: Alignment.center,
      children: [
        // Border
        CustomPaint(
          foregroundPainter: FloatSelectBorderPainter(
            borderColor: _style.strokeColor,
            strokeWidth: _style.strokeWidth,
            spacer: _handlerLength + _style.handlerGap,
            outsideSpace: _style.outsideSpace,
          ),
        ),
        // Corner handlers
        ...List.generate(4, (index) {
          double? offsetHelper(double? v) =>
              v != null ? v + _style.outsideSpace : null;

          final pos = _positions[index];

          return Positioned(
            top: offsetHelper(pos.top),
            left: offsetHelper(pos.left),
            right: offsetHelper(pos.right),
            bottom: offsetHelper(pos.bottom),
            child: FloatSelectResizeRotateHandler(
              interactions: widget.interactions,
              handlerLength: _handlerLength,
              rotationCount: index,
              strokeWidth: _style.strokeWidth * 1.5,
              strokeColor: _style.strokeColor,
            ),
          );
        }),
      ],
    );
  }
}

/// Helper class to position corner handlers
class _Position {
  const _Position({this.top, this.left, this.right, this.bottom});

  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
}
