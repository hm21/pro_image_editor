import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Where the blocks of a censor area pixelated in its own coordinates lie on
/// screen, in device pixels.
@immutable
class LayerSpacePixelateGrid {
  /// Creates a grid of [blockSize] device pixels starting at [origin].
  const LayerSpacePixelateGrid({required this.blockSize, required this.origin});

  /// The grid of an area whose local coordinates map to the screen through
  /// [transform], for blocks of [layerBlockSize] logical pixels of the area,
  /// on a screen of [devicePixelRatio].
  ///
  /// The blocks scale with the transform and start at the area's top-left
  /// corner. A rotated area keeps its blocks upright on screen, starting at
  /// the corner the rotation takes its top-left corner to.
  factory LayerSpacePixelateGrid.of({
    required Matrix4 transform,
    required double layerBlockSize,
    required double devicePixelRatio,
  }) {
    // The length a logical pixel of the area has on screen; the transform's
    // own max scale would count its depth axis, which stays at 1.
    final origin = MatrixUtils.transformPoint(transform, Offset.zero);
    final scale = math.max(
      (MatrixUtils.transformPoint(transform, const Offset(1, 0)) - origin)
          .distance,
      (MatrixUtils.transformPoint(transform, const Offset(0, 1)) - origin)
          .distance,
    );
    return LayerSpacePixelateGrid(
      blockSize: math.max(1, layerBlockSize * scale * devicePixelRatio),
      origin: origin * devicePixelRatio,
    );
  }

  /// The edge length of a block.
  final double blockSize;

  /// The top-left corner of the block at the area's top-left corner.
  final Offset origin;

  @override
  bool operator ==(Object other) =>
      other is LayerSpacePixelateGrid &&
      other.blockSize == blockSize &&
      other.origin == origin;

  @override
  int get hashCode => Object.hash(blockSize, origin);
}

/// A backdrop filter that pixelates its area in blocks of [blockSize] of the
/// area's own logical pixels; see [LayerSpacePixelateGrid].
///
/// The pixelate shader works in device pixels, so the blocks are measured
/// against the area's transform to the screen each time it paints. A parent
/// transform can change without the area painting again, e.g. when the editor
/// zooms, so after every frame the transform is compared and the area
/// repainted when it moved.
class LayerSpacePixelateFilter extends SingleChildRenderObjectWidget {
  /// Creates a filter that pixelates the backdrop behind [child].
  const LayerSpacePixelateFilter({
    super.key,
    required this.shader,
    required this.blockSize,
    required this.devicePixelRatio,
    required this.deviceSize,
    required this.blendMode,
    this.fitToWidth = true,
    this.backdropKey,
    super.child,
  });

  /// The pixelate shader. The filter sets its uniforms, so it must not be
  /// shared with other widgets.
  final ui.FragmentShader shader;

  /// The edge length of a block, in the area's logical pixels.
  final double blockSize;

  /// The device pixel ratio of the screen.
  final double devicePixelRatio;

  /// The size of the screen in device pixels.
  final Size deviceSize;

  /// How the pixelated backdrop is blended with the content behind it.
  final BlendMode blendMode;

  /// Whether the image fits the width of the screen rather than its height.
  ///
  /// The shader scales the blocks by the side the image fits when the final
  /// image renders at another resolution than the screen.
  final bool fitToWidth;

  /// The key of the backdrop group the filter belongs to.
  final BackdropKey? backdropKey;

  @override
  RenderLayerSpacePixelateFilter createRenderObject(BuildContext context) {
    return RenderLayerSpacePixelateFilter(
      shader: shader,
      blockSize: blockSize,
      devicePixelRatio: devicePixelRatio,
      deviceSize: deviceSize,
      blendMode: blendMode,
      fitToWidth: fitToWidth,
      backdropKey: backdropKey,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderLayerSpacePixelateFilter renderObject,
  ) {
    renderObject
      ..shader = shader
      ..blockSize = blockSize
      ..devicePixelRatio = devicePixelRatio
      ..deviceSize = deviceSize
      ..blendMode = blendMode
      ..fitToWidth = fitToWidth
      ..backdropKey = backdropKey;
  }
}

/// The render object of [LayerSpacePixelateFilter].
class RenderLayerSpacePixelateFilter extends RenderProxyBox {
  /// Creates the render object of [LayerSpacePixelateFilter].
  RenderLayerSpacePixelateFilter({
    required this._shader,
    required this._blockSize,
    required this._devicePixelRatio,
    required this._deviceSize,
    required this._blendMode,
    this._fitToWidth = true,
    this._backdropKey,
  });

