// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

import '/core/models/paint_editor/painted_model.dart';
import '../controllers/paint_controller.dart';
import '../enums/paint_editor_enum.dart';
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
    this.onStart,
    this.onCreated,
    this.onRemoveLayer,
    this.freeStyleHighPerformance = false,
    required this.drawAreaSize,
    required this.paintCtrl,
  });

  /// Callback function when the active paint is done.
  final VoidCallback? onCreated;

  /// Callback invoked when layers are removed.
  ///
  /// Receives a list of layer identifiers that have been removed.
  final ValueChanged<List<String>>? onRemoveLayer;

  /// Callback invoked when paint starts.
  final VoidCallback? onStart;

  /// Size of the image.
  final Size drawAreaSize;

  /// The `PaintController` class is responsible for managing and controlling
  /// the paint state.
  final PaintController paintCtrl;

  /// Controls high-performance for free-style drawing.
  final bool freeStyleHighPerformance;

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

  @override
  void initState() {
    _activePaintStreamCtrl = StreamController.broadcast();
    super.initState();
  }

  @override
  void dispose() {
    _activePaintStreamCtrl.close();
    super.dispose();
  }

  /// This method is called when a scaling gesture for paint begins. It
  /// captures the starting point of the gesture.
  ///
  /// It is not meant to be called directly but is an event handler for scaling
  /// gestures.
  void _onScaleStart(ScaleStartDetails details) {
    if (widget.paintCtrl.mode == PaintMode.moveAndZoom) {
      return;
    } else if (widget.paintCtrl.mode == PaintMode.eraser) {
      setState(() {});
      return;
    }

    final offset = details.localFocalPoint;
    _paintCtrl
      ..setStart(offset)
      ..addOffsets(offset);
    _activePaintStreamCtrl.add(null);
  }

  /// Fires while the user is interacting with the screen to record paint.
  ///
  /// This method is called during an ongoing scaling gesture to record
  /// paint actions. It captures the current position and updates the
  /// paint controller accordingly.
  ///
  /// It is not meant to be called directly but is an event handler for scaling
  /// gestures.
  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (widget.paintCtrl.mode == PaintMode.moveAndZoom) {
      return;
    } else if (widget.paintCtrl.mode == PaintMode.eraser) {
      List<String> removeIds = [];
      for (var item in _paintCtrl.activePaintItemList) {
        if (item.hit) removeIds.add(item.id);
      }
      if (removeIds.isNotEmpty) widget.onRemoveLayer?.call(removeIds);
    } else {
      final offset = details.localFocalPoint;
      if (!_paintCtrl.busy) {
        widget.onStart?.call();
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
    }
  }

  /// Fires when the user stops interacting with the screen.
  ///
  /// This method is called when a scaling gesture for paint ends. It
  /// finalizes and records the paint action.
  ///
  /// It is not meant to be called directly but is an event handler for scaling
  /// gestures.
  void _onScaleEnd(ScaleEndDetails details) {
    if (widget.paintCtrl.mode == PaintMode.moveAndZoom ||
        widget.paintCtrl.mode == PaintMode.eraser) {
      return;
    }

    _paintCtrl.setInProgress(false);

    List<Offset?>? offsets;

    if (_paintCtrl.start != null && _paintCtrl.end != null) {
      if (_paintCtrl.mode == PaintMode.freeStyle) {
        offsets = [..._paintCtrl.offsets];
      } else if (_paintCtrl.start != null && _paintCtrl.end != null) {
        offsets = [_paintCtrl.start, _paintCtrl.end];
      }
    }
    if (offsets != null) {
      _paintCtrl.addPaintInfo(
        PaintedModel(
          offsets: offsets,
          mode: _paintCtrl.mode,
          color: _paintCtrl.color,
          strokeWidth: _paintCtrl.scaledStrokeWidth,
          fill: _paintCtrl.fill,
          opacity: _paintCtrl.opacity,
        ),
      );
      widget.onCreated?.call();
    }

    _paintCtrl.reset();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _paintCtrl.mode == PaintMode.moveAndZoom,
      child: Stack(
        fit: StackFit.expand,
        children: [
          for (final item in _paintCtrl.activePaintItemList)
            Opacity(
              opacity: item.opacity,
              child: CustomPaint(
                willChange: false,
                isComplex: item.mode == PaintMode.freeStyle,
                painter: DrawPaintItem(
                  item: item,
                  freeStyleHighPerformance: widget.freeStyleHighPerformance,
                  enabledHitDetection: _paintCtrl.mode == PaintMode.eraser,
                ),
              ),
            ),
          StreamBuilder(
            stream: _activePaintStreamCtrl.stream,
            builder: (context, snapshot) {
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onScaleStart: _onScaleStart,
                onScaleUpdate: _onScaleUpdate,
                onScaleEnd: _onScaleEnd,
                child: _paintCtrl.busy
                    ? Opacity(
                        opacity: _paintCtrl.opacity,
                        child: CustomPaint(
                          size: widget.drawAreaSize,
                          willChange: true,
                          isComplex: true,
                          painter: DrawPaintItem(item: _paintCtrl.paintedModel),
                        ),
                      )
                    : const SizedBox.expand(),
              );
            },
          ),
        ],
      ),
    );
  }
}
