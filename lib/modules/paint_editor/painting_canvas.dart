import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart' hide Image, decodeImageFromList;
import 'package:flutter/services.dart';

import '../../models/editor_configs/paint_editor_configs.dart';
import '../../models/layer.dart';
import '../../models/paint_editor/painted_model.dart';
import '../../models/theme/theme.dart';
import '../../models/i18n/i18n.dart';
import '../../models/icons/icons.dart';
import '../../utils/design_mode.dart';
import '../../utils/theme_functions.dart';
import '../../widgets/bottom_sheets_header_row.dart';
import 'utils/draw/draw_multiple_canvas.dart';
import 'utils/paint_controller.dart';
import 'utils/paint_editor_enum.dart';

/// A widget for creating a canvas for painting on images.
///
/// This widget allows you to create a canvas for painting on images loaded from various sources, including network URLs, asset paths, files, or memory (Uint8List). It provides customization options for appearance and behavior.
class PaintingCanvas extends StatefulWidget {
  /// The network URL of the image (if loading from a network).
  final String? networkUrl;

  /// A byte array representing the image data (if loading from memory).
  final Uint8List? byteArray;

  /// The file representing the image (if loading from a file).
  final File? file;

  /// The asset path of the image (if loading from assets).
  final String? assetPath;

  /// The theme configuration for the editor.
  final ThemeData theme;

  /// The design mode of the editor (material or custom).
  final ImageEditorDesignModeE designMode;

  /// The internationalization (i18n) configuration for the editor.
  final I18n i18n;

  /// Icons used in the editor.
  final ImageEditorIcons icons;

  /// The theme configuration specific to the image editor.
  final ImageEditorTheme imageEditorTheme;

  /// A callback function called when the painting is updated.
  final VoidCallback? onUpdate;

  /// The configuration options for the paint editor.
  final PaintEditorConfigs configs;

  /// The size of the image.
  final Size imageSize;

  /// Creates a [PaintingCanvas] widget.
  ///
  /// This constructor is not intended to be used directly. Instead, use one of the factory methods to create an instance of [PaintingCanvas] based on the image source (network, asset, file, or memory).
  ///
  /// See factory methods like [PaintingCanvas.network], [PaintingCanvas.asset], [PaintingCanvas.file], and [PaintingCanvas.memory] for creating instances of this widget with specific image sources.
  const PaintingCanvas._({
    super.key,
    this.assetPath,
    this.networkUrl,
    this.byteArray,
    this.file,
    required this.imageSize,
    required this.theme,
    required this.designMode,
    required this.i18n,
    required this.imageEditorTheme,
    required this.icons,
    required this.configs,
    this.onUpdate,
  });

  /// Create a [PaintingCanvas] widget with an image loaded from a network URL.
  ///
  /// Use this factory method to create a [PaintingCanvas] widget for painting on an image loaded from a network URL. Customize the appearance and behavior of the widget using the provided parameters.
  ///
  /// Parameters:
  /// - `networkUrl`: The network URL of the image (required).
  /// - `key`: A required Key to uniquely identify this widget in the widget tree.
  /// - `imageSize`: The size of the image (required).
  /// - `theme`: The theme configuration for the editor (required).
  /// - `designMode`: The design mode of the editor (material or custom, required).
  /// - `i18n`: The internationalization (i18n) configuration for the editor (required).
  /// - `imageEditorTheme`: The theme configuration specific to the image editor (required).
  /// - `icons`: Icons used in the editor (required).
  /// - `configs`: The configuration options for the paint editor (required).
  /// - `onUpdate`: A callback function called when the painting is updated.
  ///
  /// Returns:
  /// A [PaintingCanvas] widget configured with the provided parameters and the image loaded from the network URL.
  ///
  /// Example Usage:
  /// ```dart
  /// final String imageUrl = 'https://example.com/image.jpg'; // Provide the network URL.
  /// final painter = PaintingCanvas.network(
  ///   imageUrl,
  ///   key: GlobalKey(),
  ///   theme: ThemeData.light(),
  ///   i18n: I18n(),
  ///   imageEditorTheme: ImageEditorTheme(),
  ///   icons: ImageEditorIcons(),
  ///   designMode: ImageEditorDesignMode.material,
  /// );
  /// ```
  factory PaintingCanvas.network(
    String networkUrl, {
    required Key key,
    Widget? placeholderWidget,
    bool? scalable,
    bool? showColorPicker,
    List<Color>? colors,
    Function? save,
    VoidCallback? onUpdate,
    Widget? undoIcon,
    Widget? colorIcon,
    required Size imageSize,
    required ThemeData theme,
    required I18n i18n,
    required ImageEditorTheme imageEditorTheme,
    required ImageEditorIcons icons,
    required ImageEditorDesignModeE designMode,
    required PaintEditorConfigs configs,
  }) {
    return PaintingCanvas._(
      key: key,
      networkUrl: networkUrl,
      onUpdate: onUpdate,
      configs: configs,
      theme: theme,
      imageSize: imageSize,
      i18n: i18n,
      imageEditorTheme: imageEditorTheme,
      icons: icons,
      designMode: designMode,
    );
  }

