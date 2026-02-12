// Dart imports:
import 'dart:async';
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

import '/core/models/editor_configs/paint_editor/paint_editor_configs.dart';
import '/core/models/layers/layer.dart';
import '/shared/widgets/censor/blur_area_item.dart';
import '/shared/widgets/censor/pixelate_area_item.dart';
import '../controllers/paint_controller.dart';
import '../enums/paint_editor_enum.dart';
import '../models/eraser_model.dart';
import '../services/paint_item_hit_test_manager.dart';
import 'draw_paint_item.dart';

/// A widget for creating a canvas for paint on images.
///
/// This widget allows you to create a canvas for paint on images loaded
/// from various sources, including network URLs, asset paths, files, or memory
/// (Uint8List).
/// It provides customization options for appearance and behavior.
class PaintCanvas extends StatefulWidget {
  /// Constructs a `PaintCanvas` widget.
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

  /// Callback function when the active paint is done.
  final Function(PaintedModel item) onCreated;

  /// Callback invoked when layers are removed.
  ///
  /// Receives a list of layer identifiers that have been removed.
  final ValueChanged<List<String>> onRemoveLayer;

  /// Callback triggered when the user begins a partial erase action.
  final Function() onRemovePartialStart;

  /// Callback triggered when the user finishes a partial erase action.
  ///
  /// [hasRemovedAreas] is `true` if at least one area was erased during
  /// the action, otherwise `false`.
  final Function(bool hasRemovedAreas) onRemovePartialEnd;

  /// Callback function that is triggered when a tap down event occurs on the
  /// canvas.
  ///
  /// The [details] parameter provides information about the position and
  /// characteristics of the tap event. This callback can be used to handle
  /// custom tap interactions within the paint editor.
  final Function(TapDownDetails details) onTap;

  /// Callback to refresh the current state or view.
  final VoidCallback onRefresh;

  /// Size of the image.
  final Size drawAreaSize;

  /// Size of the paint editor body.
  final Size editorBodySize;

  /// The scale factor applied to the layer stack, used to adjust the size
  /// of the canvas layers relative to their original dimensions.
  final double layerStackScaleFactor;

  /// The `PaintController` class is responsible for managing and controlling
  /// the paint state.
  final PaintController paintCtrl;

  /// Configuration settings for the paint editor.
  /// This field holds an instance of [PaintEditorConfigs] which contains
  /// various settings and options used to customize the behavior and
  /// appearance of the paint editor.
  final PaintEditorConfigs paintEditorConfigs;

  /// A list of layers that make up the paint canvas.
  final List<Layer> layers;

  /// The current eraser mode used in the paint canvas.
  ///
  /// Determines how the eraser tool behaves when removing paint strokes,
  /// such as whether it erases pixel by pixel or removes entire stroke paths.
  final EraserMode eraserMode;

  /// The radius of the eraser tool in logical pixels.
  ///
  /// This value determines the size of the eraser when removing painted content
  /// from the canvas. A larger radius creates a bigger eraser area.
  final double eraserRadius;

  @override
  PaintCanvasState createState() => PaintCanvasState();
}

/// State class for managing the paint canvas.
class PaintCanvasState extends State<PaintCanvas> {
  /// Getter for accessing the [PaintController] instance provided by the
  /// parent widget.
  PaintController get _paintCtrl => widget.paintCtrl;

  /// Stream controller for updating paint events.
  late final StreamController<void> _activePaintStreamCtrl;
  TapDownDetails? _tapDownDetails;
  final _hitTestManager = PaintItemHitTestManager();

  bool _hasPartialErasedAreas = false;

  /// Tracks the number of active pointers to detect multi-touch gestures.
  /// When more than one pointer is active, drawing is disabled to allow
  /// pinch-to-zoom gestures.
  int _activePointerCount = 0;

  /// Tracks whether the current gesture started as a multi-touch gesture.
  /// Used to prevent drawing when the user is performing a pinch-to-zoom.
  bool _isMultiTouch = false;

  /// Tracks the position of the first pointer for tap detection.
  Offset? _pointerDownPosition;

  /// Maximum distance in logical pixels between pointer down and up positions
  /// for the interaction to be considered a tap rather than a drag gesture.
  static const double _tapDistanceThreshold = 10.0;

  bool get _isPartialEraser => widget.eraserMode == EraserMode.partial;
  bool get _isFreeStyleMode =>
      _paintCtrl.mode == PaintMode.freeStyle ||
      _paintCtrl.mode == PaintMode.freeStyleArrowStart ||
      _paintCtrl.mode == PaintMode.freeStyleArrowEnd ||
      _paintCtrl.mode == PaintMode.freeStyleArrowStartEnd;

