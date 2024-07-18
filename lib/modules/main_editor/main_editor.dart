// Dart imports:
import 'dart:async';
import 'dart:io';
import 'dart:math';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:vibration/vibration.dart';

// Project imports:
import '../../mixins/converted_configs.dart';
import '../../mixins/editor_callbacks_mixin.dart';
import '../../mixins/editor_configs_mixin.dart';
import '../../mixins/main_editor/main_editor_global_keys.dart';
import '../../models/crop_rotate_editor/transform_factors.dart';
import '../../models/history/last_layer_interaction_position.dart';
import '../../models/history/state_history.dart';
import '../../models/import_export/export_state_history.dart';
import '../../models/import_export/utils/export_import_version.dart';
import '../../models/theme/theme_dragable_sheet.dart';
import '../../plugins/defer_pointer/defer_pointer.dart';
import '../../pro_image_editor.dart';
import '../../utils/content_recorder.dart/content_recorder.dart';
import '../../utils/content_recorder.dart/utils/record_invisible_widget.dart';
import '../../utils/debounce.dart';
import '../../utils/layer_transform_generator.dart';
import '../../widgets/adaptive_dialog.dart';
import '../../widgets/auto_image.dart';
import '../../widgets/extended/extended_interactive_viewer.dart';
import '../../widgets/extended/extended_mouse_cursor.dart';
import '../../widgets/layer_widget.dart';
import '../../widgets/screen_resize_detector.dart';
import '../../widgets/transform/transformed_content_generator.dart';
import '../crop_rotate_editor/utils/crop_layer_painter.dart';
import '../filter_editor/types/filter_matrix.dart';
import '../filter_editor/widgets/filtered_image.dart';
import 'utils/desktop_interaction_manager.dart';
import 'utils/layer_copy_manager.dart';
import 'utils/layer_interaction_manager.dart';
import 'utils/main_editor_controllers.dart';
import 'utils/sizes_manager.dart';
import 'utils/state_manager.dart';

/// A widget for image editing using ProImageEditor.
///
/// `ProImageEditor` provides a versatile image editing widget for Flutter applications.
/// It allows you to edit images from various sources like memory, files, assets, or network URLs.
///
/// You can use one of the specific constructors, such as `memory`, `file`, `asset`, or `network`,
/// to create an instance of this widget based on your image source. Additionally, you can provide
/// custom configuration settings through the `configs` parameter.
///
/// Example usage:
///
/// ```dart
/// ProImageEditor.memory(Uint8List.fromList(imageBytes));
/// ProImageEditor.file(File('path/to/image.jpg'));
/// ProImageEditor.asset('assets/images/image.png');
/// ProImageEditor.network('https://example.com/image.jpg');
/// ```
///
/// To handle image editing, you can use the callbacks provided by the `EditorConfigs` instance
/// passed through the `configs` parameter.
///
/// See also:
/// - [ProImageEditorConfigs] for configuring image editing options.
/// - [ProImageEditorCallbacks] for callbacks.
class ProImageEditor extends StatefulWidget
    with SimpleConfigsAccess, SimpleCallbacksAccess {
  @override
  final ProImageEditorConfigs configs;
  @override
  final ProImageEditorCallbacks callbacks;

  /// Image data as a `Uint8List` from memory.
  final Uint8List? byteArray;

  /// Path to the image asset.
  final String? assetPath;

  /// URL of the image to be loaded from the network.
  final String? networkUrl;

  /// File object representing the image file.
  final File? file;

  /// Creates a `ProImageEditor` widget for image editing.
  ///
  /// Use one of the specific constructors like `memory`, `file`, `asset`, or `network`
  /// to create an instance of this widget based on your image source.
  ///
  /// The [byteArray], [assetPath], [networkUrl], and [file] parameters represent different
  /// sources of the image data. At least one of these parameters must not be null.
  ///
  /// The `configs` parameter allows you to customize the image editing experience by providing
  /// various configuration options. If not specified, default settings will be used.
  ///
  /// The `callbacks` parameter is required and specifies the callbacks to handle events and interactions within the image editor.
  const ProImageEditor._({
    super.key,
    required this.callbacks,
    this.byteArray,
    this.assetPath,
    this.networkUrl,
    this.file,
    this.configs = const ProImageEditorConfigs(),
  }) : assert(
          byteArray != null ||
              file != null ||
              networkUrl != null ||
              assetPath != null,
          'At least one of bytes, file, networkUrl, or assetPath must not be null.',
        );

  /// This constructor creates a `ProImageEditor` widget configured to edit an image loaded from the specified `byteArray`.
  ///
  /// The `byteArray` parameter should contain the image data as a `Uint8List`.
  ///
  /// The `key` parameter is an optional parameter used to provide a `Key` to the widget for identification and state preservation.
  ///
  /// The `configs` parameter specifies the configuration options for the image editor. It defaults to an empty instance of `ProImageEditorConfigs`.
  ///
  /// The `callbacks` parameter is required and specifies the callbacks to handle events and interactions within the image editor.
  ///
  /// Example usage:
  /// ```dart
  /// ProImageEditor.ProImageEditor.memory(
  ///   bytes,
  ///   configs: ProImageEditorConfigs(),
  ///   callbacks: ProImageEditorCallbacks(
  ///      onImageEditingComplete: (Uint8List bytes) async {
  ///        /*
  ///          `Your code to handle the edited image. Upload it to your server as an example.
  ///
  ///           You can choose to use await, so that the load dialog remains visible until your code is ready,
  ///           or no async, so that the load dialog closes immediately.
  ///        */
  ///        Navigator.pop(context);
  ///      },
  ///   ),
  /// )
  /// ```
  factory ProImageEditor.memory(
    Uint8List byteArray, {
    Key? key,
    required ProImageEditorCallbacks callbacks,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
  }) {
    return ProImageEditor._(
      key: key,
      byteArray: byteArray,
      configs: configs,
      callbacks: callbacks,
    );
  }

  /// This constructor creates a `ProImageEditor` widget configured to edit an image loaded from the specified `file`.
  ///
  /// The `file` parameter should point to the image file.
  ///
  /// The `key` parameter is an optional parameter used to provide a `Key` to the widget for identification and state preservation.
  ///
  /// The `configs` parameter specifies the configuration options for the image editor. It defaults to an empty instance of `ProImageEditorConfigs`.
  ///
  /// The `callbacks` parameter is required and specifies the callbacks to handle events and interactions within the image editor.
  ///
  /// Example usage:
  /// ```dart
  /// ProImageEditor.ProImageEditor.file(
  ///   File(pathToMyFile),
  ///   configs: ProImageEditorConfigs(),
  ///   callbacks: ProImageEditorCallbacks(
  ///      onImageEditingComplete: (Uint8List bytes) async {
  ///        /*
  ///          `Your code to handle the edited image. Upload it to your server as an example.
  ///
  ///           You can choose to use await, so that the load dialog remains visible until your code is ready,
  ///           or no async, so that the load dialog closes immediately.
  ///        */
  ///        Navigator.pop(context);
  ///      },
  ///   ),
  /// )
  /// ```
  factory ProImageEditor.file(
    File file, {
    Key? key,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    required ProImageEditorCallbacks callbacks,
  }) {
    return ProImageEditor._(
      key: key,
      file: file,
      configs: configs,
      callbacks: callbacks,
    );
  }

  /// This constructor creates a `ProImageEditor` widget configured to edit an image loaded from the specified `assetPath`.
  ///
  /// The `assetPath` parameter should specify the path to the image asset.
  ///
  /// The `key` parameter is an optional parameter used to provide a `Key` to the widget for identification and state preservation.
  ///
  /// The `configs` parameter specifies the configuration options for the image editor. It defaults to an empty instance of `ProImageEditorConfigs`.
  ///
  /// The `callbacks` parameter is required and specifies the callbacks to handle events and interactions within the image editor.
  ///
  /// Example usage:
  /// ```dart
  /// ProImageEditor.asset(
  ///   'assets/demo.png',
  ///   configs: ProImageEditorConfigs(),
  ///   callbacks: ProImageEditorCallbacks(
  ///      onImageEditingComplete: (Uint8List bytes) async {
  ///        /*
  ///          `Your code to handle the edited image. Upload it to your server as an example.
  ///
  ///           You can choose to use await, so that the load dialog remains visible until your code is ready,
  ///           or no async, so that the load dialog closes immediately.
  ///        */
  ///        Navigator.pop(context);
  ///      },
  ///   ),
  /// )
  /// ```
  factory ProImageEditor.asset(
    String assetPath, {
    Key? key,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    required ProImageEditorCallbacks callbacks,
  }) {
    return ProImageEditor._(
      key: key,
      assetPath: assetPath,
      configs: configs,
      callbacks: callbacks,
    );
  }

  /// This constructor creates a `ProImageEditor` widget configured to edit an image loaded from the specified `networkUrl`.
  ///
  /// The `networkUrl` parameter specifies the URL from which the image will be loaded.
  ///
  /// The `key` parameter is an optional parameter used to provide a `Key` to the widget for identification and state preservation.
  ///
  /// The `configs` parameter specifies the configuration options for the image editor. It defaults to an empty instance of `ProImageEditorConfigs`.
  ///
  /// The `callbacks` parameter is required and specifies the callbacks to handle events and interactions within the image editor.
  ///
  /// Example usage:
  /// ```dart
  /// ProImageEditor.network(
  ///   'https://example.com/image.jpg',
  ///   configs: ProImageEditorConfigs(),
  ///   callbacks: ProImageEditorCallbacks(
  ///      onImageEditingComplete: (Uint8List bytes) async {
  ///        /*
  ///          `Your code to handle the edited image. Upload it to your server as an example.
  ///
  ///           You can choose to use await, so that the load dialog remains visible until your code is ready,
  ///           or no async, so that the load dialog closes immediately.
  ///        */
  ///        Navigator.pop(context);
  ///      },
  ///   ),
  /// )
  /// ```
  factory ProImageEditor.network(
    String networkUrl, {
    Key? key,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    required ProImageEditorCallbacks callbacks,
  }) {
    return ProImageEditor._(
      key: key,
      networkUrl: networkUrl,
      configs: configs,
      callbacks: callbacks,
    );
  }

  @override
  State<ProImageEditor> createState() => ProImageEditorState();
}

