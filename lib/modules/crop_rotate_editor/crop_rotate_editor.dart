import 'dart:io';
import 'dart:math';
import 'dart:ui' show Image;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:pro_image_editor/modules/crop_rotate_editor/widgets/crop_aspect_ratio_options.dart';
import 'package:pro_image_editor/widgets/pro_image_editor_desktop_mode.dart';

import '../../models/crop_rotate_editor_response.dart';
import '../../models/custom_widgets.dart';
import '../../models/editor_configs/crop_rotate_editor_configs.dart';
import '../../models/editor_image.dart';
import '../../models/theme/theme.dart';
import '../../models/i18n/i18n.dart';
import '../../models/icons/icons.dart';
import '../../utils/debounce.dart';
import '../../widgets/auto_image.dart';
import '../../widgets/platform_popup_menu.dart';
import 'utils/crop_aspect_ratios.dart';
import '../../utils/design_mode.dart';
import '../../widgets/loading_dialog.dart';
import 'utils/crop_corner_painter.dart';

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

  /// The internationalization (i18n) configuration for the editor.
  final I18n i18n;

  /// Custom widgets configuration for the editor.
  final ImageEditorCustomWidgets customWidgets;

  /// Icons used in the editor.
  final ImageEditorIcons icons;

  /// The theme configuration for the editor.
  final ThemeData theme;

  /// The design mode of the editor.
  final ImageEditorDesignModeE designMode;

  /// The theme configuration specific to the image editor.
  final ImageEditorTheme imageEditorTheme;

  /// Configuration settings for the CropRotateEditor.
  ///
  /// This parameter allows you to customize the behavior and appearance of the CropRotateEditor.
  final CropRotateEditorConfigs configs;

  /// The size of the image to be edited.
  final Size imageSize;

  /// A unique hero tag for the image.
  final String heroTag;

