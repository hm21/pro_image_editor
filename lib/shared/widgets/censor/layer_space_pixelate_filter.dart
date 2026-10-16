import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '/shared/services/shader_manager.dart';

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
/// The area does not filter the backdrop on its own: it shows a pass of
/// [group] that pixelates many areas at once; see [LayerSpacePixelateGroup].
class LayerSpacePixelateFilter extends SingleChildRenderObjectWidget {
  /// Creates a filter that pixelates the backdrop behind [child].
  const LayerSpacePixelateFilter({
    super.key,
    required this.group,
    required this.blockSize,
    required this.devicePixelRatio,
    required this.deviceSize,
    required this.blendMode,
    this.fitToWidth = true,
    this.isOval = false,
    super.child,
  });

  /// The group whose shared passes pixelate the area.
  final LayerSpacePixelateGroup group;

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

  /// Whether the area is clipped to an oval rather than its rectangle.
  ///
  /// A pixel of a shared pass takes the grid of the topmost area that covers
  /// it, so the pass needs the area's shape.
  final bool isOval;

  @override
  RenderLayerSpacePixelateFilter createRenderObject(BuildContext context) {
    return RenderLayerSpacePixelateFilter(
      group: group,
      blockSize: blockSize,
      devicePixelRatio: devicePixelRatio,
      deviceSize: deviceSize,
      blendMode: blendMode,
      fitToWidth: fitToWidth,
      isOval: isOval,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderLayerSpacePixelateFilter renderObject,
  ) {
    renderObject
      ..group = group
      ..blockSize = blockSize
      ..devicePixelRatio = devicePixelRatio
      ..deviceSize = deviceSize
      ..blendMode = blendMode
      ..fitToWidth = fitToWidth
      ..isOval = isOval;
  }
}

/// The render object of [LayerSpacePixelateFilter].
class RenderLayerSpacePixelateFilter extends RenderProxyBox {
  /// Creates the render object of [LayerSpacePixelateFilter].
  RenderLayerSpacePixelateFilter({
    required this._group,
    required this._blockSize,
    required this._devicePixelRatio,
    required this._deviceSize,
    required this._blendMode,
    this._fitToWidth = true,
    this._isOval = false,
  });

  LayerSpacePixelateGroup _group;
  double _blockSize;
  double _devicePixelRatio;
  Size _deviceSize;
  BlendMode _blendMode;
  bool _fitToWidth;
  bool _isOval;

  /// The filter of the pass that pixelates the area, or `null` while the
  /// area is in none.
  ui.ImageFilter? _passFilter;

  /// The backdrop key of that pass.
  BackdropKey? _passKey;

  /// The filter of the pass that pixelates the area, or `null` while the
  /// area is in none.
  @visibleForTesting
  ui.ImageFilter? get passFilter => _passFilter;

  /// The backdrop key of the pass that pixelates the area.
  @visibleForTesting
  BackdropKey? get passKey => _passKey;

  /// The group whose shared passes pixelate the area.
  set group(LayerSpacePixelateGroup value) {
    if (identical(value, _group)) return;
    if (attached) {
      _group._remove(this);
      value._add(this);
    }
    _group = value;
    _usePass(null, null);
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

  /// Whether the area is clipped to an oval rather than its rectangle.
  set isOval(bool value) {
    if (value == _isOval) return;
    _isOval = value;
    markNeedsPaint();
  }

  final LayerHandle<BackdropFilterLayer> _backdropLayer =
      LayerHandle<BackdropFilterLayer>();

  /// The group updates the filter of a pass without repainting its areas, so
  /// a capture of the layer (`RenderRepaintBoundary.toImage`, run between and
  /// even within frames) never finds a boundary that needs paint. As its own
  /// repaint boundary a change of the area's own settings stays here as well.
  @override
  bool get isRepaintBoundary => true;

  @override
  bool get alwaysNeedsCompositing => child != null;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _group._add(this);
  }

  @override
  void detach() {
    _group._remove(this);
    super.detach();
  }

  @override
  void dispose() {
    _backdropLayer.layer = null;
    super.dispose();
  }

  /// Shows the pass with [filter] and [key], also on the layer painted
  /// before. Returns whether the area has no such layer yet and needs to
  /// paint to show the pass.
  ///
  /// The renderer only shares a pass between areas whose filters are all
  /// equal, so an area that stays out of every pass leaves its key: an old
  /// filter left on the key would make every other area of it render on its
  /// own.
  bool _usePass(ui.ImageFilter? filter, BackdropKey? key) {
    _passFilter = filter;
    _passKey = key;
    final layer = _backdropLayer.layer;
    if (layer == null) return filter != null;
    if (filter != null) layer.filter = filter;
    layer.backdropKey = key;
    return false;
  }

