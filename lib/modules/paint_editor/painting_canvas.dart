import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart' hide Image, decodeImageFromList;
import 'package:flutter/services.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../../models/editor_image.dart';
import '../../models/init_configs/paint_canvas_init_configs.dart';
import '../../models/layer.dart';
import '../../models/paint_editor/painted_model.dart';
import '../../utils/theme_functions.dart';
import '../../widgets/bottom_sheets_header_row.dart';
import 'utils/draw/draw_multiple_canvas.dart';
import 'utils/paint_controller.dart';

/// A widget for creating a canvas for painting on images.
///
/// This widget allows you to create a canvas for painting on images loaded from various sources, including network URLs, asset paths, files, or memory (Uint8List).
/// It provides customization options for appearance and behavior.
class PaintingCanvas extends StatefulWidget {
  /// The initialization configurations for the canvas.
  final PaintCanvasInitConfigs initConfigs;

  /// The image being edited on the canvas.
  final EditorImage editorImage;

  /// Constructs a `PaintingCanvas` widget.
  ///
  /// The [key] parameter is used to provide a key for the widget.
  /// The [editorImage] parameter specifies the image to be edited on the canvas.
  /// The [initConfigs] parameter specifies the initialization configurations for the canvas.
  const PaintingCanvas._({
    super.key,
    required this.editorImage,
    required this.initConfigs,
  });

