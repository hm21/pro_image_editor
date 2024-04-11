import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:pro_image_editor/designs/whatsapp/whatsapp_crop_rotate_toolbar.dart';
import 'package:pro_image_editor/models/crop_rotate_editor/transform_factors.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/widgets/transformed_content_generator.dart';

import '../../models/editor_image.dart';
import '../../models/layer.dart';
import '../../models/transform_helper.dart';
import '../../widgets/auto_image.dart';
import '../../widgets/layer_stack.dart';
import '../../widgets/platform_popup_menu.dart';
import '../../widgets/pro_image_editor_desktop_mode.dart';
import 'utils/crop_aspect_ratios.dart';
import 'utils/crop_corner_painter.dart';
import 'utils/rotate_angle.dart';
import 'widgets/crop_aspect_ratio_options.dart';

/// The `CropRotateEditor` widget is used for cropping and rotating images.
/// It provides various constructors for loading images from different sources and allows users to crop and rotate the image.
///
/// You can create a `CropRotateEditor` using one of the factory methods provided:
/// - `CropRotateEditor.file`: Loads an image from a file.
/// - `CropRotateEditor.asset`: Loads an image from an asset.
/// - `CropRotateEditor.network`: Loads an image from a network URL.
/// - `CropRotateEditor.memory`: Loads an image from memory as a `Uint8List`.
/// - `CropRotateEditor.autoSource`: Automatically selects the source based on provided parameters.
class CropRotateEditor extends StatefulWidget {
  /// A byte array representing the image data.
  final Uint8List? byteArray;

  /// The asset path of the image.
  final String? assetPath;

  /// The network URL of the image.
  final String? networkUrl;

  /// The file representing the image.
  final File? file;

  /// The theme configuration for the editor.
  final ThemeData theme;

  /// A list of Layer objects representing image layers.
  final List<Layer>? layers;

  /// The image editor configs
  final ProImageEditorConfigs configs;

  /// The transform configurations how the image should be initialized.
  final TransformConfigs? transformConfigs;

  /// The size of the image to be edited.
  final Size imageSize;

  /// The rendered image size with layers.
  /// Required to calculate the correct layer position.
  final Size? imageSizeWithLayers;

  /// The rendered body size with layers.
  /// Required to calculate the correct layer position.
  final Size? bodySizeWithLayers;

  /// A callback function that can be used to update the UI from custom widgets.
  final Function? onUpdateUI;

  /// Private constructor for creating a `CropRotateEditor` widget.
  const CropRotateEditor._({
    super.key,
    this.byteArray,
    this.assetPath,
    this.networkUrl,
    this.file,
    this.onUpdateUI,
    this.layers,
    required this.theme,
    this.transformConfigs,
    this.imageSizeWithLayers,
    this.bodySizeWithLayers,
    required this.imageSize,
    required this.configs,
  }) : assert(
          byteArray != null || file != null || networkUrl != null || assetPath != null,
          'At least one of bytes, file, networkUrl, or assetPath must not be null.',
        );

  /// Create a CropRotateEditor widget with an in-memory image represented as a Uint8List.
  ///
  /// This factory method allows you to create a CropRotateEditor widget that can be used to crop and rotate an image represented as a Uint8List in memory. The provided parameters allow you to customize the appearance and behavior of the CropRotateEditor widget.
  ///
  /// Parameters:
  /// - `byteArray`: A Uint8List representing the image data in memory.
  /// - `key`: An optional Key to uniquely identify this widget in the widget tree.
  /// - `theme`: A ThemeData object that defines the visual styling of the CropRotateEditor widget (required).
  /// - `layers`: A list of Layer objects representing image layers.
  /// - `imageSize`: The size of the image to be edited (required).
  /// - `configs`: The image editor configs.
  /// - `transformConfigs` The transform configurations how the image should be initialized.
  /// - `onUpdateUI`:  A callback function that can be used to update the UI from custom widgets.
  ///
  /// Returns:
  /// A CropRotateEditor widget configured with the provided parameters and the in-memory image data.
  ///
  /// Example Usage:
  /// ```dart
  /// final Uint8List imageBytes = ... // Load your image data here.
  /// final editor = CropRotateEditor.memory(
  ///   imageBytes,
  ///   theme: ThemeData.light(),
  ///   imageSize: Size(300, 300), // Set the image size.
  ///   configs: CropRotateEditorConfigs(), // Customize editor behavior.
  /// );
  /// ```
  factory CropRotateEditor.memory(
    Uint8List byteArray, {
    Key? key,
    required ThemeData theme,
    required Size imageSize,
    TransformConfigs? transformConfigs,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    List<Layer>? layers,
    Size? imageSizeWithLayers,
    Size? bodySizeWithLayers,
    Function? onUpdateUI,
  }) {
    return CropRotateEditor._(
      key: key,
      byteArray: byteArray,
      theme: theme,
      layers: layers,
      imageSize: imageSize,
      configs: configs,
      transformConfigs: transformConfigs,
      onUpdateUI: onUpdateUI,
      imageSizeWithLayers: imageSizeWithLayers,
      bodySizeWithLayers: bodySizeWithLayers,
    );
  }

