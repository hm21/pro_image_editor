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
import '../../utils/helper/editor_mixin.dart';
import '../../utils/transition_timing.dart';
import '../../widgets/auto_image.dart';
import '../../widgets/layer_stack.dart';
import '../../widgets/platform_popup_menu.dart';
import '../../widgets/pro_image_editor_desktop_mode.dart';
import 'utils/crop_area_part.dart';
import 'utils/crop_aspect_ratios.dart';
import 'utils/crop_corner_painter.dart';
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
class CropRotateEditor extends StatefulWidget with ImageEditorMixin {
  @override
  final ProImageEditorConfigs configs;

  /// The theme configuration for the editor.
  final ThemeData theme;

  /// A Uint8List representing the image data in memory.
  final Uint8List? byteArray;

  /// The asset path of the image.
  final String? assetPath;

  /// The network URL of the image.
  final String? networkUrl;

  /// A File representing the image file.
  final File? file;

  /// The transform configurations how the image should be initialized.
  final TransformConfigs? transformConfigs;

  /// A list of Layer objects representing image layers.
  final List<Layer>? layers;

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
          byteArray != null ||
              file != null ||
              networkUrl != null ||
              assetPath != null,
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
      throw ArgumentError(
          "Either 'byteArray', 'file', 'networkUrl' or 'assetPath' must be provided.");
    }
  }

  @override
  State<CropRotateEditor> createState() => CropRotateEditorState();
}

