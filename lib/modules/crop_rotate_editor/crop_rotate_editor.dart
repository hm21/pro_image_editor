import 'dart:io';
import 'dart:ui' show Image;

import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';

import '../../models/crop_rotate_editor_response.dart';
import '../../models/custom_widgets.dart';
import '../../models/editor_configs/crop_rotate_editor_configs.dart';
import '../../models/editor_image.dart';
import '../../models/theme/theme.dart';
import '../../models/i18n/i18n.dart';
import '../../models/icons/icons.dart';
import '../../widgets/auto_image.dart';
import '../../widgets/platform_popup_menu.dart';
import 'utils/crop_rotate_editor_helper.dart';
import '../../utils/design_mode.dart';
import 'utils/aspect_ratio_button.dart';
import '../../models/aspect_ratio_item.dart';
import '../../widgets/flat_icon_text_button.dart';
import '../../widgets/loading_dialog.dart';

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

  /// The image data with layers (if any) for editing.
  final Uint8List? bytesWithLayers;

  /// Configuration settings for the CropRotateEditor.
  ///
  /// This parameter allows you to customize the behavior and appearance of the CropRotateEditor.
  final CropRotateEditorConfigs configs;

  /// The size of the image to be edited.
  final Size imageSize;

  /// A unique hero tag for the image.
  final String heroTag;

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
    required this.theme,
    required this.i18n,
    required this.customWidgets,
    required this.icons,
    required this.designMode,
    required this.imageEditorTheme,
    required this.imageSize,
    required this.heroTag,
    required this.configs,
    this.bytesWithLayers,
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
  /// - `bytesWithLayers`: An optional Uint8List representing the image data with layers.
  /// - `imageSize`: The size of the image to be edited (required).
  /// - `heroTag`: A unique hero tag for the image (required).
  /// - `configs`: Configuration settings for the CropRotateEditor (required).
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
    Uint8List? bytesWithLayers,
    Function? onUpdateUI,
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
      bytesWithLayers: bytesWithLayers,
      imageSize: imageSize,
      heroTag: heroTag,
      configs: configs,
      onUpdateUI: onUpdateUI,
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
  /// - `bytesWithLayers`: An optional Uint8List representing the image data with layers.
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
    Uint8List? bytesWithLayers,
    Function? onUpdateUI,
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
      bytesWithLayers: bytesWithLayers,
      onUpdateUI: onUpdateUI,
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
  /// - `bytesWithLayers`: An optional Uint8List representing the image data with layers.
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
    Uint8List? bytesWithLayers,
    Function? onUpdateUI,
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
      bytesWithLayers: bytesWithLayers,
      imageSize: imageSize,
      heroTag: heroTag,
      configs: configs,
      onUpdateUI: onUpdateUI,
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
  /// - `onUpdateUI`:  A callback function that can be used to update the UI from custom widgets.
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
    Uint8List? bytesWithLayers,
    Function? onUpdateUI,
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
      bytesWithLayers: bytesWithLayers,
      imageSize: imageSize,
      heroTag: heroTag,
      configs: configs,
      onUpdateUI: onUpdateUI,
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
  /// - `onUpdateUI`:  A callback function that can be used to update the UI from custom widgets.
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
    Uint8List? bytesWithLayers,
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
        i18n: i18n,
        customWidgets: customWidgets,
        icons: icons,
        designMode: designMode,
        imageEditorTheme: imageEditorTheme,
        bytesWithLayers: bytesWithLayers,
        imageSize: imageSize,
        heroTag: heroTag,
        configs: configs,
        onUpdateUI: onUpdateUI,
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
        bytesWithLayers: bytesWithLayers,
        imageSize: imageSize,
        heroTag: heroTag,
        configs: configs,
        onUpdateUI: onUpdateUI,
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
        bytesWithLayers: bytesWithLayers,
        imageSize: imageSize,
        heroTag: heroTag,
        configs: configs,
        onUpdateUI: onUpdateUI,
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
        bytesWithLayers: bytesWithLayers,
        imageSize: imageSize,
        heroTag: heroTag,
        configs: configs,
        onUpdateUI: onUpdateUI,
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
class CropRotateEditorState extends State<CropRotateEditor> {
  final GlobalKey<ExtendedImageEditorState> _editorKey = GlobalKey<ExtendedImageEditorState>();