class ProImageEditorState extends State<ProImageEditor>
    with
        ImageEditorConvertedConfigs,
        SimpleConfigsAccessState,
        SimpleCallbacksAccessState,
        MainEditorGlobalKeys {
  final _mouseCursorsKey = GlobalKey<ExtendedMouseRegionState>();
  final _bottomBarKey = GlobalKey();
  final _removeAreaKey = GlobalKey();
  final _interactiveViewer = GlobalKey<ExtendedInteractiveViewerState>();
  late final StreamController _rebuildController;

  /// Helper class for managing sizes and layout calculations.
  late final SizesManager sizesManager;

  /// Manager class for handling desktop interactions in the image editor.
  late final DesktopInteractionManager _desktopInteractionManager;

  /// Manager class to copy layers.
  final LayerCopyManager _layerCopyManager = LayerCopyManager();

  /// Helper class for managing interactions with layers in the editor.
  final LayerInteractionManager layerInteractionManager =
      LayerInteractionManager();

  /// Manager class for managing the state of the editor.
  final StateManager stateManager = StateManager();

  /// Controller instances for managing various aspects of the main editor.
  late final MainEditorControllers _controllers;

  /// The current theme used by the image editor.
  late ThemeData _theme;

  /// Temporary layer used during editing.
  Layer? _tempLayer;

  /// Index of the selected layer.
  int selectedLayerIndex = -1;

  /// Flag indicating if the editor has been initialized.
  bool _inited = false;

  /// Flag indicating if the image needs decoding.
  bool _imageNeedDecode = true;

  /// Flag to track if editing is completed.
  bool _processFinalImage = false;

  /// The pixel ratio of the device's screen.
  ImageInfos? _imageInfos;

  /// Whether a sub editor is currently open.
  bool isSubEditorOpen = false;

  /// Whether a dialog is currently open.
  bool _openDialog = false;

  /// Indicates whether the `onScaleUpdate` function can be triggered to interact
  /// with the layers
  bool blockOnScaleUpdateFunction = false;

  /// Indicates whether the browser's context menu was enabled before any changes.
  bool _browserContextMenuBeforeEnabled = false;

  /// Indicates whether PopScope is disabled.
  bool disablePopScope = false;

  /// Getter for the active layer currently being edited.
  Layer? get _activeLayer =>
      activeLayers.length > selectedLayerIndex && selectedLayerIndex >= 0
          ? activeLayers[selectedLayerIndex]
          : null;

  /// Get the list of layers from the current image editor changes.
  List<Layer> get activeLayers =>
      stateManager.stateHistory[stateManager.position].layers;

  /// List to store the history of image editor changes.
  List<EditorStateHistory> get stateHistory => stateManager.stateHistory;

  /// Determines whether undo actions can be performed on the current state.
  bool get canUndo => stateManager.position > 0;

  /// Determines whether redo actions can be performed on the current state.
  bool get canRedo =>
      stateManager.position < stateManager.stateHistory.length - 1;

  /// Get the current background image.
  late EditorImage editorImage;

  /// A [Completer] used to track the completion of a page open operation.
  ///
  /// The completer is initialized and can be used to await the page open operation.
  Completer _pageOpenCompleter = Completer();

  /// A [Completer] used to track the completion of an image decoding operation.
  ///
  /// The completer is initialized and can be used to await the image decoding operation.
  final Completer _decodeImageCompleter = Completer();

  @override
  void initState() {
    super.initState();
    _rebuildController = StreamController.broadcast();
    _controllers = MainEditorControllers(configs);
    _controllers.screenshot.generateOnlyThumbnail =
        callbacks.onThumbnailGenerated != null;
    _desktopInteractionManager = DesktopInteractionManager(
      configs: configs,
      context: context,
      onUpdateUI: mainEditorCallbacks?.handleUpdateUI,
      setState: setState,
    );
    sizesManager = SizesManager(configs: configs, context: context);
    layerInteractionManager.scaleDebounce =
        Debounce(const Duration(milliseconds: 100));

    editorImage = EditorImage(
      assetPath: widget.assetPath,
      byteArray: widget.byteArray,
      file: widget.file,
      networkUrl: widget.networkUrl,
    );

    stateManager.stateHistory.add(EditorStateHistory(
      transformConfigs: TransformConfigs.empty(),
      blur: 0,
      layers: [],
      filters: [],
    ));

    if (helperLines.hitVibration) {
      Vibration.hasVibrator().then((hasVibrator) {
        layerInteractionManager.deviceCanVibrate = hasVibrator ?? false;

        if (layerInteractionManager.deviceCanVibrate) {
          Vibration.hasCustomVibrationsSupport()
              .then((hasCustomVibrationsSupport) {
            layerInteractionManager.deviceCanCustomVibrate =
                hasCustomVibrationsSupport ?? false;
          });
        }
      });
    }

    ServicesBinding.instance.keyboard.addHandler(_onKeyEvent);
    if (kIsWeb) {
      _browserContextMenuBeforeEnabled = BrowserContextMenu.enabled;
      BrowserContextMenu.disableContextMenu();
    }
    mainEditorCallbacks?.onInit?.call();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      mainEditorCallbacks?.onAfterViewInit?.call();
      _calcAppBarHeight();
    });
  }

  @override
  void dispose() {
    _rebuildController.close();
    _controllers.dispose();
    layerInteractionManager.scaleDebounce.dispose();
    SystemChrome.setSystemUIOverlayStyle(_theme.brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark);
    SystemChrome.restoreSystemUIOverlays();
    ServicesBinding.instance.keyboard.removeHandler(_onKeyEvent);
    if (kIsWeb && _browserContextMenuBeforeEnabled) {
      BrowserContextMenu.enableContextMenu();
    }
    super.dispose();
  }

  @override
  void setState(void Function() fn) {
    _rebuildController.add(null);
    super.setState(fn);
  }

  void _checkInteractiveViewer() {
    _interactiveViewer.currentState?.setEnableInteraction(
      selectedLayerIndex < 0 && layerInteractionManager.selectedLayerId.isEmpty,
    );
  }

  /// Handle keyboard events
  bool _onKeyEvent(KeyEvent event) {
    return _desktopInteractionManager.onKey(
      event,
      activeLayer: _activeLayer,
      onEscape: () {
        if (!_openDialog) {
          if (isSubEditorOpen) {
            if (!imageEditorTheme.subEditorPage.barrierDismissible) {
              if (cropRotateEditor.currentState != null) {
                // Important to close the crop-editor like that cuz we need to set
                // the fake hero first
                cropRotateEditor.currentState!.close();
              } else {
                Navigator.pop(context);
              }
            }
          } else {
            closeEditor();
          }
        }
      },
      onUndoRedo: (undo) {
        if (_openDialog || isSubEditorOpen) return;

        undo ? undoAction() : redoAction();
      },
    );
  }

  /// Adds a new state to the history with the given configuration and updates the state manager.
  ///
  /// This method is responsible for capturing the current state of the editor,
  /// including layers, transformations, filters, and blur settings. It then adds
  /// this state to the history, enabling undo and redo functionality. Additionally,
  /// it can take a screenshot if required.
  ///
  /// - [layers]: An optional list of layers to be included in the new state.
  /// - [newLayer]: An optional new layer to be added to the current layers.
  /// - [transformConfigs]: Optional transformation configurations for the new state.
  /// - [filters]: An optional list of filter states to be included in the new state.
  /// - [blur]: An optional blur state to be included in the new state.
  /// - [heroScreenshotRequired]: A flag indicating whether a hero screenshot is required.
  ///
  /// Example usage:
  /// ```dart
  /// addHistory(
  ///   layers: currentLayers,
  ///   newLayer: additionalLayer,
  ///   transformConfigs: currentTransformConfigs,
  ///   filters: currentFilters,
  ///   blur: currentBlurState,
  ///   heroScreenshotRequired: false,
  /// );
  /// ```
  void addHistory({
    List<Layer>? layers,
    Layer? newLayer,
    TransformConfigs? transformConfigs,
    FilterMatrix? filters,
    double? blur,
    bool heroScreenshotRequired = false,
    bool blockCaptureScreenshot = false,
  }) {
    stateManager.cleanForwardChanges();

    List<Layer> activeLayerList = _layerCopyManager.copyLayerList(activeLayers);

    stateHistory.add(
      EditorStateHistory(
        transformConfigs: transformConfigs ?? stateManager.transformConfigs,
        blur: blur ?? stateManager.activeBlur,
        layers: layers ??
            (newLayer != null
                ? [...activeLayerList, newLayer]
                : activeLayerList),
        filters: filters ?? stateManager.activeFilters,
      ),
    );
    if (!blockCaptureScreenshot) {
      if (!heroScreenshotRequired) {
        _takeScreenshot();
      } else {
        stateManager.heroScreenshotRequired = true;
      }
    } else {
      _controllers.screenshot
          .addEmptyScreenshot(screenshots: stateManager.screenshots);
    }
    stateManager.position++;

    stateManager.setHistoryLimit(configs.stateHistoryConfigs.stateHistoryLimit);
  }

  /// Add a new layer to the image editor.
  ///
  /// This method adds a new layer to the image editor and updates the editing state.
  void addLayer(
    Layer layer, {
    int removeLayerIndex = -1,
    bool blockSelectLayer = false,
    bool blockCaptureScreenshot = false,
  }) {
    layerInteractionManager.selectedLayerId = '';

    addHistory(newLayer: layer, blockCaptureScreenshot: blockCaptureScreenshot);

    if (removeLayerIndex >= 0) {
      activeLayers.removeAt(removeLayerIndex);
    }
    if (!blockSelectLayer &&
        layerInteractionManager.layersAreSelectable(configs) &&
        layerInteraction.initialSelected) {
      /// Skip one frame to ensure captured image in seperate thread will not capture the border.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        layerInteractionManager.selectedLayerId = layer.id;
        _controllers.uiLayerCtrl.add(null);
        _checkInteractiveViewer();
      });
    }
    mainEditorCallbacks?.handleAddLayer(layer);
    setState(() {});
  }

  /// Remove a layer from the editor.
  ///
  /// This method removes a layer from the editor and updates the editing state.
  void removeLayer(int layerPos, {Layer? layer}) {
    int oldIndex = activeLayers
        .indexWhere((element) => element.id == (layer?.id ?? _tempLayer!.id));
    if (oldIndex >= 0) {
      stateHistory[stateManager.position].layers[oldIndex] =
          _layerCopyManager.copyLayer(_tempLayer ?? layer!);

      mainEditorCallbacks?.handleRemoveLayer(
          stateHistory[stateManager.position].layers[oldIndex]);
    }

    var layers = _layerCopyManager.copyLayerList(activeLayers);
    layers.removeAt(layerPos);
    addHistory(layers: layers);
    setState(() {});
  }

  /// Remove all layers from the editor.
  ///
  /// This method removes all layers from the editor and updates the editing state.
  void removeAllLayers() {
    addHistory(layers: []);
    setState(() {});
  }

  /// Update the temporary layer in the editor.
  ///
  /// This method updates the temporary layer in the editor and updates the editing state.
  void _updateTempLayer() {
    addHistory();
    layerInteractionManager.selectedLayerId = '';
    _checkInteractiveViewer();
    _controllers.uiLayerCtrl.add(null);

    /* 
    String selectedLayerId = _layerInteractionManager.selectedLayerId;
    _layerInteractionManager.selectedLayerId = '';
    setState(() {});
    takeScreenshot();
    if (selectedLayerId.isNotEmpty) {
      /// Skip one frame to ensure captured image in seperate thread will not capture the border.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _layerInteractionManager.selectedLayerId = selectedLayerId;
        setState(() {});
      });
    } */

    List<Layer> oldLayers = stateHistory[stateManager.position - 1].layers;
    int oldIndex =
        oldLayers.indexWhere((element) => element.id == _tempLayer!.id);
    if (oldIndex >= 0) {
      oldLayers[oldIndex] = _layerCopyManager.copyLayer(_tempLayer!);
    }
    _tempLayer = null;
  }

  /// Decode the image being edited.
  ///
  /// This method decodes the image if it hasn't been decoded yet and updates its properties.
  Future<void> decodeImage([TransformConfigs? transformConfigs]) async {
    bool shouldImportStateHistory =
        _imageNeedDecode && stateHistoryConfigs.initStateHistory != null;
    _imageNeedDecode = false;
    LoadingDialog? loading;
    if (shouldImportStateHistory && i18n.importStateHistoryMsg.isNotEmpty) {
      loading = LoadingDialog();
      await loading.show(
        context,
        theme: _theme,
        configs: configs,
        message: i18n.importStateHistoryMsg,
      );
    }
    if (!mounted) return;
    _imageInfos = await decodeImageInfos(
      bytes: await editorImage.safeByteArray(context),
      screenSize: Size(
        sizesManager.lastScreenSize.width,
        sizesManager.bodySize.height,
      ),
      configs: transformConfigs ?? stateManager.transformConfigs,
    );
    sizesManager.originalImageSize ??= _imageInfos!.rawSize;
    sizesManager.decodedImageSize = _imageInfos!.renderedSize;

    _inited = true;
    if (!_decodeImageCompleter.isCompleted) {
      _decodeImageCompleter.complete(true);
    }

    if (shouldImportStateHistory) {
      importStateHistory(stateHistoryConfigs.initStateHistory!);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await loading?.hide(context);
      });
    }
    if (mounted) setState(() {});
    mainEditorCallbacks?.handleUpdateUI();
  }

  /// Set the temporary layer to a copy of the provided layer.
  void _setTempLayer(Layer layer) {
    _tempLayer = _layerCopyManager.copyLayer(layer);
  }

  void _calcAppBarHeight() {
    double? renderedBottomBarHeight =
        _bottomBarKey.currentContext?.size?.height;
    if (renderedBottomBarHeight != null) {
      sizesManager.bottomBarHeight = renderedBottomBarHeight;
      sizesManager.appBarHeight = sizesManager.editorSize.height -
          sizesManager.bodySize.height -
          sizesManager.bottomBarHeight;
    }
  }

  /// Handle the start of a scaling operation.
  ///
  /// This method is called when a scaling operation begins and initializes the necessary variables.
  void _onScaleStart(ScaleStartDetails details) {
    if (sizesManager.bodySize != sizesManager.editorSize) {
      _calcAppBarHeight();
    }

    layerInteractionManager.snapStartPosX = details.focalPoint.dx;
    layerInteractionManager.snapStartPosY = details.focalPoint.dy;

    if (selectedLayerIndex < 0) return;

    var layer = activeLayers[selectedLayerIndex];

    if (layerInteractionManager.selectedLayerId != layer.id) {
      layerInteractionManager.selectedLayerId = '';
      _checkInteractiveViewer();
    }

    _setTempLayer(layer);
    layerInteractionManager.baseScaleFactor = layer.scale;
    layerInteractionManager.baseAngleFactor = layer.rotation;
    layerInteractionManager.snapStartRotation = layer.rotation * 180 / pi;
    layerInteractionManager.snapLastRotation =
        layerInteractionManager.snapStartRotation;
    layerInteractionManager.rotationStartedHelper = false;
    layerInteractionManager.showHelperLines = true;

    double posX = layer.offset.dx;
    double posY = layer.offset.dy;

    layerInteractionManager.lastPositionY =
        posY <= -layerInteractionManager.hitSpan
            ? LayerLastPosition.top
            : posY >= layerInteractionManager.hitSpan
                ? LayerLastPosition.bottom
                : LayerLastPosition.center;

    layerInteractionManager.lastPositionX =
        posX <= -layerInteractionManager.hitSpan
            ? LayerLastPosition.left
            : posX >= layerInteractionManager.hitSpan
                ? LayerLastPosition.right
                : LayerLastPosition.center;
    setState(() {});
    mainEditorCallbacks?.handleScaleStart(details);
  }

  /// Handle updates during scaling.
  ///
  /// This method is called during a scaling operation and updates the selected layer's position and properties.
  void _onScaleUpdate(ScaleUpdateDetails details) {
    mainEditorCallbacks?.handleScaleUpdate(details);
    if (selectedLayerIndex < 0 || blockOnScaleUpdateFunction) return;

    bool beforeShowHorizontalHelperLine =
        layerInteractionManager.showHorizontalHelperLine;
    bool beforeShowVerticalHelperLine =
        layerInteractionManager.showVerticalHelperLine;
    bool beforeShowRotationHelperLine =
        layerInteractionManager.showRotationHelperLine;

    checkUpdateHelperLineUI() {
      if (beforeShowHorizontalHelperLine !=
              layerInteractionManager.showHorizontalHelperLine ||
          beforeShowVerticalHelperLine !=
              layerInteractionManager.showVerticalHelperLine ||
          beforeShowRotationHelperLine !=
              layerInteractionManager.showRotationHelperLine) {
        _controllers.helperLineCtrl.add(null);
      }
    }

    if (_activeLayer == null) return;

    if (layerInteractionManager.rotateScaleLayerSizeHelper != null) {
      layerInteractionManager.freeStyleHighPerformanceScaling =
          paintEditorConfigs.freeStyleHighPerformanceScaling ?? !isDesktop;
      layerInteractionManager.calculateInteractiveButtonScaleRotate(
        configs: configs,
        activeLayer: _activeLayer!,
        configEnabledHitVibration: helperLines.hitVibration,
        details: details,
        editorSize: sizesManager.editorSize,
        layerTheme: imageEditorTheme.layerInteraction,
        editorScaleFactor: _interactiveViewer.currentState?.scaleFactor ?? 1.0,
        editorScaleOffset:
            _interactiveViewer.currentState?.offset ?? Offset.zero,
      );
      _activeLayer!.key.currentState!.setState(() {});
      checkUpdateHelperLineUI();
      return;
    }

    double editorScaleFactor =
        _interactiveViewer.currentState?.scaleFactor ?? 1.0;

    layerInteractionManager.enabledHitDetection = false;
    if (details.pointerCount == 1) {
      layerInteractionManager.freeStyleHighPerformanceMoving =
          paintEditorConfigs.freeStyleHighPerformanceMoving ?? isWebMobile;
      layerInteractionManager.calculateMovement(
        editorScaleFactor: editorScaleFactor,
        removeAreaKey: _removeAreaKey,
        activeLayer: _activeLayer!,
        context: context,
        detail: details,
        configEnabledHitVibration: helperLines.hitVibration,
        onHoveredRemoveChanged: _controllers.removeBtnCtrl.add,
      );
    } else if (details.pointerCount == 2) {
      layerInteractionManager.freeStyleHighPerformanceScaling =
          paintEditorConfigs.freeStyleHighPerformanceScaling ?? !isDesktop;
      layerInteractionManager.calculateScaleRotate(
        editorScaleFactor: editorScaleFactor,
        configs: configs,
        activeLayer: _activeLayer!,
        detail: details,
        editorSize: sizesManager.editorSize,
        screenPaddingHelper: sizesManager.imageMargin,
        configEnabledHitVibration: helperLines.hitVibration,
      );
    }
    mainEditorCallbacks?.handleUpdateLayer(_activeLayer!);
    _activeLayer?.key.currentState?.setState(() {});
    checkUpdateHelperLineUI();
  }

  /// Handle the end of a scaling operation.
  ///
  /// This method is called when a scaling operation ends and resets helper lines and flags.
  void _onScaleEnd(ScaleEndDetails details) async {
    mainEditorCallbacks?.handleScaleEnd(details);

    if (!layerInteractionManager.hoverRemoveBtn && _tempLayer != null) {
      _updateTempLayer();
    }

    layerInteractionManager.onScaleEnd();
    setState(() {});
  }

  /// Handles tap events on a text layer.
  ///
  /// This method opens a text editor for the specified text layer and updates the layer's properties
  /// based on the user's input.
  ///
  /// [layerData] - The text layer data to be edited.
  void _onTextLayerTap(TextLayerData layerData) async {
    TextLayerData? layer = await openPage(
      TextEditor(
        key: textEditor,
        layer: layerData,
        heroTag: layerData.id,
        configs: configs,
        theme: _theme,
        callbacks: callbacks,
      ),

      /// Small Duration is important for a smooth hero animation
      duration: const Duration(milliseconds: 250),
    );

    if (layer == null || !mounted) return;

    int i = activeLayers.indexWhere((element) => element.id == layerData.id);
    if (i >= 0) {
      _setTempLayer(layerData);
      TextLayerData textLayer = activeLayers[i] as TextLayerData;
      textLayer
        ..text = layer.text
        ..background = layer.background
        ..color = layer.color
        ..colorMode = layer.colorMode
        ..colorPickerPosition = layer.colorPickerPosition
        ..align = layer.align
        ..fontScale = layer.fontScale
        ..textStyle = layer.textStyle
        ..id = layerData.id
        ..flipX = layerData.flipX
        ..flipY = layerData.flipY
        ..offset = layerData.offset
        ..scale = layerData.scale
        ..customSecondaryColor = layer.customSecondaryColor
        ..rotation = layerData.rotation;

      _updateTempLayer();
    }

    setState(() {});
    mainEditorCallbacks?.handleUpdateUI();
  }

  /// Initializes the key event listener by adding a handler to the keyboard service.
  void initKeyEventListener() {
    ServicesBinding.instance.keyboard.addHandler(_onKeyEvent);
  }

  /// Removes the key event listener by removing the handler from the keyboard service.
  void removeKeyEventListener() {
    ServicesBinding.instance.keyboard.removeHandler(_onKeyEvent);
  }

  void _selectLayerAfterHeroIsDone(String id) {
    if (layerInteractionManager.layersAreSelectable(configs) &&
        layerInteraction.initialSelected) {
      /// Skip one frame to ensure captured image in seperate thread will not capture the border.
      Future.delayed(const Duration(milliseconds: 1), () async {
        if (isSubEditorOpen) await _pageOpenCompleter.future;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          layerInteractionManager.selectedLayerId = id;
          _checkInteractiveViewer();
          setState(() {});
        });
      });
    }
  }

  /// Open a new page on top of the current page.
  ///
  /// This method navigates to a new page using a fade transition animation.
  Future<T?> openPage<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    layerInteractionManager.selectedLayerId = '';
    _checkInteractiveViewer();
    isSubEditorOpen = true;

    if (paintEditorConfigs.freeStyleHighPerformanceHero) {
      layerInteractionManager.freeStyleHighPerformanceHero = true;
    }

    setState(() {});

    SubEditor editorName = SubEditor.unknown;

    if (T is PaintingEditor) {
      editorName = SubEditor.paint;
    } else if (T is TextEditor) {
      editorName = SubEditor.text;
    } else if (T is CropRotateEditor) {
      editorName = SubEditor.cropRotate;
    } else if (T is FilterEditor) {
      editorName = SubEditor.filter;
    } else if (T is BlurEditor) {
      editorName = SubEditor.blur;
    } else if (T is EmojiEditor) {
      editorName = SubEditor.emoji;
    }

    mainEditorCallbacks?.handleOpenSubEditor(editorName);
    _pageOpenCompleter = Completer();
    return Navigator.push<T?>(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: imageEditorTheme.subEditorPage.barrierColor,
        barrierDismissible: imageEditorTheme.subEditorPage.barrierDismissible,
        transitionDuration: duration,
        reverseTransitionDuration: duration,
        transitionsBuilder: imageEditorTheme.subEditorPage.transitionsBuilder ??
            (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
        pageBuilder: (context, animation, secondaryAnimation) {
          void animationStatusListener(AnimationStatus status) {
            if (status == AnimationStatus.completed) {
              if (cropRotateEditor.currentState != null) {
                cropRotateEditor.currentState!.hideFakeHero();
              }
            } else if (status == AnimationStatus.dismissed) {
              setState(() {
                isSubEditorOpen = false;
                if (!_pageOpenCompleter.isCompleted) {
                  _pageOpenCompleter.complete(true);
                }
                layerInteractionManager.freeStyleHighPerformanceHero = false;

                if (stateManager.heroScreenshotRequired) {
                  stateManager.heroScreenshotRequired = false;
                  _takeScreenshot();
                }
              });

              animation.removeStatusListener(animationStatusListener);
              mainEditorCallbacks?.handleCloseSubEditor(editorName);
            }
          }

          animation.addStatusListener(animationStatusListener);
          if (imageEditorTheme.subEditorPage.requireReposition) {
            return SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: imageEditorTheme.subEditorPage.positionTop,
                    left: imageEditorTheme.subEditorPage.positionLeft,
                    right: imageEditorTheme.subEditorPage.positionRight,
                    bottom: imageEditorTheme.subEditorPage.positionBottom,
                    child: Center(
                      child: Container(
                        width: imageEditorTheme
                                .subEditorPage.enforceSizeFromMainEditor
                            ? sizesManager.editorSize.width
                            : null,
                        height: imageEditorTheme
                                .subEditorPage.enforceSizeFromMainEditor
                            ? sizesManager.editorSize.height
                            : null,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius:
                              imageEditorTheme.subEditorPage.borderRadius,
                        ),
                        child: page,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return page;
          }
        },
      ),
    );
  }

  /// Opens the painting editor.
  ///
  /// This method opens the painting editor and allows the user to draw on the current image.
  /// After closing the painting editor, any changes made are applied to the image's layers.
  void openPaintingEditor() async {
    List<PaintingLayerData>? paintingLayers =
        await openPage<List<PaintingLayerData>>(
      PaintingEditor.autoSource(
        key: paintingEditor,
        file: editorImage.file,
        byteArray: editorImage.byteArray,
        assetPath: editorImage.assetPath,
        networkUrl: editorImage.networkUrl,
        initConfigs: PaintEditorInitConfigs(
          configs: configs,
          callbacks: callbacks,
          layers: activeLayers,
          theme: _theme,
          mainImageSize: sizesManager.decodedImageSize,
          mainBodySize: sizesManager.bodySize,
          transformConfigs: stateManager.transformConfigs,
          appliedBlurFactor: stateManager.activeBlur,
          appliedFilters: stateManager.activeFilters,
        ),
      ),
      duration: const Duration(milliseconds: 150),
    );
    if (paintingLayers != null && paintingLayers.isNotEmpty) {
      for (var i = 0; i < paintingLayers.length; i++) {
        addLayer(
          paintingLayers[i],
          blockSelectLayer: true,
          blockCaptureScreenshot: i != paintingLayers.length - 1,
        );
      }

      _selectLayerAfterHeroIsDone(paintingLayers.last.id);

      setState(() {});
      mainEditorCallbacks?.handleUpdateUI();
    }
  }

  /// Opens the text editor.
  ///
  /// This method opens the text editor, allowing the user to add or edit text layers on the image.
  void openTextEditor({
    /// Small Duration is important for a smooth hero animation
    Duration duration = const Duration(milliseconds: 150),
  }) async {
    TextLayerData? layer = await openPage(
      TextEditor(
        key: textEditor,
        configs: configs,
        theme: _theme,
        callbacks: callbacks,
      ),
      duration: duration,
    );

    if (layer == null || !mounted) return;

    addLayer(layer, blockSelectLayer: true);
    _selectLayerAfterHeroIsDone(layer.id);

    setState(() {});
    mainEditorCallbacks?.handleUpdateUI();
  }

  /// Opens the crop rotate editor.
  ///
  /// This method opens the crop editor, allowing the user to crop and rotate the image.
  void openCropRotateEditor() async {
    if (!_inited) await _decodeImageCompleter.future;

    openPage<TransformConfigs?>(
      CropRotateEditor.autoSource(
        key: cropRotateEditor,
        file: editorImage.file,
        byteArray: editorImage.byteArray,
        assetPath: editorImage.assetPath,
        networkUrl: editorImage.networkUrl,
        initConfigs: CropRotateEditorInitConfigs(
          configs: configs,
          callbacks: callbacks,
          theme: _theme,
          layers: stateManager.activeLayers,
          transformConfigs:
              stateManager.stateHistory[stateManager.position].transformConfigs,
          mainImageSize: sizesManager.decodedImageSize,
          mainBodySize: sizesManager.bodySize,
          enableFakeHero: true,
          appliedBlurFactor: stateManager.activeBlur,
          appliedFilters: stateManager.activeFilters,
          onDone: (transformConfigs, fitToScreenFactor) async {
            List<Layer> updatedLayers = LayerTransformGenerator(
              layers: stateManager.activeLayers,
              activeTransformConfigs: stateManager.transformConfigs,
              newTransformConfigs: transformConfigs,
              layerDrawAreaSize: sizesManager.bodySize,
              undoChanges: false,
              fitToScreenFactor: fitToScreenFactor,
            ).updatedLayers;

            _imageInfos = null;
            decodeImage(transformConfigs);
            addHistory(
              transformConfigs: transformConfigs,
              layers: updatedLayers,
              heroScreenshotRequired: true,
            );

            /// Important to reset the layer hero positions
            if (activeLayers.isNotEmpty) {
              _controllers.layerHeroResetCtrl.add(true);
              await Future.delayed(const Duration(milliseconds: 60));
              _controllers.layerHeroResetCtrl.add(false);
            }

            setState(() {});
          },
        ),
      ),
    ).then((transformConfigs) async {
      if (transformConfigs != null) {
        setState(() {});
        mainEditorCallbacks?.handleUpdateUI();
      }
    });
  }

  /// Opens the filter editor.
  ///
  /// This method allows the user to apply filters to the current image and replaces the image
  /// with the filtered version if a filter is applied.
  ///
  /// The filter editor is opened as a page, and the resulting filtered image is received as a
  /// `Uint8List`. If no filter is applied or the operation is canceled, the original image is retained.
  void openFilterEditor() async {
    if (!mounted) return;
    FilterMatrix? filters = await openPage(
      FilterEditor.autoSource(
        key: filterEditor,
        file: editorImage.file,
        byteArray: editorImage.byteArray,
        assetPath: editorImage.assetPath,
        networkUrl: editorImage.networkUrl,
        initConfigs: FilterEditorInitConfigs(
          theme: _theme,
          configs: configs,
          callbacks: callbacks,
          transformConfigs: stateManager.transformConfigs,
          layers: activeLayers,
          mainImageSize: sizesManager.decodedImageSize,
          mainBodySize: sizesManager.bodySize,
          convertToUint8List: false,
          appliedBlurFactor: stateManager.activeBlur,
          appliedFilters: stateManager.activeFilters,
        ),
      ),
    );

    if (filters == null) return;

    addHistory(
      filters: filters,
      heroScreenshotRequired: true,
    );

    setState(() {});
    mainEditorCallbacks?.handleUpdateUI();
  }

  /// Opens the blur editor as a modal bottom sheet.
  void openBlurEditor() async {
    if (!mounted) return;
    double? blur = await openPage(
      BlurEditor.autoSource(
        key: blurEditor,
        file: editorImage.file,
        byteArray: editorImage.byteArray,
        assetPath: editorImage.assetPath,
        networkUrl: editorImage.networkUrl,
        initConfigs: BlurEditorInitConfigs(
          theme: _theme,
          mainImageSize: sizesManager.decodedImageSize,
          mainBodySize: sizesManager.bodySize,
          layers: activeLayers,
          configs: configs,
          callbacks: callbacks,
          transformConfigs: stateManager.transformConfigs,
          convertToUint8List: false,
          appliedBlurFactor: stateManager.activeBlur,
          appliedFilters: stateManager.activeFilters,
        ),
      ),
    );

    if (blur == null) return;

    addHistory(
      blur: blur,
      heroScreenshotRequired: true,
    );

    setState(() {});
    mainEditorCallbacks?.handleUpdateUI();
  }

  /// Opens the emoji editor.
  ///
  /// This method opens the emoji editor as a modal bottom sheet, allowing the user to add emoji
  /// layers to the current image. The selected emoji layer's properties, such as scale and offset,
  /// are adjusted before adding it to the image's layers.
  ///
  /// Keyboard event handlers are temporarily removed while the emoji editor is active and restored
  /// after its closure.
  void openEmojiEditor() async {
    setState(() => layerInteractionManager.selectedLayerId = '');
    _checkInteractiveViewer();
    ServicesBinding.instance.keyboard.removeHandler(_onKeyEvent);
    final effectiveBoxConstraints = imageEditorTheme
            .emojiEditor.editorBoxConstraintsBuilder
            ?.call(context, configs) ??
        imageEditorTheme.editorBoxConstraintsBuilder?.call(context, configs);

    ThemeDraggableSheet sheetTheme =
        imageEditorTheme.emojiEditor.themeDraggableSheet;
    bool useDraggableSheet = sheetTheme.maxChildSize != sheetTheme.minChildSize;
    EmojiLayerData? layer = await showModalBottomSheet(
        context: context,
        backgroundColor: imageEditorTheme.emojiEditor.backgroundColor,
        constraints: effectiveBoxConstraints,
        showDragHandle: imageEditorTheme.emojiEditor.showDragHandle,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (BuildContext context) {
          if (!useDraggableSheet) {
            return ConstrainedBox(
              constraints: effectiveBoxConstraints ??
                  BoxConstraints(
                      maxHeight:
                          300 + MediaQuery.of(context).viewInsets.bottom),
              child: EmojiEditor(configs: configs),
            );
          }

          return DraggableScrollableSheet(
              expand: sheetTheme.expand,
              initialChildSize: sheetTheme.initialChildSize,
              maxChildSize: sheetTheme.maxChildSize,
              minChildSize: sheetTheme.minChildSize,
              shouldCloseOnMinExtent: sheetTheme.shouldCloseOnMinExtent,
              snap: sheetTheme.snap,
              snapAnimationDuration: sheetTheme.snapAnimationDuration,
              snapSizes: sheetTheme.snapSizes,
              builder: (_, controller) {
                return EmojiEditor(
                  configs: configs,
                  scrollController: controller,
                );
              });
        });
    ServicesBinding.instance.keyboard.addHandler(_onKeyEvent);
    if (layer == null || !mounted) return;
    layer.scale = emojiEditorConfigs.initScale;

    addLayer(layer);

    setState(() {});
    mainEditorCallbacks?.handleUpdateUI();
  }

  /// Opens the sticker editor as a modal bottom sheet.
  void openStickerEditor() async {
    setState(() => layerInteractionManager.selectedLayerId = '');
    _checkInteractiveViewer();
    ServicesBinding.instance.keyboard.removeHandler(_onKeyEvent);
    final effectiveBoxConstraints = imageEditorTheme
            .stickerEditor.editorBoxConstraintsBuilder
            ?.call(context, configs) ??
        imageEditorTheme.editorBoxConstraintsBuilder?.call(context, configs);
    var sheetTheme = imageEditorTheme.stickerEditor.themeDraggableSheet;
    StickerLayerData? layer = await showModalBottomSheet(
        context: context,
        backgroundColor:
            imageEditorTheme.stickerEditor.bottomSheetBackgroundColor,
        constraints: effectiveBoxConstraints,
        showDragHandle: imageEditorTheme.stickerEditor.showDragHandle,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) {
          return DraggableScrollableSheet(
            expand: sheetTheme.expand,
            initialChildSize: sheetTheme.initialChildSize,
            maxChildSize: sheetTheme.maxChildSize,
            minChildSize: sheetTheme.minChildSize,
            shouldCloseOnMinExtent: sheetTheme.shouldCloseOnMinExtent,
            snap: sheetTheme.snap,
            snapAnimationDuration: sheetTheme.snapAnimationDuration,
            snapSizes: sheetTheme.snapSizes,
            builder: (_, controller) {
              return StickerEditor(
                configs: configs,
                scrollController: controller,
              );
            },
          );
        });
    ServicesBinding.instance.keyboard.addHandler(_onKeyEvent);
    if (layer == null || !mounted) return;

    addLayer(layer);

    setState(() {});
    mainEditorCallbacks?.handleUpdateUI();
  }

  /// Moves a layer in the list to a new position.
  ///
  /// - `oldIndex` is the current index of the layer.
  /// - `newIndex` is the desired index to move the layer to.
  void moveLayerListPosition({
    required int oldIndex,
    required int newIndex,
  }) {
    List<Layer> layers = _layerCopyManager.copyLayerList(activeLayers);
    if (newIndex > oldIndex) {
      var item = layers.removeAt(oldIndex);
      layers.insert(newIndex - 1, item);
    } else {
      var item = layers.removeAt(oldIndex);
      layers.insert(newIndex, item);
    }
    addHistory(layers: layers);
    setState(() {});
  }

  /// Undo the last editing action.
  ///
  /// This function allows the user to undo the most recent editing action performed on the image.
  /// It decreases the edit position, and the image is decoded to reflect the previous state.
  void undoAction() {
    if (stateManager.position > 0) {
      setState(() {
        layerInteractionManager.selectedLayerId = '';
        _checkInteractiveViewer();
        stateManager.position--;
        decodeImage();
      });
      mainEditorCallbacks?.handleUndo();
    }
  }

  /// Redo the previously undone editing action.
  ///
  /// This function allows the user to redo an editing action that was previously undone using the
  /// `undoAction` function. It increases the edit position, and the image is decoded to reflect
  /// the next state.
  void redoAction() {
    if (stateManager.position < stateHistory.length - 1) {
      setState(() {
        layerInteractionManager.selectedLayerId = '';
        _checkInteractiveViewer();
        stateManager.position++;
        decodeImage();
      });
      mainEditorCallbacks?.handleRedo();
    }
  }

  /// Takes a screenshot of the current editor state.
  ///
  /// This method is intended to be used for capturing the current state of the editor
  /// and saving it as an image.
  ///
  /// - If a subeditor is currently open, the method waits until it is fully loaded.
  /// - The screenshot is taken in a post-frame callback to ensure the UI is fully rendered.
  void _takeScreenshot() async {
    // Wait for the editor to be fully open, if it is currently opening
    if (isSubEditorOpen) await _pageOpenCompleter.future;

    // Capture the screenshot in a post-frame callback to ensure the UI is fully rendered
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_imageInfos == null) await decodeImage();

      if (!mounted) return;

      _controllers.screenshot.captureImage(
        imageInfos: _imageInfos!,
        screenshots: stateManager.screenshots,
      );
    });
  }

  /// Complete the editing process and return the edited image.
  ///
  /// This function is called when the user is done editing the image. If no changes have been made
  /// or if the image has no additional layers, it cancels the editing process and closes the editor.
  /// Otherwise, it captures the current state of the image, including any applied changes or layers,
  /// and returns it as a byte array.
  ///
  /// Before returning the edited image, a loading dialog is displayed to indicate that the operation
  /// is in progress.
  void doneEditing() async {
    if (_processFinalImage) return;
    if (stateManager.position <= 0 && activeLayers.isEmpty) {
      if (!imageGenerationConfigs.allowEmptyEditCompletion) {
        return closeEditor();
      }
    }
    callbacks.onImageEditingStarted?.call();

    /// Hide every unnessacary element that Screenshot Controller will capture a correct image.
    setState(() {
      _processFinalImage = true;
      layerInteractionManager.selectedLayerId = '';
      _checkInteractiveViewer();
    });

    /// Ensure hero animations finished
    if (isSubEditorOpen) await _pageOpenCompleter.future;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      LoadingDialog loading = LoadingDialog();
      await loading.show(
        context,
        theme: _theme,
        configs: configs,
        message: i18n.doneLoadingMsg,
      );

      if (callbacks.onThumbnailGenerated != null) {
        if (_imageInfos == null) await decodeImage();

        final List<dynamic> results = await Future.wait([
          captureEditorImage(),
          _controllers.screenshot.getOriginalImage(imageInfos: _imageInfos!),
        ]);

        await callbacks.onThumbnailGenerated!(results[0], results[1]);
      } else {
        Uint8List? bytes = await captureEditorImage();
        await onImageEditingComplete?.call(bytes);
      }

      if (mounted) loading.hide(context);

      onCloseEditor?.call();

      /// Allow users to continue editing if they didn't close the editor.
      setState(() => _processFinalImage = false);
    });
  }

  /// Captures the final editor image.
  ///
  /// This method generates the final image of the editor content, taking
  /// into account the pixel ratio for high-resolution images. If `generateOnlyImageBounds`
  /// is set in `imageGenerationConfigs`, it uses the base pixel ratio; otherwise, it uses
  /// the maximum of the base pixel ratio and the device's pixel ratio.
  ///
  /// Returns a [Uint8List] representing the final image.
  ///
  /// Returns an empty [Uint8List] if the screenshot capture fails.
  Future<Uint8List> captureEditorImage() async {
    if (isSubEditorOpen) {
      Navigator.pop(context);
      if (!_pageOpenCompleter.isCompleted) await _pageOpenCompleter.future;
      if (!mounted) return Uint8List.fromList([]);
    }

    if (_imageInfos == null) await decodeImage();

    if (!mounted) return Uint8List.fromList([]);

    return await _controllers.screenshot.captureFinalScreenshot(
          imageInfos: _imageInfos!,
          backgroundScreenshot:
              stateManager.position > 0 ? stateManager.activeScreenshot : null,
          originalImageBytes: stateManager.position > 0
              ? null
              : await editorImage.safeByteArray(context),
        ) ??
        Uint8List.fromList([]);
  }

  /// Close the image editor.
  ///
  /// This function allows the user to close the image editor without saving any changes or edits.
  /// It navigates back to the previous screen or closes the modal editor.
  void closeEditor() {
    if (stateManager.position <= 0) {
      if (onCloseEditor == null) {
        Navigator.pop(context);
      } else {
        onCloseEditor!.call();
      }
    } else {
      closeWarning();
    }
  }

  /// Displays a warning dialog before closing the image editor.
  void closeWarning() async {
    if (disablePopScope) {
      Navigator.pop(context);
      return;
    }
    _openDialog = true;

    bool close = false;

    if (!mounted) return;

    if (customWidgets.mainEditor.closeWarningDialog != null) {
      close = await customWidgets.mainEditor.closeWarningDialog!(this);
    } else {
      await showAdaptiveDialog(
        context: context,
        builder: (BuildContext context) => Theme(
          data: _theme,
          child: AdaptiveDialog(
            designMode: designMode,
            brightness: _theme.brightness,
            imageEditorTheme: imageEditorTheme,
            title: Text(i18n.various.closeEditorWarningTitle),
            content: Text(i18n.various.closeEditorWarningMessage),
            actions: <AdaptiveDialogAction>[
              AdaptiveDialogAction(
                designMode: designMode,
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: Text(i18n.various.closeEditorWarningCancelBtn),
              ),
              AdaptiveDialogAction(
                designMode: designMode,
                onPressed: () {
                  close = true;
                  stateManager.position = 0;
                  Navigator.pop(context, 'OK');
                },
                child: Text(i18n.various.closeEditorWarningConfirmBtn),
              ),
            ],
          ),
        ),
      );
    }

    if (close) {
      if (onCloseEditor == null) {
        if (mounted) Navigator.pop(context);
      } else {
        onCloseEditor!.call();
      }
    }

    _openDialog = false;
  }

  /// Imports state history and performs necessary recalculations.
  ///
  /// If [ImportStateHistory.configs.recalculateSizeAndPosition] is `true`, it recalculates the position and size of layers.
  /// It adjusts the scale and offset of each layer based on the image size and the editor's dimensions.
  ///
  /// If [ImportStateHistory.configs.mergeMode] is [ImportEditorMergeMode.replace], it replaces the current state history with the imported one.
  /// Otherwise, it merges the imported state history with the current one based on the merge mode.
  ///
  /// After importing, it updates the UI by calling [setState()] and the optional [onUpdateUI] callback.
  void importStateHistory(ImportStateHistory import) {
    /// Recalculate position and size
    if (import.configs.recalculateSizeAndPosition ||
        import.version == ExportImportVersion.version_1_0_0) {
      Size imgSize = import.imgSize / (_imageInfos?.pixelRatio ?? 1);
      for (EditorStateHistory el in import.stateHistory) {
        for (Layer layer in el.layers) {
          if (import.configs.recalculateSizeAndPosition) {
            // Calculate scaling factors for width and height
            double scaleWidth =
                sizesManager.decodedImageSize.width / imgSize.width;
            double scaleHeight =
                sizesManager.decodedImageSize.height / imgSize.height;

            if (scaleWidth == 0 || scaleWidth.isInfinite) scaleWidth = 1;
            if (scaleHeight == 0 || scaleHeight.isInfinite) scaleHeight = 1;

            // Choose the middle value between scaleWidth and scaleHeight
            double scale = (scaleWidth + scaleHeight) / 2;

            // Adjust the scale
            layer.scale *= scale;

            // Adjust the offset
            layer.offset = Offset(
              layer.offset.dx * scaleWidth,
              layer.offset.dy * scaleHeight,
            );
          }
          if (import.version == ExportImportVersion.version_1_0_0) {
            layer.offset -= Offset(
              sizesManager.bodySize.width / 2 -
                  sizesManager.imageScreenGaps.left,
              sizesManager.bodySize.height / 2 -
                  sizesManager.imageScreenGaps.top,
            );
          }
        }
      }
    }

    if (import.configs.mergeMode == ImportEditorMergeMode.replace) {
      stateManager.screenshots = [];

      stateManager.position =
          import.editorPosition + (import.stateHistory.isEmpty ? 0 : 1);
      stateManager.stateHistory = [
        EditorStateHistory(
          transformConfigs: TransformConfigs.empty(),
          blur: 0,
          filters: [],
          layers: [],
        ),
        ...import.stateHistory
      ];
      for (var i = 0; i < import.stateHistory.length; i++) {
        if (i < import.stateHistory.length - 1) {
          _controllers.screenshot
              .addEmptyScreenshot(screenshots: stateManager.screenshots);
        } else {
          _controllers.screenshot
              .addEmptyScreenshot(screenshots: stateManager.screenshots);
        }
      }
    } else {
      for (var el in stateManager.screenshots) {
        el.broken = true;
      }

      for (var el in import.stateHistory) {
        if (import.configs.mergeMode == ImportEditorMergeMode.merge) {
          el.layers.insertAll(0, stateHistory.last.layers);
          el.filters.insertAll(0, stateHistory.last.filters);
        }
      }

      for (var i = 0; i < import.stateHistory.length; i++) {
        stateHistory.add(import.stateHistory[i]);
        if (i < import.stateHistory.length - 1) {
          _controllers.screenshot
              .addEmptyScreenshot(screenshots: stateManager.screenshots);
        } else {
          _takeScreenshot();
        }
      }
      stateManager.position = stateHistory.length - 1;
    }

    setState(() {});
    decodeImage(stateManager.transformConfigs);
    mainEditorCallbacks?.handleUpdateUI();
  }

  /// Exports the current state history.
  ///
  /// `configs` specifies the export configurations, such as whether to include filters or layers.
  ///
  /// Returns an [ExportStateHistory] object containing the exported state history, image state history, image size, edit position, and export configurations.
  Future<ExportStateHistory> exportStateHistory(
      {ExportEditorConfigs configs = const ExportEditorConfigs()}) async {
    if (_imageInfos == null) await decodeImage();

    return ExportStateHistory(
      editorConfigs: this.configs,
      stateHistory: stateManager.stateHistory,
      imageInfos: _imageInfos!,
      imgSize: sizesManager.decodedImageSize,
      editorPosition: stateManager.position,
      configs: configs,
      contentRecorderCtrl: _controllers.screenshot,
      // ignore: use_build_context_synchronously
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    _theme = configs.theme ??
        ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue.shade800,
            brightness: Brightness.dark,
          ),
        );

    return RecordInvisibleWidget(
      controller: _controllers.screenshot,
      child: PopScope(
        canPop:
            disablePopScope || stateManager.position <= 0 || _processFinalImage,
        onPopInvoked: (didPop) {
          if (!didPop &&
              !disablePopScope &&
              stateManager.position > 0 &&
              !_processFinalImage) {
            closeWarning();
          }
          mainEditorCallbacks?.onPopInvoked?.call(didPop);
        },
        child: ScreenResizeDetector(
          ignoreSafeArea: true,
          onResizeUpdate: (event) {
            sizesManager.recalculateLayerPosition(
              history: stateManager.stateHistory,
              resizeEvent: ResizeEvent(
                oldContentSize: Size(
                  event.oldContentSize.width,
                  event.oldContentSize.height - sizesManager.allToolbarHeight,
                ),
                newContentSize: Size(
                  event.newContentSize.width,
                  event.newContentSize.height - sizesManager.allToolbarHeight,
                ),
              ),
            );
            sizesManager.lastScreenSize = event.newContentSize;
          },
          onResizeEnd: (event) async {
            await decodeImage();
          },
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: imageEditorTheme.uiOverlayStyle,
            child: Theme(
              data: _theme,
              child: SafeArea(
                child: LayoutBuilder(builder: (context, constraints) {
                  sizesManager.editorSize = constraints.biggest;
                  return Scaffold(
                    backgroundColor: imageEditorTheme.background,
                    resizeToAvoidBottomInset: false,
                    appBar: _buildAppBar(),
                    body: _buildBody(),
                    bottomNavigationBar: _buildBottomNavBar(),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    if (customWidgets.mainEditor.appBar != null) {
      return customWidgets.mainEditor.appBar!
          .call(this, _rebuildController.stream);
    }

    return selectedLayerIndex >= 0
        ? null
        : AppBar(
            automaticallyImplyLeading: false,
            foregroundColor: imageEditorTheme.appBarForegroundColor,
            backgroundColor: imageEditorTheme.appBarBackgroundColor,
            actions: [
              IconButton(
                tooltip: i18n.cancel,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: Icon(icons.closeEditor),
                onPressed: closeEditor,
              ),
              const Spacer(),
              IconButton(
                key: const ValueKey('MainEditorUndoButton'),
                tooltip: i18n.undo,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: Icon(
                  icons.undoAction,
                  color: stateManager.position > 0
                      ? imageEditorTheme.appBarForegroundColor
                      : imageEditorTheme.appBarForegroundColor.withAlpha(80),
                ),
                onPressed: undoAction,
              ),
              IconButton(
                key: const ValueKey('MainEditorRedoButton'),
                tooltip: i18n.redo,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: Icon(
                  icons.redoAction,
                  color: stateManager.position < stateHistory.length - 1
                      ? imageEditorTheme.appBarForegroundColor
                      : imageEditorTheme.appBarForegroundColor.withAlpha(80),
                ),
                onPressed: redoAction,
              ),
              !_inited
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 11.0),
                      child: SizedBox.square(
                        dimension: 22,
                        child:
                            PlatformCircularProgressIndicator(configs: configs),
                      ),
                    )
                  : IconButton(
                      key: const ValueKey('MainEditorDoneButton'),
                      tooltip: i18n.done,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      icon: Icon(icons.doneIcon),
                      iconSize: 28,
                      onPressed: doneEditing,
                    ),
            ],
          );
  }

  Widget _buildBody() {
    return LayoutBuilder(builder: (context, constraints) {
      sizesManager.bodySize = constraints.biggest;
      return Listener(
        behavior: HitTestBehavior.translucent,
        onPointerSignal: isDesktop && _activeLayer != null
            ? (event) {
                if (_activeLayer == null) return;
                _desktopInteractionManager.mouseScroll(
                  event,
                  activeLayer: _activeLayer!,
                  selectedLayerIndex: selectedLayerIndex,
                );
              }
            : null,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (layerInteractionManager.selectedLayerId.isNotEmpty) {
              layerInteractionManager.selectedLayerId = '';
              _checkInteractiveViewer();
              setState(() {});
            }
            mainEditorCallbacks?.onTap?.call();
          },
          onDoubleTap: mainEditorCallbacks?.onDoubleTap,
          onLongPress: mainEditorCallbacks?.onLongPress,
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          child: customWidgets.mainEditor.wrapBody?.call(
                this,
                _rebuildController.stream,
                _buildInteractiveContent(),
              ) ??
              _buildInteractiveContent(),
        ),
      );
    });
  }

  Widget _buildInteractiveContent() {
    return Center(
      child: Stack(
        children: [
          Padding(
            padding: selectedLayerIndex >= 0
                ? EdgeInsets.only(
                    top: sizesManager.appBarHeight,
                    bottom: sizesManager.bottomBarHeight,
                  )
                : EdgeInsets.zero,
            child: ExtendedInteractiveViewer(
              key: _interactiveViewer,
              editorIsZoomable: mainEditorConfigs.editorIsZoomable,
              minScale: mainEditorConfigs.editorMinScale,
              maxScale: mainEditorConfigs.editorMaxScale,
              onInteractionStart: (details) {
                callbacks.mainEditorCallbacks?.onEditorZoomScaleStart
                    ?.call(details);
                layerInteractionManager.freeStyleHighPerformanceEditorZoom =
                    (paintEditorConfigs.freeStyleHighPerformanceMoving ??
                            !isDesktop) ||
                        (paintEditorConfigs.freeStyleHighPerformanceScaling ??
                            !isDesktop);

                _controllers.uiLayerCtrl.add(null);
              },
              onInteractionUpdate:
                  callbacks.mainEditorCallbacks?.onEditorZoomScaleUpdate,
              onInteractionEnd: (details) {
                callbacks.mainEditorCallbacks?.onEditorZoomScaleEnd
                    ?.call(details);
                layerInteractionManager.freeStyleHighPerformanceEditorZoom =
                    false;
                _controllers.uiLayerCtrl.add(null);
              },
              child: ContentRecorder(
                key: const ValueKey('main-editor-content-recorder'),
                autoDestroyController: false,
                controller: _controllers.screenshot,
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: [
                    /// Build Image
                    _buildImage(),

                    /// Build layer stack
                    _buildLayers(),

                    if (widget.configs.imageGenerationConfigs
                        .captureOnlyBackgroundImageArea)
                      Hero(
                        tag: 'crop_layer_painter_hero',
                        child: CustomPaint(
                          foregroundPainter: imageGenerationConfigs
                                  .captureOnlyBackgroundImageArea
                              ? CropLayerPainter(
                                  opacity: imageEditorTheme
                                      .outsideCaptureAreaLayerOpacity,
                                  backgroundColor: imageEditorTheme.background,
                                  imgRatio:
                                      stateManager.transformConfigs.isNotEmpty
                                          ? stateManager.transformConfigs
                                              .cropRect.size.aspectRatio
                                          : sizesManager
                                              .decodedImageSize.aspectRatio,
                                  isRoundCropper:
                                      cropRotateEditorConfigs.roundCropper,
                                  is90DegRotated: stateManager
                                      .transformConfigs.is90DegRotated,
                                )
                              : null,
                          child: const SizedBox.expand(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          /// Build helper stuff
          if (!_processFinalImage) ...[
            _buildHelperLines(),
            if (selectedLayerIndex >= 0) _buildRemoveIcon(),
          ],
          if (customWidgets.mainEditor.bodyItems != null)
            ...customWidgets.mainEditor.bodyItems!(
                this, _rebuildController.stream),
        ],
      ),
    );
  }

  Widget? _buildBottomNavBar() {
    var bottomTextStyle = const TextStyle(fontSize: 10.0, color: Colors.white);
    double bottomIconSize = 22.0;

    if (customWidgets.mainEditor.bottomBar != null) {
      return customWidgets.mainEditor.bottomBar!
          .call(this, _rebuildController.stream, _bottomBarKey);
    }

    return selectedLayerIndex >= 0
        ? null
        : SizedBox(
            key: _bottomBarKey,
            child: LayoutBuilder(builder: (context, constraints) {
              return Theme(
                data: _theme,
                child: Scrollbar(
                  controller: _controllers.bottomBarScrollCtrl,
                  scrollbarOrientation: ScrollbarOrientation.top,
                  thickness: isDesktop ? null : 0,
                  child: BottomAppBar(
                    height: kBottomNavigationBarHeight,
                    color: imageEditorTheme.bottomBarBackgroundColor,
                    padding: EdgeInsets.zero,
                    child: Center(
                      child: SingleChildScrollView(
                        controller: _controllers.bottomBarScrollCtrl,
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: min(
                                sizesManager.lastScreenSize.width != 0
                                    ? sizesManager.lastScreenSize.width
                                    : constraints.maxWidth,
                                600),
                            maxWidth: 600,
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                if (paintEditorConfigs.enabled)
                                  FlatIconTextButton(
                                    key: const ValueKey(
                                        'open-painting-editor-btn'),
                                    label: Text(
                                        i18n.paintEditor
                                            .bottomNavigationBarText,
                                        style: bottomTextStyle),
                                    icon: Icon(
                                      icons.paintingEditor.bottomNavBar,
                                      size: bottomIconSize,
                                      color: Colors.white,
                                    ),
                                    onPressed: openPaintingEditor,
                                  ),
                                if (textEditorConfigs.enabled)
                                  FlatIconTextButton(
                                    key: const ValueKey('open-text-editor-btn'),
                                    label: Text(
                                        i18n.textEditor.bottomNavigationBarText,
                                        style: bottomTextStyle),
                                    icon: Icon(
                                      icons.textEditor.bottomNavBar,
                                      size: bottomIconSize,
                                      color: Colors.white,
                                    ),
                                    onPressed: openTextEditor,
                                  ),
                                if (cropRotateEditorConfigs.enabled)
                                  FlatIconTextButton(
                                    key: const ValueKey(
                                        'open-crop-rotate-editor-btn'),
                                    label: Text(
                                        i18n.cropRotateEditor
                                            .bottomNavigationBarText,
                                        style: bottomTextStyle),
                                    icon: Icon(
                                      icons.cropRotateEditor.bottomNavBar,
                                      size: bottomIconSize,
                                      color: Colors.white,
                                    ),
                                    onPressed: openCropRotateEditor,
                                  ),
                                if (filterEditorConfigs.enabled)
                                  FlatIconTextButton(
                                    key: const ValueKey(
                                        'open-filter-editor-btn'),
                                    label: Text(
                                        i18n.filterEditor
                                            .bottomNavigationBarText,
                                        style: bottomTextStyle),
                                    icon: Icon(
                                      icons.filterEditor.bottomNavBar,
                                      size: bottomIconSize,
                                      color: Colors.white,
                                    ),
                                    onPressed: openFilterEditor,
                                  ),
                                if (blurEditorConfigs.enabled)
                                  FlatIconTextButton(
                                    key: const ValueKey('open-blur-editor-btn'),
                                    label: Text(
                                        i18n.blurEditor.bottomNavigationBarText,
                                        style: bottomTextStyle),
                                    icon: Icon(
                                      icons.blurEditor.bottomNavBar,
                                      size: bottomIconSize,
                                      color: Colors.white,
                                    ),
                                    onPressed: openBlurEditor,
                                  ),
                                if (emojiEditorConfigs.enabled)
                                  FlatIconTextButton(
                                    key:
                                        const ValueKey('open-emoji-editor-btn'),
                                    label: Text(
                                        i18n.emojiEditor
                                            .bottomNavigationBarText,
                                        style: bottomTextStyle),
                                    icon: Icon(
                                      icons.emojiEditor.bottomNavBar,
                                      size: bottomIconSize,
                                      color: Colors.white,
                                    ),
                                    onPressed: openEmojiEditor,
                                  ),
                                if (stickerEditorConfigs?.enabled == true)
                                  FlatIconTextButton(
                                    key: const ValueKey(
                                        'open-sticker-editor-btn'),
                                    label: Text(
                                        i18n.stickerEditor
                                            .bottomNavigationBarText,
                                        style: bottomTextStyle),
                                    icon: Icon(
                                      icons.stickerEditor.bottomNavBar,
                                      size: bottomIconSize,
                                      color: Colors.white,
                                    ),
                                    onPressed: openStickerEditor,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
  }

  Widget _buildLayers() {
    return IgnorePointer(
      ignoring: selectedLayerIndex >= 0,
      child: StreamBuilder<bool>(
          stream: _controllers.layerHeroResetCtrl.stream,
          initialData: false,
          builder: (context, resetLayerSnapshot) {
            if (resetLayerSnapshot.data!) return Container();
            return RepaintBoundary(
              child: ExtendedMouseRegion(
                key: _mouseCursorsKey,
                onHover: isDesktop
                    ? (event) {
                        bool hasHit = activeLayers.indexWhere((element) =>
                                element is PaintingLayerData &&
                                element.item.hit) >=
                            0;

                        MouseCursor activeCursor =
                            _mouseCursorsKey.currentState!.currentCursor;
                        MouseCursor moveCursor =
                            imageEditorTheme.layerInteraction.hoverCursor;

                        if (hasHit && activeCursor != moveCursor) {
                          _mouseCursorsKey.currentState!.setCursor(moveCursor);
                        } else if (!hasHit &&
                            activeCursor != SystemMouseCursors.basic) {
                          _mouseCursorsKey.currentState!
                              .setCursor(SystemMouseCursors.basic);
                        }
                      }
                    : null,
                child: DeferredPointerHandler(
                  child: StreamBuilder(
                      stream: _controllers.uiLayerCtrl.stream,
                      builder: (context, snapshot) {
                        return Stack(
                          children: activeLayers.asMap().entries.map((entry) {
                            final int i = entry.key;
                            final Layer layerItem = entry.value;

                            return LayerWidget(
                              key: layerItem.key,
                              configs: configs,
                              editorCenterX: sizesManager.editorSize.width / 2,
                              editorCenterY: sizesManager
                                  .editorCenterY(selectedLayerIndex),
                              layerData: layerItem,
                              enableHitDetection:
                                  layerInteractionManager.enabledHitDetection,
                              selected:
                                  layerInteractionManager.selectedLayerId ==
                                      layerItem.id,
                              isInteractive: !isSubEditorOpen,
                              highPerformanceMode: layerInteractionManager
                                  .freeStyleHighPerformance,
                              onEditTap: () {
                                if (layerItem is TextLayerData) {
                                  _onTextLayerTap(layerItem);
                                }
                              },
                              onTap: (layer) async {
                                if (layerInteractionManager
                                    .layersAreSelectable(configs)) {
                                  layerInteractionManager.selectedLayerId =
                                      layer.id ==
                                              layerInteractionManager
                                                  .selectedLayerId
                                          ? ''
                                          : layer.id;
                                  _checkInteractiveViewer();
                                } else if (layer is TextLayerData) {
                                  _onTextLayerTap(layer);
                                }
                              },
                              onTapUp: () {
                                if (layerInteractionManager.hoverRemoveBtn) {
                                  removeLayer(
                                    activeLayers.indexWhere((element) =>
                                        element.id == layerItem.id),
                                    layer: layerItem,
                                  );
                                }
                                _controllers.uiLayerCtrl.add(null);
                                mainEditorCallbacks?.handleUpdateUI();
                                selectedLayerIndex = -1;

                                _checkInteractiveViewer();
                              },
                              onTapDown: () {
                                selectedLayerIndex = i;
                                _setTempLayer(layerItem);
                                _checkInteractiveViewer();
                              },
                              onScaleRotateDown: (details, layerOriginalSize) {
                                selectedLayerIndex = i;
                                layerInteractionManager
                                        .rotateScaleLayerSizeHelper =
                                    layerOriginalSize;
                                layerInteractionManager
                                        .rotateScaleLayerScaleHelper =
                                    layerItem.scale;
                                _checkInteractiveViewer();
                              },
                              onScaleRotateUp: (details) {
                                layerInteractionManager
                                    .rotateScaleLayerSizeHelper = null;
                                layerInteractionManager
                                    .rotateScaleLayerScaleHelper = null;
                                setState(() {
                                  selectedLayerIndex = -1;
                                });
                                _checkInteractiveViewer();
                                mainEditorCallbacks?.handleUpdateUI();
                              },
                              onRemoveTap: () {
                                setState(() {
                                  removeLayer(
                                    activeLayers.indexWhere((element) =>
                                        element.id == layerItem.id),
                                    layer: layerItem,
                                  );
                                });
                                mainEditorCallbacks?.handleUpdateUI();
                              },
                            );
                          }).toList(),
                        );
                      }),
                ),
              ),
            );
          }),
    );
  }

  Widget _buildHelperLines() {
    double screenH = sizesManager.screen.height;
    double screenW = sizesManager.screen.width;
    double lineH = 1.25;
    int duration = 100;
    if (!layerInteractionManager.showHelperLines) {
      return const SizedBox.shrink();
    }
    return RepaintBoundary(
      child: StreamBuilder(
          stream: _controllers.helperLineCtrl.stream,
          builder: (context, snapshot) {
            if (_interactiveViewer.currentState != null &&
                _interactiveViewer.currentState!.scaleFactor > 1) {
              return const SizedBox.shrink();
            }
            return Stack(
              children: [
                if (helperLines.showVerticalLine)
                  Align(
                    alignment: Alignment.center,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: duration),
                      width: layerInteractionManager.showVerticalHelperLine
                          ? lineH
                          : 0,
                      height: screenH,
                      color: imageEditorTheme.helperLine.verticalColor,
                    ),
                  ),
                if (helperLines.showHorizontalLine)
                  Align(
                    alignment: Alignment.center,
                    child: AnimatedContainer(
                      margin: EdgeInsets.only(
                        top: sizesManager.appBarHeight,
                        bottom: sizesManager.bottomBarHeight,
                      ),
                      duration: Duration(milliseconds: duration),
                      width: screenW,
                      height: layerInteractionManager.showHorizontalHelperLine
                          ? lineH
                          : 0,
                      color: imageEditorTheme.helperLine.horizontalColor,
                    ),
                  ),
                if (helperLines.showRotateLine)
                  Positioned(
                    left: layerInteractionManager.rotationHelperLineX,
                    top: layerInteractionManager.rotationHelperLineY,
                    child: FractionalTranslation(
                      translation: const Offset(-0.5, -0.5),
                      child: Transform.rotate(
                        angle: layerInteractionManager.rotationHelperLineDeg,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: duration),
                          width: layerInteractionManager.showRotationHelperLine
                              ? lineH
                              : 0,
                          height: screenH * 2,
                          color: imageEditorTheme.helperLine.rotateColor,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
    );
  }

  Widget _buildRemoveIcon() {
    return customWidgets.mainEditor.removeLayerArea
            ?.call(_removeAreaKey, _controllers.removeBtnCtrl.stream) ??
        Positioned(
          key: _removeAreaKey,
          top: 0,
          left: 0,
          child: SafeArea(
            bottom: false,
            child: StreamBuilder(
                stream: _controllers.removeBtnCtrl.stream,
                builder: (context, snapshot) {
                  return Container(
                    height: kToolbarHeight,
                    width: kToolbarHeight,
                    decoration: BoxDecoration(
                      color: layerInteractionManager.hoverRemoveBtn
                          ? imageEditorTheme
                              .layerInteraction.removeAreaBackgroundActive
                          : imageEditorTheme
                              .layerInteraction.removeAreaBackgroundInactive,
                      borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(100)),
                    ),
                    padding: const EdgeInsets.only(right: 12, bottom: 7),
                    child: Center(
                      child: Icon(
                        icons.removeElementZone,
                        size: 28,
                      ),
                    ),
                  );
                }),
          ),
        );
  }

  Widget _buildImage() {
    return Hero(
      tag: heroTag,
      createRectTween: (begin, end) => RectTween(begin: begin, end: end),
      child: !_inited
          ? AutoImage(
              editorImage,
              fit: BoxFit.contain,
              width: sizesManager.decodedImageSize.width,
              height: sizesManager.decodedImageSize.height,
              configs: configs,
            )
          : TransformedContentGenerator(
              transformConfigs: stateManager.transformConfigs,
              configs: configs,
              child: FilteredImage(
                width: sizesManager.decodedImageSize.width,
                height: sizesManager.decodedImageSize.height,
                configs: configs,
                image: editorImage,
                filters: stateManager.activeFilters,
                blurFactor: stateManager.activeBlur,
              ),
            ),
    );
  }
}