  /// Constructs a `PaintingCanvas` widget with an image loaded from a network URL.
  factory PaintingCanvas.network(
    String networkUrl, {
    required Key key,
    required PaintCanvasInitConfigs initConfigs,
  }) {
    return PaintingCanvas._(
      key: key,
      editorImage: EditorImage(networkUrl: networkUrl),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `PaintingCanvas` widget with an image loaded from an asset path.
  factory PaintingCanvas.asset(
    String path, {
    required Key key,
    required PaintCanvasInitConfigs initConfigs,
  }) {
    return PaintingCanvas._(
      key: key,
      editorImage: EditorImage(assetPath: path),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `PaintingCanvas` widget with an image loaded from a file.
  factory PaintingCanvas.file(
    File file, {
    required Key key,
    required PaintCanvasInitConfigs initConfigs,
  }) {
    return PaintingCanvas._(
      key: key,
      editorImage: EditorImage(file: file),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `PaintingCanvas` widget with an image loaded into memory.
  factory PaintingCanvas.memory(
    Uint8List byteArray, {
    required Key key,
    required PaintCanvasInitConfigs initConfigs,
  }) {
    return PaintingCanvas._(
      key: key,
      editorImage: EditorImage(byteArray: byteArray),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `PaintingCanvas` widget with an image loaded automatically based on the provided source.
  ///
  /// Either [byteArray], [file], [networkUrl], or [assetPath] must be provided.
  factory PaintingCanvas.autoSource({
    required Key key,
    required PaintCanvasInitConfigs initConfigs,
    Uint8List? byteArray,
    File? file,
    String? assetPath,
    String? networkUrl,
  }) {
    if (byteArray != null) {
      return PaintingCanvas.memory(
        byteArray,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (file != null) {
      return PaintingCanvas.file(
        file,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (networkUrl != null) {
      return PaintingCanvas.network(
        networkUrl,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (assetPath != null) {
      return PaintingCanvas.asset(
        assetPath,
        key: key,
        initConfigs: initConfigs,
      );
    } else {
      throw ArgumentError(
          "Either 'byteArray', 'file', 'networkUrl' or 'assetPath' must be provided.");
    }
  }

  @override
  PaintingCanvasState createState() => PaintingCanvasState();
}

class PaintingCanvasState extends State<PaintingCanvas> {
  late final PaintingController _paintCtrl;

  PaintEditorConfigs get configs => widget.initConfigs.configs;

  @override
  void initState() {
    var w = widget.initConfigs.imageSize.width;
    var h = widget.initConfigs.imageSize.height;

    _paintCtrl = PaintingController(
      fill: configs.initialFill,
      mode: configs.initialPaintMode,
      strokeWidth: configs.initialStrokeWidth,
      color: configs.initialColor,
      strokeMultiplier: (w + h) > 1440 ? (w + h) ~/ 1440 : 1,
    );

    super.initState();
  }

  @override
  void dispose() {
    _paintCtrl.dispose();
    super.dispose();
  }

  /// Get the active selected color.
  Color get activeColor => _paintCtrl.color;

  /// Get the current stroke width
  double get strokeWidth => _paintCtrl.strokeWidth;

  /// Undo the most recent paint action on the canvas.
  ///
  /// This method allows you to revert the most recent paint action performed on the canvas.
  void undo() => {_paintCtrl.undo()};

  /// Redo a previously undone paint action.
  ///
  /// Use this method to redo a paint action that was previously undone.
  void redo() => {_paintCtrl.redo()};

  /// Set the fill mode for painting shapes.
  ///
  /// If [fill] is set to `true`, shapes will be filled when painted on the canvas. If set to `false`, shapes will be outlined.
  void setFill(bool fill) => {_paintCtrl.setFill(fill)};

  /// Set the color for painting on the canvas.
  ///
  /// Use this method to set the color for painting. The [value] parameter should be an integer representing the color.
  void setColor(int value) => {_paintCtrl.setColor(Color(value))};

  /// Handles the start of a scaling gesture for painting.

  /// This method is called when a scaling gesture for painting begins. It captures the starting point of the gesture.
  ///
  /// It is not meant to be called directly but is an event handler for scaling gestures.
  void _onScaleStart(ScaleStartDetails onStart) {
    final offset = onStart.localFocalPoint;
    _paintCtrl.setStart(offset);
    _paintCtrl.addOffsets(offset);
  }

  /// Fires while the user is interacting with the screen to record painting.
  ///
  /// This method is called during an ongoing scaling gesture to record painting actions. It captures the current position and updates the painting controller accordingly.
  ///
  /// It is not meant to be called directly but is an event handler for scaling gestures.
  void _onScaleUpdate(ScaleUpdateDetails onUpdate) {
    final offset = onUpdate.localFocalPoint;
    _paintCtrl.setInProgress(true);
    if (_paintCtrl.start == null) {
      _paintCtrl.setStart(offset);
    }
    _paintCtrl.setEnd(offset);
    if (_paintCtrl.mode == PaintModeE.freeStyle) {
      _paintCtrl.addOffsets(offset);
    }
  }

  /// Fires when the user stops interacting with the screen.
  ///
  /// This method is called when a scaling gesture for painting ends. It finalizes and records the painting action.
  ///
  /// It is not meant to be called directly but is an event handler for scaling gestures.
  void _onScaleEnd(ScaleEndDetails onEnd) {
    _paintCtrl.setInProgress(false);
    if (_paintCtrl.start != null &&
        _paintCtrl.end != null &&
        (_paintCtrl.mode == PaintModeE.freeStyle)) {
      _addFreeStylePoints();
    } else if (_paintCtrl.start != null && _paintCtrl.end != null) {
      _addEndPoints();
    }
    _paintCtrl.resetStartAndEnd();
  }

  /// Adds end points to the paint history.
  ///
  /// This method adds the recorded end points to the paint history.
  void _addEndPoints() {
    _addPaintHistory(
      PaintedModel(
        offsets: <Offset?>[_paintCtrl.start, _paintCtrl.end],
        mode: _paintCtrl.mode,
        color: _paintCtrl.color,
        strokeWidth: _paintCtrl.scaledStrokeWidth,
        fill: _paintCtrl.fill,
      ),
    );
  }

  /// Adds free-style points to the paint history.
  ///
  /// This method adds the recorded free-style points to the paint history.
  void _addFreeStylePoints() {
    _addPaintHistory(
      PaintedModel(
        offsets: <Offset?>[..._paintCtrl.offsets],
        mode: PaintModeE.freeStyle,
        color: _paintCtrl.color,
        strokeWidth: _paintCtrl.scaledStrokeWidth,
      ),
    );
  }

  /// Adds a painted model to the paint history.
  ///
  /// This method adds a [PaintedModel] object to the paint history and calls the [onUpdate] callback if provided.
  void _addPaintHistory(PaintedModel info) {
    _paintCtrl.addPaintInfo(info);
    widget.initConfigs.onUpdate?.call();
  }

  /// Set the stroke width.
  void setStrokeWidth(double value) {
    _paintCtrl.setStrokeWidth(value);
    setState(() {});
    if (configs.strokeWidthOnChanged != null) {
      configs.strokeWidthOnChanged!(value);
    }
  }

  /// Displays a range slider for adjusting the line width of the painting tool.
  ///
  /// This method shows a range slider in a modal bottom sheet for adjusting the line width of the painting tool.
  void showRangeSlider() {
    showModalBottomSheet(
      context: context,
      backgroundColor: widget.initConfigs.imageEditorTheme.paintingEditor
          .lineWidthBottomSheetColor,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Material(
            color: Colors.transparent,
            textStyle:
                platformTextStyle(context, widget.initConfigs.designMode),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BottomSheetHeaderRow(
                      title: widget.initConfigs.i18n.paintEditor.lineWidth,
                      theme: widget.initConfigs.theme,
                    ),
                    StatefulBuilder(builder: (context, setState) {
                      return Slider.adaptive(
                        max: 40,
                        min: 2,
                        divisions: 19,
                        value: _paintCtrl.strokeWidth,
                        onChanged: (value) {
                          setStrokeWidth(value);
                          setState(() {});
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  /// Finds the extreme points (bounding box) of a list of [Offset] points.
  ///
  /// Given a list of [Offset] points, this method calculates the leftmost, topmost, rightmost, and bottommost points to determine the bounding box of the points.
  ///
  /// If the input [points] list is empty, it returns [ExtremePoints] with both extreme points set to `null`.
  ExtremePoints _findExtremePoints(List<Offset?> points) {
    if (points.isEmpty) {
      return ExtremePoints(null, null);
    }

    double leftmostX = double.infinity;
    double topmostY = double.infinity;
    double rightmostX = double.negativeInfinity;
    double bottommostY = double.negativeInfinity;

    for (final point in points) {
      if (point != null) {
        if (point.dx < leftmostX) {
          leftmostX = point.dx;
        }
        if (point.dy < topmostY) {
          topmostY = point.dy;
        }
        if (point.dx > rightmostX) {
          rightmostX = point.dx;
        }
        if (point.dy > bottommostY) {
          bottommostY = point.dy;
        }
      }
    }

    Offset leftTopmost = Offset(leftmostX, topmostY);
    Offset rightBottommost = Offset(rightmostX, bottommostY);

    return ExtremePoints(leftTopmost, rightBottommost);
  }

  /// Exports the painted items as a list of [PaintingLayerData].
  ///
  /// This method converts the painting history into a list of [PaintingLayerData] representing the painted items.
  ///
  /// Example:
  /// ```dart
  /// List<PaintingLayerData> layers = exportPaintedItems();
  /// ```
  List<PaintingLayerData> exportPaintedItems() {
    // Convert to free positions
    return _paintCtrl.paintHistory.map((e) {
      var layer = PaintedModel(
        mode: e.mode,
        offsets: [...e.offsets],
        color: e.color,
        strokeWidth: e.strokeWidth,
        fill: e.fill,
      );

      // Find extreme points of the painting layer
      var points = _findExtremePoints(e.offsets);

      Size size = Size(
        ((points.leftTopmost?.dx ?? 0) - (points.rightBottommost?.dx ?? 0))
            .abs(),
        ((points.leftTopmost?.dy ?? 0) - (points.rightBottommost?.dy ?? 0))
            .abs(),
      );

      bool onlyStrokeMode = e.mode == PaintModeE.freeStyle ||
          e.mode == PaintModeE.line ||
          e.mode == PaintModeE.dashLine ||
          e.mode == PaintModeE.arrow ||
          ((e.mode == PaintModeE.rect || e.mode == PaintModeE.circle) &&
              !e.fill);

      // Scale and offset the offsets of the painting layer
      double strokeHelperWidth = onlyStrokeMode ? e.strokeWidth : 0;

      for (int i = 0; i < layer.offsets.length; i++) {
        var element = layer.offsets[i];
        if (element != null) {
          layer.offsets[i] = Offset(
            element.dx - (points.leftTopmost?.dx ?? 0) + strokeHelperWidth / 2,
            element.dy - (points.leftTopmost?.dy ?? 0) + strokeHelperWidth / 2,
          );
        }
      }

      // Calculate the final offset of the painting layer
      Offset finalOffset = Offset(
        (points.leftTopmost?.dx ?? 0) + size.width / 2,
        (points.leftTopmost?.dy ?? 0) + size.height / 2,
      );

      if (onlyStrokeMode) {
        size = Size(
          size.width + strokeHelperWidth,
          size.height + strokeHelperWidth,
        );
      }

      // Create and return a PaintingLayerData instance for the exported layer
      return PaintingLayerData(
        item: layer.copy(),
        rawSize: Size(
          max(size.width, layer.strokeWidth),
          max(size.height, layer.strokeWidth),
        ),
        offset: finalOffset,
      );
    }).toList();
  }

  /// Sets the painting mode for the canvas.
  ///
  /// Use this method to change the painting mode, such as freehand drawing, line, rectangle, etc.
  set mode(PaintModeE mode) => {_paintCtrl.setMode(mode)};

  /// Gets the current painting mode of the canvas.
  PaintModeE get mode => _paintCtrl.mode;

  /// Indicates whether there are actions that can be undone.
  ///
  /// Returns `true` if there are actions in the painting history that can be undone; otherwise, returns `false`.
  bool get canUndo => _paintCtrl.paintHistory.isNotEmpty;

  /// Indicates whether there are actions that can be redone.
  ///
  /// Returns `true` if there are actions in the redo history that can be redone; otherwise, returns `false`.
  bool get canRedo => _paintCtrl.paintRedoHistory.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
      child: CustomPaint(
        size: widget.initConfigs.imageSize,
        willChange: true,
        isComplex: true,
        painter: DrawImage(paintCtrl: _paintCtrl),
      ),
    );
  }
}

/// A class representing extreme points of a shape or region.
class ExtremePoints {
  /// The left-topmost point of the shape or region.
  final Offset? leftTopmost;

  /// The right-bottommost point of the shape or region.
  final Offset? rightBottommost;

  /// Creates an instance of [ExtremePoints] with the specified left-topmost and right-bottommost points.
  ///
  /// If either [leftTopmost] or [rightBottommost] is `null`, it indicates that the corresponding point is not available.
  ExtremePoints(this.leftTopmost, this.rightBottommost);
}