  /// Create a [PaintingCanvas] widget with an image loaded from an asset.
  ///
  /// Use this factory method to create a [PaintingCanvas] widget for painting on an image loaded from an asset. Customize the appearance and behavior of the widget using the provided parameters.
  ///
  /// Parameters:
  /// - `path`: The asset path of the image (required).
  /// - `key`: A required Key to uniquely identify this widget in the widget tree.
  /// - `imageSize`: The size of the image (required).
  /// - `theme`: The theme configuration for the editor (required).
  /// - `designMode`: The design mode of the editor (material or custom, required).
  /// - `i18n`: The internationalization (i18n) configuration for the editor (required).
  /// - `imageEditorTheme`: The theme configuration specific to the image editor (required).
  /// - `icons`: Icons used in the editor (required).
  /// - `configs`: The configuration options for the paint editor (required).
  /// - `onUpdate`: A callback function called when the painting is updated.
  ///
  /// Returns:
  /// A [PaintingCanvas] widget configured with the provided parameters and the image loaded from the asset.
  ///
  /// Example Usage:
  /// ```dart
  /// final String assetPath = 'assets/image.png'; // Provide the asset path.
  /// final painter = PaintingCanvas.asset(
  ///   assetPath,
  ///   key: GlobalKey(),
  ///   theme: ThemeData.light(),
  ///   i18n: I18n(),
  ///   imageEditorTheme: ImageEditorTheme(),
  ///   icons: ImageEditorIcons(),
  ///   designMode: ImageEditorDesignMode.material,
  /// );
  /// ```
  factory PaintingCanvas.asset(
    String path, {
    required Key key,
    bool? scalable,
    bool? showColorPicker,
    Widget? placeholderWidget,
    Function? save,
    List<Color>? colors,
    VoidCallback? onUpdate,
    Widget? undoIcon,
    Widget? colorIcon,
    required Size imageSize,
    required ThemeData theme,
    required I18n i18n,
    required ImageEditorTheme imageEditorTheme,
    required ImageEditorIcons icons,
    required ImageEditorDesignModeE designMode,
    required PaintEditorConfigs configs,
  }) {
    return PaintingCanvas._(
      key: key,
      assetPath: path,
      onUpdate: onUpdate,
      configs: configs,
      theme: theme,
      imageSize: imageSize,
      i18n: i18n,
      imageEditorTheme: imageEditorTheme,
      icons: icons,
      designMode: designMode,
    );
  }

  /// Create a [PaintingCanvas] widget with an image loaded from a File.
  ///
  /// Use this factory method to create a [PaintingCanvas] widget for painting on an image loaded from a File. Customize the appearance and behavior of the widget using the provided parameters.
  ///
  /// Parameters:
  /// - `file`: The File object representing the image file (required).
  /// - `key`: A required Key to uniquely identify this widget in the widget tree.
  /// - `imageSize`: The size of the image (required).
  /// - `theme`: The theme configuration for the editor (required).
  /// - `designMode`: The design mode of the editor (material or custom, required).
  /// - `i18n`: The internationalization (i18n) configuration for the editor (required).
  /// - `imageEditorTheme`: The theme configuration specific to the image editor (required).
  /// - `icons`: Icons used in the editor (required).
  /// - `configs`: The configuration options for the paint editor (required).
  /// - `onUpdate`: A callback function called when the painting is updated.
  ///
  /// Returns:
  /// A [PaintingCanvas] widget configured with the provided parameters and the image loaded from the File.
  ///
  /// Example Usage:
  /// ```dart
  /// final File imageFile = File('path/to/image.jpg'); // Provide the image File.
  /// final painter = PaintingCanvas.file(
  ///   imageFile,
  ///   key: GlobalKey(),
  ///   theme: ThemeData.light(),
  ///   i18n: I18n(),
  ///   imageEditorTheme: ImageEditorTheme(),
  ///   icons: ImageEditorIcons(),
  ///   designMode: ImageEditorDesignMode.material,
  /// );
  /// ```
  factory PaintingCanvas.file(
    File file, {
    required Key key,
    Function? save,
    bool? scalable,
    bool? showColorPicker,
    Widget? placeholderWidget,
    List<Color>? colors,
    VoidCallback? onUpdate,
    Widget? undoIcon,
    Widget? colorIcon,
    required Size imageSize,
    required ThemeData theme,
    required I18n i18n,
    required ImageEditorTheme imageEditorTheme,
    required ImageEditorIcons icons,
    required ImageEditorDesignModeE designMode,
    required PaintEditorConfigs configs,
  }) {
    return PaintingCanvas._(
      key: key,
      file: file,
      onUpdate: onUpdate,
      configs: configs,
      theme: theme,
      imageSize: imageSize,
      i18n: i18n,
      imageEditorTheme: imageEditorTheme,
      icons: icons,
      designMode: designMode,
    );
  }