  @override
  void initState() {
    super.initState();
    _activePaintStreamCtrl = StreamController.broadcast();
  }

  @override
  void dispose() {
    _activePaintStreamCtrl.close();
    super.dispose();
  }

  /// Handles the pointer down event for immediate response to touch/stylus
  /// input.
  ///
  /// This uses the low-level [Listener] widget instead of [GestureDetector]
  /// to eliminate gesture disambiguation delays, significantly reducing drawing
  /// latency on devices like iPad with Apple Pencil.
  void _onPointerDown(PointerDownEvent event) {
    _activePointerCount++;
    if (_activePointerCount > 1) {
      // Multi-touch detected - disable drawing to allow pinch-to-zoom
      _isMultiTouch = true;
      // Cancel any ongoing drawing
      if (_paintCtrl.busy) {
        _paintCtrl
          ..setInProgress(false)
          ..reset();
        _activePaintStreamCtrl.add(null);
      }
      return;
    }

    _pointerDownPosition = event.localPosition;
    final offset = event.localPosition;

    switch (widget.paintCtrl.mode) {
      case PaintMode.moveAndZoom:
        return;
      case PaintMode.eraser:
        _hasPartialErasedAreas = false;
        widget.onRemovePartialStart();
        setState(() {});
        return;
      case PaintMode.polygon:
        // Only add the point on pointer down; completion check happens on
        // pointer up when we can verify this was a tap (not a drag gesture)
        _addPolygonPoint(offset);
        return;
      default:
        _paintCtrl
          ..setStart(offset)
          ..addOffsets(offset);
        _activePaintStreamCtrl.add(null);
        break;
    }
  }

  /// Handles the pointer move event for continuous drawing updates.
  ///
  /// This provides immediate response to pointer movement without the
  /// gesture disambiguation delay that occurs with [GestureDetector].
  void _onPointerMove(PointerMoveEvent event) {
    // Skip if multi-touch gesture is active (pinch-to-zoom)
    if (_isMultiTouch || _activePointerCount > 1) return;

    final offset = event.localPosition;

    switch (widget.paintCtrl.mode) {
      case PaintMode.moveAndZoom:
      case PaintMode.polygon:
        return;
      case PaintMode.eraser:
        _processEraserInputAt(offset);
        break;
      default:
        if (!_paintCtrl.busy) {
          widget.onRefresh();
          _paintCtrl.setInProgress(true);
        }

        if (_paintCtrl.start == null) {
          _paintCtrl.setStart(offset);
        }

        if (_isFreeStyleMode) {
          _paintCtrl.addOffsets(offset);
        }

        _paintCtrl.setEnd(offset);

        _activePaintStreamCtrl.add(null);
    }
  }

  /// Handles the pointer up event to finalize drawing.
  void _onPointerUp(PointerUpEvent event) {
    _activePointerCount = max(0, _activePointerCount - 1);

    // If this was part of a multi-touch gesture, reset and return
    if (_isMultiTouch) {
      if (_activePointerCount == 0) {
        _isMultiTouch = false;
      }
      return;
    }

    final offset = event.localPosition;

    // Handle tap detection for polygon and other modes
    if (_pointerDownPosition != null) {
      final distance = (offset - _pointerDownPosition!).distance;
      // If movement was minimal, treat as a tap
      if (distance < _tapDistanceThreshold) {
        _tapDownDetails = TapDownDetails(
          globalPosition: event.position,
          localPosition: event.localPosition,
        );
        // For polygon mode, check if the shape should be completed on tap
        if (_paintCtrl.mode == PaintMode.polygon) {
          _checkPolygonIsComplete();
        }
        widget.onTap(_tapDownDetails!);
        _tapDownDetails = null;
      }
    }
    _pointerDownPosition = null;

    if (widget.paintCtrl.mode == PaintMode.moveAndZoom) {
      return;
    } else if (widget.paintCtrl.mode == PaintMode.eraser) {
      // Eraser mode doesn't create paintings - it only removes existing ones.
      // The removal is handled during pointer move via _processEraserInputAt.
      if (_isPartialEraser) widget.onRemovePartialEnd(_hasPartialErasedAreas);
      return;
    }

    List<Offset?>? offsets;

    if (_paintCtrl.start != null && _paintCtrl.end != null) {
      if (_isFreeStyleMode) {
        offsets = [..._paintCtrl.offsets];
      } else if (_paintCtrl.start != null && _paintCtrl.end != null) {
        offsets = [_paintCtrl.start, _paintCtrl.end];
      }
    } else if (_paintCtrl.mode == PaintMode.polygon) {
      _checkPolygonIsComplete();
      return;
    }
    _createPainting(offsets);
  }