  /// Create a CropRotateEditor widget with an image loaded from a File.
  ///
  /// This factory method allows you to create a CropRotateEditor widget that can be used to crop and rotate an image loaded from a File. The provided parameters allow you to customize the appearance and behavior of the CropRotateEditor widget.
  ///
  /// Parameters:
  /// - `file`: A File object representing the image file to be loaded.
  /// - `key`: An optional Key to uniquely identify this widget in the widget tree.
  /// - `theme`: A ThemeData object that defines the visual styling of the CropRotateEditor widget (required).
  /// - `imageSize`: The size of the image to be edited (required).
  /// - `configs`: The image editor configs.
  /// - `transformConfigs` The transform configurations how the image should be initialized.
  /// - `layers`: A list of Layer objects representing image layers.
  /// - `onUpdateUI`:  A callback function that can be used to update the UI from custom widgets.
  ///
  ///
  /// Returns:
  /// A CropRotateEditor widget configured with the provided parameters and the image loaded from the File.
  ///
  /// Example Usage:
  /// ```dart
  /// final File imageFile = ... // Provide the image file.
  /// final editor = CropRotateEditor.file(
  ///   imageFile,
  ///   theme: ThemeData.light(),
  ///   imageSize: Size(300, 300), // Set the image size.
  ///   configs: CropRotateEditorConfigs(), // Customize editor behavior.
  /// );
  /// ```
  factory CropRotateEditor.file(
    File file, {
    Key? key,
    required ThemeData theme,
    required Size imageSize,
    TransformConfigs? transformConfigs,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    List<Layer>? layers,
    Size? imageSizeWithLayers,
    Size? bodySizeWithLayers,
    Function? onUpdateUI,
  }) {
    return CropRotateEditor._(
      key: key,
      file: file,
      theme: theme,
      layers: layers,
      onUpdateUI: onUpdateUI,
      imageSizeWithLayers: imageSizeWithLayers,
      bodySizeWithLayers: bodySizeWithLayers,
      imageSize: imageSize,
      configs: configs,
      transformConfigs: transformConfigs,
    );
  }

  /// Create a CropRotateEditor widget with an image loaded from an asset.
  ///
  /// This factory method allows you to create a CropRotateEditor widget that can be used to crop and rotate an image loaded from an asset. The provided parameters allow you to customize the appearance and behavior of the CropRotateEditor widget.
  ///
  /// Parameters:
  /// - `assetPath`: A String representing the asset path of the image to be loaded.
  /// - `key`: An optional Key to uniquely identify this widget in the widget tree.
  /// - `theme`: A ThemeData object that defines the visual styling of the CropRotateEditor widget (required).
  /// - `imageSize`: The size of the image to be edited (required).
  /// - `configs`: The image editor configs.
  /// - `transformConfigs` The transform configurations how the image should be initialized.
  /// - `layers`: A list of Layer objects representing image layers.
  /// - `onUpdateUI`:  A callback function that can be used to update the UI from custom widgets.
  ///
  /// Returns:
  /// A CropRotateEditor widget configured with the provided parameters and the image loaded from the asset.
  ///
  /// Example Usage:
  /// ```dart
  /// final String assetPath = 'assets/image.png'; // Provide the asset path.
  /// final editor = CropRotateEditor.asset(
  ///   assetPath,
  ///   theme: ThemeData.light(),
  ///   imageSize: Size(300, 300), // Set the image size.
  ///   configs: CropRotateEditorConfigs(), // Customize editor behavior.
  /// );
  /// ```
  factory CropRotateEditor.asset(
    String assetPath, {
    Key? key,
    required ThemeData theme,
    required Size imageSize,
    TransformConfigs? transformConfigs,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    List<Layer>? layers,
    Size? imageSizeWithLayers,
    Size? bodySizeWithLayers,
    Function? onUpdateUI,
  }) {
    return CropRotateEditor._(
      key: key,
      assetPath: assetPath,
      theme: theme,
      layers: layers,
      imageSize: imageSize,
      configs: configs,
      transformConfigs: transformConfigs,
      onUpdateUI: onUpdateUI,
      imageSizeWithLayers: imageSizeWithLayers,
      bodySizeWithLayers: bodySizeWithLayers,
    );
  }

  /// Create a CropRotateEditor widget with an image loaded from a network URL.
  ///
  /// This factory method allows you to create a CropRotateEditor widget that can be used to apply various image filters and edit an image loaded from a network URL. The provided parameters allow you to customize the appearance and behavior of the CropRotateEditor widget.
  ///
  /// Parameters:
  /// - `networkUrl`: A String representing the network URL of the image to be loaded.
  /// - `key`: An optional Key to uniquely identify this widget in the widget tree.
  /// - `theme`: An optional ThemeData object that defines the visual styling of the CropRotateEditor widget.
  /// - `configs`: The image editor configs.
  /// - `transformConfigs` The transform configurations how the image should be initialized.
  /// - `onUpdateUI`:  A callback function that can be used to update the UI from custom widgets.
  ///
  /// Returns:
  /// A CropRotateEditor widget configured with the provided parameters and the image loaded from the network URL.
  ///
  /// Example Usage:
  /// ```dart
  /// final String imageUrl = 'https://example.com/image.jpg'; // Provide the network URL.
  /// final CropRotateEditor = CropRotateEditor.network(
  ///   imageUrl,
  ///   theme: ThemeData.light(),
  /// );
  /// ```
  factory CropRotateEditor.network(
    String networkUrl, {
    Key? key,
    required ThemeData theme,
    required Size imageSize,
    TransformConfigs? transformConfigs,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    List<Layer>? layers,
    Size? imageSizeWithLayers,
    Size? bodySizeWithLayers,
    Function? onUpdateUI,
  }) {
    return CropRotateEditor._(
      key: key,
      networkUrl: networkUrl,
      theme: theme,
      layers: layers,
      imageSize: imageSize,
      configs: configs,
      transformConfigs: transformConfigs,
      onUpdateUI: onUpdateUI,
      imageSizeWithLayers: imageSizeWithLayers,
      bodySizeWithLayers: bodySizeWithLayers,
    );
  }

