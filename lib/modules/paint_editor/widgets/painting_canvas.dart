// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/modules/paint_editor/widgets/draw_painting.dart';
import '../../../models/paint_editor/painted_model.dart';
import '../utils/paint_controller.dart';
import '../utils/paint_editor_enum.dart';

/// A widget for creating a canvas for painting on images.
///
/// This widget allows you to create a canvas for painting on images loaded from various sources, including network URLs, asset paths, files, or memory (Uint8List).
/// It provides customization options for appearance and behavior.
class PaintingCanvas extends StatefulWidget {
  /// Callback function when the active painting is done.
  final VoidCallback? onCreatedPainting;

  final ValueChanged<List<String>>? onRemoveLayer;
  final VoidCallback? onStartPainting;

  /// Size of the image.
  final Size drawAreaSize;

  /// The `PaintingController` class is responsible for managing and controlling
  /// the painting state.
  final PaintingController paintCtrl;

  /// Constructs a `PaintingCanvas` widget.
  const PaintingCanvas({
    super.key,
    this.onStartPainting,
    this.onCreatedPainting,
    this.onRemoveLayer,
    required this.drawAreaSize,
    required this.paintCtrl,
  });

  @override
  PaintingCanvasState createState() => PaintingCanvasState();
}

class PaintingCanvasState extends State<PaintingCanvas> {
  /// Getter for accessing the [PaintingController] instance provided by the
  /// parent widget.
  PaintingController get _paintCtrl => widget.paintCtrl;

  /// Stream controller for updating painting events.
  late final StreamController _activePaintingStreamCtrl;

  @override
  void initState() {
    _activePaintingStreamCtrl = StreamController.broadcast();
    super.initState();
  }

  @override
  void dispose() {
    _activePaintingStreamCtrl.close();
    super.dispose();
  }

  /// This method is called when a scaling gesture for painting begins. It captures the starting point of the gesture.
  ///
  /// It is not meant to be called directly but is an event handler for scaling gestures.
  void _onScaleStart(ScaleStartDetails details) {
    if (widget.paintCtrl.mode == PaintModeE.eraser) {
      setState(() {});
      return;
    }

    final offset = details.localFocalPoint;
    _paintCtrl.setStart(offset);
    _paintCtrl.addOffsets(offset);
    _activePaintingStreamCtrl.add(null);
  }

  /// Fires while the user is interacting with the screen to record painting.
  ///
  /// This method is called during an ongoing scaling gesture to record painting actions. It captures the current position and updates the painting controller accordingly.
  ///
  /// It is not meant to be called directly but is an event handler for scaling gestures.
  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (widget.paintCtrl.mode == PaintModeE.eraser) {
      List<String> removeIds = [];
      for (var item in _paintCtrl.activePaintings) {
        if (item.hit) removeIds.add(item.id);
      }
      if (removeIds.isNotEmpty) widget.onRemoveLayer?.call(removeIds);
    } else {
      final offset = details.localFocalPoint;
      if (!_paintCtrl.busy) {
        widget.onStartPainting?.call();
        _paintCtrl.setInProgress(true);
      }

      if (_paintCtrl.start == null) {
        _paintCtrl.setStart(offset);
      }

      if (_paintCtrl.mode == PaintModeE.freeStyle) {
        _paintCtrl.addOffsets(offset);
      }

      _paintCtrl.setEnd(offset);

      _activePaintingStreamCtrl.add(null);
    }
  }

  /// Fires when the user stops interacting with the screen.
  ///
  /// This method is called when a scaling gesture for painting ends. It finalizes and records the painting action.
  ///
  /// It is not meant to be called directly but is an event handler for scaling gestures.
  void _onScaleEnd(ScaleEndDetails details) {
    if (widget.paintCtrl.mode == PaintModeE.eraser) return;

    _paintCtrl.setInProgress(false);

    List<Offset?>? offsets;

    if (_paintCtrl.start != null && _paintCtrl.end != null) {
      if (_paintCtrl.mode == PaintModeE.freeStyle) {
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
        ),
      );
      widget.onCreatedPainting?.call();
    }

    _paintCtrl.reset();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (final item in _paintCtrl.activePaintings)
          CustomPaint(
            willChange: false,
            isComplex: item.mode == PaintModeE.freeStyle,
            painter: DrawPainting(
              item: item,
              enabledHitDetection: _paintCtrl.mode == PaintModeE.eraser,
            ),
          ),
        StreamBuilder(
            stream: _activePaintingStreamCtrl.stream,
            builder: (context, snapshot) {
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onScaleStart: _onScaleStart,
                onScaleUpdate: _onScaleUpdate,
                onScaleEnd: _onScaleEnd,
                child: _paintCtrl.busy
                    ? CustomPaint(
                        size: widget.drawAreaSize,
                        willChange: true,
                        isComplex: true,
                        painter: DrawPainting(item: _paintCtrl.paintedModel),
                      )
                    : const SizedBox.expand(),
              );
            }),
      ],
    );
  }
}