  /// Create a [PaintingCanvas] widget with an image loaded from a Uint8List (memory).
  ///
  /// Use this factory method to create a [PaintingCanvas] widget for painting on an image loaded from a Uint8List (memory). Customize the appearance and behavior of the widget using the provided parameters.
  ///
  /// Parameters:
  /// - `byteArray`: The Uint8List representing the image data loaded in memory (required).
  /// - `key`: A required Key to uniquely identify this widget in the widget tree.
  /// - `imageSize`: The size of the image (required).
  /// - `theme`: The theme configuration for the editor (required).
  /// - `designMode`: The design mode of the editor (material or custom, required).
  /// - `i18n`: The internationalization (i18n) configuration for the editor (required).
  /// - `imageEditorTheme`: The theme configuration specific to the image editor (required).
  /// - `icons`: Icons used in the editor (required).
  /// - `configs`: The configuration options for the paint editor (required).
  /// - `onUpdate`: A callback function called when the painting is updated.
  ///
  /// Returns:
  /// A [PaintingCanvas] widget configured with the provided parameters and the image loaded from the Uint8List (memory).
  ///
  /// Example Usage:
  /// ```dart
  /// final Uint8List imageBytes = Uint8List( /* Image byte data */ ); // Provide the image byte data.
  /// final painter = PaintingCanvas.memory(
  ///   imageBytes,
  ///   key: GlobalKey(),
  ///   theme: ThemeData.light(),
  ///   i18n: I18n(),
  ///   imageEditorTheme: ImageEditorTheme(),
  ///   icons: ImageEditorIcons(),
  ///   designMode: ImageEditorDesignMode.material,
  /// );
  /// ```
  factory PaintingCanvas.memory(
    Uint8List byteArray, {
    required Key key,
    bool? scalable,
    bool? showColorPicker,
    Function? save,
    Widget? placeholderWidget,
    List<Color>? colors,
    VoidCallback? onUpdate,
    Widget? undoIcon,
    Widget? colorIcon,
    required Size imageSize,
    required ThemeData theme,
    required I18n i18n,
    required ImageEditorTheme imageEditorTheme,
    required ImageEditorIcons icons,
    required ImageEditorDesignModeE designMode,
    required PaintEditorConfigs configs,
  }) {
    return PaintingCanvas._(
      key: key,
      byteArray: byteArray,
      onUpdate: onUpdate,
      configs: configs,
      theme: theme,
      imageSize: imageSize,
      i18n: i18n,
      imageEditorTheme: imageEditorTheme,
      icons: icons,
      designMode: designMode,
    );
  }

