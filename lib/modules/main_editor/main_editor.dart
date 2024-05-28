// Dart imports:
import 'dart:async';
import 'dart:io';
import 'dart:math';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:defer_pointer/defer_pointer.dart';
import 'package:vibration/vibration.dart';

// Project imports:
import 'package:pro_image_editor/designs/whatsapp/whatsapp_appbar.dart';
import 'package:pro_image_editor/mixins/editor_configs_mixin.dart';
import 'package:pro_image_editor/models/crop_rotate_editor/transform_factors.dart';
import 'package:pro_image_editor/models/init_configs/crop_rotate_editor_init_configs.dart';
import 'package:pro_image_editor/modules/main_editor/utils/layer_copy_manager.dart';
import 'package:pro_image_editor/modules/main_editor/utils/main_editor_controllers.dart';
import 'package:pro_image_editor/modules/main_editor/utils/state_manager.dart';
import 'package:pro_image_editor/modules/sticker_editor.dart';
import 'package:pro_image_editor/utils/layer_transform_generator.dart';
import 'package:pro_image_editor/utils/swipe_mode.dart';
import 'package:pro_image_editor/widgets/screen_resize_detector.dart';
import '../../utils/decode_image.dart';
import '../blur_editor.dart';
import '../crop_rotate_editor/crop_rotate_editor.dart';
import '../emoji_editor/emoji_editor.dart';
import '../filter_editor/filter_editor.dart';
import '../filter_editor/widgets/filter_editor_item_list.dart';
import '../filter_editor/widgets/image_with_filters.dart';
import '../paint_editor/paint_editor.dart';
import '../text_editor/text_editor.dart';
import '/designs/whatsapp/whatsapp_filter_button.dart';
import '/designs/whatsapp/whatsapp_sticker_editor.dart';
import '/mixins/converted_configs.dart';
import '/mixins/editor_callbacks_mixin.dart';
import '/mixins/main_editor/main_editor_global_keys.dart';
import '/models/editor_image.dart';
import '/models/history/blur_state_history.dart';
import '/models/history/filter_state_history.dart';
import '/models/history/last_position.dart';
import '/models/history/state_history.dart';
import '/models/import_export/export_state_history.dart';
import '/models/layer.dart';
import '/pro_image_editor.dart';
import '/utils/constants.dart';
import '/utils/content_recorder.dart/content_recorder.dart';
import '/utils/debounce.dart';
import '/widgets/adaptive_dialog.dart';
import '/widgets/auto_image.dart';
import '/widgets/flat_icon_text_button.dart';
import '/widgets/layer_widget.dart';
import '/widgets/loading_dialog.dart';
import '/widgets/pro_image_editor_desktop_mode.dart';
import '/widgets/transform/transformed_content_generator.dart';
import 'utils/desktop_interaction_manager.dart';
import 'utils/layer_interaction_manager.dart';
import 'utils/sizes_manager.dart';
import 'utils/whatsapp_helper.dart';

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
  /// Helper class for managing sizes and layout calculations.
  late final SizesManager _sizesManager;

  /// Manager class for handling desktop interactions in the image editor.
  late final DesktopInteractionManager _desktopInteractionManager;

  /// Manager class to copy layers.
  final LayerCopyManager _layerCopyManager = LayerCopyManager();

  /// Helper class for managing interactions with layers in the editor.
  final LayerInteractionManager _layerInteractionManager =
      LayerInteractionManager();

  /// Manager class for managing the state of the editor.
  final StateManager _stateManager = StateManager();

  /// Controller instances for managing various aspects of the main editor.
  late final MainEditorControllers _controllers;

  /// Helper class for managing WhatsApp filters.
  final WhatsAppHelper _whatsAppHelper = WhatsAppHelper();

  /// The current theme used by the image editor.
  late ThemeData _theme;

  /// Temporary layer used during editing.
  Layer? _tempLayer;

  /// Index of the selected layer.
  int _selectedLayerIndex = -1;

  /// Flag indicating if the editor has been initialized.
  bool _inited = false;

  /// Flag indicating if the image needs decoding.
  bool _imageNeedDecode = true;

  /// Flag to track if editing is completed.
  bool _doneEditing = false;

  /// The pixel ratio of the device's screen.
  double _pixelRatio = 1;

  /// Whether an editor is currently open.
  bool _isEditorOpen = false;

  /// Whether a dialog is currently open.
  bool _openDialog = false;

  /// Represents the direction of swipe action.
  SwipeMode _swipeDirection = SwipeMode.none;

  /// Represents the start time of the swipe action.
  DateTime _swipeStartTime = DateTime.now();

  /// Indicates whether the browser's context menu was enabled before any changes.
  bool _browserContextMenuBeforeEnabled = false;

  /// Getter for the active layer currently being edited.
  Layer? get _activeLayer =>
      activeLayers.length > _selectedLayerIndex && _selectedLayerIndex >= 0
          ? activeLayers[_selectedLayerIndex]
          : null;

  /// Get the list of layers from the current image editor changes.
  List<Layer> get activeLayers =>
      _stateManager.stateHistory[_stateManager.position].layers;

  /// List to store the history of image editor changes.
  List<EditorStateHistory> get stateHistory => _stateManager.stateHistory;

  /// Determines whether undo actions can be performed on the current state.
  bool get canUndo => _stateManager.position > 0;

  /// Determines whether redo actions can be performed on the current state.
  bool get canRedo =>
      _stateManager.position < _stateManager.stateHistory.length - 1;

  /// Get the current image being edited from the change list.
  late EditorImage _image;

  Offset get newLayerOffsetPosition =>
      layerInteraction.newLayerOffsetPosition ?? Offset.zero;

  Completer _pageOpenCompleter = Completer();
  final Completer _decodeImageCompleter = Completer();

  @override
  void initState() {
    super.initState();
    _controllers = MainEditorControllers(configs);
    _desktopInteractionManager = DesktopInteractionManager(
      configs: configs,
      context: context,
      onUpdateUI: onUpdateUI,
      setState: setState,
    );
    _sizesManager = SizesManager(configs: configs, context: context);
    _layerInteractionManager.scaleDebounce =
        Debounce(const Duration(milliseconds: 100));

    _image = EditorImage(
      assetPath: widget.assetPath,
      byteArray: widget.byteArray,
      file: widget.file,
      networkUrl: widget.networkUrl,
    );

    _stateManager.stateHistory.add(EditorStateHistory(
      transformConfigs: TransformConfigs.empty(),
      blur: BlurStateHistory(),
      layers: [],
      filters: [],
    ));

    Vibration.hasVibrator().then(
        (value) => _layerInteractionManager.deviceCanVibrate = value ?? false);
    Vibration.hasCustomVibrationsSupport().then((value) =>
        _layerInteractionManager.deviceCanCustomVibrate = value ?? false);

    ServicesBinding.instance.keyboard.addHandler(_onKeyEvent);
    if (kIsWeb) {
      _browserContextMenuBeforeEnabled = BrowserContextMenu.enabled;
      BrowserContextMenu.disableContextMenu();
    }
  }

  @override
  void dispose() {
    _controllers.dispose();
    _layerInteractionManager.scaleDebounce.dispose();
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

  /// Handle keyboard events
  bool _onKeyEvent(KeyEvent event) {
    return _desktopInteractionManager.onKey(
      event,
      activeLayer: _activeLayer,
      onEscape: () {
        if (!_openDialog) {
          if (_isEditorOpen) {
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
        if (_openDialog || _isEditorOpen) return;

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
  /// _addHistory(
  ///   layers: currentLayers,
  ///   newLayer: additionalLayer,
  ///   transformConfigs: currentTransformConfigs,
  ///   filters: currentFilters,
  ///   blur: currentBlurState,
  ///   heroScreenshotRequired: false,
  /// );
  /// ```
  void _addHistory({
    List<Layer>? layers,
    Layer? newLayer,
    TransformConfigs? transformConfigs,
    List<FilterStateHistory>? filters,
    BlurStateHistory? blur,
    bool heroScreenshotRequired = false,
    bool blockCaptureScreenshot = false,
  }) {
    _stateManager.cleanForwardChanges();

    List<Layer> activeLayerList = _layerCopyManager.copyLayerList(activeLayers);

    stateHistory.add(
      EditorStateHistory(
        transformConfigs: transformConfigs ?? _stateManager.transformConfigs,
        blur: blur ?? _stateManager.activeBlur,
        layers: layers ??
            (newLayer != null
                ? [...activeLayerList, newLayer]
                : activeLayerList),
        filters: filters ?? _stateManager.activeFilters,
      ),
    );
    if (!blockCaptureScreenshot) {
      if (!heroScreenshotRequired) {
        _takeScreenshot();
      } else {
        _stateManager.heroScreenshotRequired = true;
      }
    } else {
      _controllers.screenshot
          .isolateAddEmptyScreenshot(screenshots: _stateManager.screenshots);
    }
    _stateManager.position++;

    _stateManager
        .setHistoryLimit(configs.stateHistoryConfigs.stateHistoryLimit);
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
    _addHistory(
        newLayer: layer, blockCaptureScreenshot: blockCaptureScreenshot);

    if (removeLayerIndex >= 0) {
      activeLayers.removeAt(removeLayerIndex);
    }
    if (!blockSelectLayer &&
        _layerInteractionManager.layersAreSelectable(configs) &&
        layerInteraction.initialSelected) {
      /// Skip one frame to ensure captured image in seperate thread will not capture the border.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _layerInteractionManager.selectedLayerId = layer.id;
        _controllers.uiLayerStream.add(null);
      });
    }
    setState(() {});
    callbacks.onAddLayer?.call();
  }

  /// Remove a layer from the editor.
  ///
  /// This method removes a layer from the editor and updates the editing state.
  void removeLayer(int layerPos, {Layer? layer}) {
    int oldIndex = activeLayers
        .indexWhere((element) => element.id == (layer?.id ?? _tempLayer!.id));
    if (oldIndex >= 0) {
      stateHistory[_stateManager.position].layers[oldIndex] =
          _layerCopyManager.copyLayer(_tempLayer ?? layer!);
    }

    var layers = _layerCopyManager.copyLayerList(activeLayers);
    layers.removeAt(layerPos);
    _addHistory(layers: layers);

    callbacks.onRemoveLayer?.call();
  }

  /// Update the temporary layer in the editor.
  ///
  /// This method updates the temporary layer in the editor and updates the editing state.
  void _updateTempLayer() {
    _addHistory();
    _layerInteractionManager.selectedLayerId = '';
    _controllers.uiLayerStream.add(null);
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

    List<Layer> oldLayers = stateHistory[_stateManager.position - 1].layers;
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
  Future<void> _decodeImage([TransformConfigs? transformConfigs]) async {
    bool shouldImportStateHistory =
        _imageNeedDecode && stateHistoryConfigs.initStateHistory != null;
    _imageNeedDecode = false;
    LoadingDialog? loading;
    if (shouldImportStateHistory && i18n.importStateHistoryMsg.isNotEmpty) {
      loading = LoadingDialog()
        ..show(
          context,
          theme: _theme,
          configs: configs,
          message: i18n.importStateHistoryMsg,
        );
    }
    DecodedImageInfos infos = await decodeImageInfos(
      bytes: await _image.safeByteArray(context),
      screenSize: Size(
        _sizesManager.lastScreenSize.width,
        _sizesManager.bodySize.height,
      ),
      configs: transformConfigs ?? _stateManager.transformConfigs,
    );
    _sizesManager.originalImageSize ??= infos.rawImageSize;
    _sizesManager.decodedImageSize = infos.renderedImageSize;

    _pixelRatio = infos.pixelRatio;

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
    onUpdateUI?.call();
  }

  /// Set the temporary layer to a copy of the provided layer.
  void _setTempLayer(Layer layer) {
    _tempLayer = _layerCopyManager.copyLayer(layer);
  }

  /// Handle the start of a scaling operation.
  ///
  /// This method is called when a scaling operation begins and initializes the necessary variables.
  void _onScaleStart(ScaleStartDetails details) {
    _swipeDirection = SwipeMode.none;
    _swipeStartTime = DateTime.now();
    _layerInteractionManager.snapStartPosX = details.focalPoint.dx;
    _layerInteractionManager.snapStartPosY = details.focalPoint.dy;

    if (_selectedLayerIndex < 0) return;

    var layer = activeLayers[_selectedLayerIndex];

    if (_layerInteractionManager.selectedLayerId != layer.id) {
      _layerInteractionManager.selectedLayerId = '';
    }

    _setTempLayer(layer);
    _layerInteractionManager.baseScaleFactor = layer.scale;
    _layerInteractionManager.baseAngleFactor = layer.rotation;
    _layerInteractionManager.snapStartRotation = layer.rotation * 180 / pi;
    _layerInteractionManager.snapLastRotation =
        _layerInteractionManager.snapStartRotation;
    _layerInteractionManager.rotationStartedHelper = false;
    _layerInteractionManager.showHelperLines = true;

    double posX = layer.offset.dx;
    double posY = layer.offset.dy;

    _layerInteractionManager.lastPositionY =
        posY <= -_layerInteractionManager.hitSpan
            ? LayerLastPosition.top
            : posY >= _layerInteractionManager.hitSpan
                ? LayerLastPosition.bottom
                : LayerLastPosition.center;

    _layerInteractionManager.lastPositionX =
        posX <= -_layerInteractionManager.hitSpan
            ? LayerLastPosition.left
            : posX >= _layerInteractionManager.hitSpan
                ? LayerLastPosition.right
                : LayerLastPosition.center;
    setState(() {});
    callbacks.onScaleStart?.call(details);
  }

  /// Handle updates during scaling.
  ///
  /// This method is called during a scaling operation and updates the selected layer's position and properties.
  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_selectedLayerIndex < 0) {
      if (imageEditorTheme.editorMode == ThemeEditorMode.whatsapp) {
        _whatsAppHelper.filterShowHelper -= details.focalPointDelta.dy;
        _whatsAppHelper.filterShowHelper =
            max(0, min(120, _whatsAppHelper.filterShowHelper));

        double pointerOffset =
            _layerInteractionManager.snapStartPosY - details.focalPoint.dy;
        if (pointerOffset > 20) {
          _swipeDirection = SwipeMode.up;
        } else if (pointerOffset < -20) {
          _swipeDirection = SwipeMode.down;
        }

        setState(() {});
      }
      return;
    }

    if (_whatsAppHelper.filterShowHelper > 0 || _activeLayer == null) return;

    if (_layerInteractionManager.rotateScaleLayerSizeHelper != null) {
      _layerInteractionManager.freeStyleHighPerformanceScaling =
          paintEditorConfigs.freeStyleHighPerformanceScaling ?? !isDesktop;
      _layerInteractionManager.calculateInteractiveButtonScaleRotate(
        activeLayer: _activeLayer!,
        configEnabledHitVibration: helperLines.hitVibration,
        details: details,
        editorSize: _sizesManager.editorSize,
        layerTheme: imageEditorTheme.layerInteraction,
      );
      _controllers.uiLayerStream.add(null);
      onUpdateUI?.call();
      return;
    }

    _layerInteractionManager.enabledHitDetection = false;
    if (details.pointerCount == 1) {
      _layerInteractionManager.freeStyleHighPerformanceMoving =
          paintEditorConfigs.freeStyleHighPerformanceMoving ?? isWebMobile;
      _layerInteractionManager.calculateMovement(
        activeLayer: _activeLayer!,
        context: context,
        detail: details,
        configEnabledHitVibration: helperLines.hitVibration,
      );
    } else if (details.pointerCount == 2) {
      _layerInteractionManager.freeStyleHighPerformanceScaling =
          paintEditorConfigs.freeStyleHighPerformanceScaling ?? !isDesktop;
      _layerInteractionManager.calculateScaleRotate(
        activeLayer: _activeLayer!,
        detail: details,
        editorSize: _sizesManager.editorSize,
        screenPaddingHelper: _sizesManager.imageMargin,
        configEnabledHitVibration: helperLines.hitVibration,
      );
    }
    _controllers.uiLayerStream.add(null);
    onUpdateUI?.call();
    callbacks.onScaleUpdate?.call(details);
  }

  /// Handle the end of a scaling operation.
  ///
  /// This method is called when a scaling operation ends and resets helper lines and flags.
  void _onScaleEnd(ScaleEndDetails details) async {
    if (_selectedLayerIndex < 0 &&
        imageEditorTheme.editorMode == ThemeEditorMode.whatsapp) {
      _layerInteractionManager.showHelperLines = false;

      if (_swipeDirection != SwipeMode.none &&
          DateTime.now().difference(_swipeStartTime).inMilliseconds < 200) {
        if (_swipeDirection == SwipeMode.up) {
          _whatsAppHelper.filterSheetAutoAnimation(true, setState);
        } else if (_swipeDirection == SwipeMode.down) {
          _whatsAppHelper.filterSheetAutoAnimation(false, setState);
        }
      } else {
        if (_whatsAppHelper.filterShowHelper < 90) {
          _whatsAppHelper.filterSheetAutoAnimation(false, setState);
        } else {
          _whatsAppHelper.filterSheetAutoAnimation(true, setState);
        }
      }

      _whatsAppHelper.filterShowHelper =
          max(0, min(120, _whatsAppHelper.filterShowHelper));
      setState(() {});
    }

    if (!_layerInteractionManager.hoverRemoveBtn && _tempLayer != null) {
      _updateTempLayer();
    }

    _layerInteractionManager.onScaleEnd();
    setState(() {});
    onUpdateUI?.call();
    callbacks.onScaleEnd?.call(details);
  }

  /// Handles tap events on a text layer.
  ///
  /// This method opens a text editor for the specified text layer and updates the layer's properties
  /// based on the user's input.
  ///
  /// [layerData] - The text layer data to be edited.
  void _onTextLayerTap(TextLayerData layerData) async {
    TextLayerData? layer = await _openPage(
      TextEditor(
        key: textEditor,
        layer: layerData,
        heroTag: layerData.id,
        configs: widget.configs,
        theme: _theme,
        callbacks: TextEditorCallbacks(
          onUpdateUI: callbacks.onUpdateUI,
          onChanged: callbacks.textEditorCallbacks?.onChanged,
          onSubmitted: callbacks.textEditorCallbacks?.onSubmitted,
          onEditingComplete: callbacks.textEditorCallbacks?.onEditingComplete,
        ),
      ),
      duration: const Duration(milliseconds: 50),
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
        ..rotation = layerData.rotation;

      _updateTempLayer();
    }

    setState(() {});
    onUpdateUI?.call();
  }

  void _selectLayerAfterHeroIsDone(String id) {
    if (_layerInteractionManager.layersAreSelectable(configs) &&
        layerInteraction.initialSelected) {
      /// Skip one frame to ensure captured image in seperate thread will not capture the border.
      Future.delayed(const Duration(milliseconds: 1), () async {
        if (_isEditorOpen) await _pageOpenCompleter.future;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          _layerInteractionManager.selectedLayerId = id;
          setState(() {});
        });
      });
    }
  }

  /// Open a new page on top of the current page.
  ///
  /// This method navigates to a new page using a fade transition animation.
  Future<T?> _openPage<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    _layerInteractionManager.selectedLayerId = '';
    _isEditorOpen = true;

    if (paintEditorConfigs.freeStyleHighPerformanceHero) {
      _layerInteractionManager.freeStyleHighPerformanceHero = true;
    }

    setState(() {});
    callbacks.onOpenSubEditor?.call();
    _pageOpenCompleter = Completer.sync();
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
                _isEditorOpen = false;
                if (!_pageOpenCompleter.isCompleted) {
                  _pageOpenCompleter.complete(true);
                }
                _layerInteractionManager.freeStyleHighPerformanceHero = false;

                if (_stateManager.heroScreenshotRequired) {
                  _stateManager.heroScreenshotRequired = false;
                  _takeScreenshot();
                }
              });

              animation.removeStatusListener(animationStatusListener);
              callbacks.onCloseSubEditor?.call();
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
                            ? _sizesManager.lastScreenSize.width
                            : null,
                        height: imageEditorTheme
                                .subEditorPage.enforceSizeFromMainEditor
                            ? _sizesManager.lastScreenSize.height
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
        await _openPage<List<PaintingLayerData>>(
      PaintingEditor.autoSource(
        key: paintingEditor,
        file: _image.file,
        byteArray: _image.byteArray,
        assetPath: _image.assetPath,
        networkUrl: _image.networkUrl,
        initConfigs: PaintEditorInitConfigs(
          layers: activeLayers,
          theme: _theme,
          mainImageSize: _sizesManager.decodedImageSize,
          mainBodySize: _sizesManager.bodySize,
          configs: widget.configs,
          transformConfigs: _stateManager.transformConfigs,
          onUpdateUI: onUpdateUI,
          appliedBlurFactor: _stateManager.activeBlur.blur,
          appliedFilters: _stateManager.activeFilters,
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
      onUpdateUI?.call();
    }
  }

  /// Opens the text editor.
  ///
  /// This method opens the text editor, allowing the user to add or edit text layers on the image.
  void openTextEditor() async {
    TextLayerData? layer = await _openPage(
      TextEditor(
        key: textEditor,
        configs: widget.configs,
        theme: _theme,
        callbacks: TextEditorCallbacks(
          onUpdateUI: callbacks.onUpdateUI,
          onChanged: callbacks.textEditorCallbacks?.onChanged,
          onSubmitted: callbacks.textEditorCallbacks?.onSubmitted,
          onEditingComplete: callbacks.textEditorCallbacks?.onEditingComplete,
        ),
      ),
      duration: const Duration(milliseconds: 50),
    );

    if (layer == null || !mounted) return;
    layer.offset = newLayerOffsetPosition;

    addLayer(layer, blockSelectLayer: true);
    _selectLayerAfterHeroIsDone(layer.id);

    setState(() {});
    onUpdateUI?.call();
  }

  /// Opens the crop rotate editor.
  ///
  /// This method opens the crop editor, allowing the user to crop and rotate the image.
  void openCropRotateEditor() async {
    if (!_inited) await _decodeImageCompleter.future;

    _openPage<TransformConfigs?>(
      CropRotateEditor.autoSource(
        key: cropRotateEditor,
        file: _image.file,
        byteArray: _image.byteArray,
        assetPath: _image.assetPath,
        networkUrl: _image.networkUrl,
        initConfigs: CropRotateEditorInitConfigs(
          onUpdateUI: onUpdateUI,
          theme: _theme,
          layers: _stateManager.activeLayers,
          configs: widget.configs,
          transformConfigs: _stateManager
              .stateHistory[_stateManager.position].transformConfigs,
          mainImageSize: _sizesManager.decodedImageSize,
          mainBodySize: _sizesManager.bodySize,
          enableFakeHero: true,
          appliedBlurFactor: _stateManager.activeBlur.blur,
          appliedFilters: _stateManager.activeFilters,
          onDone: (transformConfigs) async {
            List<Layer> updatedLayers = LayerTransformGenerator(
              layers: _stateManager.activeLayers,
              activeTransformConfigs: _stateManager.transformConfigs,
              newTransformConfigs: transformConfigs,
              layerDrawAreaSize: _sizesManager.bodySize,
              undoChanges: false,
            ).updatedLayers;

            await _decodeImage(transformConfigs);

            _addHistory(
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
        onUpdateUI?.call();
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
    FilterStateHistory? filterAppliedImage = await _openPage(
      FilterEditor.autoSource(
        key: filterEditor,
        file: _image.file,
        byteArray: _image.byteArray,
        assetPath: _image.assetPath,
        networkUrl: _image.networkUrl,
        initConfigs: FilterEditorInitConfigs(
          theme: _theme,
          configs: widget.configs,
          transformConfigs: _stateManager.transformConfigs,
          onUpdateUI: onUpdateUI,
          layers: activeLayers,
          mainImageSize: _sizesManager.decodedImageSize,
          mainBodySize: _sizesManager.bodySize,
          convertToUint8List: false,
          appliedBlurFactor: _stateManager.activeBlur.blur,
          appliedFilters: _stateManager.activeFilters,
        ),
      ),
    );

    if (filterAppliedImage == null) return;

    _addHistory(
      filters: [
        filterAppliedImage,
        ..._stateManager.activeFilters,
      ],
      heroScreenshotRequired: true,
    );

    setState(() {});
    onUpdateUI?.call();
  }

  /// Opens the blur editor as a modal bottom sheet.
  void openBlurEditor() async {
    if (!mounted) return;
    double? blur = await _openPage(
      BlurEditor.autoSource(
        key: blurEditor,
        file: _image.file,
        byteArray: _image.byteArray,
        assetPath: _image.assetPath,
        networkUrl: _image.networkUrl,
        initConfigs: BlurEditorInitConfigs(
          theme: _theme,
          mainImageSize: _sizesManager.decodedImageSize,
          mainBodySize: _sizesManager.bodySize,
          layers: activeLayers,
          configs: widget.configs,
          transformConfigs: _stateManager.transformConfigs,
          onUpdateUI: onUpdateUI,
          convertToUint8List: false,
          appliedBlurFactor: _stateManager.activeBlur.blur,
          appliedFilters: _stateManager.activeFilters,
        ),
      ),
    );

    if (blur == null) return;

    _addHistory(
      blur: BlurStateHistory(blur: blur),
      heroScreenshotRequired: true,
    );

    setState(() {});
    onUpdateUI?.call();
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
    setState(() => _layerInteractionManager.selectedLayerId = '');
    ServicesBinding.instance.keyboard.removeHandler(_onKeyEvent);
    EmojiLayerData? layer = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (BuildContext context) => EmojiEditor(
        configs: widget.configs,
      ),
    );
    ServicesBinding.instance.keyboard.addHandler(_onKeyEvent);
    if (layer == null || !mounted) return;
    layer.scale = emojiEditorConfigs.initScale;
    layer.offset = newLayerOffsetPosition;

    addLayer(layer);

    setState(() {});
    onUpdateUI?.call();
  }

  /// Opens the sticker editor as a modal bottom sheet.
  void openStickerEditor() async {
    setState(() => _layerInteractionManager.selectedLayerId = '');
    ServicesBinding.instance.keyboard.removeHandler(_onKeyEvent);
    StickerLayerData? layer = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (BuildContext context) => StickerEditor(
        configs: widget.configs,
      ),
    );
    ServicesBinding.instance.keyboard.addHandler(_onKeyEvent);
    if (layer == null || !mounted) return;
    layer.offset = newLayerOffsetPosition;

    addLayer(layer);

    setState(() {});
    onUpdateUI?.call();
  }

  /// Opens the WhatsApp sticker editor.
  ///
  /// This method removes the keyboard handler, then depending on the design mode specified in the [configs] parameter of the widget, it either opens the WhatsAppStickerPage directly or shows it as a modal bottom sheet.
  ///
  /// If the design mode is set to [ImageEditorDesignModeE.material], the WhatsAppStickerPage is opened directly using [_openPage()]. Otherwise, it is displayed as a modal bottom sheet with specific configurations such as transparent background, black barrier color, and controlled scrolling.
  ///
  /// After the page is opened and a layer is returned, the keyboard handler is added back. If no layer is returned or the widget is not mounted, the method returns early.
  ///
  /// If the returned layer's runtime type is not StickerLayerData, the layer's scale is set to the initial scale specified in [emojiEditorConfigs] of the [configs] parameter. Regardless, the layer's offset is set to the center of the image.
  ///
  /// Finally, the layer is added, the UI is updated, and the widget's [onUpdateUI] callback is called if provided.
  void openWhatsAppStickerEditor() async {
    ServicesBinding.instance.keyboard.removeHandler(_onKeyEvent);

    Layer? layer;
    if (designMode == ImageEditorDesignModeE.material) {
      layer = await _openPage(WhatsAppStickerPage(
        configs: widget.configs,
      ));
    } else {
      layer = await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black12,
        showDragHandle: false,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              clipBehavior: Clip.hardEdge,
              child: WhatsAppStickerPage(
                configs: widget.configs,
              ),
            ),
          );
        },
      );
    }

    ServicesBinding.instance.keyboard.addHandler(_onKeyEvent);
    if (layer == null || !mounted) {
      setState(() {});
      return;
    }

    if (layer.runtimeType != StickerLayerData) {
      layer.scale = emojiEditorConfigs.initScale;
    }
    layer.offset = newLayerOffsetPosition;

    addLayer(layer);

    setState(() {});
    onUpdateUI?.call();
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
    _addHistory(layers: layers);
    setState(() {});
  }

  /// Undo the last editing action.
  ///
  /// This function allows the user to undo the most recent editing action performed on the image.
  /// It decreases the edit position, and the image is decoded to reflect the previous state.
  void undoAction() {
    if (_stateManager.position > 0) {
      setState(() {
        _layerInteractionManager.selectedLayerId = '';
        _stateManager.position--;
        _decodeImage();
      });
      onUpdateUI?.call();
    }
  }

  /// Redo the previously undone editing action.
  ///
  /// This function allows the user to redo an editing action that was previously undone using the
  /// `undoAction` function. It increases the edit position, and the image is decoded to reflect
  /// the next state.
  void redoAction() {
    if (_stateManager.position < stateHistory.length - 1) {
      setState(() {
        _layerInteractionManager.selectedLayerId = '';
        _stateManager.position++;
        _decodeImage();
      });
      onUpdateUI?.call();
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
    if (_isEditorOpen) await _pageOpenCompleter.future;

    // Capture the screenshot in a post-frame callback to ensure the UI is fully rendered
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _controllers.screenshot.isolateCaptureImage(
        pixelRatio: _pixelRatio,
        screenshots: _stateManager.screenshots,
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
    if (_doneEditing) return;
    if (_stateManager.position <= 0 && activeLayers.isEmpty) {
      if (!imageGenerationConfigs.allowEmptyEditCompletion) {
        return closeEditor();
      }
    }
    callbacks.onImageEditingStarted?.call();

    /// Hide every unnessacary element that Screenshot Controller will capture a correct image.
    setState(() {
      _doneEditing = true;
      _layerInteractionManager.selectedLayerId = '';
    });

    /// Ensure hero animations finished
    if (_isEditorOpen) await _pageOpenCompleter.future;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      LoadingDialog loading = LoadingDialog()
        ..show(
          context,
          theme: _theme,
          configs: configs,
          message: i18n.doneLoadingMsg,
        );

      Uint8List? bytes = await captureEditorImage();

      await onImageEditingComplete(bytes);

      if (mounted) loading.hide(context);

      onCloseEditor?.call();
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
    if (_isEditorOpen) {
      Navigator.pop(context);
      if (!_pageOpenCompleter.isCompleted) await _pageOpenCompleter.future;
      if (!mounted) return Uint8List.fromList([]);
    }

    double pixelRatio = imageGenerationConfigs.generateOnlyImageBounds
        ? _pixelRatio
        : max(_pixelRatio, MediaQuery.of(context).devicePixelRatio);

    return await _controllers.screenshot.captureFinalScreenshot(
          pixelRatio: pixelRatio,
          backgroundScreenshot: _stateManager.position > 0
              ? _stateManager.activeScreenshot
              : null,
          originalImageBytes: _stateManager.position > 0
              ? null
              : await _image.safeByteArray(context),
        ) ??
        Uint8List.fromList([]);
  }

  /// Close the image editor.
  ///
  /// This function allows the user to close the image editor without saving any changes or edits.
  /// It navigates back to the previous screen or closes the modal editor.
  void closeEditor() {
    if (_stateManager.position <= 0) {
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
    _openDialog = true;

    bool close = false;

    if (customWidgets.closeWarningDialog != null) {
      close = await customWidgets.closeWarningDialog!();
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
                  _stateManager.position = 0;
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
    if (import.configs.recalculateSizeAndPosition) {
      var imgSize = import.imgSize;
      for (var el in import.stateHistory) {
        for (var layer in el.layers) {
          // Calculate scaling factors for width and height
          double scaleWidth =
              _sizesManager.decodedImageSize.width / imgSize.width;
          double scaleHeight =
              _sizesManager.decodedImageSize.height / imgSize.height;

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
      }
    }

    if (import.configs.mergeMode == ImportEditorMergeMode.replace) {
      _stateManager.position = import.editorPosition + 1;
      _stateManager.stateHistory = [
        EditorStateHistory(
          transformConfigs: TransformConfigs.empty(),
          blur: BlurStateHistory(),
          filters: [],
          layers: [],
        ),
        ...import.stateHistory
      ];
      for (var i = 0; i < import.stateHistory.length; i++) {
        if (i < import.stateHistory.length - 1) {
          _controllers.screenshot.isolateAddEmptyScreenshot(
              screenshots: _stateManager.screenshots);
        } else {
          _takeScreenshot();
        }
      }
    } else {
      for (var el in import.stateHistory) {
        if (import.configs.mergeMode == ImportEditorMergeMode.merge) {
          el.layers.insertAll(0, stateHistory.last.layers);
          el.filters.insertAll(0, stateHistory.last.filters);
        }
      }

      for (var i = 0; i < import.stateHistory.length; i++) {
        stateHistory.add(import.stateHistory[i]);
        if (i < import.stateHistory.length - 1) {
          _controllers.screenshot.isolateAddEmptyScreenshot(
              screenshots: _stateManager.screenshots);
        } else {
          _takeScreenshot();
        }
      }
      _stateManager.position = stateHistory.length - 1;
    }

    setState(() {});
    onUpdateUI?.call();
  }

  /// Exports the current state history.
  ///
  /// `configs` specifies the export configurations, such as whether to include filters or layers.
  ///
  /// Returns an [ExportStateHistory] object containing the exported state history, image state history, image size, edit position, and export configurations.
  ExportStateHistory exportStateHistory(
      {ExportEditorConfigs configs = const ExportEditorConfigs()}) {
    return ExportStateHistory(
      _stateManager.stateHistory,
      _sizesManager.decodedImageSize,
      _stateManager.position,
      configs: configs,
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

    return Constants(
      child: PopScope(
        canPop: _stateManager.position <= 0 || _doneEditing,
        onPopInvoked: (didPop) {
          if (_stateManager.position > 0 && !_doneEditing) {
            closeWarning();
          }
        },
        child: ScreenResizeDetector(
          ignoreSafeArea: true,
          onResizeUpdate: (event) {
            _sizesManager.recalculateLayerPosition(
              history: _stateManager.stateHistory,
              resizeEvent: ResizeEvent(
                oldContentSize: Size(
                  event.oldContentSize.width,
                  event.oldContentSize.height - _sizesManager.allToolbarHeight,
                ),
                newContentSize: Size(
                  event.newContentSize.width,
                  event.newContentSize.height - _sizesManager.allToolbarHeight,
                ),
              ),
            );
            _sizesManager.lastScreenSize = event.newContentSize;
          },
          onResizeEnd: (event) async {
            await _decodeImage();
          },
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: imageEditorTheme.uiOverlayStyle,
            child: Theme(
              data: _theme,
              child: SafeArea(
                child: LayoutBuilder(builder: (context, constraints) {
                  _sizesManager.editorSize = constraints.biggest;
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
    return _selectedLayerIndex >= 0
        ? null
        : customWidgets.appBar ??
            (imageEditorTheme.editorMode == ThemeEditorMode.simple
                ? AppBar(
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
                        key: const ValueKey('MainEditorMainUndoButton'),
                        tooltip: i18n.undo,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        icon: Icon(
                          icons.undoAction,
                          color: _stateManager.position > 0
                              ? imageEditorTheme.appBarForegroundColor
                              : imageEditorTheme.appBarForegroundColor
                                  .withAlpha(80),
                        ),
                        onPressed: undoAction,
                      ),
                      IconButton(
                        key: const ValueKey('MainEditorMainRedoButton'),
                        tooltip: i18n.redo,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        icon: Icon(
                          icons.redoAction,
                          color:
                              _stateManager.position < stateHistory.length - 1
                                  ? imageEditorTheme.appBarForegroundColor
                                  : imageEditorTheme.appBarForegroundColor
                                      .withAlpha(80),
                        ),
                        onPressed: redoAction,
                      ),
                      IconButton(
                        key: const ValueKey('MainEditorMainDoneButton'),
                        tooltip: i18n.done,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        icon: Icon(icons.doneIcon),
                        iconSize: 28,
                        onPressed: doneEditing,
                      ),
                    ],
                  )
                : null);
  }

  Widget _buildBody() {
    return LayoutBuilder(builder: (context, constraints) {
      _sizesManager.bodySize = constraints.biggest;
      return Listener(
        behavior: HitTestBehavior.translucent,
        onPointerSignal: isDesktop && _activeLayer != null
            ? (event) {
                if (_activeLayer == null) return;
                _desktopInteractionManager.mouseScroll(
                  event,
                  activeLayer: _activeLayer!,
                  selectedLayerIndex: _selectedLayerIndex,
                );
              }
            : null,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (_layerInteractionManager.selectedLayerId.isNotEmpty) {
              _layerInteractionManager.selectedLayerId = '';
              setState(() {});
            }
          },
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          child: imageEditorTheme.editorMode == ThemeEditorMode.simple
              ? _buildInteractiveContent()
              : Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  clipBehavior: Clip.none,
                  children: [
                    Transform.scale(
                      transformHitTests: false,
                      scale: 1 /
                          constraints.maxHeight *
                          (constraints.maxHeight -
                              _whatsAppHelper.filterShowHelper * 2),
                      child: _buildInteractiveContent(),
                    ),
                    if (_selectedLayerIndex < 0) ..._buildWhatsAppWidgets(),
                  ],
                ),
        ),
      );
    });
  }

  Widget _buildInteractiveContent() {
    return Center(
      child: ContentRecorder(
        controller: _controllers.screenshot,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            /// Build Image
            _buildImageWithFilter(),

            /// Build layer stack
            _buildLayers(),

            /// Build helper stuff
            if (!_doneEditing) ...[
              _buildHelperLines(),
              if (_selectedLayerIndex >= 0) _buildRemoveIcon(),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildWhatsAppWidgets() {
    double opacity =
        max(0, min(1, 1 - 1 / 120 * _whatsAppHelper.filterShowHelper));
    return [
      WhatsAppAppBar(
        configs: widget.configs,
        onClose: closeEditor,
        onTapCropRotateEditor: openCropRotateEditor,
        onTapStickerEditor: openWhatsAppStickerEditor,
        onTapPaintEditor: openPaintingEditor,
        onTapTextEditor: openTextEditor,
        onTapUndo: undoAction,
        canUndo: canUndo,
        openEditor: _isEditorOpen,
      ),
      if (designMode == ImageEditorDesignModeE.material)
        WhatsAppFilterBtn(
          configs: widget.configs,
          opacity: opacity,
        ),
      if (customWidgets.whatsAppBottomWidget != null)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: opacity,
            child: customWidgets.whatsAppBottomWidget!,
          ),
        ),
      Positioned(
        left: 0,
        right: 0,
        bottom: -120 + _whatsAppHelper.filterShowHelper,
        child: Opacity(
          opacity: max(0, min(1, 1 / 120 * _whatsAppHelper.filterShowHelper)),
          child: Container(
            margin: const EdgeInsets.only(top: 7),
            color: imageEditorTheme.filterEditor.whatsAppBottomBarColor,
            child: FilterEditorItemList(
              mainBodySize: _sizesManager.bodySize,
              mainImageSize: _sizesManager.decodedImageSize,
              transformConfigs: _stateManager.transformConfigs,
              itemScaleFactor:
                  max(0, min(1, 1 / 120 * _whatsAppHelper.filterShowHelper)),
              byteArray: widget.byteArray,
              file: widget.file,
              assetPath: widget.assetPath,
              networkUrl: widget.networkUrl,
              blurFactor: _stateManager.activeBlur.blur,
              activeFilters: _stateManager.activeFilters,
              configs: widget.configs,
              selectedFilter: _stateManager.activeFilters.isNotEmpty
                  ? _stateManager.activeFilters.first.filter
                  : PresetFilters.none,
              onSelectFilter: (filter) {
                _addHistory(filters: [
                  FilterStateHistory(
                    filter: filter,
                    opacity: 1,
                  ),
                ]);

                setState(() {});
                onUpdateUI?.call();
              },
            ),
          ),
        ),
      ),
    ];
  }

  Widget? _buildBottomNavBar() {
    var bottomTextStyle = const TextStyle(fontSize: 10.0, color: Colors.white);
    double bottomIconSize = 22.0;

    return _selectedLayerIndex >= 0
        ? null
        : customWidgets.bottomNavigationBar ??
            (imageEditorTheme.editorMode == ThemeEditorMode.simple
                ? LayoutBuilder(builder: (context, constraints) {
                    return Theme(
                      data: _theme,
                      child: Scrollbar(
                        controller: _controllers.bottomBarScroll,
                        scrollbarOrientation: ScrollbarOrientation.top,
                        thickness: isDesktop ? null : 0,
                        child: BottomAppBar(
                          height: _sizesManager.bottomBarHeight,
                          color: imageEditorTheme.bottomBarBackgroundColor,
                          padding: EdgeInsets.zero,
                          child: Center(
                            child: SingleChildScrollView(
                              controller: _controllers.bottomBarScroll,
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: min(
                                      _sizesManager.lastScreenSize.width != 0
                                          ? _sizesManager.lastScreenSize.width
                                          : constraints.maxWidth,
                                      600),
                                  maxWidth: 600,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                          key: const ValueKey(
                                              'open-text-editor-btn'),
                                          label: Text(
                                              i18n.textEditor
                                                  .bottomNavigationBarText,
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
                                          key: const ValueKey(
                                              'open-blur-editor-btn'),
                                          label: Text(
                                              i18n.blurEditor
                                                  .bottomNavigationBarText,
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
                                          key: const ValueKey(
                                              'open-emoji-editor-btn'),
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
                  })
                : null);
  }

  Widget _buildLayers() {
    return IgnorePointer(
      ignoring: _selectedLayerIndex >= 0,
      child: StreamBuilder<bool>(
          stream: _controllers.layerHeroResetCtrl.stream,
          initialData: false,
          builder: (context, resetLayerSnapshot) {
            if (resetLayerSnapshot.data!) return Container();

            return StreamBuilder<Object>(
                stream: _controllers.mouseMoveStream.stream,
                initialData: false,
                builder: (context, snapshot) {
                  return MouseRegion(
                    cursor: snapshot.data != true
                        ? SystemMouseCursors.basic
                        : imageEditorTheme.layerInteraction.hoverCursor,
                    onHover: isDesktop
                        ? (event) {
                            var hasHit = activeLayers.indexWhere((element) =>
                                    element is PaintingLayerData &&
                                    element.item.hit) >=
                                0;
                            if (hasHit != snapshot.data) {
                              _controllers.mouseMoveStream.add(hasHit);
                            }
                          }
                        : null,
                    child: DeferredPointerHandler(
                      child: StreamBuilder(
                          stream: _controllers.uiLayerStream.stream,
                          builder: (context, snapshot) {
                            return Stack(
                              children:
                                  activeLayers.asMap().entries.map((entry) {
                                final int i = entry.key;
                                final Layer layerItem = entry.value;
                                return LayerWidget(
                                  key: ValueKey('${layerItem.id}-$i'),
                                  configs: configs,
                                  editorBodySize: _sizesManager.bodySize,
                                  layerData: layerItem,
                                  enableHitDetection: _layerInteractionManager
                                      .enabledHitDetection,
                                  selected: _layerInteractionManager
                                          .selectedLayerId ==
                                      layerItem.id,
                                  isInteractive: !_isEditorOpen,
                                  highPerformanceMode: _layerInteractionManager
                                          .freeStyleHighPerformanceScaling ||
                                      _layerInteractionManager
                                          .freeStyleHighPerformanceMoving ||
                                      _layerInteractionManager
                                          .freeStyleHighPerformanceHero,
                                  onEditTap: () {
                                    if (layerItem is TextLayerData) {
                                      _onTextLayerTap(layerItem);
                                    }
                                  },
                                  onTap: (layer) async {
                                    if (_layerInteractionManager
                                        .layersAreSelectable(configs)) {
                                      _layerInteractionManager.selectedLayerId =
                                          layer.id ==
                                                  _layerInteractionManager
                                                      .selectedLayerId
                                              ? ''
                                              : layer.id;
                                    } else if (layer is TextLayerData) {
                                      _onTextLayerTap(layer);
                                    }
                                  },
                                  onTapUp: () {
                                    if (_layerInteractionManager
                                        .hoverRemoveBtn) {
                                      removeLayer(
                                        activeLayers.indexWhere((element) =>
                                            element.id == layerItem.id),
                                        layer: layerItem,
                                      );
                                    }
                                    _controllers.uiLayerStream.add(null);
                                    onUpdateUI?.call();
                                    _selectedLayerIndex = -1;
                                  },
                                  onTapDown: () {
                                    _selectedLayerIndex = i;
                                    _setTempLayer(layerItem);
                                  },
                                  onScaleRotateDown:
                                      (details, layerOriginalSize) {
                                    _selectedLayerIndex = i;
                                    _layerInteractionManager
                                            .rotateScaleLayerSizeHelper =
                                        layerOriginalSize;
                                    _layerInteractionManager
                                            .rotateScaleLayerScaleHelper =
                                        layerItem.scale;
                                  },
                                  onScaleRotateUp: (details) {
                                    _layerInteractionManager
                                        .rotateScaleLayerSizeHelper = null;
                                    _layerInteractionManager
                                        .rotateScaleLayerScaleHelper = null;
                                    setState(() {
                                      _selectedLayerIndex = -1;
                                    });
                                    onUpdateUI?.call();
                                  },
                                  onRemoveTap: () {
                                    setState(() {
                                      removeLayer(
                                        activeLayers.indexWhere((element) =>
                                            element.id == layerItem.id),
                                        layer: layerItem,
                                      );
                                    });
                                    onUpdateUI?.call();
                                  },
                                );
                              }).toList(),
                            );
                          }),
                    ),
                  );
                });
          }),
    );
  }

  Widget _buildHelperLines() {
    double screenH = _sizesManager.screen.height;
    double screenW = _sizesManager.screen.width;
    double lineH = 1.25;
    int duration = 100;
    if (!_layerInteractionManager.showHelperLines) {
      return const SizedBox.shrink();
    }
    return StreamBuilder(
        stream: _controllers.uiLayerStream.stream,
        builder: (context, snapshot) {
          return Stack(
            children: [
              if (helperLines.showVerticalLine)
                Align(
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: duration),
                    width: _layerInteractionManager.showVerticalHelperLine
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
                    duration: Duration(milliseconds: duration),
                    width: screenW,
                    height: _layerInteractionManager.showHorizontalHelperLine
                        ? lineH
                        : 0,
                    color: imageEditorTheme.helperLine.horizontalColor,
                  ),
                ),
              if (helperLines.showRotateLine)
                Positioned(
                  left: _layerInteractionManager.rotationHelperLineX,
                  top: _layerInteractionManager.rotationHelperLineY,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, -0.5),
                    child: Transform.rotate(
                      angle: _layerInteractionManager.rotationHelperLineDeg,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: duration),
                        width: _layerInteractionManager.showRotationHelperLine
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
        });
  }

  Widget _buildRemoveIcon() {
    return customWidgets.removeLayer ??
        Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
            bottom: false,
            child: StreamBuilder(
                stream: _controllers.uiLayerStream.stream,
                builder: (context, snapshot) {
                  return Container(
                    height: kToolbarHeight,
                    width: kToolbarHeight,
                    decoration: BoxDecoration(
                      color: _layerInteractionManager.hoverRemoveBtn
                          ? Colors.red
                          : (imageEditorTheme.editorMode ==
                                  ThemeEditorMode.simple
                              ? Colors.grey.shade800
                              : Colors.black12),
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

  Widget _buildImageWithFilter() {
    return Container(
      padding: _selectedLayerIndex >= 0
          ? EdgeInsets.only(
              top: _sizesManager.appBarHeight,
              bottom: _sizesManager.bottomBarHeight)
          : EdgeInsets.zero,
      child: Hero(
        tag: !_inited ? '--' : heroTag,
        createRectTween: (begin, end) => RectTween(begin: begin, end: end),
        child: !_inited
            ? AutoImage(
                _image,
                fit: BoxFit.contain,
                width: _sizesManager.decodedImageSize.width,
                height: _sizesManager.decodedImageSize.height,
                designMode: designMode,
              )
            : TransformedContentGenerator(
                transformConfigs: _stateManager.transformConfigs,
                configs: configs,
                child: ImageWithFilters(
                  width: _sizesManager.decodedImageSize.width,
                  height: _sizesManager.decodedImageSize.height,
                  designMode: designMode,
                  image: _image,
                  filters: _stateManager.activeFilters,
                  blurFactor: _stateManager.activeBlur.blur,
                ),
              ),
      ),
    );
  }
}