// TODO: write doc
  final Widget? layersWidget;

  /// Private constructor for creating a `CropRotateEditor` widget.
  const CropRotateEditor._({
    super.key,
    this.byteArray,
    this.assetPath,
    this.networkUrl,
    this.file,
    required this.theme,
    required this.i18n,
    required this.customWidgets,
    required this.icons,
    required this.designMode,
    required this.imageEditorTheme,
    required this.imageSize,
    required this.heroTag,
    required this.configs,
    this.layersWidget,
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
  /// - `i18n`: An I18n object for localization and internationalization (required).
  /// - `customWidgets`: A CustomWidgets object for customizing the widgets used in the editor (required).
  /// - `icons`: An ImageEditorIcons object for customizing the icons used in the editor (required).
  /// - `designMode`: An ImageEditorDesignMode enum to specify the design mode (material or custom) of the ImageEditor (required).
  /// - `imageEditorTheme`: An ImageEditorTheme object for customizing the overall theme of the editor (required).
  /// - `imageSize`: The size of the image to be edited (required).
  /// - `heroTag`: A unique hero tag for the image (required).
  /// - `configs`: Configuration settings for the CropRotateEditor (required).
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
  ///   i18n: I18n(),
  ///   customWidgets: CustomWidgets(),
  ///   icons: ImageEditorIcons(),
  ///   designMode: ImageEditorDesignMode.material,
  ///   imageEditorTheme: ImageEditorTheme(),
  ///   imageSize: Size(300, 300), // Set the image size.
  ///   heroTag: 'image_hero_tag', // Set a unique hero tag.
  ///   configs: CropRotateEditorConfigs(), // Customize editor behavior.
  /// );
  /// ```
  factory CropRotateEditor.memory(
    Uint8List byteArray, {
    Key? key,
    required ThemeData theme,
    I18n i18n = const I18n(),
    ImageEditorCustomWidgets customWidgets = const ImageEditorCustomWidgets(),
    ImageEditorIcons icons = const ImageEditorIcons(),
    ImageEditorDesignModeE designMode = ImageEditorDesignModeE.material,
    ImageEditorTheme imageEditorTheme = const ImageEditorTheme(),
    required Size imageSize,
    required String heroTag,
    CropRotateEditorConfigs configs = const CropRotateEditorConfigs(),
    Widget? layersWidget,
  }) {
    return CropRotateEditor._(
      key: key,
      byteArray: byteArray,
      theme: theme,
      i18n: i18n,
      customWidgets: customWidgets,
      icons: icons,
      designMode: designMode,
      imageEditorTheme: imageEditorTheme,
      layersWidget: layersWidget,
      imageSize: imageSize,
      heroTag: heroTag,
      configs: configs,
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
  /// - `i18n`: An I18n object for localization and internationalization (required).
  /// - `customWidgets`: A CustomWidgets object for customizing the widgets used in the editor (required).
  /// - `icons`: An ImageEditorIcons object for customizing the icons used in the editor (required).
  /// - `designMode`: An ImageEditorDesignMode enum to specify the design mode (material or custom) of the ImageEditor (required).
  /// - `imageEditorTheme`: An ImageEditorTheme object for customizing the overall theme of the editor (required).
  /// - `imageSize`: The size of the image to be edited (required).
  /// - `heroTag`: A unique hero tag for the image (required).
  /// - `configs`: Configuration settings for the CropRotateEditor (required).
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
  ///   i18n: I18n(),
  ///   customWidgets: CustomWidgets(),
  ///   icons: ImageEditorIcons(),
  ///   designMode: ImageEditorDesignMode.material,
  ///   imageEditorTheme: ImageEditorTheme(),
  ///   imageSize: Size(300, 300), // Set the image size.
  ///   heroTag: 'image_hero_tag', // Set a unique hero tag.
  ///   configs: CropRotateEditorConfigs(), // Customize editor behavior.
  /// );
  /// ```
  factory CropRotateEditor.file(
    File file, {
    Key? key,
    required ThemeData theme,
    I18n i18n = const I18n(),
    ImageEditorCustomWidgets customWidgets = const ImageEditorCustomWidgets(),
    ImageEditorIcons icons = const ImageEditorIcons(),
    ImageEditorDesignModeE designMode = ImageEditorDesignModeE.material,
    ImageEditorTheme imageEditorTheme = const ImageEditorTheme(),
    required Size imageSize,
    required String heroTag,
    CropRotateEditorConfigs configs = const CropRotateEditorConfigs(),
    Widget? layersWidget,
  }) {
    return CropRotateEditor._(
      key: key,
      file: file,
      theme: theme,
      i18n: i18n,
      customWidgets: customWidgets,
      icons: icons,
      designMode: designMode,
      imageEditorTheme: imageEditorTheme,
      layersWidget: layersWidget,
      imageSize: imageSize,
      heroTag: heroTag,
      configs: configs,
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
  /// - `i18n`: An I18n object for localization and internationalization (required).
  /// - `customWidgets`: A CustomWidgets object for customizing the widgets used in the editor (required).
  /// - `icons`: An ImageEditorIcons object for customizing the icons used in the editor (required).
  /// - `designMode`: An ImageEditorDesignMode enum to specify the design mode (material or custom) of the ImageEditor (required).
  /// - `imageEditorTheme`: An ImageEditorTheme object for customizing the overall theme of the editor (required).
  /// - `imageSize`: The size of the image to be edited (required).
  /// - `heroTag`: A unique hero tag for the image (required).
  /// - `configs`: Configuration settings for the CropRotateEditor (required).
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
  ///   i18n: I18n(),
  ///   customWidgets: CustomWidgets(),
  ///   icons: ImageEditorIcons(),
  ///   designMode: ImageEditorDesignMode.material,
  ///   imageEditorTheme: ImageEditorTheme(),
  ///   imageSize: Size(300, 300), // Set the image size.
  ///   heroTag: 'image_hero_tag', // Set a unique hero tag.
  ///   configs: CropRotateEditorConfigs(), // Customize editor behavior.
  /// );
  /// ```
  factory CropRotateEditor.asset(
    String assetPath, {
    Key? key,
    required ThemeData theme,
    I18n i18n = const I18n(),
    ImageEditorCustomWidgets customWidgets = const ImageEditorCustomWidgets(),
    ImageEditorIcons icons = const ImageEditorIcons(),
    ImageEditorDesignModeE designMode = ImageEditorDesignModeE.material,
    ImageEditorTheme imageEditorTheme = const ImageEditorTheme(),
    required Size imageSize,
    required String heroTag,
    CropRotateEditorConfigs configs = const CropRotateEditorConfigs(),
    Widget? layersWidget,
  }) {
    return CropRotateEditor._(
      key: key,
      assetPath: assetPath,
      theme: theme,
      i18n: i18n,
      customWidgets: customWidgets,
      icons: icons,
      designMode: designMode,
      imageEditorTheme: imageEditorTheme,
      layersWidget: layersWidget,
      imageSize: imageSize,
      heroTag: heroTag,
      configs: configs,
    );
  }

  /// Create a FilterEditor widget with an image loaded from a network URL.
  ///
  /// This factory method allows you to create a FilterEditor widget that can be used to apply various image filters and edit an image loaded from a network URL. The provided parameters allow you to customize the appearance and behavior of the FilterEditor widget.
  ///
  /// Parameters:
  /// - `networkUrl`: A String representing the network URL of the image to be loaded.
  /// - `key`: An optional Key to uniquely identify this widget in the widget tree.
  /// - `theme`: An optional ThemeData object that defines the visual styling of the FilterEditor widget.
  /// - `designMode`: An optional ImageEditorDesignMode enum to specify the design mode (material or custom) of the ImageEditor.
  /// - `i18n`: An optional I18n object for localization and internationalization.
  /// - `customWidgets`: An optional CustomWidgets object for customizing the widgets used in the editor.
  /// - `icons`: An optional ImageEditorIcons object for customizing the icons used in the editor.
  /// - `imageEditorTheme`: An optional ImageEditorTheme object for customizing the overall theme of the editor.
  /// - `heroTag`: An optional String used to create a hero animation between two FilterEditor instances.
  /// - `configs`: An optional FilterEditorConfigs object for customizing the behavior of the FilterEditor.
  ///
  /// Returns:
  /// A FilterEditor widget configured with the provided parameters and the image loaded from the network URL.
  ///
  /// Example Usage:
  /// ```dart
  /// final String imageUrl = 'https://example.com/image.jpg'; // Provide the network URL.
  /// final filterEditor = FilterEditor.network(
  ///   imageUrl,
  ///   theme: ThemeData.light(),
  ///   designMode: ImageEditorDesignMode.material,
  ///   heroTag: 'unique_hero_tag',
  /// );
  /// ```
  factory CropRotateEditor.network(
    String networkUrl, {
    Key? key,
    required ThemeData theme,
    I18n i18n = const I18n(),
    ImageEditorCustomWidgets customWidgets = const ImageEditorCustomWidgets(),
    ImageEditorIcons icons = const ImageEditorIcons(),
    ImageEditorDesignModeE designMode = ImageEditorDesignModeE.material,
    ImageEditorTheme imageEditorTheme = const ImageEditorTheme(),
    required Size imageSize,
    required String heroTag,
    CropRotateEditorConfigs configs = const CropRotateEditorConfigs(),
    Widget? layersWidget,
  }) {
    return CropRotateEditor._(
      key: key,
      networkUrl: networkUrl,
      theme: theme,
      i18n: i18n,
      customWidgets: customWidgets,
      icons: icons,
      designMode: designMode,
      imageEditorTheme: imageEditorTheme,
      layersWidget: layersWidget,
      imageSize: imageSize,
      heroTag: heroTag,
      configs: configs,
    );
  }

  /// Create a FilterEditor widget with automatic image source detection.
  ///
  /// This factory method allows you to create a FilterEditor widget with automatic detection of the image source type (Uint8List, File, asset, or network URL). Based on the provided parameters, it selects the appropriate source type and creates the FilterEditor widget accordingly.
  ///
  /// Parameters:
  /// - `key`: An optional Key to uniquely identify this widget in the widget tree.
  /// - `theme`: An optional ThemeData object that defines the visual styling of the FilterEditor widget.
  /// - `designMode`: An optional ImageEditorDesignMode enum to specify the design mode (material or custom) of the ImageEditor.
  /// - `i18n`: An optional I18n object for localization and internationalization.
  /// - `customWidgets`: An optional CustomWidgets object for customizing the widgets used in the editor.
  /// - `icons`: An optional ImageEditorIcons object for customizing the icons used in the editor.
  /// - `imageEditorTheme`: An optional ImageEditorTheme object for customizing the overall theme of the editor.
  /// - `heroTag`: An optional String used to create a hero animation between two FilterEditor instances.
  /// - `byteArray`: An optional Uint8List representing the image data in memory.
  /// - `file`: An optional File object representing the image file to be loaded.
  /// - `assetPath`: An optional String representing the asset path of the image to be loaded.
  /// - `networkUrl`: An optional String representing the network URL of the image to be loaded.
  /// - `configs`: An optional FilterEditorConfigs object for customizing the behavior of the FilterEditor.
  ///
  /// Returns:
  /// A FilterEditor widget configured with the provided parameters and the detected image source.
  ///
  /// Example Usage:
  /// ```dart
  /// // Provide one of the image sources: byteArray, file, assetPath, or networkUrl.
  /// final filterEditor = FilterEditor.autoSource(
  ///   byteArray: imageBytes,
  ///   theme: ThemeData.light(),
  ///   designMode: ImageEditorDesignMode.material,
  ///   heroTag: 'unique_hero_tag',
  /// );
  /// ```
  factory CropRotateEditor.autoSource({
    Key? key,
    required ThemeData theme,
    I18n i18n = const I18n(),
    ImageEditorCustomWidgets customWidgets = const ImageEditorCustomWidgets(),
    ImageEditorIcons icons = const ImageEditorIcons(),
    ImageEditorDesignModeE designMode = ImageEditorDesignModeE.material,
    ImageEditorTheme imageEditorTheme = const ImageEditorTheme(),
    required Size imageSize,
    required String heroTag,
    CropRotateEditorConfigs configs = const CropRotateEditorConfigs(),
    Widget? layersWidget,
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
        i18n: i18n,
        customWidgets: customWidgets,
        icons: icons,
        designMode: designMode,
        imageEditorTheme: imageEditorTheme,
        layersWidget: layersWidget,
        imageSize: imageSize,
        heroTag: heroTag,
        configs: configs,
      );
    } else if (file != null) {
      return CropRotateEditor.file(
        file,
        key: key,
        theme: theme,
        i18n: i18n,
        customWidgets: customWidgets,
        icons: icons,
        designMode: designMode,
        imageEditorTheme: imageEditorTheme,
        layersWidget: layersWidget,
        imageSize: imageSize,
        heroTag: heroTag,
        configs: configs,
      );
    } else if (networkUrl != null) {
      return CropRotateEditor.network(
        networkUrl,
        key: key,
        theme: theme,
        i18n: i18n,
        customWidgets: customWidgets,
        icons: icons,
        designMode: designMode,
        imageEditorTheme: imageEditorTheme,
        layersWidget: layersWidget,
        imageSize: imageSize,
        heroTag: heroTag,
        configs: configs,
      );
    } else if (assetPath != null) {
      return CropRotateEditor.asset(
        assetPath,
        key: key,
        theme: theme,
        i18n: i18n,
        customWidgets: customWidgets,
        icons: icons,
        designMode: designMode,
        imageEditorTheme: imageEditorTheme,
        layersWidget: layersWidget,
        imageSize: imageSize,
        heroTag: heroTag,
        configs: configs,
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
  bool _cropping = false;
  bool _showWidgets = false;

  double _zoomFactor = 1;
  double _oldScaleFactor = 1;
  double _screenPadding = 20;
  Offset _translate = Offset(0, 0);

  Rect _cropRect = Rect.zero;
  Rect _viewRect = Rect.zero;
  late BoxConstraints _contentConstraints;

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
    _rotateAnimation = Tween<double>(begin: 0, end: 0).animate(_rotateCtrl);

    _scaleCtrl = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1, end: 1).animate(_scaleCtrl);

    _image = EditorImage(
      byteArray: widget.byteArray,
      assetPath: widget.assetPath,
      file: widget.file,
      networkUrl: widget.networkUrl,
    );
    _aspectRatio = widget.configs.initAspectRatio ?? CropAspectRatios.custom;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calcCropRect();

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
  }

  double get _imgWidth => widget.imageSize.width;
  double get _imgHeight => widget.imageSize.height;
  bool get _imageSticksToScreenWidth => _imgWidth >= _contentConstraints.maxWidth;
  bool get _rotated90deg => _rotationCount % 2 != 0;
  Size get _imgSize => Size(
        _rotated90deg ? _imgHeight : _imgWidth,
        _rotated90deg ? _imgWidth : _imgHeight,
      );

  /// Handles the crop image operation.
  Future<void> done() async {
    if (_cropping) return;

    _cropping = true;
    LoadingDialog loading = LoadingDialog()
      ..show(
        context,
        i18n: widget.i18n,
        theme: widget.theme,
        designMode: widget.designMode,
        message: widget.i18n.cropRotateEditor.applyChangesDialogMsg,
        imageEditorTheme: widget.imageEditorTheme,
      );
    Uint8List? fileData;

/*     var cropPadding = _editor.editAction?.cropRectPadding;
    var finalDestination = _editor.editAction!.getFinalDestinationRect();
    var scale = _editor.editAction!.preTotalScale; */

    try {
      // Important cuz screen will be frozen in web
      if (kIsWeb) await Future.delayed(const Duration(seconds: 1));

      // Bugfix web
      /*    fileData = await cropImage(
        rawImage: await _image.safeByteArray,
        editAction: _editor.editAction!,
        cropRect: _editor.getCropRect()!,
        imageWidth: _editor.image!.width,
        imageHeight: _editor.image!.height,
        extendedImage: _editor.widget.extendedImageState.imageWidget,
        imageProvider: _editor.widget.extendedImageState.imageProvider,
        isExtendedResizeImage: _editor.widget.extendedImageState.imageProvider is ExtendedResizeImage,
      ); */
    } finally {
      if (mounted) {
        if (fileData != null) {
          /*    var res = CropRotateEditorResponse(
            bytes: fileData,
            cropRect: _editor.getCropRect()!,
            scale: scale,
            isHalfPi: _editor.editAction?.isHalfPi ?? false,
            posX: finalDestination.left - (cropPadding?.left ?? 0),
            posY: finalDestination.top - (cropPadding?.top ?? 0),
            flipX: _editor.editAction?.flipX ?? false,
            flipY: _editor.editAction?.flipY ?? false,
            rotationRadian: _editor.editAction?.rotateRadian ?? 0,
            rotationAngle: _editor.editAction?.rotateAngle ?? 0,
          );
          var decodedImage = await decodeImageFromList(res.bytes!);
          if (mounted) {
            await loading.hide(context);
            _cropping = false;
            if (mounted) {
              Navigator.pop(
                context,
                CropRotateEditorRes(
                  result: res,
                  image: decodedImage,
                ),
              );
            }
          } */
        } else {
          close();
        }
      }
    }
  }

  /// Closes the editor without applying changes.
  void close() {
    Navigator.pop(context);
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
    _rotationCount++;
    _rotateCtrl.animateTo(pi, curve: Curves.ease);
    _rotateAnimation = Tween<double>(begin: _rotateAnimation.value, end: _rotationCount * pi / 2).animate(_rotateCtrl);
    _rotateCtrl
      ..reset()
      ..forward();

    Size screenSize = Size(
      _contentConstraints.maxWidth,
      _contentConstraints.maxHeight,
    );

    double scaleX = screenSize.width / _imgSize.width;
    double scaleY = screenSize.height / _imgSize.height;

    double scale = !_rotated90deg ? 1 : min(scaleX, scaleY);
    _scaleCtrl.animateTo(scale, curve: Curves.ease);
    _scaleAnimation = Tween<double>(begin: _oldScaleFactor, end: scale).animate(_scaleCtrl);
    _scaleCtrl
      ..reset()
      ..forward();

    _oldScaleFactor = scale;
    _calcCropRect();
  }

  void _calcCropRect() {
    double imgSizeRatio = _imgHeight / _imgWidth;

    double padding = _screenPadding * 2;
    double newImgW = (_rotated90deg ? _imgSize.height : _imgSize.width) - padding;
    double newImgH = (_rotated90deg ? _imgSize.width : _imgSize.height) - padding;

    double cropWidth = _imageSticksToScreenWidth ? newImgW : newImgH / imgSizeRatio;
    double cropHeight = _imageSticksToScreenWidth ? newImgW * imgSizeRatio : newImgH;

    _cropRect = Rect.fromLTWH(0, 0, cropWidth, cropHeight);
    _viewRect = Rect.fromLTWH(0, 0, cropWidth, cropHeight);
    //TODO:   setState(() {});
  }

  /// Opens a dialog to select from predefined aspect ratios.
  void openAspectRatioOptions() {
    showDialog<double>(
        context: context,
        builder: (BuildContext context) {
          return CropAspectRatioOptions(
            aspectRatio: _aspectRatio,
            i18n: widget.i18n.cropRotateEditor,
          );
        }).then((value) {
      if (value != null) {
        setState(() {
          _aspectRatio = value;
        });
      }
    });
  }

  CropAreaPart _currentCropAreaPart = CropAreaPart.none;

  CropAreaPart _determineCropAreaPart(Offset localPosition) {
    const double edgeSize = 20;
    bool nearLeftEdge = (localPosition.dx - _cropRect.left).abs() < edgeSize;
    bool nearRightEdge = (localPosition.dx - _cropRect.right).abs() < edgeSize;
    bool nearTopEdge = (localPosition.dy - _cropRect.top).abs() < edgeSize;
    bool nearBottomEdge = (localPosition.dy - _cropRect.bottom).abs() < edgeSize;

    print(localPosition.dx);
    if (nearLeftEdge && nearTopEdge) {
      return CropAreaPart.topLeft;
    } else if (nearRightEdge && nearTopEdge) {
      return CropAreaPart.topRight;
    } else if (nearLeftEdge && nearBottomEdge) {
      return CropAreaPart.bottomLeft;
    } else if (nearRightEdge && nearBottomEdge) {
      return CropAreaPart.bottomRight;
    } else if (_cropRect.contains(localPosition)) {
      return CropAreaPart.inside;
    }
    return CropAreaPart.none;
  }

  void _onDragStart(DragStartDetails details) {
    _currentCropAreaPart = _determineCropAreaPart(details.localPosition);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    // Convert the global position to local position
    Offset localPosition = details.localPosition;

    if (_currentCropAreaPart != CropAreaPart.none) {
      // Update the _cropRect based on the dragged corner
      setState(() {
        // Example for one corner; implement similar logic for other corners
        if (_currentCropAreaPart == CropAreaPart.topLeft) {
          _cropRect = Rect.fromLTRB(
            max(0, localPosition.dx),
            max(0, localPosition.dy),
            _cropRect.right,
            _cropRect.bottom,
          );
        }
        // Add similar logic for other corners...
      });
    } else {
      _translate += details.delta;
      _setOffsetLimits();
      setState(() {});
    }
  }

  void _setOffsetLimits() {
    double cropW = _cropRect.width;
    double minX = (cropW * _zoomFactor - cropW) / 2;
    double minY = (cropW * _zoomFactor - cropW) / 2;

    if (_translate.dx > minX) {
      _translate = Offset(minX, _translate.dy);
    }
    if (_translate.dx < -minX) {
      _translate = Offset(-minX, _translate.dy);
    }
    if (_translate.dy > minY) {
      _translate = Offset(_translate.dx, minY);
    }
    if (_translate.dy < -minY) {
      _translate = Offset(-minY, _translate.dy);
    }

    print('-----------');
    print(_zoomFactor);
    print(minX);
    print(_translate.dx);
  }

  void _mouseScroll(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      double factor = 0.1;
      if (event.scrollDelta.dy > 0) {
        _zoomFactor -= factor;
        _zoomFactor = max(1, _zoomFactor);
      } else if (event.scrollDelta.dy < 0) {
        _zoomFactor += factor;
        _zoomFactor = min(7, _zoomFactor);
      }
      // TODO: Zoom to exact mouse position
      _setOffsetLimits();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: widget.imageEditorTheme.uiOverlayStyle,
        child: Theme(
          data: widget.theme.copyWith(tooltipTheme: widget.theme.tooltipTheme.copyWith(preferBelow: true)),
          child: Scaffold(
            backgroundColor: widget.imageEditorTheme.cropRotateEditor.background,
            appBar: _buildAppBar(constraints),
            body: _buildBody(),
          ),
        ),
      );
    });
  }

  /// Builds the app bar for the editor, including buttons for actions such as back, rotate, aspect ratio, and done.
  PreferredSizeWidget _buildAppBar(BoxConstraints constraints) {
    return widget.customWidgets.appBarCropRotateEditor ??
        AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: widget.imageEditorTheme.cropRotateEditor.appBarBackgroundColor,
          foregroundColor: widget.imageEditorTheme.cropRotateEditor.appBarForegroundColor,
          actions: [
            IconButton(
              tooltip: widget.i18n.cropRotateEditor.back,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: Icon(widget.icons.backButton),
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
              if (widget.configs.canRotate)
                IconButton(
                  icon: Icon(widget.icons.cropRotateEditor.rotate),
                  tooltip: widget.i18n.cropRotateEditor.rotate,
                  onPressed: rotate,
                ),
              if (widget.configs.canFlip)
                IconButton(
                  icon: Icon(widget.icons.cropRotateEditor.flip),
                  tooltip: widget.i18n.cropRotateEditor.flip,
                  onPressed: flip,
                ),
              if (widget.configs.canChangeAspectRatio)
                IconButton(
                  key: const ValueKey('pro-image-editor-aspect-ratio-btn'),
                  icon: Icon(widget.icons.cropRotateEditor.aspectRatio),
                  tooltip: widget.i18n.cropRotateEditor.ratio,
                  onPressed: openAspectRatioOptions,
                ),
              const Spacer(),
              _buildDoneBtn(),
            ] else ...[
              const Spacer(),
              _buildDoneBtn(),
              PlatformPopupBtn(
                designMode: widget.designMode,
                title: widget.i18n.cropRotateEditor.smallScreenMoreTooltip,
                options: [
                  if (widget.configs.canRotate)
                    PopupMenuOption(
                      label: widget.i18n.cropRotateEditor.rotate,
                      icon: Icon(widget.icons.cropRotateEditor.rotate),
                      onTap: () {
                        rotate();

                        if (widget.designMode == ImageEditorDesignModeE.cupertino) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  if (widget.configs.canChangeAspectRatio)
                    PopupMenuOption(
                      label: widget.i18n.cropRotateEditor.ratio,
                      icon: Icon(widget.icons.cropRotateEditor.aspectRatio),
                      onTap: openAspectRatioOptions,
                    ),
                ],
              ),
            ],
          ],
        );
  }

  Widget _buildBody() {
    /// TODO: remove me
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
      onPanStart: _onDragStart,
      onPanUpdate: _onDragUpdate,
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

  Container _buildCropPainter({required Widget child}) {
    return Container(
      color: Colors.amber.withOpacity(0.3), // TODO: deleteme
      child: CustomPaint(
        isComplex: _showWidgets,
        willChange: _showWidgets,
        foregroundPainter: _showWidgets
            ? CropCornerPainter(
                cropRect: _cropRect,
                viewRect: _viewRect,
                scaleFactor: _zoomFactor,
                interactionActive: _interactionActive,
                screenSize: Size(
                  _contentConstraints.maxWidth,
                  _contentConstraints.maxHeight,
                ),
                imageEditorTheme: widget.imageEditorTheme,
              )
            : null,
        child: child,
      ),
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
    return Hero(
      tag: widget.heroTag,
      child: AutoImage(
        _image,
        fit: BoxFit.contain,
        designMode: widget.designMode,
      ),
    );
  }

  /// Builds and returns an IconButton for applying changes.
  Widget _buildDoneBtn() {
    return IconButton(
      tooltip: widget.i18n.cropRotateEditor.done,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      icon: Icon(widget.icons.applyChanges),
      iconSize: 28,
      onPressed: done,
    );
  }
}

class CropRotateEditorRes {
  final CropRotateEditorResponse result;
  final Image image;

  CropRotateEditorRes({
    required this.result,
    required this.image,
  });
}

enum CropAreaPart {
  none,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  inside,
}