  /// Create a `PaintingCanvas` widget with automatic image source detection.
  ///
  /// This factory method allows you to create a `PaintingCanvas` widget with automatic detection of the image source, including options for loading from a Uint8List (memory), File, asset path, or network URL. The provided parameters allow you to customize the appearance and behavior of the `PaintingCanvas` widget.
  ///
  /// Parameters:
  /// - `key`: A required Key to uniquely identify this widget in the widget tree.
  /// - `onUpdate`: An optional callback function triggered when the painting is updated.
  /// - `imageSize`: The size of the image to be loaded (required).
  /// - `theme`: A `ThemeData` object that defines the visual styling of the `PaintingCanvas` widget (required).
  /// - `i18n`: An `I18n` object for localization and internationalization (required).
  /// - `imageEditorTheme`: An `ImageEditorTheme` object for customizing the overall theme of the editor (required).
  /// - `icons`: An `ImageEditorIcons` object for customizing the icons used in the editor (required).
  /// - `designMode`: An `ImageEditorDesignMode` enum to specify the design mode (material or custom) of the ImageEditor (required).
  /// - `byteArray`: A Uint8List representing the image data loaded in memory (optional).
  /// - `file`: A File object representing the image file to be loaded (optional).
  /// - `assetPath`: A String specifying the asset path for the image (optional).
  /// - `networkUrl`: A String specifying the network URL for the image (optional).
  ///
  /// Returns:
  /// A `PaintingCanvas` widget configured with the provided parameters and the image loaded from the detected source (Uint8List, File, asset, or network URL).
  ///
  /// Example Usage:
  /// ```dart
  /// final Uint8List imageBytes = Uint8List( /* Image byte data */ ); // Provide the image byte data.
  /// final painter = PaintingCanvas.autoSource(
  ///   key: GlobalKey(),
  ///   theme: ThemeData.light(),
  ///   i18n: I18n(),
  ///   imageEditorTheme: ImageEditorTheme(),
  ///   icons: ImageEditorIcons(),
  ///   designMode: ImageEditorDesignMode.material,
  ///   byteArray: imageBytes,
  /// );
  /// // Alternatively, provide a 'file', 'assetPath', or 'networkUrl' instead of 'byteArray' for automatic source detection.
  /// ```
  factory PaintingCanvas.autoSource({
    required Key key,
    VoidCallback? onUpdate,
    required Size imageSize,
    required ThemeData theme,
    required I18n i18n,
    required ImageEditorTheme imageEditorTheme,
    required ImageEditorIcons icons,
    required ImageEditorDesignModeE designMode,
    required PaintEditorConfigs configs,
    Uint8List? byteArray,
    File? file,
    String? assetPath,
    String? networkUrl,
  }) {
    if (byteArray != null) {
      return PaintingCanvas.memory(
        byteArray,
        key: key,
        onUpdate: onUpdate,
        configs: configs,
        theme: theme,
        imageSize: imageSize,
        i18n: i18n,
        imageEditorTheme: imageEditorTheme,
        icons: icons,
        designMode: designMode,
      );
    } else if (file != null) {
      return PaintingCanvas.file(
        file,
        key: key,
        onUpdate: onUpdate,
        configs: configs,
        theme: theme,
        imageSize: imageSize,
        i18n: i18n,
        imageEditorTheme: imageEditorTheme,
        icons: icons,
        designMode: designMode,
      );
    } else if (networkUrl != null) {
      return PaintingCanvas.network(
        networkUrl,
        key: key,
        onUpdate: onUpdate,
        configs: configs,
        theme: theme,
        imageSize: imageSize,
        i18n: i18n,
        imageEditorTheme: imageEditorTheme,
        icons: icons,
        designMode: designMode,
      );
    } else if (assetPath != null) {
      return PaintingCanvas.asset(
        assetPath,
        key: key,
        onUpdate: onUpdate,
        configs: configs,
        theme: theme,
        imageSize: imageSize,
        i18n: i18n,
        imageEditorTheme: imageEditorTheme,
        icons: icons,
        designMode: designMode,
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

  @override
  void initState() {
    var w = widget.imageSize.width;
    var h = widget.imageSize.height;

    _paintCtrl = PaintingController(
      fill: widget.configs.initialFill,
      mode: widget.configs.initialPaintMode,
      strokeWidth: widget.configs.initialStrokeWidth,
      color: widget.configs.initialColor,
      strokeMultiplier: (w + h) > 1440 ? (w + h) ~/ 1440 : 1,
    );

    super.initState();
  }

  @override
  void dispose() {
    _paintCtrl.dispose();
    super.dispose();
  }

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
    widget.onUpdate?.call();
  }

  /// Displays a range slider for adjusting the line width of the painting tool.
  ///
  /// This method shows a range slider in a modal bottom sheet for adjusting the line width of the painting tool.
  void showRangeSlider() {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          widget.imageEditorTheme.paintingEditor.lineWidthBottomSheetColor,
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          textStyle: platformTextStyle(context, widget.designMode),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BottomSheetHeaderRow(
                    title: widget.i18n.paintEditor.lineWidth,
                    theme: widget.theme,
                  ),
                  StatefulBuilder(builder: (context, setState) {
                    return Slider.adaptive(
                      max: 40,
                      min: 2,
                      divisions: 19,
                      value: _paintCtrl.strokeWidth,
                      onChanged: (value) {
                        _paintCtrl.setStrokeWidth(value);
                        setState(() {});
                        if (widget.configs.strokeWidthOnChanged != null) {
                          widget.configs.strokeWidthOnChanged!(value);
                        }
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        );
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
        size: widget.imageSize,
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