  /// Whether the area's layer is part of the scene.
  bool get _isInScene => layer?.attached ?? false;

  /// Where the area lies on screen and the grid it is pixelated in, or
  /// `null` while it has no area to pixelate.
  LayerSpacePixelateArea? _currentArea() {
    if (child == null || !attached || !hasSize || size.isEmpty) return null;
    final toGlobal = getTransformTo(null);
    final toDevice = Matrix4.diagonal3Values(
      _devicePixelRatio,
      _devicePixelRatio,
      1,
    )..multiply(toGlobal);
    final fromDevice = Matrix4.tryInvert(toDevice);
    if (fromDevice == null) return null;
    return LayerSpacePixelateArea.of(
      fromDevice: fromDevice,
      size: size,
      grid: LayerSpacePixelateGrid.of(
        transform: toGlobal,
        layerBlockSize: _blockSize,
        devicePixelRatio: _devicePixelRatio,
      ),
      isOval: _isOval,
      deviceSize: _deviceSize,
      fitToWidth: _fitToWidth,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) {
      _backdropLayer.layer = null;
      return;
    }
    _group._updateForPaint();
    final filter = _passFilter;
    if (filter == null) {
      _backdropLayer.layer = null;
      super.paint(context, offset);
      return;
    }
    _group._awaitingPaint.remove(this);
    final backdrop = (_backdropLayer.layer ??= BackdropFilterLayer())
      ..filter = filter
      ..blendMode = _blendMode
      ..backdropKey = _passKey;
    context.pushLayer(backdrop, super.paint, offset);
  }
}

/// A censor area as a pass of [LayerSpacePixelateGroup] sees it.
@immutable
class LayerSpacePixelateArea {
  /// Creates an area from its values in a pass.
  const LayerSpacePixelateArea({
    required this.toUnit,
    required this.grid,
    required this.isOval,
    required this.deviceSize,
    required this.fitToWidth,
  });

  /// The area of [size] logical pixels whose local coordinates the map
  /// [fromDevice] reaches from device pixels.
  factory LayerSpacePixelateArea.of({
    required Matrix4 fromDevice,
    required Size size,
    required LayerSpacePixelateGrid grid,
    required bool isOval,
    required Size deviceSize,
    required bool fitToWidth,
  }) {
    final m = fromDevice.storage;
    final w = size.width;
    final h = size.height;
    return LayerSpacePixelateArea(
      toUnit: [m[0] / w, m[4] / w, m[12] / w, m[1] / h, m[5] / h, m[13] / h],
      grid: grid,
      isOval: isOval,
      deviceSize: deviceSize,
      fitToWidth: fitToWidth,
    );
  }

  /// The two rows of the affine map from device pixels to the area's unit
  /// square, the area's top-left corner at the origin.
  final List<double> toUnit;

  /// The blocks the area is pixelated in.
  final LayerSpacePixelateGrid grid;

  /// Whether the area is an oval rather than its rectangle.
  final bool isOval;

  /// The size of the screen in device pixels.
  final Size deviceSize;

  /// Whether the image fits the width of the screen rather than its height.
  final bool fitToWidth;

  /// The number of floats an area takes in the shader's uniforms.
  static const int uniformLength = 12;

  /// Writes the area to the uniforms of the pass shader from [index] on.
  void writeTo(ui.FragmentShader shader, int index) {
    shader
      ..setFloat(index, toUnit[0])
      ..setFloat(index + 1, toUnit[1])
      ..setFloat(index + 2, toUnit[2])
      ..setFloat(index + 3, 0)
      ..setFloat(index + 4, toUnit[3])
      ..setFloat(index + 5, toUnit[4])
      ..setFloat(index + 6, toUnit[5])
      ..setFloat(index + 7, 0)
      ..setFloat(index + 8, grid.origin.dx)
      ..setFloat(index + 9, grid.origin.dy)
      ..setFloat(index + 10, grid.blockSize)
      ..setFloat(index + 11, isOval ? 1 : 0);
  }

  @override
  bool operator ==(Object other) =>
      other is LayerSpacePixelateArea &&
      listEquals(other.toUnit, toUnit) &&
      other.grid == grid &&
      other.isOval == isOval &&
      other.deviceSize == deviceSize &&
      other.fitToWidth == fitToWidth;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(toUnit), grid, isOval, deviceSize, fitToWidth);
}

