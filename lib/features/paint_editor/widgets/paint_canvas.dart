// Dart imports:
import 'dart:async';
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '/core/models/editor_configs/paint_editor/paint_editor_configs.dart';
import '/core/models/layers/layer.dart';
import '/shared/widgets/censor/blur_area_item.dart';
import '/shared/widgets/censor/pixelate_area_item.dart';
import '../controllers/paint_controller.dart';
import '../enums/paint_editor_enum.dart';
import '../models/eraser_model.dart';
import '../models/painted_model.dart';
import '../services/paint_item_hit_test_manager.dart';
import 'draw_paint_item.dart';

/// A widget for creating a canvas for paint on images.
class PaintCanvas extends StatefulWidget {
  const PaintCanvas({
    super.key,
    required this.onRefresh,
    required this.onCreated,
    required this.onRemoveLayer,
    required this.onRemovePartialStart,
    required this.onRemovePartialEnd,
    required this.onTap,
    required this.drawAreaSize,
    required this.editorBodySize,
    required this.paintCtrl,
    required this.paintEditorConfigs,
    required this.layers,
    required this.layerStackScaleFactor,
    required this.eraserMode,
    required this.eraserRadius,
  });

  final Function(PaintedModel item) onCreated;
  final ValueChanged<List<String>> onRemoveLayer;
  final Function() onRemovePartialStart;
  final Function(bool hasRemovedAreas) onRemovePartialEnd;
  final Function(TapDownDetails details) onTap;
  final VoidCallback onRefresh;

  final Size drawAreaSize;
  final Size editorBodySize;
  final double layerStackScaleFactor;

  final PaintController paintCtrl;
  final PaintEditorConfigs paintEditorConfigs;
  final List<Layer> layers;

  final EraserMode eraserMode;
  final double eraserRadius;

  @override
  PaintCanvasState createState() => PaintCanvasState();
}

class PaintCanvasState extends State<PaintCanvas> {
  PaintController get _paintCtrl => widget.paintCtrl;

  late final StreamController<void> _activePaintStreamCtrl;
  TapDownDetails? _tapDownDetails;

  final _hitTestManager = PaintItemHitTestManager();
  bool _hasPartialErasedAreas = false;

  bool get _isPartialEraser => widget.eraserMode == EraserMode.partial;

  @override
  void initState() {
    super.initState();
    _activePaintStreamCtrl = StreamController<void>.broadcast();
  }

  @override
  void dispose() {
    _activePaintStreamCtrl.close();
    super.dispose();
  }

  // ---------------------------
  // Gesture handlers
  // ---------------------------