  /// Create a CropRotateEditor widget with automatic image source detection.
  ///
  /// This factory method allows you to create a CropRotateEditor widget with automatic detection of the image source type (Uint8List, File, asset, or network URL). Based on the provided parameters, it selects the appropriate source type and creates the CropRotateEditor widget accordingly.
  ///
  /// Parameters:
  /// - `key`: An optional Key to uniquely identify this widget in the widget tree.
  /// - `theme`: An optional ThemeData object that defines the visual styling of the CropRotateEditor widget.
  /// - `byteArray`: An optional Uint8List representing the image data in memory.
  /// - `file`: An optional File object representing the image file to be loaded.
  /// - `assetPath`: An optional String representing the asset path of the image to be loaded.
  /// - `networkUrl`: An optional String representing the network URL of the image to be loaded.
  /// - `configs`: The image editor configs.
  /// - `transformConfigs` The transform configurations how the image should be initialized.
  /// - `onUpdateUI`:  A callback function that can be used to update the UI from custom widgets.
  ///
  /// Returns:
  /// A CropRotateEditor widget configured with the provided parameters and the detected image source.
  ///
  /// Example Usage:
  /// ```dart
  /// // Provide one of the image sources: byteArray, file, assetPath, or networkUrl.
  /// final CropRotateEditor = CropRotateEditor.autoSource(
  ///   byteArray: imageBytes,
  ///   theme: ThemeData.light(),
  /// );
  /// ```
  factory CropRotateEditor.autoSource({
    Key? key,
    required ThemeData theme,
    required Size imageSize,
    TransformConfigs? transformConfigs,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    List<Layer>? layers,
    Size? imageSizeWithLayers,
    Size? bodySizeWithLayers,
    Function? onUpdateUI,
    Uint8List? byteArray,
    File? file,
    String? assetPath,
    String? networkUrl,
  }) {
    if (byteArray != null) {
      return CropRotateEditor.memory(
        byteArray,
        key: key,
        theme: theme,
        layers: layers,
        imageSize: imageSize,
        configs: configs,
        transformConfigs: transformConfigs,
        onUpdateUI: onUpdateUI,
        imageSizeWithLayers: imageSizeWithLayers,
        bodySizeWithLayers: bodySizeWithLayers,
      );
    } else if (file != null) {
      return CropRotateEditor.file(
        file,
        key: key,
        theme: theme,
        layers: layers,
        imageSize: imageSize,
        configs: configs,
        transformConfigs: transformConfigs,
        onUpdateUI: onUpdateUI,
        imageSizeWithLayers: imageSizeWithLayers,
        bodySizeWithLayers: bodySizeWithLayers,
      );
    } else if (networkUrl != null) {
      return CropRotateEditor.network(
        networkUrl,
        key: key,
        theme: theme,
        layers: layers,
        imageSize: imageSize,
        configs: configs,
        transformConfigs: transformConfigs,
        onUpdateUI: onUpdateUI,
        imageSizeWithLayers: imageSizeWithLayers,
        bodySizeWithLayers: bodySizeWithLayers,
      );
    } else if (assetPath != null) {
      return CropRotateEditor.asset(
        assetPath,
        key: key,
        theme: theme,
        layers: layers,
        imageSize: imageSize,
        configs: configs,
        transformConfigs: transformConfigs,
        onUpdateUI: onUpdateUI,
        imageSizeWithLayers: imageSizeWithLayers,
        bodySizeWithLayers: bodySizeWithLayers,
      );
    } else {
      throw ArgumentError("Either 'byteArray', 'file', 'networkUrl' or 'assetPath' must be provided.");
    }
  }

  @override
  State<CropRotateEditor> createState() => CropRotateEditorState();
}

/// A state class for ImageCropRotateEditor widget.
///
/// This class handles the state and UI for an image editor
/// that supports cropping, rotating, and aspect ratio adjustments.
class CropRotateEditorState extends State<CropRotateEditor> with TickerProviderStateMixin {
  late AnimationController _rotateCtrl;
  late AnimationController _scaleCtrl;

  late Animation<double> _rotateAnimation;
  late Animation<double> _scaleAnimation;

  late EditorImage _image;

  int _rotationCount = 0;
  late double _aspectRatio;
  bool _flipX = false;
  bool _flipY = false;
  bool _showWidgets = false;

  double _cropCornerLength = 36;
  double _zoomFactor = 1;
  double _oldScaleFactor = 1;
  final double _screenPadding = 20;
  Offset _translate = const Offset(0, 0);