/// Pixelates the [LayerSpacePixelateFilter]s of a `CensorScope` in shared
/// passes.
///
/// The renderer filters the backdrop once for all backdrop filters of a key
/// only when their filters are all equal; otherwise every one of them renders
/// an offscreen pass of its own, and with many areas that runs out of memory.
/// Areas pixelated in their own coordinates differ in their grids, so instead
/// of a shader each, up to [maxAreasPerPass] areas share one whose uniforms
/// hold the grids of all of them, and every area of a pass shows the same
/// filter. A pixel takes the grid of the topmost area that covers it.
///
/// The grids follow the areas' transforms to the screen. They are measured
/// when an area paints and after every frame, since a parent transform can
/// change without any area painting again, e.g. when the editor zooms. A
/// change then updates the filter of every area without repainting it. Until
/// then a pixel that no area covers in the pass takes the grid of the nearest
/// one, so it stays pixelated.
class LayerSpacePixelateGroup {
  /// Creates a group whose passes [createPass] makes, by default with the
  /// shader of `ShaderMode.pixelateAreas` once it is loaded.
  LayerSpacePixelateGroup({LayerSpacePixelatePassFactory? createPass})
    : _createPass = createPass ?? _ShaderPixelatePass.create;

  /// The most areas one pass pixelates; the shader holds this many grids.
  static const int maxAreasPerPass = 32;

  final LayerSpacePixelatePassFactory _createPass;
  final Set<RenderLayerSpacePixelateFilter> _members = {};
  final List<LayerSpacePixelatePass> _passes = [];

  /// The areas in the passes, from the bottom one to the top one.
  List<RenderLayerSpacePixelateFilter> _passMembers = const [];

  /// Where those areas were when the passes were written.
  List<LayerSpacePixelateArea> _passAreas = const [];

  /// Areas that got a pass without a layer to show it on, e.g. because they
  /// painted before the shader loaded. They repaint after the frame, as an
  /// area cannot mark another as needing paint while it paints itself.
  final Set<RenderLayerSpacePixelateFilter> _awaitingPaint = {};

  bool _membersChanged = true;
  bool _updatedThisFrame = false;
  bool _checkScheduled = false;
  bool _disposed = false;

  /// The number of passes the group currently renders.
  @visibleForTesting
  int get passCount => _passes.length;

  /// The areas in the passes, from the bottom one to the top one.
  @visibleForTesting
  List<RenderLayerSpacePixelateFilter> get passMembers => _passMembers;

  void _add(RenderLayerSpacePixelateFilter member) {
    if (_disposed) return;
    _members.add(member);
    _membersChanged = true;
    _scheduleCheck();
  }

  void _remove(RenderLayerSpacePixelateFilter member) {
    if (!_members.remove(member)) return;
    _awaitingPaint.remove(member);
    member._usePass(null, null);
    _membersChanged = true;
    _scheduleCheck();
  }

  /// Releases the shaders of the passes.
  void dispose() {
    _disposed = true;
    _disposePasses();
  }

  void _disposePasses() {
    for (final pass in _passes) {
      pass.dispose();
    }
    _passes.clear();
    _passMembers = const [];
    _passAreas = const [];
  }

  void _updateForPaint() {
    if (_updatedThisFrame) return;
    _updatedThisFrame = true;
    _update();
    _scheduleCheck();
  }

  void _scheduleCheck() {
    if (_checkScheduled || _disposed) return;
    _checkScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback(_check);
  }

  /// Catches the areas a parent transform moved without them painting.
  /// Runs after every frame while the group has areas; it schedules a frame
  /// only when a pass changed.
  void _check(Duration _) {
    _checkScheduled = false;
    _updatedThisFrame = false;
    if (_disposed) return;
    if (_members.isEmpty) {
      _disposePasses();
      return;
    }
    if (_update()) SchedulerBinding.instance.scheduleFrame();
    // An area that is not in the scene, e.g. while the editor is hidden
    // behind a route, waits: its paint would be skipped and mark every hidden
    // ancestor repaint boundary as needing paint instead, which a capture of
    // those asserts against.
    _awaitingPaint.removeWhere((member) {
      if (!member.attached) return true;
      if (!member._isInScene) return false;
      member.markNeedsPaint();
      return true;
    });
    _scheduleCheck();
  }