/// A state class for ImageCropRotateEditor widget.
///
/// This class handles the state and UI for an image editor
/// that supports cropping, rotating, and aspect ratio adjustments.
class CropRotateEditorState extends State<CropRotateEditor>
    with TickerProviderStateMixin, ImageEditorStateMixin {
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
  bool _blockInteraction = false;

  double _aspectRatioZoomHelper = 1;
  double _userZoom = 1;
  double _oldScaleFactor = 1;
  final double _screenPadding = 20;
  Offset _translate = const Offset(0, 0);
  double _startingPinchScale = 1;
  Offset _startingTranslate = Offset.zero;
  Offset _startingCenterOffset = Offset.zero;

  Rect _cropRect = Rect.zero;
  Rect _viewRect = Rect.zero;
  late BoxConstraints _contentConstraints;
  late BoxConstraints _renderedImgConstraints;
  late TapDownDetails _doubleTapDetails;

  /// Debounce for scaling actions in the editor.
  bool _interactionActive = false;

  double get _cropCornerLength => 36;

  double get _zoomFactor => _aspectRatioZoomHelper * _userZoom;

  double get _imgWidth => widget.imageSize.width;
  double get _imgHeight => widget.imageSize.height;

  double get _ratio =>
      1 / (_aspectRatio == 0 ? widget.imageSize.aspectRatio : _aspectRatio);

  bool get _imageSticksToScreenWidth =>
      _imgWidth >= _contentConstraints.maxWidth;
  bool get _rotated90deg => _rotationCount % 2 != 0;
  Size get _renderedImgSize => Size(
        _rotated90deg
            ? _renderedImgConstraints.maxHeight
            : _renderedImgConstraints.maxWidth,
        _rotated90deg
            ? _renderedImgConstraints.maxWidth
            : _renderedImgConstraints.maxHeight,
      );

  CropAreaPart _currentCropAreaPart = CropAreaPart.none;

  @override
  void initState() {
    super.initState();

    double initAngle = widget.transformConfigs?.angle ?? 0.0;
    _rotateCtrl = AnimationController(
        duration: cropRotateEditorConfigs.animationDuration, vsync: this);
    _rotateCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        var tempZoom = _aspectRatioZoomHelper;
        _calcAspectRatioZoomHelper();
        if (tempZoom != _aspectRatioZoomHelper) {
          _userZoom *= tempZoom / _aspectRatioZoomHelper;
          _setOffsetLimits();
        }
        setState(() {});
      }
    });
    _rotateAnimation =
        Tween<double>(begin: initAngle, end: initAngle).animate(_rotateCtrl);

    double initScale = widget.transformConfigs?.scaleRotation ?? 1;
    _scaleCtrl = AnimationController(
        duration: cropRotateEditorConfigs.animationDuration, vsync: this);
    _scaleAnimation =
        Tween<double>(begin: initScale, end: initScale).animate(_scaleCtrl);

    _aspectRatio =
        cropRotateEditorConfigs.initAspectRatio ?? CropAspectRatios.custom;

    if (widget.transformConfigs != null) {
      _rotationCount = (widget.transformConfigs!.angle * 2 / pi).abs().toInt();
      _flipX = widget.transformConfigs!.flipX;
      _flipY = widget.transformConfigs!.flipY;
      _translate = widget.transformConfigs!.offset;
      _aspectRatioZoomHelper = widget.transformConfigs!.scaleAspectRatio;
      _userZoom = widget.transformConfigs!.scaleUser;
      _aspectRatio = widget.transformConfigs!.aspectRatio;
    }

    _image = EditorImage(
      byteArray: widget.byteArray,
      assetPath: widget.assetPath,
      file: widget.file,
      networkUrl: widget.networkUrl,
    );

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

  void reset() {
    _flipX = false;
    _flipY = false;
    _translate = Offset.zero;

    int rotationCount = _rotationCount % 4;
    _rotateAnimation = Tween<double>(
            begin: rotationCount == 3 ? pi / 2 : -rotationCount * pi / 2,
            end: 0)
        .animate(_rotateCtrl);
    _rotateCtrl
      ..reset()
      ..forward();
    _rotationCount = 0;

    _scaleAnimation =
        Tween<double>(begin: _oldScaleFactor * _zoomFactor, end: 1)
            .animate(_scaleCtrl);
    _scaleCtrl
      ..reset()
      ..forward();
    _oldScaleFactor = 1;

    _userZoom = 1;
    _aspectRatioZoomHelper = 1;
    _aspectRatio =
        cropRotateEditorConfigs.initAspectRatio ?? CropAspectRatios.custom;
    _calcCropRect(calcCropRect: true);
    setState(() {});
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
        scaleAspectRatio: _aspectRatioZoomHelper,
        scaleUser: _userZoom,
        scaleRotation: _scaleAnimation.value,
        aspectRatio: _ratio,
        flipX: _flipX,
        flipY: _flipY,
        offset: _translate,
        maxSide: _imageSticksToScreenWidth
            ? ImageMaxSide.horizontal
            : ImageMaxSide.vertical,
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
    var piHelper =
        cropRotateEditorConfigs.rotateDirection == RotateDirection.left
            ? -pi
            : pi;

    _rotationCount++;
    _rotateAnimation = Tween<double>(
            begin: _rotateAnimation.value, end: _rotationCount * piHelper / 2)
        .animate(
      CurvedAnimation(
        parent: _rotateCtrl,
        curve: cropRotateEditorConfigs.rotateAnimationCurve,
      ),
    );
    _rotateCtrl
      ..reset()
      ..forward();

    Size contentSize = Size(
      _contentConstraints.maxWidth - _screenPadding * 2,
      _contentConstraints.maxHeight - _screenPadding * 2,
    );

    double scaleX = contentSize.width / _renderedImgSize.width;
    double scaleY = contentSize.height / _renderedImgSize.height;

    double scale = min(scaleX, scaleY);

    if (_rotated90deg) {
      scale *= _aspectRatioZoomHelper;
    }

    _scaleAnimation = Tween<double>(begin: _oldScaleFactor, end: scale).animate(
      CurvedAnimation(
        parent: _scaleCtrl,
        curve: cropRotateEditorConfigs.scaleAnimationCurve,
      ),
    );
    _scaleCtrl
      ..reset()
      ..forward();

    _oldScaleFactor = scale;
    setState(() {});
  }

  /// Opens a dialog to select from predefined aspect ratios.
  void openAspectRatioOptions() {
    showModalBottomSheet<double>(
        context: context,
        backgroundColor:
            imageEditorTheme.cropRotateEditor.aspectRatioSheetBackgroundColor,
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
          reset();
          _aspectRatio = value;

          if (_ratio >= 0) {
            Size bodySize = Size(
              _contentConstraints.maxWidth - _screenPadding * 2,
              _contentConstraints.maxHeight - _screenPadding * 2,
            );
            _cropRect = Rect.fromCenter(
              center: _cropRect.center,
              width: bodySize.width,
              height: bodySize.width * _ratio,
            );
            if (_cropRect.height > bodySize.height) {
              _cropRect = Rect.fromCenter(
                center: _cropRect.center,
                width: bodySize.height / _ratio,
                height: bodySize.height,
              );
            }

            _calcAspectRatioZoomHelper();
          }
        });
      }
    });
  }

  void _calcAspectRatioZoomHelper() {
    double w = _rotated90deg ? _cropRect.height : _cropRect.width;
    double h = _rotated90deg ? _cropRect.width : _cropRect.height;
    double imgW = _rotated90deg
        ? _renderedImgConstraints.maxHeight
        : _renderedImgConstraints.maxWidth;
    double imgH = _rotated90deg
        ? _renderedImgConstraints.maxWidth
        : _renderedImgConstraints.maxHeight;

    if (w > imgW) {
      _aspectRatioZoomHelper = w / imgW;
    } else if (h > imgH) {
      _aspectRatioZoomHelper = h / imgH;
    } else {
      _aspectRatioZoomHelper = 1;
    }
  }

  void _calcCropRect({
    bool calcCropRect = false,
  }) {
    if (!_showWidgets) return;
    double imgSizeRatio = _imgHeight / _imgWidth;

    double newImgW = _renderedImgConstraints.maxWidth;
    double newImgH = _renderedImgConstraints.maxHeight;

    double cropWidth =
        _imageSticksToScreenWidth ? newImgW : newImgH / imgSizeRatio;
    double cropHeight =
        _imageSticksToScreenWidth ? newImgW * imgSizeRatio : newImgH;

    if (calcCropRect || _cropRect.isEmpty)
      _cropRect = Rect.fromLTWH(0, 0, cropWidth, cropHeight);
    _viewRect = Rect.fromLTWH(0, 0, cropWidth, cropHeight);
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (_blockInteraction) return;
    _blockInteraction = true;
    CropAreaPart determineCropAreaPart(Offset localPosition) {
      Offset offset = localPosition;
      double dx = offset.dx;
      double dy = offset.dy;

      double left = dx - _cropRect.left;
      double right = dx - _cropRect.right;
      double top = dy - _cropRect.top;
      double bottom = dy - _cropRect.bottom;

      bool nearLeftEdge = left.abs() <= _cropCornerLength;
      bool nearRightEdge = right.abs() <= _cropCornerLength;
      bool nearTopEdge = top.abs() <= _cropCornerLength;
      bool nearBottomEdge = bottom.abs() <= _cropCornerLength;
      if (_cropRect.contains(localPosition)) {
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

    _startingPinchScale = _userZoom;
    _startingTranslate = _translate;

    // Calculate the center offset point from the old zoomed view
    _startingCenterOffset = _startingTranslate +
        _getRealHitPoint(position: details.localFocalPoint, zoom: _userZoom) /
            _userZoom;

    _currentCropAreaPart = determineCropAreaPart(details.localFocalPoint);
    _interactionActive = true;
    _blockInteraction = false;
    setState(() {});
  }

  void _onScaleEnd(ScaleEndDetails details) async {
    if (_blockInteraction) return;
    _blockInteraction = true;
    _interactionActive = false;
    setState(() {});

    if (_cropRect != _viewRect) {
      int frameRate = 1000 ~/ 60;
      double duration = 200;

      // TODO: Transform image to new crop area

/*       _zoomFactor *= 1 / _cropRect.longestSide * _viewRect.longestSide;
      _translate += Offset(
        _cropRect.left / 2,
        _cropRect.top / 2,
      );
 */

      // TODO: set aspect ratio to custom value if not is set to "free"
      double aspecRatio = _cropRect.size.aspectRatio;

      var body = Size(
        _contentConstraints.maxWidth - _screenPadding * 2,
        _contentConstraints.maxHeight - _screenPadding * 2,
      );

      bool _scaleToWidth = false;

      if (body.width > _cropRect.width && body.height > _cropRect.height) {
        _scaleToWidth =
            body.width - _cropRect.width < body.height - _cropRect.height;
      }

      double gapTop = _cropRect.top;
      double gapBottom = (_viewRect.bottom - _cropRect.bottom);

      double factorLeft = _cropRect.left / duration * frameRate;
      double factorTop = gapTop / duration * frameRate;
      double factorRight =
          (_viewRect.right - _cropRect.right) / duration * frameRate;
      double factorBottom = gapBottom / duration * frameRate;

      double factorZoom = body.width / _cropRect.width / duration * frameRate;

      bool activeLoop = false;
      double deleteme = 0; //TODO:

      while (
          activeLoop /*_cropRect.top > 0 ||
              _cropRect.left > 0 ||
              _cropRect.right < _viewRect.right ||
              _cropRect.bottom < _viewRect.bottom   ||
        body.width > _cropRect.width ||
          body.height > _cropRect.height */
          ) {
        /*    _zoomFactor += factorZoom / 2;

         _translate = Offset(
          _translate.dx - factorLeft / 2,
          _translate.dy - factorTop / 2,
        ); 
        _cropRect = Rect.fromLTRB(
          _cropRect.left > 0 ? max(0, _cropRect.left - factorLeft) : 0,
          _cropRect.top > 0 ? max(0, _cropRect.top - factorTop) : 0,
          _cropRect.right < _viewRect.right ? min(_viewRect.right, _cropRect.right + factorRight) : _viewRect.right,
          _cropRect.bottom < _viewRect.bottom ? min(_viewRect.bottom, _cropRect.bottom + factorBottom) : _viewRect.bottom,
        );

       */
        if (_cropRect.width >= _viewRect.width &&
            _cropRect.height < _viewRect.height) {
          if (gapTop > 0 && _cropRect.top > gapTop / 2) {
            _translate = Offset(0, _translate.dy - factorTop / 2);

            _cropRect = Rect.fromLTRB(
              _cropRect.left,
              max(gapTop / 2, _cropRect.top - factorTop / 2),
              _cropRect.right,
              max(gapTop / 2, _cropRect.bottom - factorTop / 2),
            );
          } else if (gapBottom > 0 && _cropRect.top < gapBottom / 2) {
            _translate = Offset(0, _translate.dy + factorBottom / 2);

            _cropRect = Rect.fromLTRB(
              _cropRect.left,
              _cropRect.top + factorBottom / 2,
              _cropRect.right,
              _cropRect.bottom + factorBottom / 2,
            );
          } else {
            activeLoop = false;
          }
        } else {
          activeLoop = false;
        }

        await Future.delayed(Duration(milliseconds: frameRate));
        setState(() {});

        if (deleteme > 100) activeLoop = false;
        deleteme++;
      }

      _calcCropRect();
    }
    _blockInteraction = false;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    _blockInteraction = false;

    if (_blockInteraction) return;
    _blockInteraction = true;
    if (details.pointerCount == 2) {
      double newZoom = max(
        1,
        min(
          cropRotateEditorConfigs.maxScale,
          _startingPinchScale * details.scale,
        ),
      );

      // Calculate the center offset point from the new zoomed view
      Offset centerZoomOffset =
          _startingCenterOffset * _startingPinchScale / newZoom;

      // Update translation and zoom values
      _translate =
          _startingTranslate - _startingCenterOffset + centerZoomOffset;
      _userZoom = newZoom;

      // Set offset limits and trigger widget rebuild
      _setOffsetLimits();
      setState(() {});
    } else {
      var offset = details.focalPointDelta;

      if (_currentCropAreaPart != CropAreaPart.none &&
          _currentCropAreaPart != CropAreaPart.inside) {
        double imgW = _renderedImgConstraints.maxWidth;
        double imgH = _renderedImgConstraints.maxHeight;

        double outsidePadding = _screenPadding * 2;
        double cornerGap = _cropCornerLength * 2.25;
        double minCornerDistance = outsidePadding + cornerGap;

        Offset offset = details.localFocalPoint;
        double dx = offset.dx;
        double dy = offset.dy;

        double maxRight = _cropRect.right + outsidePadding - minCornerDistance;
        double maxBottom =
            _cropRect.bottom + outsidePadding - minCornerDistance;

        switch (_currentCropAreaPart) {
          case CropAreaPart.topLeft:
            double left = min(maxRight, max(0, dx));
            _cropRect = Rect.fromLTRB(
              left,
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

        if (_ratio >= 0 && _cropRect.size.aspectRatio != _ratio) {
          if (_currentCropAreaPart == CropAreaPart.left ||
              _currentCropAreaPart == CropAreaPart.right) {
            _cropRect = Rect.fromCenter(
              center: _cropRect.center,
              width: _cropRect.width,
              height: _cropRect.width * _ratio,
            );
          } else if (_currentCropAreaPart == CropAreaPart.top ||
              _currentCropAreaPart == CropAreaPart.bottom) {
            _cropRect = Rect.fromCenter(
              center: _cropRect.center,
              width: _cropRect.height / _ratio,
              height: _cropRect.height,
            );
          } else if (_currentCropAreaPart == CropAreaPart.topLeft ||
              _currentCropAreaPart == CropAreaPart.topRight) {
            double gapBottom = _viewRect.height - _cropRect.bottom;
            _cropRect = Rect.fromLTRB(
              _cropRect.left,
              _viewRect.height - gapBottom - _cropRect.width * _ratio,
              _cropRect.right,
              _cropRect.bottom,
            );
          } else if (_currentCropAreaPart == CropAreaPart.bottomLeft ||
              _currentCropAreaPart == CropAreaPart.bottomRight) {
            _cropRect = Rect.fromLTRB(
              _cropRect.left,
              _cropRect.top,
              _cropRect.right,
              _cropRect.width * _ratio + _cropRect.top,
            );
          }
        }

        setState(() {});
      } else {
        _translate += Offset(offset.dx, offset.dy) *
            (cropRotateEditorConfigs.reverseDragDirection ? -1 : 1);
        _setOffsetLimits();

        setState(() {});
      }
    }
    _blockInteraction = false;
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() async {
    double clampValue(double value, double min, double max) {
      if (value < min) {
        return min;
      } else if (value > max) {
        return max;
      } else {
        return value;
      }
    }

    if (!cropRotateEditorConfigs.enableDoubleTap || _blockInteraction) return;
    _blockInteraction = true;

    bool zoomInside = _userZoom <= 1;
    int frameRate = 1000 ~/ 60;
    double duration =
        cropRotateEditorConfigs.animationDuration.inMilliseconds.toDouble();
    double startTime = DateTime.now().millisecondsSinceEpoch.toDouble();
    double endTime = startTime + duration;
    double startZoom = _userZoom;
    double targetZoom =
        zoomInside ? cropRotateEditorConfigs.doubleTapScaleFactor : 1;
    Offset startOffset = _translate;

    Offset targetOffset = zoomInside
        ? (_translate -
            Offset(
              _doubleTapDetails.localPosition.dx -
                  _renderedImgConstraints.maxWidth / 2,
              _doubleTapDetails.localPosition.dy -
                  _renderedImgConstraints.maxHeight / 2,
            ))
        : Offset.zero;

    double maxOffsetX =
        (_renderedImgConstraints.maxWidth * targetZoom - _viewRect.width) /
            2 /
            targetZoom;
    double maxOffsetY =
        (_renderedImgConstraints.maxHeight * targetZoom - _viewRect.height) /
            2 /
            targetZoom;
    _blockInteraction = false;

    /// direct double clamp trigger an error on android samsung s10 so better use own solution to clamp
    targetOffset = Offset(
      clampValue(targetOffset.dx, -maxOffsetX, maxOffsetX),
      clampValue(targetOffset.dy, -maxOffsetY, maxOffsetY),
    );

    while (DateTime.now().millisecondsSinceEpoch < endTime) {
      double t = (DateTime.now().millisecondsSinceEpoch - startTime) / duration;
      double curveT = decelerate(t);
      _userZoom = startZoom + (targetZoom - startZoom) * curveT;
      _translate = startOffset +
          (targetOffset - startOffset) * targetZoom / _userZoom * curveT;
      setState(() {});
      await Future.delayed(Duration(milliseconds: frameRate));
    }

    _userZoom = targetZoom;
    _translate = targetOffset;
    _setOffsetLimits();
    setState(() {});
    _blockInteraction = false;
  }

  void _setOffsetLimits() {
    if (_zoomFactor == 1) {
      _translate = const Offset(0, 0);
    } else {
      double cropWidth = (_cropRect.right - _cropRect.left);
      double cropHeight = (_cropRect.bottom - _cropRect.top);

      double minX =
          (_renderedImgConstraints.maxWidth * _zoomFactor - cropWidth) /
              2 /
              _zoomFactor;
      double minY =
          (_renderedImgConstraints.maxHeight * _zoomFactor - cropHeight) /
              2 /
              _zoomFactor;

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
    // Check if interaction is blocked
    if (_blockInteraction) return;

    if (event is PointerScrollEvent) {
      // Define zoom factor and extract vertical scroll delta
      double factor = cropRotateEditorConfigs.mouseScaleFactor;

      double deltaY = event.scrollDelta.dy *
          (cropRotateEditorConfigs.reverseMouseScroll ? -1 : 1);

      double startZoom = _userZoom;
      double newZoom = _userZoom;
      // Adjust zoom based on scroll direction
      if (deltaY > 0) {
        newZoom -= factor;
        newZoom = max(1, newZoom);
      } else if (deltaY < 0) {
        newZoom += factor;
        newZoom = min(cropRotateEditorConfigs.maxScale, newZoom);
      }

      // Get dimensions of the rendered image

      // Calculate the center offset point from the old zoomed view
      Offset centerOffset = _translate +
          _getRealHitPoint(zoom: startZoom, position: event.localPosition) /
              startZoom;
      // Calculate the center offset point from the new zoomed view
      Offset centerZoomOffset = centerOffset * startZoom / newZoom;

      // Update translation and zoom values
      _translate -= centerOffset - centerZoomOffset;
      _userZoom = newZoom;

      // Set offset limits and trigger widget rebuild
      _setOffsetLimits();
      setState(() {});
    }
  }

  Offset _getRealHitPoint({
    required double zoom,
    required Offset position,
  }) {
    double imgW = _renderedImgConstraints.maxWidth;
    double imgH = _renderedImgConstraints.maxHeight;

    // Calculate the transformed local position of the pointer
    Offset transformedLocalPosition = position * zoom;
    // Calculate the size of the transformed image
    Size transformedImgSize = Size(
      imgW * zoom,
      imgH * zoom,
    );

    // Calculate the center offset point from the old zoomed view
    return Offset(
      transformedLocalPosition.dx - transformedImgSize.width / 2,
      transformedLocalPosition.dy - transformedImgSize.height / 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: imageEditorTheme.uiOverlayStyle,
        child: Theme(
          data: widget.theme.copyWith(
              tooltipTheme:
                  widget.theme.tooltipTheme.copyWith(preferBelow: true)),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: imageEditorTheme.cropRotateEditor.background,
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
    return customWidgets.appBarCropRotateEditor ??
        (imageEditorTheme.editorMode == ThemeEditorMode.simple
            ? AppBar(
                automaticallyImplyLeading: false,
                backgroundColor:
                    imageEditorTheme.cropRotateEditor.appBarBackgroundColor,
                foregroundColor:
                    imageEditorTheme.cropRotateEditor.appBarForegroundColor,
                actions: [
                  IconButton(
                    tooltip: i18n.cropRotateEditor.back,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    icon: Icon(icons.backButton),
                    onPressed: close,
                  ),
                  const Spacer(),
                  if (constraints.maxWidth >= 300) ...[
                    if (cropRotateEditorConfigs.canRotate)
                      IconButton(
                        icon: Icon(icons.cropRotateEditor.rotate),
                        tooltip: i18n.cropRotateEditor.rotate,
                        onPressed: rotate,
                      ),
                    if (cropRotateEditorConfigs.canFlip)
                      IconButton(
                        icon: Icon(icons.cropRotateEditor.flip),
                        tooltip: i18n.cropRotateEditor.flip,
                        onPressed: flip,
                      ),
                    if (cropRotateEditorConfigs.canChangeAspectRatio)
                      IconButton(
                        icon: Icon(icons.cropRotateEditor.aspectRatio),
                        tooltip: i18n.cropRotateEditor.ratio,
                        onPressed: openAspectRatioOptions,
                      ),
                    if (cropRotateEditorConfigs.canReset)
                      IconButton(
                        icon: Icon(icons.cropRotateEditor.reset),
                        tooltip: i18n.cropRotateEditor.reset,
                        onPressed: reset,
                      ),
                    const Spacer(),
                    _buildDoneBtn(),
                  ] else ...[
                    const Spacer(),
                    _buildDoneBtn(),
                    PlatformPopupBtn(
                      designMode: designMode,
                      title: i18n.cropRotateEditor.smallScreenMoreTooltip,
                      options: [
                        if (cropRotateEditorConfigs.canRotate)
                          PopupMenuOption(
                            label: i18n.cropRotateEditor.rotate,
                            icon: Icon(icons.cropRotateEditor.rotate),
                            onTap: () {
                              rotate();

                              if (designMode ==
                                  ImageEditorDesignModeE.cupertino) {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        if (cropRotateEditorConfigs.canFlip)
                          PopupMenuOption(
                            label: i18n.cropRotateEditor.flip,
                            icon: Icon(icons.cropRotateEditor.flip),
                            onTap: flip,
                          ),
                        if (cropRotateEditorConfigs.canChangeAspectRatio)
                          PopupMenuOption(
                            label: i18n.cropRotateEditor.ratio,
                            icon: Icon(icons.cropRotateEditor.aspectRatio),
                            onTap: openAspectRatioOptions,
                          ),
                        if (cropRotateEditorConfigs.canReset)
                          PopupMenuOption(
                            label: i18n.cropRotateEditor.reset,
                            icon: Icon(icons.cropRotateEditor.reset),
                            onTap: reset,
                          ),
                      ],
                    ),
                  ],
                ],
              )
            : null);
  }

  Widget? _buildBottomNavigationBar() {
    if (imageEditorTheme.editorMode == ThemeEditorMode.whatsapp) {
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
    return LayoutBuilder(
      builder: (context, constraints) {
        _contentConstraints = constraints;
        _calcCropRect();

        return _buildRotationTransform(
          child: _buildFlipTransform(
            child: _buildRotationScaleTransform(
              child: _buildPaintContainer(
                child: _buildCropPainter(
                  child: _buildUserScaleTransform(
                    child: _buildTranslate(
                      child: _buildMouseListener(
                        child: _buildGestureDetector(
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
      },
    );
  }

  Listener _buildMouseListener({required Widget child}) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerSignal: isDesktop ? _mouseScroll : null,
      child: child,
    );
  }

  Widget _buildGestureDetector({required Widget child}) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onScaleStart: _onScaleStart,
      onScaleEnd: _onScaleEnd,
      onScaleUpdate: _onScaleUpdate,
      onDoubleTapDown: _handleDoubleTapDown,
      onDoubleTap: _handleDoubleTap,
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

  Widget _buildUserScaleTransform({required Widget child}) {
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

  Widget _buildRotationScaleTransform({required Widget child}) {
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

  Widget _buildCropPainter({required Widget child}) {
    return CustomPaint(
      isComplex: _showWidgets,
      willChange: _showWidgets,
      foregroundPainter: _showWidgets
          ? CropCornerPainter(
              offset: _translate,
              cropRect: _cropRect,
              viewRect: _viewRect,
              scaleFactor: _zoomFactor,
              rotationScaleFactor: _oldScaleFactor,
              interactionActive: _interactionActive,
              screenSize: Size(
                _contentConstraints.maxWidth,
                _contentConstraints.maxHeight,
              ),
              imageEditorTheme: imageEditorTheme,
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
    double maxWidth = _imgWidth /
        _imgHeight *
        (_contentConstraints.maxHeight - _screenPadding * 2);
    double maxHeight = (_contentConstraints.maxWidth - _screenPadding * 2) *
        _imgHeight /
        _imgWidth;
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
                tag: 'disabled: $heroTag',

                /// Important that the image fly correctly
                flightShuttleBuilder: (
                  BuildContext flightContext,
                  Animation<double> animation,
                  HeroFlightDirection flightDirection,
                  BuildContext fromHeroContext,
                  BuildContext toHeroContext,
                ) {
                  final hero = flightDirection == HeroFlightDirection.push
                      ? toHeroContext.widget
                      : toHeroContext.widget;
                  return (hero as Hero).child;
                },
                child: AutoImage(
                  _image,
                  fit: BoxFit.contain,
                  designMode: designMode,
                  width: _imgWidth,
                  height: _imgHeight,
                ),
              ),

              /// TODO: Add layers with hero animation.
              /// Note: When the image is rotated or flipped it affect the hero animation.

              if (cropRotateEditorConfigs.transformLayers &&
                  widget.layers != null)
                ClipRRect(
                  clipBehavior: Clip.hardEdge,
                  child: TransformedContentGenerator(
                    configs:
                        widget.transformConfigs ?? TransformConfigs.empty(),
                    child: LayerStack(
                      transformHelper: TransformHelper(
                        alignTopLeft: false,
                        mainBodySize: widget.bodySizeWithLayers ?? Size.zero,
                        mainImageSize: widget.imageSizeWithLayers ?? Size.zero,
                        editorBodySize: Size(
                          _renderedImgConstraints.maxWidth,
                          _renderedImgConstraints.maxHeight,
                        ),
                      ),
                      configs: widget.configs,
                      layers: widget.layers!,
                      clipBehavior: Clip.none,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Builds and returns an IconButton for applying changes.
  Widget _buildDoneBtn() {
    return IconButton(
      tooltip: i18n.cropRotateEditor.done,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      icon: Icon(icons.applyChanges),
      iconSize: 28,
      onPressed: done,
    );
  }
}