  /// Handles the pointer cancel event to clean up state.
  void _onPointerCancel(PointerCancelEvent event) {
    _activePointerCount = max(0, _activePointerCount - 1);
    _pointerDownPosition = null;

    if (_activePointerCount == 0) {
      _isMultiTouch = false;
    }

    // Reset any ongoing drawing
    if (_paintCtrl.busy) {
      _paintCtrl
        ..setInProgress(false)
        ..reset();
      _activePaintStreamCtrl.add(null);
    }
  }

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

  /// Processes eraser input at the given position.
  ///
  /// This method handles both full stroke and partial erasing based on
  /// the current [EraserMode].
  void _processEraserInputAt(Offset focalPoint) {
    List<String> removeIds = [];
    final double stackScale = widget.layerStackScaleFactor;
    final Offset editorHalfSize = Offset(
          widget.editorBodySize.width,
          widget.editorBodySize.height,
        ) /
        2;
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
        // Apply inverse rotation to get the correct position in layer space
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
        bool hasHit = _hitTestManager.hitTest(
          item: paintLayer.item,
          position: position,
          scaleFactor: stackScale * layerScale,
          isRoundCensorArea: useRoundCensor,
          paintEditorConfigs: widget.paintEditorConfigs,
        );
        if (hasHit) {
          removeIds.add(layer.id);
        }
      }
    }

    if (_isPartialEraser) {
      widget.onRefresh();
    } else if (removeIds.isNotEmpty) {
      widget.onRemoveLayer(removeIds);
    }
  }

  void _addPolygonPoint(Offset offset) {
    if (_paintCtrl.offsets.isEmpty) {
      _paintCtrl
        ..setStart(offset)
        ..setInProgress(true);
      widget.onRefresh();
    }
    _paintCtrl.addOffsets(offset);
    _activePaintStreamCtrl.add(null);
  }

  void _checkPolygonIsComplete() {
    List<Offset?> rawOffsets = [..._paintCtrl.offsets];

    if (rawOffsets.length >= 2 &&
        rawOffsets.first != null &&
        rawOffsets.last != null) {
      final p1 = rawOffsets.first!;
      final p2 = rawOffsets.last!;

      final threshold = widget.paintEditorConfigs.polygonConnectionThreshold;

      if ((p1 - p2).distance < threshold) {
        // Connect them by replacing the last point with the first one
        rawOffsets[rawOffsets.length - 1] = rawOffsets.first;

        if (rawOffsets.isNotEmpty) _createPainting(rawOffsets);
      }
    }
  }

  void _createPainting(List<Offset?>? offsets) {
    if (offsets != null) {
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
    return StreamBuilder(
      stream: _activePaintStreamCtrl.stream,
      builder: (context, snapshot) {
        // Use Listener instead of GestureDetector for immediate pointer
        // response. This significantly reduces drawing latency on devices
        // like iPad with Apple Pencil by eliminating gesture disambiguation
        // delays.
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerCancel,
          child: _paintCtrl.busy
              ? _paintCtrl.mode == PaintMode.blur ||
                      _paintCtrl.mode == PaintMode.pixelate
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildCensorItem(_paintCtrl.paintedModel),
                      ],
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
    List<Offset?> offsets = item.offsets;
    if (offsets.length != 2) return const SizedBox.shrink();

    var topLeft = offsets[0];
    if (topLeft == null) return const SizedBox.shrink();

    var bottomRight = offsets[1];
    if (bottomRight == null) return const SizedBox.shrink();

    double width = (bottomRight.dx - topLeft.dx);
    double height = (bottomRight.dy - topLeft.dy);

    double left = width >= 0 ? topLeft.dx : topLeft.dx + width;
    double top = height >= 0 ? topLeft.dy : topLeft.dy + height;

    var censorConfigs = widget.paintEditorConfigs.censorConfigs;

    return Positioned(
      left: left,
      top: top,
      width: width.abs(),
      height: height.abs(),
      child: MouseRegion(
        onEnter: (event) {
          item.hit = true;
        },
        onExit: (event) {
          item.hit = false;
        },
        child: item.mode == PaintMode.pixelate
            ? PixelateAreaItem(censorConfigs: censorConfigs)
            : BlurAreaItem(censorConfigs: censorConfigs),
      ),
    );
  }
}