  Rect _cropRect = Rect.zero;
  Rect _viewRect = Rect.zero;
  late BoxConstraints _contentConstraints;
  late BoxConstraints _renderedImgConstraints;

  /// Debounce for scaling actions in the editor.
  bool _interactionActive = false;

  @override
  void initState() {
    super.initState();
    _initializeEditor();
  }

  /// Initializes the editor with default settings.
  void _initializeEditor() {
    _rotateCtrl = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
    double initAngle = widget.transformConfigs?.angle ?? 0.0;
    _rotateAnimation = Tween<double>(begin: initAngle, end: initAngle).animate(_rotateCtrl);

    _scaleCtrl = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1, end: 1).animate(_scaleCtrl);

    if (widget.transformConfigs != null) {
      _rotationCount = (widget.transformConfigs!.angle * 2 / pi).abs().toInt();
      _flipX = widget.transformConfigs!.flipX;
      _flipY = widget.transformConfigs!.flipY;
      _translate = widget.transformConfigs!.offset;
      _zoomFactor = widget.transformConfigs!.scale;
    }

    _image = EditorImage(
      byteArray: widget.byteArray,
      assetPath: widget.assetPath,
      file: widget.file,
      networkUrl: widget.networkUrl,
    );
    _aspectRatio = widget.configs.cropRotateEditorConfigs.initAspectRatio ?? CropAspectRatios.custom;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calcCropRect(calcCropRect: true);