  late EditorImage _image;

  double? _aspectRatio;
  bool _cropping = false;
  bool _inited = false;

  EditorCropLayerPainter? _cropLayerPainter;

  @override
  void initState() {
    super.initState();
    _initializeEditor();
  }

  /// Initializes the editor with default settings.
  void _initializeEditor() {
    _image = EditorImage(
      byteArray: widget.byteArray,
      assetPath: widget.assetPath,
      file: widget.file,
      networkUrl: widget.networkUrl,
    );
    _aspectRatio = widget.configs.initAspectRatio ?? _aspectRatios.first.value;
    _cropLayerPainter = const EditorCropLayerPainter();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _delayedInit();
    });
  }

  /// Performs a delayed initialization to ensure UI is ready.
  Future<void> _delayedInit() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() => _inited = true);
      widget.onUpdateUI?.call();
    }
  }

  /// Returns a list of predefined aspect ratios.
  ExtendedImageEditorState get _editor => _editorKey.currentState!;

  /// Returns a list of predefined aspect ratios.
  List<AspectRatioItem> get _aspectRatios {
    return [
      AspectRatioItem(text: widget.i18n.cropRotateEditor.aspectRatioFree, value: CropAspectRatios.custom),
      AspectRatioItem(text: widget.i18n.cropRotateEditor.aspectRatioOriginal, value: CropAspectRatios.original),
      AspectRatioItem(text: '1*1', value: CropAspectRatios.ratio1_1),
      AspectRatioItem(text: '4*3', value: CropAspectRatios.ratio4_3),
      AspectRatioItem(text: '3*4', value: CropAspectRatios.ratio3_4),
      AspectRatioItem(text: '16*9', value: CropAspectRatios.ratio16_9),
      AspectRatioItem(text: '9*16', value: CropAspectRatios.ratio9_16)
    ];
  }

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

    var cropPadding = _editor.editAction?.cropRectPadding;
    var finalDestination = _editor.editAction!.getFinalDestinationRect();
    var scale = _editor.editAction!.preTotalScale;

    try {
      // Important cuz screen will be frozen in web
      if (kIsWeb) await Future.delayed(const Duration(seconds: 1));

      // Bugfix web
      fileData = await cropImage(
        rawImage: await _image.safeByteArray,
        editAction: _editor.editAction!,
        cropRect: _editor.getCropRect()!,
        imageWidth: _editor.image!.width,
        imageHeight: _editor.image!.height,
        extendedImage: _editor.widget.extendedImageState.imageWidget,
        imageProvider: _editor.widget.extendedImageState.imageProvider,
        isExtendedResizeImage: _editor.widget.extendedImageState.imageProvider is ExtendedResizeImage,
      );
    } finally {
      if (mounted) {
        if (fileData != null) {
          var res = CropRotateEditorResponse(
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
          }
        } else {
          close();
        }
      }
    }
  }

  /// Rotates the image clockwise.
  void rotate() {
    _editor.rotate(right: true);
  }

  /// Opens a dialog to select from predefined aspect ratios.
  void openAspectRatioOptions() {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return Column(
            key: const ValueKey('pro-image-editor-aspect-ratio-bottom-list'),
            children: <Widget>[
              const Expanded(
                child: SizedBox(),
              ),
              Container(
                color: Colors.black87,
                height: 100,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  itemBuilder: (_, int index) {
                    final AspectRatioItem item = _aspectRatios[index];
                    return GestureDetector(
                      child: FlatIconTextButton(
                        label: Text(
                          item.text,
                          style: const TextStyle(color: Colors.white),
                        ),
                        icon: SizedBox(
                          height: 38,
                          child: FittedBox(
                            child: AspectRatioButton(
                              aspectRatio: item.value,
                              aspectRatioS: '',
                              isSelected: item.value == _aspectRatio,
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _aspectRatio = item.value;
                        });
                        widget.onUpdateUI?.call();
                      },
                    );
                  },
                  itemCount: _aspectRatios.length,
                ),
              ),
            ],
          );
        });
  }

  /// Closes the editor without applying changes.
  void close() {
    Navigator.pop(context);
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
            body: SafeArea(
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: _buildBody(),
              ),
            ),
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

  /// Builds the body of the editor, including the image to be edited and additional elements such as aspect ratio options.
  List<Widget> _buildBody() {
    var config = _buildEditorConfig();

    return [
      Opacity(
        opacity: _inited ? 1 : 0,
        child: Hero(
          tag: !_inited ? 'block-hero' : widget.heroTag,
          child: _image.hasBytes || widget.bytesWithLayers != null
              ? ExtendedImage.memory(
                  widget.bytesWithLayers ?? _image.byteArray!,
                  key: const ValueKey('Crop_Rotate_Editor'),
                  fit: BoxFit.contain,
                  mode: ExtendedImageMode.editor,
                  extendedImageEditorKey: _editorKey,
                  initEditorConfigHandler: (ExtendedImageState? state) => config,
                  cacheRawData: true,
                )
              : _image.hasFile
                  ? ExtendedImage.file(
                      _image.file! as dynamic,
                      key: const ValueKey('Crop_Rotate_Editor'),
                      fit: BoxFit.contain,
                      mode: ExtendedImageMode.editor,
                      extendedImageEditorKey: _editorKey,
                      initEditorConfigHandler: (ExtendedImageState? state) => config,
                      cacheRawData: true,
                    )
                  : _image.hasNetworkUrl
                      ? ExtendedImage.network(
                          _image.networkUrl!,
                          key: const ValueKey('Crop_Rotate_Editor'),
                          fit: BoxFit.contain,
                          mode: ExtendedImageMode.editor,
                          extendedImageEditorKey: _editorKey,
                          initEditorConfigHandler: (ExtendedImageState? state) => config,
                          cacheRawData: true,
                        )
                      : ExtendedImage.asset(
                          _image.assetPath!,
                          key: const ValueKey('Crop_Rotate_Editor'),
                          fit: BoxFit.contain,
                          mode: ExtendedImageMode.editor,
                          extendedImageEditorKey: _editorKey,
                          initEditorConfigHandler: (ExtendedImageState? state) => config,
                          cacheRawData: true,
                        ),
        ),
      ),
      _buildFakeHero(config),
    ];
  }

  /// Builds a fake hero widget to provide a smooth transition between different image states.
  Widget _buildFakeHero(EditorConfig config) {
    var img = EditorImage(
      byteArray: widget.bytesWithLayers ?? _image.byteArray,
      assetPath: _image.assetPath,
      file: _image.file,
      networkUrl: _image.networkUrl,
    );
    return Hero(
      tag: !_inited ? widget.heroTag : 'Block-Image-Editor-Hero',
      child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: !_inited
              ? Padding(
                  padding: _buildEditorConfig().cropRectPadding,
                  child: AutoImage(
                    img,
                    designMode: widget.designMode,
                    fit: BoxFit.contain,
                    width: widget.imageSize.width + config.cropRectPadding.horizontal,
                    height: widget.imageSize.height + config.cropRectPadding.vertical,
                  ),
                )
              : const SizedBox.expand()),
    );
  }

  /// Builds the configuration for the ExtendedImage editor.
  EditorConfig _buildEditorConfig() {
    return EditorConfig(
      maxScale: 8.0,
      cropRectPadding: const EdgeInsets.all(20.0),
      hitTestSize: 20.0,
      cropLayerPainter: _cropLayerPainter!,
      cornerColor: widget.imageEditorTheme.cropRotateEditor.cropCornerColor,
      cropAspectRatio: _aspectRatio,
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