  /// Writes the passes for where the areas are now. Returns whether a pass
  /// changed.
  bool _update() {
    final members = <RenderLayerSpacePixelateFilter>[];
    final areas = <LayerSpacePixelateArea>[];
    for (final member in _inPaintOrder()) {
      final area = member._currentArea();
      if (area == null) {
        member._usePass(null, null);
        _awaitingPaint.remove(member);
        continue;
      }
      members.add(member);
      areas.add(area);
    }
    if (!_membersChanged &&
        listEquals(members, _passMembers) &&
        listEquals(areas, _passAreas)) {
      return false;
    }

    final passCount = (areas.length + maxAreasPerPass - 1) ~/ maxAreasPerPass;
    while (_passes.length > passCount) {
      _passes.removeLast().dispose();
    }
    while (_passes.length < passCount) {
      final pass = _createPass();
      // Not loaded yet; the areas show their passes once it is.
      if (pass == null) return false;
      _passes.add(pass);
    }
    _membersChanged = false;
    _passMembers = members;
    _passAreas = areas;
    for (var p = 0; p < passCount; p++) {
      final start = p * maxAreasPerPass;
      final end = math.min(start + maxAreasPerPass, areas.length);
      final pass = _passes[p]..write(areas.sublist(start, end));
      for (var i = start; i < end; i++) {
        if (members[i]._usePass(pass.filter, pass.key)) {
          _awaitingPaint.add(members[i]);
        }
      }
    }
    return true;
  }

  /// The attached areas in the order they paint, the bottom one first.
  List<RenderLayerSpacePixelateFilter> _inPaintOrder() {
    final childIndices = <RenderObject, Map<RenderObject, int>>{};
    List<int> pathOf(RenderObject node) {
      final path = <int>[];
      RenderObject child = node;
      RenderObject? parent = node.parent;
      while (parent != null) {
        final container = parent;
        final indices = childIndices.putIfAbsent(container, () {
          final map = <RenderObject, int>{};
          container.visitChildren((c) => map[c] = map.length);
          return map;
        });
        path.add(indices[child] ?? 0);
        child = container;
        parent = container.parent;
      }
      return path.reversed.toList();
    }

    final paths = [
      for (final member in _members)
        if (member.attached) (member, pathOf(member)),
    ]..sort((a, b) => _comparePaths(a.$2, b.$2));
    return [for (final entry in paths) entry.$1];
  }

  static int _comparePaths(List<int> a, List<int> b) {
    final length = math.min(a.length, b.length);
    for (var i = 0; i < length; i++) {
      if (a[i] != b[i]) return a[i].compareTo(b[i]);
    }
    return a.length.compareTo(b.length);
  }
}

/// Creates a pass of a [LayerSpacePixelateGroup], or returns `null` while it
/// cannot yet.
typedef LayerSpacePixelatePassFactory = LayerSpacePixelatePass? Function();

/// One shared pass of a [LayerSpacePixelateGroup]: a filter that pixelates
/// up to [LayerSpacePixelateGroup.maxAreasPerPass] areas, each in its own
/// grid.
abstract class LayerSpacePixelatePass {
  /// The key every area of the pass shows it under.
  BackdropKey get key;

  /// The filter every area of the pass shows.
  ///
  /// A new one after each [write]: the renderer keeps the uniforms a filter
  /// was composed with, so an older one keeps the old grids.
  ui.ImageFilter get filter;

  /// Pixelates [areas], the bottom one first.
  void write(List<LayerSpacePixelateArea> areas);

  /// Releases the pass.
  void dispose();
}

/// A pass of the `pixelate_areas` shader.
class _ShaderPixelatePass implements LayerSpacePixelatePass {
  _ShaderPixelatePass(this._shader);

  /// A pass of the loaded shader, or `null` while it loads.
  static LayerSpacePixelatePass? create() {
    final program = ShaderManager.instance.programs[ShaderMode.pixelateAreas];
    if (program == null) return null;
    return _ShaderPixelatePass(program.fragmentShader());
  }

  /// The index of the first area in the shader's uniforms.
  static const int _firstAreaIndex = 8;

  final ui.FragmentShader _shader;

  @override
  final BackdropKey key = BackdropKey();

  @override
  late ui.ImageFilter filter;

  @override
  void write(List<LayerSpacePixelateArea> areas) {
    final first = areas.first;
    _shader
      ..setFloat(2, first.deviceSize.width)
      ..setFloat(3, first.deviceSize.height)
      ..setFloat(4, first.fitToWidth ? 1 : 0)
      ..setFloat(5, areas.length.toDouble())
      ..setFloat(6, 0)
      ..setFloat(7, 0);
    for (var i = 0; i < areas.length; i++) {
      areas[i].writeTo(
        _shader,
        _firstAreaIndex + i * LayerSpacePixelateArea.uniformLength,
      );
    }
    filter = ui.ImageFilter.shader(_shader);
  }

  @override
  void dispose() => _shader.dispose();
}