  ui.FragmentShader _shader;
  double _blockSize;
  double _devicePixelRatio;
  Size _deviceSize;
  BlendMode _blendMode;
  bool _fitToWidth;
  BackdropKey? _backdropKey;

  /// The grid the area was last painted with.
  LayerSpacePixelateGrid? _paintedGrid;

  /// Whether a [_checkTransform] is pending. A detach and attach within one
  /// frame, e.g. when the layer moves in the tree, must not start a second
  /// chain of checks.
  bool _transformCheckScheduled = false;

  /// The pixelate shader.
  set shader(ui.FragmentShader value) {
    if (identical(value, _shader)) return;
    _shader = value;
    markNeedsPaint();
  }

  /// The edge length of a block, in the area's logical pixels.
  set blockSize(double value) {
    if (value == _blockSize) return;
    _blockSize = value;
    markNeedsPaint();
  }

  /// The device pixel ratio of the screen.
  set devicePixelRatio(double value) {
    if (value == _devicePixelRatio) return;
    _devicePixelRatio = value;
    markNeedsPaint();
  }

  /// The size of the screen in device pixels.
  set deviceSize(Size value) {
    if (value == _deviceSize) return;
    _deviceSize = value;
    markNeedsPaint();
  }

  /// How the pixelated backdrop is blended with the content behind it.
  set blendMode(BlendMode value) {
    if (value == _blendMode) return;
    _blendMode = value;
    markNeedsPaint();
  }

  /// Whether the image fits the width of the screen rather than its height.
  set fitToWidth(bool value) {
    if (value == _fitToWidth) return;
    _fitToWidth = value;
    markNeedsPaint();
  }

  /// The key of the backdrop group the filter belongs to.
  set backdropKey(BackdropKey? value) {
    if (value == _backdropKey) return;
    _backdropKey = value;
    markNeedsPaint();
  }

  final LayerHandle<BackdropFilterLayer> _backdropLayer =
      LayerHandle<BackdropFilterLayer>();

  /// The area repaints itself between frames when it moved, see
  /// [_checkTransform]. As its own repaint boundary that repaint stays here
  /// and does not mark the layer's repaint boundary as needing paint, which a
  /// capture of the layer (`RenderRepaintBoundary.toImage`, run between and
  /// even within frames) asserts against.
  @override
  bool get isRepaintBoundary => true;

  @override
  bool get alwaysNeedsCompositing => child != null;

  @override
  void dispose() {
    _backdropLayer.layer = null;
    super.dispose();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _scheduleTransformCheck();
  }

  void _scheduleTransformCheck() {
    if (_transformCheckScheduled) return;
    _transformCheckScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback(_checkTransform);
  }

  LayerSpacePixelateGrid _currentGrid() => LayerSpacePixelateGrid.of(
    transform: getTransformTo(null),
    layerBlockSize: _blockSize,
    devicePixelRatio: _devicePixelRatio,
  );

  /// Repaints when a parent transform moved or scaled the area since it was
  /// last painted. Runs after every frame while attached; it schedules a
  /// frame only when the area moved.
  ///
  /// It waits while the area is not in the scene, e.g. while the editor is
  /// hidden behind a route: a paint is skipped there and marks every hidden
  /// ancestor repaint boundary as needing paint instead, which a capture of
  /// those asserts against. The first frame that shows the area again catches
  /// up.
  void _checkTransform(Duration _) {
    _transformCheckScheduled = false;
    if (!attached) return;
    if (_paintedGrid != null &&
        hasSize &&
        (layer?.attached ?? false) &&
        _currentGrid() != _paintedGrid) {
      markNeedsPaint();
    }
    _scheduleTransformCheck();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) {
      _backdropLayer.layer = null;
      return;
    }
    final grid = _currentGrid();
    _paintedGrid = grid;
    _shader
      ..setFloat(2, grid.blockSize)
      ..setFloat(3, _deviceSize.width)
      ..setFloat(4, _deviceSize.height)
      ..setFloat(5, _fitToWidth ? 1 : 0)
      ..setFloat(6, grid.origin.dx)
      ..setFloat(7, grid.origin.dy)
      ..setFloat(8, 1);

    final backdrop = (_backdropLayer.layer ??= BackdropFilterLayer())
      ..filter = ui.ImageFilter.shader(_shader)
      ..blendMode = _blendMode
      ..backdropKey = _backdropKey;
    context.pushLayer(backdrop, super.paint, offset);
  }
}