  void _onScaleStart(ScaleStartDetails details) {
    final offset = details.localFocalPoint;

    switch (_paintCtrl.mode) {
      case PaintMode.moveAndZoom:
        return;

      case PaintMode.eraser:
        _hasPartialErasedAreas = false;
        widget.onRemovePartialStart();
        setState(() {});
        return;

      case PaintMode.polygon:
        // Hexagon (polygon tool) => click + drag (consistent with other shapes)
        widget.onRefresh();
        _paintCtrl
          ..reset()
          ..setStart(offset)
          ..setEnd(offset)
          ..setInProgress(true);

        _paintCtrl.offsets
          ..clear()
          ..addAll(_buildRegularHexagonPoints(start: offset, end: offset));

        _activePaintStreamCtrl.add(null);
        return;

      default:
        // Normal shapes start
        widget.onRefresh();
        _paintCtrl
          ..setStart(offset)
          ..addOffsets(offset)
          ..setInProgress(true);
        _activePaintStreamCtrl.add(null);
        return;
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    switch (_paintCtrl.mode) {
      case PaintMode.moveAndZoom:
        return;

      case PaintMode.eraser:
        _processEraserInput(details);
        return;

      case PaintMode.polygon:
        // Update hexagon preview while dragging
        final offset = details.localFocalPoint;

        if (!_paintCtrl.busy) {
          widget.onRefresh();
          _paintCtrl.setInProgress(true);
        }

        if (_paintCtrl.start == null) {
  _paintCtrl.setStart(offset);
}

        _paintCtrl.setEnd(offset);

        final start = _paintCtrl.start!;
        _paintCtrl.offsets
          ..clear()
          ..addAll(_buildRegularHexagonPoints(start: start, end: offset));

        _activePaintStreamCtrl.add(null);
        return;

      default:
        final offset = details.localFocalPoint;

        if (!_paintCtrl.busy) {
          widget.onRefresh();
          _paintCtrl.setInProgress(true);
        }

        if (_paintCtrl.start == null) {
  _paintCtrl.setStart(offset);
}


        if (_paintCtrl.mode == PaintMode.freeStyle) {
          _paintCtrl.addOffsets(offset);
        }

        _paintCtrl.setEnd(offset);
        _activePaintStreamCtrl.add(null);
        return;
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_paintCtrl.mode == PaintMode.moveAndZoom) return;

    if (_paintCtrl.mode == PaintMode.eraser) {
      if (_isPartialEraser) widget.onRemovePartialEnd(_hasPartialErasedAreas);
      return;
    }

    List<Offset?>? offsets;

    if (_paintCtrl.mode == PaintMode.polygon) {
      // Commit hexagon
      offsets = [..._paintCtrl.offsets];
    } else if (_paintCtrl.start != null && _paintCtrl.end != null) {
      if (_paintCtrl.mode == PaintMode.freeStyle) {
        offsets = [..._paintCtrl.offsets];
      } else {
        offsets = [_paintCtrl.start, _paintCtrl.end];
      }
    }

    _createPainting(offsets);
  }

  // ---------------------------
  // Hexagon points generator
  // ---------------------------

  List<Offset?> _buildRegularHexagonPoints({
    required Offset start,
    required Offset end,
  }) {
    final left = min(start.dx, end.dx);
    final right = max(start.dx, end.dx);
    final top = min(start.dy, end.dy);
    final bottom = max(start.dy, end.dy);

    final center = Offset((left + right) / 2, (top + bottom) / 2);
    final r = min((right - left) / 2, (bottom - top) / 2);

    final points = List<Offset?>.generate(6, (i) {
      final angle = -pi / 2 + (pi / 3) * i; // start from top
      return Offset(
        center.dx + r * cos(angle),
        center.dy + r * sin(angle),
      );
    });

    // close polygon (last = first)
    points.add(points.first);
    return points;
  }

  // ---------------------------
  // Eraser logic (unchanged)
  // ---------------------------

  Offset _rotatePoint(Offset point, Offset center, double angle) {
    if (angle == 0) return point;

    final double cosAngle = cos(angle);
    final double sinAngle = sin(angle);

    final Offset translated = point - center;

    return Offset(
          translated.dx * cosAngle - translated.dy * sinAngle,
          translated.dx * sinAngle + translated.dy * cosAngle,
        ) +
        center;
  }

  void _processEraserInput(ScaleUpdateDetails details) {
    List<String> removeIds = [];
    final Offset focalPoint = details.localFocalPoint;
    final double stackScale = widget.layerStackScaleFactor;
    final Offset editorHalfSize =
        Offset(widget.editorBodySize.width, widget.editorBodySize.height) / 2;

    final bool useRoundCensor =
        widget.paintEditorConfigs.censorConfigs.enableRoundArea;

    for (var layer in widget.layers) {
      if (!layer.isPaintLayer) continue;
      final paintLayer = layer as PaintLayer;
      final layerScale = paintLayer.scale;

      Offset position = focalPoint - editorHalfSize;

      final Size scaledRawSize = paintLayer.rawSize * stackScale * layerScale;

      position += Offset(scaledRawSize.width, scaledRawSize.height) / 2;
      position -= paintLayer.offset * stackScale;

      if (_isPartialEraser) {
        final double rotation = paintLayer.rotation;
        final Offset center =
            Offset(scaledRawSize.width, scaledRawSize.height) / 2;
        final Offset rotatedPosition =
            _rotatePoint(position, center, -rotation);

        layer.item.erasedOffsets
          ..add(ErasedOffset(
            offset: rotatedPosition / layerScale,
            radius: widget.eraserRadius,
          ))
          ..toSet()
          ..toList();
        layer.item = layer.item.copy();
        _hasPartialErasedAreas = true;
      } else {
        final hasHit = _hitTestManager.hitTest(
          item: paintLayer.item,
          position: position,
          scaleFactor: stackScale * layerScale,
          isRoundCensorArea: useRoundCensor,
          paintEditorConfigs: widget.paintEditorConfigs,
        );

        if (hasHit) removeIds.add(layer.id);
      }
    }

    if (_isPartialEraser) {
      widget.onRefresh();
    } else if (removeIds.isNotEmpty) {
      widget.onRemoveLayer(removeIds);
    }
  }

  // ---------------------------
  // Create painted layer
  // ---------------------------

  void _createPainting(List<Offset?>? offsets) {
    if (offsets != null && offsets.isNotEmpty) {
      final rawLayer = PaintedModel(
        offsets: offsets,
        erasedOffsets: [],
        mode: _paintCtrl.mode,
        color: _paintCtrl.color,
        strokeWidth: _paintCtrl.scaledStrokeWidth,
        fill: _paintCtrl.fill,
        opacity: _paintCtrl.opacity,
      );
      widget.onCreated(rawLayer);
    }

    _paintCtrl
      ..setInProgress(false)
      ..reset();

    setState(() {});
  }

  // ---------------------------
  // UI
  // ---------------------------

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _paintCtrl.mode == PaintMode.moveAndZoom,
      child: Stack(
        fit: StackFit.expand,
        children: [_buildActiveItem()],
      ),
    );
  }

  Widget _buildActiveItem() {
    return StreamBuilder<void>(
      stream: _activePaintStreamCtrl.stream,
      builder: (context, snapshot) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,

          // ✅ IMPORTANT: only scale handlers (NO pan handlers)
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,

          // Tap handling for freestyle/eraser (kept from original)
          onTapDown: (details) {
            _tapDownDetails = details;

            if (_paintCtrl.mode == PaintMode.freeStyle ||
                _paintCtrl.mode == PaintMode.eraser) {
              _onScaleStart(ScaleStartDetails(
                focalPoint: details.localPosition,
                localFocalPoint: details.localPosition,
              ));
            }
          },
          onTapUp: (details) {
            if (_paintCtrl.mode == PaintMode.freeStyle ||
                _paintCtrl.mode == PaintMode.eraser) {
              _onScaleUpdate(ScaleUpdateDetails(
                focalPoint: details.localPosition,
                localFocalPoint: details.localPosition,
              ));
              _onScaleEnd(ScaleEndDetails()); // ✅ NOT const
            }
            _tapDownDetails = null;
          },
          onTap: () {
            if (_tapDownDetails != null) widget.onTap(_tapDownDetails!);
          },

          child: _paintCtrl.busy
              ? (_paintCtrl.mode == PaintMode.blur ||
                      _paintCtrl.mode == PaintMode.pixelate)
                  ? Stack(
                      fit: StackFit.expand,
                      children: [_buildCensorItem(_paintCtrl.paintedModel)],
                    )
                  : Opacity(
                      opacity: _paintCtrl.opacity,
                      child: CustomPaint(
                        size: widget.drawAreaSize,
                        willChange: true,
                        isComplex: true,
                        painter: DrawPaintItem(
                          item: _paintCtrl.paintedModel,
                          paintEditorConfigs: widget.paintEditorConfigs,
                        ),
                      ),
                    )
              : const SizedBox.expand(),
        );
      },
    );
  }

  Widget _buildCensorItem(PaintedModel item) {
    final offsets = item.offsets;
    if (offsets.length != 2) return const SizedBox.shrink();

    final topLeft = offsets[0];
    final bottomRight = offsets[1];
    if (topLeft == null || bottomRight == null) return const SizedBox.shrink();

    final width = (bottomRight.dx - topLeft.dx);
    final height = (bottomRight.dy - topLeft.dy);

    final left = width >= 0 ? topLeft.dx : topLeft.dx + width;
    final top = height >= 0 ? topLeft.dy : topLeft.dy + height;

    final censorConfigs = widget.paintEditorConfigs.censorConfigs;

    return Positioned(
      left: left,
      top: top,
      width: width.abs(),
      height: height.abs(),
      child: MouseRegion(
        onEnter: (_) => item.hit = true,
        onExit: (_) => item.hit = false,
        child: item.mode == PaintMode.pixelate
            ? PixelateAreaItem(censorConfigs: censorConfigs)
            : BlurAreaItem(censorConfigs: censorConfigs),
      ),
    );
  }
}