      Future.delayed(const Duration(milliseconds: 200)).whenComplete(() {
        setState(() {
          _showWidgets = true;
        });
      });
    });
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    _scaleCtrl.dispose();
    super.dispose();

    /// Performs a delayed initialization to ensure UI is ready.
    Future<void> _delayedInit() async {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        /*   setState(() => _inited = true); */
        widget.onUpdateUI?.call();
      }
    }
  }

  double get _screenWidth => MediaQuery.of(context).size.width;
  double get _imgWidth => widget.imageSize.width;
  double get _imgHeight => widget.imageSize.height;

  double get _renderedImgWidth => min(_renderedImgConstraints.maxWidth, _imgWidth);
  double get _renderedImgHeight => min(_renderedImgConstraints.maxHeight, _imgHeight);

  bool get _imageSticksToScreenWidth => _imgWidth >= _contentConstraints.maxWidth;
  bool get _rotated90deg => _rotationCount % 2 != 0;
  Size get _imgSize => Size(
        _rotated90deg ? _imgHeight : _imgWidth,
        _rotated90deg ? _imgWidth : _imgHeight,
      );
  Size get _renderedImgSize => Size(
        _rotated90deg ? _renderedImgHeight : _renderedImgWidth,
        _rotated90deg ? _renderedImgWidth : _renderedImgHeight,
      );

  CropAreaPart _currentCropAreaPart = CropAreaPart.none;

  void reset() {
    _rotateCtrl.animateTo(0, curve: Curves.ease);
    _rotateAnimation = Tween<double>(begin: _rotateAnimation.value, end: 0).animate(_rotateCtrl);
    _rotateCtrl
      ..reset()
      ..forward();
    _rotationCount = 0;
    _flipX = false;
    _flipY = false;
    _translate = Offset.zero;
    _zoomFactor = 1;
  }

  /// Closes the editor without applying changes.
  void close() {
    Navigator.pop(context);
  }

  /// Handles the crop image operation.
  Future<void> done() async {
    Navigator.pop(
      context,
      TransformConfigs(
        angle: _rotateAnimation.value,
        scale: _zoomFactor * _scaleAnimation.value,
        flipX: _flipX,
        flipY: _flipY,
        offset: _translate,
      ),
    );
  }

  /// Flip the image horizontally
  void flip() {
    setState(() {
      if (_rotationCount % 2 != 0) {
        _flipY = !_flipY;
      } else {
        _flipX = !_flipX;
      }
    });
  }

  /// Rotates the image clockwise.
  void rotate() {
    var piHelper = widget.configs.cropRotateEditorConfigs.rotateDirection == RotateDirection.left ? -pi : pi;

    _rotationCount++;
    _rotateCtrl.animateTo(pi, curve: Curves.ease);
    _rotateAnimation = Tween<double>(begin: _rotateAnimation.value, end: _rotationCount * piHelper / 2).animate(_rotateCtrl);
    _rotateCtrl
      ..reset()
      ..forward();

    Size contentSize = Size(
      _contentConstraints.maxWidth - _screenPadding * 2,
      _contentConstraints.maxHeight - _screenPadding * 2,
    );
    bool shouldTransformY = contentSize.aspectRatio > _renderedImgSize.aspectRatio;

    double scaleX = contentSize.width / _renderedImgSize.width;
    double scaleY = contentSize.height / _renderedImgSize.height;

    double scale = shouldTransformY ? scaleY : scaleX;
    _scaleCtrl.animateTo(scale, curve: Curves.ease);
    _scaleAnimation = Tween<double>(begin: _oldScaleFactor, end: scale).animate(_scaleCtrl);
    _scaleCtrl
      ..reset()
      ..forward();

    _oldScaleFactor = scale;
    _calcCropRect(calcCropRect: true);
  }

  void _calcCropRect({
    bool calcCropRect = false,
  }) {
    if (!_showWidgets) return;
    double imgSizeRatio = _imgHeight / _imgWidth;

    double newImgW = _renderedImgConstraints.maxWidth;
    double newImgH = _renderedImgConstraints.maxHeight;

    double cropWidth = _imageSticksToScreenWidth ? newImgW : newImgH / imgSizeRatio;
    double cropHeight = _imageSticksToScreenWidth ? newImgW * imgSizeRatio : newImgH;

    if (calcCropRect || _cropRect.isEmpty) _cropRect = Rect.fromLTWH(0, 0, cropWidth, cropHeight);
    _viewRect = Rect.fromLTWH(0, 0, cropWidth, cropHeight);
    //TODO:   setState(() {});
  }

  /// Opens a dialog to select from predefined aspect ratios.
  void openAspectRatioOptions() {
    showModalBottomSheet<double>(
        context: context,
        backgroundColor: widget.configs.imageEditorTheme.cropRotateEditor.aspectRatioSheetBackgroundColor,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return CropAspectRatioOptions(
            aspectRatio: _aspectRatio,
            configs: widget.configs,
            originalAspectRatio: widget.imageSize.aspectRatio,
          );
        }).then((value) {
      if (value != null) {
        setState(() {
          _aspectRatio = value;
        });
      }
    });
  }

  Offset _getTransformedPointerPosition(Offset localPosition) {
    double imgW = _renderedImgConstraints.maxWidth;
    double imgH = _renderedImgConstraints.maxHeight;

    double gapX = max(
      _screenPadding,
      (_contentConstraints.maxWidth - imgW) / 2,
    );
    double gapY = max(
      _screenPadding,
      (_contentConstraints.maxHeight - imgH) / 2,
    );

    double dx = localPosition.dx - gapX;
    double dy = localPosition.dy - gapY;

    var angleSide = getRotateAngleSide(_rotateAnimation.value);

    /// Important round to 3 decimal that no calculation errors will happen
    if (angleSide == RotateAngleSide.left) {
      if (!_flipX) dy = imgH - dy;
      if (_flipY) dx = imgW - dx;

      return Offset(dy, dx);
    } else if (angleSide == RotateAngleSide.bottom) {
      if (!_flipX) dx = imgW - dx;
      if (!_flipY) dy = imgH - dy;

      return Offset(dx, dy);
    } else if (angleSide == RotateAngleSide.right) {
      if (!_flipY) dx = imgW - dx;
      if (_flipX) dy = imgH - dy;

      return Offset(dy, dx);
    } else {
      if (_flipX) dx = imgW - dx;
      if (_flipY) dy = imgH - dy;

      return Offset(dx, dy);
    }
  }

  CropAreaPart _determineCropAreaPart(Offset localPosition) {
    double imgW = _renderedImgConstraints.maxWidth;
    double imgH = _renderedImgConstraints.maxHeight;
    double gapX = max(
      _screenPadding,
      (_contentConstraints.maxWidth - imgW) / 2,
    );
    double gapTop = (_contentConstraints.maxHeight - imgH) / 2;
    double gapY = max(
      _screenPadding,
      gapTop,
    );
    Offset offset = _getTransformedPointerPosition(localPosition);
    double dx = offset.dx;
    double dy = offset.dy;

    double left = dx - _cropRect.left;
    double right = dx - _cropRect.right;
    double top = dy - _cropRect.top;
    double bottom = dy - _cropRect.bottom;

    bool nearLeftEdge = left <= _cropCornerLength && left >= 0;
    bool nearRightEdge = right >= -_cropCornerLength && right <= 0;
    bool nearTopEdge = top <= _cropCornerLength && top > 0;
    bool nearBottomEdge = bottom >= -_cropCornerLength && bottom <= 0;

    if (_cropRect.contains(localPosition - Offset(gapX, gapY))) {
      if (nearLeftEdge && nearTopEdge) {
        return CropAreaPart.topLeft;
      } else if (nearRightEdge && nearTopEdge) {
        return CropAreaPart.topRight;
      } else if (nearLeftEdge && nearBottomEdge) {
        return CropAreaPart.bottomLeft;
      } else if (nearRightEdge && nearBottomEdge) {
        return CropAreaPart.bottomRight;
      } else if (nearLeftEdge) {
        return CropAreaPart.left;
      } else if (nearRightEdge) {
        return CropAreaPart.right;
      } else if (nearTopEdge) {
        return CropAreaPart.top;
      } else if (nearBottomEdge) {
        return CropAreaPart.bottom;
      } else {
        return CropAreaPart.inside;
      }
    } else {
      return CropAreaPart.none;
    }
  }

  void _onDragStart(DragStartDetails details) {
    _currentCropAreaPart = _determineCropAreaPart(details.localPosition);
    _interactionActive = true;
    setState(() {});
  }

  void _onDragEnd(DragEndDetails details) {
    _interactionActive = false;
    setState(() {});
  }

  void _onDragUpdate(DragUpdateDetails details) {
    var offset = _convertOffsetByTransformations(details.delta);

    if (_currentCropAreaPart != CropAreaPart.none && _currentCropAreaPart != CropAreaPart.inside) {
      double imgW = _renderedImgConstraints.maxWidth;
      double imgH = _renderedImgConstraints.maxHeight;

      double gapX = max(
        _screenPadding,
        (_contentConstraints.maxWidth - imgW) / 2,
      );
      double gapY = max(
        _screenPadding,
        (_contentConstraints.maxHeight - imgH) / 2,
      );

      double outsidePadding = _screenPadding * 2;
      double cornerGap = _cropCornerLength * 2.25;
      double minCornerDistance = outsidePadding + cornerGap;

      Offset offset = details.localPosition;
      double dx = offset.dx - gapX;
      double dy = offset.dy - gapY;

      var angleSide = getRotateAngleSide(_rotateAnimation.value);
      if (angleSide == RotateAngleSide.left) {
        dx = _flipX ? offset.dy - gapY : imgH - offset.dy + gapY;
        dy = _flipY ? imgW - offset.dx + gapX : offset.dx - gapX;
      } else if (angleSide == RotateAngleSide.bottom) {
        dx = _flipX ? offset.dx - gapX : imgW - offset.dx + gapX;
        dy = _flipY ? offset.dy - gapY : imgH - offset.dy + gapY;
      } else if (angleSide == RotateAngleSide.right) {
        dx = _flipX ? imgW - offset.dy + gapY : offset.dy - gapY;
        dy = _flipY ? offset.dx - gapX : imgW - offset.dx + gapX;
      } else {
        if (_flipX) dx = imgW - dx;
        if (_flipY) dy = imgH - dy;
      }

      double maxRight = _cropRect.right + outsidePadding - minCornerDistance;
      double maxBottom = _cropRect.bottom + outsidePadding - minCornerDistance;

      switch (_currentCropAreaPart) {
        case CropAreaPart.topLeft:
          _cropRect = Rect.fromLTRB(
            min(maxRight, max(0, dx)),
            min(maxBottom, max(0, dy)),
            _cropRect.right,
            _cropRect.bottom,
          );
          break;
        case CropAreaPart.topRight:
          _cropRect = Rect.fromLTRB(
            _cropRect.left,
            max(0, min(dy, maxBottom)),
            max(cornerGap + _cropRect.left, min(imgW, dx)),
            _cropRect.bottom,
          );
          break;
        case CropAreaPart.bottomLeft:
          _cropRect = Rect.fromLTRB(
            max(0, min(maxRight, dx)),
            _cropRect.top,
            _cropRect.right,
            max(cornerGap + _cropRect.top, min(imgH, dy)),
          );
          break;
        case CropAreaPart.bottomRight:
          _cropRect = Rect.fromLTRB(
            _cropRect.left,
            _cropRect.top,
            max(cornerGap + _cropRect.left, min(imgW, dx)),
            max(cornerGap + _cropRect.top, min(imgH, dy)),
          );
          break;
        case CropAreaPart.left:
          _cropRect = Rect.fromLTRB(
            min(maxRight, max(0, dx)),
            _cropRect.top,
            _cropRect.right,
            _cropRect.bottom,
          );
          break;
        case CropAreaPart.right:
          _cropRect = Rect.fromLTRB(
            _cropRect.left,
            _cropRect.top,
            max(cornerGap + _cropRect.left, min(imgW, dx)),
            _cropRect.bottom,
          );
          break;
        case CropAreaPart.top:
          _cropRect = Rect.fromLTRB(
            _cropRect.left,
            min(maxBottom, max(0, dy)),
            _cropRect.right,
            _cropRect.bottom,
          );
          break;
        case CropAreaPart.bottom:
          _cropRect = Rect.fromLTRB(
            _cropRect.left,
            _cropRect.top,
            _cropRect.right,
            max(cornerGap + _cropRect.top, min(imgH, dy)),
          );
          break;
        default:
          break;
      }
      setState(() {});
    } else {
      double zoomFactor = _zoomFactor * _scaleAnimation.value;
      _translate += Offset(offset.dx, offset.dy) / zoomFactor;
      _setOffsetLimits();

      setState(() {});
    }
  }

  void _setOffsetLimits() {
    if (_zoomFactor == 1) {
      _translate = const Offset(0, 0);
    } else {
      double zoomFactor = _zoomFactor * _scaleAnimation.value;

      double minX = (_renderedImgWidth * zoomFactor - _renderedImgWidth) / 2 / _zoomFactor;
      double minY = (_renderedImgHeight * _zoomFactor - _renderedImgHeight) / 2 / _zoomFactor;

      if (_rotated90deg) {}

      var offset = _translate;

      if (offset.dx > minX) {
        _translate = Offset(minX, _translate.dy);
      }
      if (offset.dx < -minX) {
        _translate = Offset(-minX, _translate.dy);
      }
      if (offset.dy > minY) {
        _translate = Offset(_translate.dx, minY);
      }
      if (offset.dy < -minY) {
        _translate = Offset(_translate.dx, -minY);
      }
    }
  }

  void _mouseScroll(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      double factor = 0.1;
      double delta = event.scrollDelta.dy;

      if (delta > 0) {
        _zoomFactor -= factor;
        _zoomFactor = max(1, _zoomFactor);
      } else if (delta < 0) {
        _zoomFactor += factor;
        _zoomFactor = min(7, _zoomFactor);
      }

      if (delta < 0 && _zoomFactor < 7 && _zoomFactor > 1) {
        double mouseX = _contentConstraints.maxWidth / 2 - event.position.dx;
        double mouseY = _contentConstraints.maxHeight / 2 - event.position.dy;

        double moveX = mouseX / (_zoomFactor * 10);
        double moveY = mouseY / (_zoomFactor * 10);

        var offset = _convertOffsetByTransformations(Offset(moveX, moveY));

        double offsetX = _translate.dx + offset.dx;
        double offsetY = _translate.dy + offset.dy;
        _translate = Offset(offsetX, offsetY);
      }
      _setOffsetLimits();
      setState(() {});
    }
  }

  Offset _convertOffsetByTransformations(Offset offset) {
    int rotation = _rotationCount % 4;
    double dx = offset.dx;
    double dy = offset.dy;
    if (rotation == 1) {
      dx = offset.dy;
      dy = -offset.dx;
    } else if (rotation == 2) {
      dx = -offset.dx;
      dy = -offset.dy;
    } else if (rotation == 3) {
      dx = -offset.dy;
      dy = offset.dx;
    }

    if (_flipX) dx *= -1;
    if (_flipY) dy *= -1;

    return Offset(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: widget.configs.imageEditorTheme.uiOverlayStyle,
        child: Theme(
          data: widget.theme.copyWith(tooltipTheme: widget.theme.tooltipTheme.copyWith(preferBelow: true)),
          child: Scaffold(
            backgroundColor: widget.configs.imageEditorTheme.cropRotateEditor.background,
            appBar: _buildAppBar(constraints),
            body: _buildBody(),
            bottomNavigationBar: _buildBottomNavigationBar(),
          ),
        ),
      );
    });
  }

  /// Builds the app bar for the editor, including buttons for actions such as back, rotate, aspect ratio, and done.
  PreferredSizeWidget? _buildAppBar(BoxConstraints constraints) {
    return widget.configs.customWidgets.appBarCropRotateEditor ??
        (widget.configs.imageEditorTheme.editorMode == ThemeEditorMode.simple
            ? AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: widget.configs.imageEditorTheme.cropRotateEditor.appBarBackgroundColor,
                foregroundColor: widget.configs.imageEditorTheme.cropRotateEditor.appBarForegroundColor,
                actions: [
                  IconButton(
                    tooltip: widget.configs.i18n.cropRotateEditor.back,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    icon: Icon(widget.configs.icons.backButton),
                    onPressed: close,
                  ),
                  const Spacer(),
                  if (constraints.maxWidth >= 300) ...[
                    /* IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(Icons.flip),
                tooltip: I18n.of(context)!.translate('Flip'),
                iconSize: 28,
                onPressed: () => _editor.flip(),
              ), 
              IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(Icons.restore_page_outlined),
                tooltip: I18n.of(context)!.translate('Reset'),
                iconSize: 28,
                onPressed: () => _editor.reset(),
              ), */
                    if (widget.configs.cropRotateEditorConfigs.canRotate)
                      IconButton(
                        icon: Icon(widget.configs.icons.cropRotateEditor.rotate),
                        tooltip: widget.configs.i18n.cropRotateEditor.rotate,
                        onPressed: rotate,
                      ),
                    if (widget.configs.cropRotateEditorConfigs.canFlip)
                      IconButton(
                        icon: Icon(widget.configs.icons.cropRotateEditor.flip),
                        tooltip: widget.configs.i18n.cropRotateEditor.flip,
                        onPressed: flip,
                      ),
                    if (widget.configs.cropRotateEditorConfigs.canChangeAspectRatio)
                      IconButton(
                        key: const ValueKey('pro-image-editor-aspect-ratio-btn'),
                        icon: Icon(widget.configs.icons.cropRotateEditor.aspectRatio),
                        tooltip: widget.configs.i18n.cropRotateEditor.ratio,
                        onPressed: openAspectRatioOptions,
                      ),
                    const Spacer(),
                    _buildDoneBtn(),
                  ] else ...[
                    const Spacer(),
                    _buildDoneBtn(),
                    PlatformPopupBtn(
                      designMode: widget.configs.designMode,
                      title: widget.configs.i18n.cropRotateEditor.smallScreenMoreTooltip,
                      options: [
                        if (widget.configs.cropRotateEditorConfigs.canRotate)
                          PopupMenuOption(
                            label: widget.configs.i18n.cropRotateEditor.rotate,
                            icon: Icon(widget.configs.icons.cropRotateEditor.rotate),
                            onTap: () {
                              rotate();

                              if (widget.configs.designMode == ImageEditorDesignModeE.cupertino) {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        if (widget.configs.cropRotateEditorConfigs.canChangeAspectRatio)
                          PopupMenuOption(
                            label: widget.configs.i18n.cropRotateEditor.ratio,
                            icon: Icon(widget.configs.icons.cropRotateEditor.aspectRatio),
                            onTap: openAspectRatioOptions,
                          ),
                      ],
                    ),
                  ],
                ],
              )
            : null);
  }

  Widget? _buildBottomNavigationBar() {
    if (widget.configs.imageEditorTheme.editorMode == ThemeEditorMode.whatsapp) {
      return WhatsAppCropRotateToolbar(
        configs: widget.configs,
        onCancel: close,
        onRotate: rotate,
        onDone: done,
        onReset: reset,
        openAspectRatios: openAspectRatioOptions,
      );
    }
    return null;
  }

  Widget _buildBody() {
    return LayoutBuilder(builder: (context, constraints) {
      _contentConstraints = constraints;
      _calcCropRect();
      return _buildMouseListener(
        child: _buildGestureDetector(
          child: _buildRotationTransform(
            child: _buildPaintContainer(
              child: _buildFlipTransform(
                child: _buildRotationScaleTransform(
                  child: _buildCropPainter(
                    child: _buildUserScaleTransform(
                      child: _buildTranslate(
                        child: _buildImage(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Listener _buildMouseListener({required Widget child}) {
    return Listener(
      onPointerSignal: isDesktop ? _mouseScroll : null,
      child: child,
    );
  }

  GestureDetector _buildGestureDetector({required Widget child}) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: _onDragStart,
      onPanUpdate: _onDragUpdate,
      onPanEnd: _onDragEnd,
      child: child,
    );
  }

  AnimatedBuilder _buildRotationTransform({required Widget child}) {
    return AnimatedBuilder(
      animation: _rotateAnimation,
      builder: (context, child) => Transform.rotate(
        angle: _rotateAnimation.value,
        alignment: Alignment.center,
        child: child,
      ),
      child: child,
    );
  }

  Transform _buildFlipTransform({required Widget child}) {
    return Transform.flip(
      flipX: _flipX,
      flipY: _flipY,
      child: child,
    );
  }

  Transform _buildUserScaleTransform({required Widget child}) {
    return Transform.scale(
      scale: _zoomFactor,
      alignment: Alignment.center,
      child: child,
    );
  }

  Transform _buildTranslate({required Widget child}) {
    return Transform.translate(
      offset: _translate,
      child: child,
    );
  }

  AnimatedBuilder _buildRotationScaleTransform({required Widget child}) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        alignment: Alignment.center,
        child: child,
      ),
      child: child,
    );
  }

  CustomPaint _buildCropPainter({required Widget child}) {
    return CustomPaint(
      isComplex: _showWidgets,
      willChange: _showWidgets,
      foregroundPainter: _showWidgets
          ? CropCornerPainter(
              offset: _translate,
              cropRect: _cropRect,
              viewRect: _viewRect,
              scaleFactor: _zoomFactor,
              interactionActive: _interactionActive,
              screenSize: Size(
                _contentConstraints.maxWidth,
                _contentConstraints.maxHeight,
              ),
              imageEditorTheme: widget.configs.imageEditorTheme,
              cornerLength: _cropCornerLength,
            )
          : null,
      child: child,
    );
  }

  Widget _buildPaintContainer({required Widget child}) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.all(_screenPadding),
        child: child,
      ),
    );
  }

  Widget _buildImage() {
    double maxWidth = _imgWidth / _imgHeight * (_contentConstraints.maxHeight - _screenPadding * 2);
    double maxHeight = (_contentConstraints.maxWidth - _screenPadding * 2) * _imgHeight / _imgWidth;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          _renderedImgConstraints = constraints;
          return Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              Hero(
                tag: 'disabled: ${widget.configs.heroTag}',

                /// Important that the image fly correctly
                flightShuttleBuilder: (
                  BuildContext flightContext,
                  Animation<double> animation,
                  HeroFlightDirection flightDirection,
                  BuildContext fromHeroContext,
                  BuildContext toHeroContext,
                ) {
                  final hero = flightDirection == HeroFlightDirection.push ? toHeroContext.widget : toHeroContext.widget;
                  return (hero as Hero).child;
                },
                child: AutoImage(
                  _image,
                  fit: BoxFit.contain,
                  designMode: widget.configs.designMode,
                  width: _imgWidth,
                  height: _imgHeight,
                ),
              ),

              /// TODO: Add layers with hero animation.
              /// Note: When the image is rotated or flipped it affect the hero animation.

              if (widget.configs.cropRotateEditorConfigs.transformLayers && widget.layers != null)
                Builder(builder: (context) {
                  double w = _imgWidth;
                  double h = _imgHeight;
                  double screenGap = _screenPadding * 2;
                  double editorW = _contentConstraints.maxWidth - screenGap;
                  double editorH = _contentConstraints.maxHeight - screenGap;

                  return TransformedContentGenerator(
                    configs: widget.transformConfigs ?? TransformConfigs.empty(),
                    child: Transform.translate(
                      offset: Offset(
                        -_screenPadding,
                        0, // -_screenPadding,
                      ),
                      child: LayerStack(
                        transformHelper: TransformHelper(
                          mainBodySize: widget.bodySizeWithLayers ?? Size.zero,
                          mainImageSize: widget.imageSizeWithLayers ?? Size.zero,
                          editorBodySize: Size(
                            w / h * editorH,
                            editorW * h / w,
                          ),
                        ),
                        configs: widget.configs,
                        layers: widget.layers!,
                        clipBehavior: Clip.none,
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  /// Builds and returns an IconButton for applying changes.
  Widget _buildDoneBtn() {
    return IconButton(
      tooltip: widget.configs.i18n.cropRotateEditor.done,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      icon: Icon(widget.configs.icons.applyChanges),
      iconSize: 28,
      onPressed: done,
    );
  }
}

enum CropAreaPart {
  none,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  left,
  right,
  top,
  bottom,
  inside,
}
