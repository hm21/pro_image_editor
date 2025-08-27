import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/core/constants/editor_various_constants.dart';
import '/core/mixins/converted_configs.dart';
import '/core/mixins/editor_callbacks_mixin.dart';
import '/core/mixins/editor_configs_mixin.dart';
import '/core/models/styles/draggable_sheet_style.dart';
import '/core/services/gesture_manager.dart';
import '/core/services/mouse_service.dart';
import '/features/main_editor/widgets/main_editor_appbar.dart';
import '/features/main_editor/widgets/main_editor_background_image.dart';
import '/features/main_editor/widgets/main_editor_background_video.dart';
import '/features/main_editor/widgets/main_editor_bottombar.dart';
import '/features/main_editor/widgets/main_editor_helper_lines.dart';
import '/features/main_editor/widgets/main_editor_layers.dart';
import '/features/main_editor/widgets/main_editor_remove_layer_area.dart';
import '/pro_image_editor.dart';
import '/shared/mixins/editor_zoom.mixin.dart';
import '/shared/services/content_recorder/widgets/content_recorder.dart';
import '/shared/services/import_export/export_state_history.dart';
import '/shared/services/layer_transform_generator.dart';
import '/shared/utils/file_constructor_utils.dart';
import '/shared/widgets/adaptive_dialog.dart';
import '/shared/widgets/extended/interactive_viewer/extended_interactive_viewer.dart';
import '/shared/widgets/screen_resize_detector.dart';
import '../filter_editor/types/filter_matrix.dart';
import '../filter_editor/widgets/filter_generator.dart';
import '../paint_editor/models/paint_editor_response_model.dart';
import '../paint_editor/widgets/paint_editor_layer_editor.dart';
import 'controllers/main_editor_controllers.dart';
import 'mixins/main_editor_global_keys.dart';
import 'providers/image_infos_provider.dart';
import 'services/desktop_interaction_manager.dart';
import 'services/layer_copy_manager.dart';
import 'services/layer_drag_selection_service.dart';
import 'services/layer_interaction_manager.dart';
import 'services/main_editor_state_history_service.dart';
import 'services/sizes_manager.dart';
import 'widgets/main_editor_interactive_content.dart';

/// A widget for image editing using ProImageEditor.
///
/// `ProImageEditor` provides a versatile image editing widget for Flutter
/// applications.
/// It allows you to edit images from various sources like memory, files,
/// assets, or network URLs.
///
/// You can use one of the specific constructors, such as `memory`, `file`,
/// `asset`, or `network`,
/// to create an instance of this widget based on your image source.
/// Additionally, you can provide
/// custom configuration settings through the `configs` parameter.
///
/// Example usage:
///
/// ```dart
/// ProImageEditor.memory(Uint8List.fromList(imageBytes));
/// ProImageEditor.file(File('path/to/image.jpg'));
/// ProImageEditor.file('path/to/image.jpg');
/// ProImageEditor.asset('assets/images/image.png');
/// ProImageEditor.network('https://example.com/image.jpg');
/// ```
///
/// To handle image editing, you can use the callbacks provided by the
/// `EditorConfigs` instance
/// passed through the `configs` parameter.
///
/// See also:
/// - [ProImageEditorConfigs] for configuring image editing options.
/// - [ProImageEditorCallbacks] for callbacks.
class ProImageEditor extends StatefulWidget
    with SimpleConfigsAccess, SimpleCallbacksAccess {
  /// Creates a `ProImageEditor` widget for image editing.
  ///
  /// Use one of the specific constructors like `memory`, `file`, `asset`, or
  /// `network`
  /// to create an instance of this widget based on your image source.
  ///
  /// {@template mainEditorConfigs}
  /// The `key` parameter is an optional parameter used to provide a `Key` to
  /// the widget for identification and state preservation.
  ///
  /// The `configs` parameter allows you to customize the image editing
  /// experience by providing various configuration options. If not specified,
  /// default settings will be used.
  ///
  /// The `callbacks` parameter is required and specifies the callbacks to
  /// handle events and interactions within the image editor.
  /// {@endtemplate}
  const ProImageEditor._({
    super.key,
    required this.callbacks,
    this.editorImage,
    this.videoController,
    this.configs = const ProImageEditorConfigs(),
  }) : assert(
          editorImage != null || videoController != null,
          'Either editorImage or videoController must be provided.',
        );

  /// This constructor creates a `ProImageEditor` widget configured to edit an
  /// image loaded from the specified `byteArray`.
  ///
  /// The `byteArray` parameter should contain the image data as a `Uint8List`.
  ///
  /// {@macro mainEditorConfigs}
  ///
  /// Example usage:
  /// ```dart
  /// ProImageEditor.memory(
  ///   bytes,
  /// {@template mainEditorDemoTemplateCode}
  ///   configs: ProImageEditorConfigs(),
  ///   callbacks: ProImageEditorCallbacks(
  ///      onImageEditingComplete: (Uint8List bytes) async {
  ///        /*
  ///          `Your code to handle the edited image. Upload it to your server
  ///           as an example.
  ///
  ///           You can choose to use await, so that the load dialog remains
  ///           visible until your code is ready,
  ///           or no async, so that the load dialog closes immediately.
  ///        */
  ///        Navigator.pop(context);
  ///      },
  ///   ),
  /// {@endtemplate}
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
      editorImage: EditorImage(byteArray: byteArray),
      configs: configs,
      callbacks: callbacks,
    );
  }

  /// This constructor creates a `ProImageEditor` widget configured to edit an
  /// image loaded from the specified `file`.
  ///
  /// The `file` parameter should be from the type `File` or the path to the
  /// file.
  ///
  /// {@macro mainEditorConfigs}
  ///
  /// Example usage:
  /// ```dart
  /// ProImageEditor.file(
  ///   File(pathToMyFile),
  ///   {@macro mainEditorDemoTemplateCode}
  /// )
  /// ```
  factory ProImageEditor.file(
    dynamic file, {
    Key? key,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    required ProImageEditorCallbacks callbacks,
  }) {
    return ProImageEditor._(
      key: key,
      editorImage: EditorImage(file: ensureFileInstance(file)),
      configs: configs,
      callbacks: callbacks,
    );
  }

  /// This constructor creates a `ProImageEditor` widget configured to edit an
  /// image loaded from the specified `assetPath`.
  ///
  /// The `assetPath` parameter should specify the path to the image asset.
  ///
  /// {@macro mainEditorConfigs}
  ///
  /// Example usage:
  /// ```dart
  /// ProImageEditor.asset(
  ///   'assets/demo.png',
  ///   {@macro mainEditorDemoTemplateCode}
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
      editorImage: EditorImage(assetPath: assetPath),
      configs: configs,
      callbacks: callbacks,
    );
  }

  /// This constructor creates a `ProImageEditor` widget configured to edit an
  /// image loaded from the specified `networkUrl`.
  ///
  /// The `networkUrl` parameter specifies the URL from which the image will be
  /// loaded.
  ///
  /// {@macro mainEditorConfigs}
  ///
  /// Example usage:
  /// ```dart
  /// ProImageEditor.network(
  ///   'https://example.com/image.jpg',
  ///   {@macro mainEditorDemoTemplateCode}
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
      editorImage: EditorImage(networkUrl: networkUrl),
      configs: configs,
      callbacks: callbacks,
    );
  }

  /// Creates a `ProImageEditor` instance by automatically determining the
  /// image source.
  ///
  /// This factory constructor intelligently selects the appropriate image
  /// loading method based on the provided parameters. It allows for seamless
  /// integration without requiring users to manually specify whether the image
  /// is from memory, a file, a network URL, or an asset.
  ///
  /// The selection is based on the first non-null parameter in the following
  /// order of priority:
  /// 1. `byteArray` (raw image data in memory)
  /// 2. `file` (local file system)
  /// 3. `networkUrl` (image from a remote URL)
  /// 4. `assetPath` (image stored as an app asset)
  ///
  /// Additionally, an `EditorImage` instance can be provided, which may contain
  /// any of the above sources, and will be processed in the same priority
  /// order.
  ///
  /// {@macro mainEditorConfigs}
  ///
  /// Example usage:
  /// ```dart
  /// ProImageEditor.autoSource(
  ///   byteArray: imageData,
  ///   callbacks: editorCallbacks,
  ///   configs: ProImageEditorConfigs(),
  /// )
  ///
  /// ProImageEditor.autoSource(
  ///   file: File('path/to/image.jpg'),
  ///   callbacks: editorCallbacks,
  /// )
  ///
  /// ProImageEditor.autoSource(
  ///   networkUrl: 'https://example.com/image.jpg',
  ///   callbacks: editorCallbacks,
  /// )
  ///
  /// ProImageEditor.autoSource(
  ///   assetPath: 'assets/images/sample.jpg',
  ///   callbacks: editorCallbacks,
  /// )
  ///
  /// ProImageEditor.autoSource(
  ///   editorImage: EditorImage(file: File('path/to/image.jpg')),
  ///   callbacks: editorCallbacks,
  /// )
  /// ```
  ///
  /// Throws an [ArgumentError] if no valid image source is provided.
  ///
  /// - [byteArray] - Raw image data as a `Uint8List` (highest priority).
  /// - [file] - A `File` instance representing a local image file.
  /// - [networkUrl] - URL pointing to an image on the internet.
  /// - [assetPath] - Path to an image stored in the app's assets.
  /// - [editorImage] - An `EditorImage` instance containing one of the above.
  /// - [configs] - Optional configuration settings for the editor.
  /// - [callbacks] - Required callbacks for handling image editor events.
  factory ProImageEditor.autoSource({
    Key? key,
    Uint8List? byteArray,
    dynamic file,
    String? assetPath,
    String? networkUrl,
    EditorImage? editorImage,
    ProVideoController? videoController,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    required ProImageEditorCallbacks callbacks,
  }) {
    return ProImageEditor._(
      key: key,
      editorImage: editorImage ??
          EditorImage(
            byteArray: byteArray,
            file: file,
            networkUrl: networkUrl,
            assetPath: assetPath,
          ),
      videoController: videoController,
      configs: configs,
      callbacks: callbacks,
    );
  }

  /// This constructor creates a `ProImageEditor` widget configured to edit an
  /// video.
  ///
  /// {@macro mainEditorConfigs}
  ///
  /// Example usage:
  ///
  /// - [Example with video_player](https://github.com/hm21/pro_image_editor/blob/stable/example/lib/features/video_examples/pages/video_player_example.dart)
  /// - [Example with media_kit](https://github.com/hm21/pro_image_editor/blob/stable/example/lib/features/video_examples/pages/video_media_kit_example.dart)
  /// - [Example with chewie_player](https://github.com/hm21/pro_image_editor/blob/stable/example/lib/features/video_examples/pages/chewie_player_example.dart)
  /// - [Example with flick_video_player](https://github.com/hm21/pro_image_editor/blob/stable/example/lib/features/video_examples/pages/flick_video_player_example.dart)
  factory ProImageEditor.video(
    ProVideoController videoController, {
    Key? key,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    required ProImageEditorCallbacks callbacks,
  }) {
    return ProImageEditor._(
      key: key,
      videoController: videoController,
      configs: configs,
      callbacks: callbacks,
    );
  }

  @override
  final ProImageEditorConfigs configs;
  @override
  final ProImageEditorCallbacks callbacks;

  /// The image being edited in the editor.
  final EditorImage? editorImage;

  /// The controller for the video editor.
  final ProVideoController? videoController;

  @override
  State<ProImageEditor> createState() => ProImageEditorState();
}

/// State class for the ProImageEditor widget, handling configurations
/// and user interactions for image editing.
class ProImageEditorState extends State<ProImageEditor>
    with
        ImageEditorConvertedConfigs,
        SimpleConfigsAccessState,
        SimpleCallbacksAccessState,
        MainEditorGlobalKeys,
        EditorZoomMixin {
  final _bottomBarKey = GlobalKey();
  final _removeAreaKey = GlobalKey();
  final _backgroundImageColorFilterKey = GlobalKey<ColorFilterGeneratorState>();
  @override
  final interactiveViewer = GlobalKey<ExtendedInteractiveViewerState>();
  late final StreamController<void> _rebuildController;

  /// Helper class for managing sizes and layout calculations.
  late final SizesManager sizesManager;

  /// Manager class for handling desktop interactions in the image editor.
  late final DesktopInteractionManager _desktopInteractionManager;

  /// Manager class to copy layers.
  final LayerCopyManager _layerCopyManager = LayerCopyManager();

  /// Helper class for managing interactions with layers in the editor.
  late final LayerInteractionManager layerInteractionManager =
      LayerInteractionManager(
    onSelectedLayerChanged: mainEditorCallbacks?.onSelectedLayerChanged,
    onSelectedLayersChanged: mainEditorCallbacks?.onSelectedLayersChanged,
    helperLinesCallbacks: mainEditorCallbacks?.helperLines,
    configs: configs,
  );
  late final _mouseService = MouseService(
    configs: configs,
    interactionManager: layerInteractionManager,
  );

  /// Manager class for managing the state of the editor.
  late final StateManager stateManager = StateManager(
    activeBackgroundImage: widget.editorImage,
    onStateHistoryChange: () =>
        mainEditorCallbacks?.onStateHistoryChange?.call(stateManager, this),
  );

  late final _stateHistoryService = MainEditorStateHistoryService(
    sizesManager: sizesManager,
    stateManager: stateManager,
    controllers: _controllers,
    configs: configs,
    mainEditorCallbacks: mainEditorCallbacks,
    takeScreenshot: _takeScreenshot,
  );

  /// Controller instances for managing various aspects of the main editor.
  late final MainEditorControllers _controllers;

  late final _layerDragSelectionService = LayerDragSelectionService(
    layerInteractionManager: layerInteractionManager,
    activeLayers: () => activeLayers,
    bodySize: () => sizesManager.bodySize,
    configs: configs,
    onUpdateLayers: () => _controllers.uiLayerCtrl.add(null),
    interactiveViewer: () => interactiveViewer.currentState,
  );

  /// The current theme used by the image editor.
  late ThemeData _theme;

  /// Flag indicating if the editor has been initialized.
  bool _isInitialized = false;

  /// Flag indicating if the image needs decoding.
  bool _isImageNotDecoded = true;

  /// Flag to track if editing is completed.
  bool _isProcessingFinalImage = false;

  /// The pixel ratio of the device's screen.
  ImageInfos? _imageInfos;

  /// Indicates whether a sub-editor is currently open.
  bool isSubEditorOpen = false;

  /// Indicates whether a sub-editor is in the process of closing.
  bool isSubEditorClosing = false;

  /// Whether a dialog is currently open.
  bool _isDialogOpen = false;

  /// Whether a context menu is currently open.
  bool _isContextMenuOpen = false;

  /// Indicates whether the `onScaleUpdate` function can be triggered to
  /// interact with the layers.
  bool blockOnScaleUpdateFunction = false;

  /// Indicates whether the browser's context menu was enabled before any
  /// changes.
  bool _browserContextMenuBeforeEnabled = false;

  /// Indicates whether PopScope is disabled.
  bool isPopScopeDisabled = false;

  bool _isVideoPlayerReady = true;

  /// Whether a layer is currently being transformed
  /// (e.g., moved, scaled, or rotated).
  bool isLayerBeingTransformed = false;

  /// Returns `true` if one or more layers are currently selected.
  bool get hasSelectedLayers => layerInteractionManager.hasSelectedLayers;

  /// Returns the most recently selected layer, or `null` if no layer is
  /// selected.
  Layer? get selectedLayer => hasSelectedLayers
      ? activeLayers.lastWhere(
          (layer) =>
              layerInteractionManager.selectedLayerIds.contains(layer.id),
        )
      : null;

  /// Returns a list of all currently selected layers.
  List<Layer> get selectedLayers => activeLayers
      .where(
        (layer) => layerInteractionManager.selectedLayerIds.contains(layer.id),
      )
      .toList();

  /// Get the list of layers from the current image editor changes.
  List<Layer> get activeLayers => stateManager.activeLayers;

  /// List to store the history of image editor changes.
  List<EditorStateHistory> get stateHistory => stateManager.stateHistory;

  /// Determines whether undo actions can be performed on the current state.
  bool get canUndo => stateManager.canUndo;

  /// Determines whether redo actions can be performed on the current state.
  bool get canRedo => stateManager.canRedo;

  /// Indicates whether video editor is enabled.
  late final bool _isVideoEditor = widget.videoController != null;

  /// Determines whether multi-select mode is always enabled.
  ///
  /// If set to `true`, multi-select mode will be active without requiring
  /// the user to hold down CTRL/ SHIFT keys or long-press. This allows
  /// for easier selection of multiple items.
  bool get enableMultiSelectMode => _enableMultiSelectMode;
  bool _enableMultiSelectMode = false;
  set enableMultiSelectMode(bool value) {
    _enableMultiSelectMode = value;
    setState(() {});
  }

  /// Get the current background image.
  EditorImage? get editorImage => stateManager.activeBackgroundImage;

  /// A [Completer] used to track the completion of a page open operation.
  ///
  /// The completer is initialized and can be used to await the page open
  /// operation.
  Completer<bool> _pageOpenCompleter = Completer();

  /// A [Completer] used to track the completion of an image decoding operation.
  ///
  /// The completer is initialized and can be used to await the image
  /// decoding operation.
  final Completer<bool> _decodeImageCompleter = Completer();

  PointerEvent? _lastDownEvent;
  DateTime _tapDownTimestamp = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeVideoEditor();

    _rebuildController = StreamController.broadcast();
    _controllers = MainEditorControllers(configs, callbacks, _isVideoEditor);
    _desktopInteractionManager = DesktopInteractionManager(
      configs: configs,
      callbacks: callbacks,
      context: context,
      onUpdateUI: mainEditorCallbacks?.handleUpdateUI,
      setState: setState,
    );
    sizesManager = SizesManager(configs: configs, context: context);
    layerInteractionManager.scaleDebounce = Debounce(
      const Duration(milliseconds: 100),
    );

    /// For the case the user add transformConfigs we initialize the editor with
    /// this configurations and not the empty history
    if (mainEditorConfigs.transformSetup != null) {
      _initializeWithTransformations();
    } else {
      stateManager.addHistory(
        EditorStateHistory(
          transformConfigs: TransformConfigs.empty().copyWith(
            cropMode: cropRotateEditorConfigs.initialCropMode,
          ),
          blur: 0,
          layers: [],
          filters: [],
          tuneAdjustments: [],
        ),
      );
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
    SystemChrome.setSystemUIOverlayStyle(
      _theme.brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );
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
    if (mainEditorConfigs.canZoomWhenLayerSelected) return;
    interactiveViewer.currentState?.setEnableInteraction(!hasSelectedLayers);
  }

  /// Handle keyboard events
  bool _onKeyEvent(KeyEvent event) {
    return _desktopInteractionManager.onKey(
      event,
      selectedLayers: selectedLayers,
      onEscape: () {
        if (!_isDialogOpen && !_isContextMenuOpen) {
          if (isSubEditorOpen) {
            if (!mainEditorConfigs.style.subEditorPage.barrierDismissible) {
              if (cropRotateEditor.currentState != null) {
                // Important to close the crop-editor like that cuz we need to
                // set the fake hero first
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
        if (_isDialogOpen || isSubEditorOpen) return;

        undo ? undoAction() : redoAction();
      },
    );
  }

  /// Adds a new state to the history with the given configuration and updates
  /// the state manager.
  ///
  /// This method is responsible for capturing the current state of the editor,
  /// including layers, transformations, filters, and blur settings. It then
  /// adds this state to the history, enabling undo and redo functionality.
  /// Additionally, it can take a screenshot if required.
  ///
  /// - [layers]: An optional list of layers to be included in the new state.
  /// - [newLayer]: An optional new layer to be added to the current layers.
  /// - [transformConfigs]: Optional transformation configurations for the new
  /// state.
  /// - [filters]: An optional list of filter states to be included in the new
  /// state.
  /// - [tuneAdjustments]: An optional list of tune adjustments states to be
  /// included in the new state.
  /// - [blur]: An optional blur state to be included in the new state.
  /// - [heroScreenshotRequired]: A flag indicating whether a hero screenshot
  /// is required.
  ///
  /// Example usage:
  /// ```dart
  /// addHistory(
  ///   layers: currentLayers,
  ///   newLayer: additionalLayer,
  ///   transformConfigs: currentTransformConfigs,
  ///   filters: currentFilters,
  ///   tuneAdjustments: currentTuneAdjustments
  ///   blur: currentBlurState,
  ///   heroScreenshotRequired: false,
  /// );
  /// ```
  void addHistory({
    List<Layer>? layers,
    Layer? newLayer,
    TransformConfigs? transformConfigs,
    FilterMatrix? filters,
    List<TuneAdjustmentMatrix>? tuneAdjustments,
    double? blur,
    bool heroScreenshotRequired = false,
    bool blockCaptureScreenshot = false,
  }) {
    List<Layer> activeLayerList = _layerCopyManager.copyLayerList(activeLayers);

    stateManager.addHistory(
      EditorStateHistory(
        transformConfigs: transformConfigs,
        blur: blur,
        layers: layers ??
            (newLayer != null
                ? [...activeLayerList, newLayer]
                : activeLayerList),
        filters: filters ?? [],
        tuneAdjustments: tuneAdjustments ?? [],
      ),
      historyLimit: stateHistoryConfigs.stateHistoryLimit,
      enableScreenshotLimit: imageGenerationConfigs.enableBackgroundGeneration,
    );
    if (!blockCaptureScreenshot) {
      if (!heroScreenshotRequired) {
        _takeScreenshot();
      } else {
        stateManager.heroScreenshotRequired = true;
      }
    } else {
      _controllers.screenshot.addEmptyScreenshot(
        screenshots: stateManager.screenshots,
      );
    }
    setState(() {});
  }

  /// Replaces a layer at the specified index with a new layer.
  ///
  /// This method updates the current layer at the given [index] in the list of
  /// active layers with the specified [layer]. It also resets the
  /// `selectedLayerId` in the `layerInteractionManager` to an empty string,
  /// effectively deselecting any currently selected layer. Additionally, it
  /// adds the updated list of layers to the history, enabling undo/redo
  /// functionality, and triggers a UI update by sending a null event to the
  /// UI layer controller.
  ///
  /// This is useful when you need to modify an existing layer while maintaining
  /// the rest of the layer order and history tracking.
  ///
  /// Parameters:
  /// - [index]: The index of the layer to be replaced. Must be within the
  ///   bounds of the current list of active layers.
  /// - [layer]: The new `Layer` instance that will replace the existing layer
  ///   at the specified index.
  ///
  /// Example usage:
  /// ```dart
  /// replaceLayer(index: 2, layer: newLayer);
  /// ```
  void replaceLayer({required int index, required Layer layer}) {
    layerInteractionManager.clearSelectedLayers();

    addHistory(
      layers: _layerCopyManager.copyLayerList(activeLayers)
        ..removeAt(index)
        ..insert(index, layer),
    );

    _controllers.uiLayerCtrl.add(null);
  }

  /// Add a new layer to the image editor.
  ///
  /// This method adds a new layer to the image editor and updates the editing
  /// state.
  void addLayer(
    Layer layer, {
    int removeLayerIndex = -1,
    bool blockSelectLayer = false,
    bool blockCaptureScreenshot = false,
    bool autoCorrectZoomOffset = true,
    bool autoCorrectZoomScale = true,
  }) {
    void correctOffset() {
      Offset fractionalOffset = const Offset(-0.5, -0.5);
      if (layer.isTextLayer) {
        fractionalOffset = textEditorConfigs.layerFractionalOffset;
      } else if (layer.isEmojiLayer) {
        fractionalOffset = emojiEditorConfigs.layerFractionalOffset;
      } else if (layer.isPaintLayer) {
        fractionalOffset = paintEditorConfigs.layerFractionalOffset;
      } else if (layer.isWidgetLayer) {
        fractionalOffset = stickerEditorConfigs.layerFractionalOffset;
      }

      if (fractionalOffset != const Offset(-0.5, -0.5)) {
        final overlayPadding = layerInteraction.style.overlayPadding;
        double dxCorrected = 0;
        double dyCorrected = 0;

        if (fractionalOffset.dx == 0) {
          dxCorrected = -overlayPadding.left;
        } else if (fractionalOffset.dx == 1) {
          dxCorrected = overlayPadding.right;
        }
        if (fractionalOffset.dy == 0) {
          dyCorrected = -overlayPadding.top;
        } else if (fractionalOffset.dy == 1) {
          dyCorrected = overlayPadding.bottom;
        }

        layer.offset += Offset(dxCorrected, dyCorrected);
      }
    }

    correctOffset();

    final viewer = interactiveViewer.currentState;
    if (viewer != null) {
      final scaleDelta = viewer.scaleFactor;

      if (autoCorrectZoomScale) {
        layer.scale /= scaleDelta;
      }
      if (autoCorrectZoomOffset) {
        final bodySize = sizesManager.bodySize;

        final scaledSize = bodySize * scaleDelta;

        final zoomOffset = Offset(
              scaledSize.width - bodySize.width,
              scaledSize.height - bodySize.height,
            ) /
            2;

        layer.offset -= (viewer.offset + zoomOffset) / viewer.scaleFactor;
      }
    }

    addHistory(newLayer: layer, blockCaptureScreenshot: blockCaptureScreenshot);

    if (removeLayerIndex >= 0) {
      activeLayers.removeAt(removeLayerIndex);
    }
    if (!blockSelectLayer && layer.interaction.enableSelection) {
      layerInteractionManager.addSelectedLayer(layer.id);
    }
    _checkInteractiveViewer();

    mainEditorCallbacks?.handleAddLayer(layer);
    setState(() {});
  }

  /// Remove a layer from the editor.
  ///
  /// This method removes a layer from the editor and updates the editing state.
  void removeLayer(Layer layer, {bool blockCaptureScreenshot = false}) {
    int layerPos = activeLayers.indexOf(layer);
    if (layerPos < 0) return;

    mainEditorCallbacks?.handleRemoveLayer(layer);

    var layers = _layerCopyManager.copyLayerList(activeLayers)
      ..removeAt(layerPos);

    addHistory(layers: layers, blockCaptureScreenshot: blockCaptureScreenshot);
    setState(() {});
  }

  /// Remove all layers from the editor.
  ///
  /// This method removes all layers from the editor and updates the editing
  /// state.
  void removeAllLayers() {
    addHistory(layers: []);
    setState(() {});
  }

  void _initializeVideoEditor() async {
    if (!_isVideoEditor) return;

    _isVideoPlayerReady = false;
    Future<Uint8List> createTransparentImage(
      double width,
      double height,
    ) async {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));
      final paint = Paint()..color = const ui.Color.fromARGB(0, 0, 0, 0);
      canvas.drawRect(Rect.fromLTWH(0.0, 0.0, width, height), paint);

      final picture = recorder.endRecording();
      final img = await picture.toImage(width.toInt(), height.toInt());
      final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

      return pngBytes!.buffer.asUint8List();
    }

    widget.videoController!.initialize(
      configsFunction: () => configs.videoEditor,
      callbacksFunction: () =>
          callbacks.videoEditorCallbacks ?? VideoEditorCallbacks(),
    );

    final resolution = widget.videoController!.initialResolution;
    stateManager.activeBackgroundImage = EditorImage(
      byteArray: await createTransparentImage(
        resolution.width,
        resolution.height,
      ),
    );
    _isVideoPlayerReady = true;

    if (!mounted) return;

    setState(() {});
    await decodeImage();
  }

  void _initializeWithTransformations() {
    var transformSetup = mainEditorConfigs.transformSetup!;

    /// Add the initial history
    stateManager.addHistory(
      EditorStateHistory(
        transformConfigs: transformSetup.transformConfigs,
        blur: 0,
        layers: [],
        filters: [],
        tuneAdjustments: [],
      ),
    );

    /// Set the decoded image infos for the case they are not empty
    if (transformSetup.imageInfos != null) {
      _imageInfos = transformSetup.imageInfos!;
      decodeImage(transformSetup.transformConfigs, transformSetup.imageInfos);
    }
  }

  /// Decode the image being edited.
  ///
  /// This method decodes the image if it hasn't been decoded yet and updates
  /// its properties.
  Future<void> decodeImage([
    TransformConfigs? transformConfigs,
    ImageInfos? imageInfos,
  ]) async {
    if (!_isVideoPlayerReady && _isVideoEditor) {
      var initSize = widget.videoController!.initialResolution;
      _imageInfos = ImageInfos(
        rawSize: initSize,
        renderedSize: initSize,
        originalRenderedSize: initSize,
        cropRectSize: initSize,
        pixelRatio: initSize.width / sizesManager.editorSize.width,
        isRotated: false,
      );

      sizesManager.originalImageSize ??= _imageInfos!.rawSize;
      sizesManager.decodedImageSize = _imageInfos!.renderedSize;

      bool shouldImportHistory =
          stateHistoryConfigs.initStateHistory != null && !_isInitialized;
      _isInitialized = true;
      _isImageNotDecoded = false;
      if (mounted) setState(() {});

      if (shouldImportHistory) {
        bool showLoadingDialog = i18n.importStateHistoryMsg.isNotEmpty;

        if (showLoadingDialog) {
          LoadingDialog.instance.show(
            context,
            theme: _theme,
            configs: configs,
            message: i18n.importStateHistoryMsg,
          );
        }
        await importStateHistory(stateHistoryConfigs.initStateHistory!);
        if (showLoadingDialog) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            LoadingDialog.instance.hide();
          });
        }
      }

      return;
    }

    bool shouldImportStateHistory =
        _isImageNotDecoded && stateHistoryConfigs.initStateHistory != null;
    _isImageNotDecoded = false;

    if (shouldImportStateHistory && i18n.importStateHistoryMsg.isNotEmpty) {
      LoadingDialog.instance.show(
        context,
        theme: _theme,
        configs: configs,
        message: i18n.importStateHistoryMsg,
      );
    }

    _imageInfos = imageInfos ??
        await decodeImageInfos(
          bytes: await editorImage!.safeByteArray(context),
          screenSize: Size(
            sizesManager.lastScreenSize.width,
            sizesManager.bodySize.height,
          ),
          configs: transformConfigs ?? stateManager.transformConfigs,
        );
    sizesManager.originalImageSize ??= _imageInfos!.rawSize;
    sizesManager.decodedImageSize = _imageInfos!.renderedSize;

    _isInitialized = true;
    if (!_decodeImageCompleter.isCompleted) {
      _decodeImageCompleter.complete(true);
    }
    mainEditorCallbacks?.onImageDecoded?.call();

    if (shouldImportStateHistory) {
      await importStateHistory(stateHistoryConfigs.initStateHistory!);
      if (i18n.importStateHistoryMsg.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          LoadingDialog.instance.hide();
        });
      }
    }
    if (mounted) setState(() {});
    mainEditorCallbacks?.handleUpdateUI();
  }

  void _calcAppBarHeight() {
    double? renderedBottomBarHeight =
        _bottomBarKey.currentContext?.size?.height;
    if (renderedBottomBarHeight != null) {
      sizesManager
        ..bottomBarHeight = renderedBottomBarHeight
        ..appBarHeight = sizesManager.editorSize.height -
            sizesManager.bodySize.height -
            sizesManager.bottomBarHeight;
    }
  }

  /// Updates the background image in the editor.
  ///
  /// If [updateHistory] is `false`, marks all background-captured images that
  /// use the old-background image as "broken" so they will be recaptured with
  /// the new image, and set the active background image to [image].
  ///
  /// If [updateHistory] is `true`, updates the background images in the
  /// state manager, replaces the old image with [image], and adds the change
  /// to the history.
  ///
  /// After updating, decodes the new image asynchronously.
  ///
  /// [image]: The new background image to set.
  /// [updateHistory]: Whether to update the history with this change
  /// (default is `true`).
  Future<void> updateBackgroundImage(
    EditorImage image, {
    bool updateHistory = true,
  }) async {
    if (!updateHistory) {
      /// Mark all background-captured images that use the old background
      /// image as "broken" so the editor captures them again with the new
      /// image.
      for (var item in stateManager.screenshots) {
        item.broken = true;
      }
      stateManager.activeBackgroundImage = image;
    } else {
      addHistory();
      stateManager.updateBackgroundImages(
        oldImage: editorImage ?? widget.editorImage!,
        newImage: image,
      );
    }

    await decodeImage();
    _rebuildController.add(null);
  }

  @override
  void resetZoom() {
    super.resetZoom();
    _controllers.cropLayerPainterCtrl.add(null);
  }

  /// Handle the start of a scaling operation.
  ///
  /// This method is called when a scaling operation begins and initializes the
  /// necessary variables.
  void _onScaleStart(ScaleStartDetails details) {
    final int pointerCount = details.pointerCount;
    if (sizesManager.bodySize != sizesManager.editorSize) {
      _calcAppBarHeight();
    }

    if (!isDesktop) {
      if (pointerCount >= 2) {
        /// On mobile devices, multi-finger gestures should trigger zoom or
        /// pan when layer-pinch-interactions are disabled.
        if (mainEditorConfigs.enableZoom &&
            !layerInteraction.enableMobilePinchRotate &&
            !layerInteraction.enableMobilePinchScale) {
          interactiveViewer.currentState?.onScaleStart(details);
          return;
        }
      } else {
        /// Handle drag selection for mobile single-finger gestures.
        if (_mouseService.validateDragAction() &&
            mainEditorConfigs.mobilePanInteraction ==
                MobilePanInteraction.dragSelect &&
            layerInteractionManager.activeInteractionLayer == null) {
          layerInteractionManager.clearSelectedLayers();
          _layerDragSelectionService.startDragging(details.localFocalPoint);
          return;
        }
      }
    }

    /// Handle pan action
    if (_mouseService.validatePanAction()) {
      interactiveViewer.currentState?.onScaleStart(details);
      return;
    }

    /// Handle drag selection for desktop or fallback
    if (_mouseService.validateDragAction() &&
        layerInteractionManager.activeInteractionLayer == null) {
      layerInteractionManager.clearSelectedLayers();
      _layerDragSelectionService.startDragging(details.localFocalPoint);
      return;
    }

    /// We add a new history entry that will be updated live during layer
    /// interaction.
    /// Important: No screenshot is taken at this point; it will be captured
    /// after the layer interaction is completed.
    if (hasSelectedLayers) addHistory(blockCaptureScreenshot: true);
    _checkInteractiveViewer();
    isLayerBeingTransformed = hasSelectedLayers;
    layerInteractionManager.onScaleStart(
      details: details,
      selectedLayers: selectedLayers,
    );

    setState(() {});
    mainEditorCallbacks?.handleScaleStart(details);
  }

  /// Handle updates during scaling.
  ///
  /// This method is called during a scaling operation and updates the selected
  /// layer's position and properties.
  void _onScaleUpdate(ScaleUpdateDetails details) {
    final int pointerCount = details.pointerCount;

    mainEditorCallbacks?.handleScaleUpdate(details);
    if (blockOnScaleUpdateFunction) return;

    if (!isDesktop) {
      if (pointerCount >= 2) {
        /// On mobile, multi-finger gestures should always trigger zoom/pan
        if (mainEditorConfigs.enableZoom &&
            !layerInteraction.enableMobilePinchRotate &&
            !layerInteraction.enableMobilePinchScale) {
          interactiveViewer.currentState?.onScaleUpdate(details);
          return;
        }
      } else {
        /// Handle active drag selection on mobile
        if (_layerDragSelectionService.isActive) {
          _layerDragSelectionService.updateSize(details.localFocalPoint);
          return;
        }
      }
    }

    /// Handle pan action
    if (_mouseService.validatePanAction()) {
      interactiveViewer.currentState?.onScaleUpdate(details);
      return;
    }

    /// Handle drag selection updates
    if (_layerDragSelectionService.isActive &&
        _mouseService.validateDragAction()) {
      _layerDragSelectionService.updateSize(details.localFocalPoint);
      return;
    }

    bool beforeShowHorizontalHelperLine =
        layerInteractionManager.showHorizontalHelperLine;
    bool beforeShowVerticalHelperLine =
        layerInteractionManager.showVerticalHelperLine;
    bool beforeShowRotationHelperLine =
        layerInteractionManager.showRotationHelperLine;

    void checkUpdateHelperLineUI() {
      if (beforeShowHorizontalHelperLine !=
              layerInteractionManager.showHorizontalHelperLine ||
          beforeShowVerticalHelperLine !=
              layerInteractionManager.showVerticalHelperLine ||
          beforeShowRotationHelperLine !=
              layerInteractionManager.showRotationHelperLine) {
        _controllers.helperLineCtrl.add(null);
      }
    }

    if (!hasSelectedLayers) return;

    if (layerInteractionManager.rotateScaleLayerSizeHelper != null) {
      layerInteractionManager.calculateInteractiveButtonScaleRotate(
        configs: configs,
        selectedLayers: selectedLayers,
        details: details,
        editorSize: sizesManager.bodySize,
        layerTheme: layerInteraction.style,
        editorScaleFactor: interactiveViewer.currentState?.scaleFactor ?? 1.0,
        editorScaleOffset:
            interactiveViewer.currentState?.offset ?? Offset.zero,
      );
      for (Layer layer in selectedLayers) {
        layer.key.currentState!.setState(() {});
      }
      checkUpdateHelperLineUI();
      return;
    }

    double editorScaleFactor =
        interactiveViewer.currentState?.scaleFactor ?? 1.0;

    layerInteractionManager.enabledHitDetection = false;
    if (pointerCount == 1) {
      layerInteractionManager.calculateMovement(
        editorScaleFactor: editorScaleFactor,
        removeAreaKey: _removeAreaKey,
        selectedLayers: selectedLayers,
        layerList: activeLayers,
        context: context,
        detail: details,
        onHoveredRemoveChanged: (value) {
          _controllers.removeBtnCtrl.add(null);
          mainEditorCallbacks?.onHoverRemoveAreaChange?.call(value);
        },
        helperLineCtrl: _controllers.helperLineCtrl,
      );
    } else if (pointerCount == 2) {
      /// If multi-selection is active and the editor is zoomable, treat
      /// two-finger gestures as zooming the editor instead of scaling a layer.
      final hasMultiSelection = selectedLayers.length > 1;

      if (hasMultiSelection && mainEditorConfigs.enableZoom) {
        interactiveViewer.currentState?.onScaleUpdate(details);
        return;
      }
      // Layer scaling (original logic)
      layerInteractionManager.calculateScaleRotate(
        configs: configs,
        selectedLayers: selectedLayers,
        detail: details,
        editorSize: sizesManager.bodySize,
        screenPaddingHelper: sizesManager.imageMargin,
        editorScaleFactor: editorScaleFactor,
      );
    }
    for (Layer layer in selectedLayers) {
      mainEditorCallbacks?.handleUpdateLayer(layer);
      layer.key.currentState?.setState(() {});
    }
    checkUpdateHelperLineUI();
  }

  /// Handle the end of a scaling operation.
  ///
  /// This method is called when a scaling operation ends and resets helper
  /// lines and flags.
  void _onScaleEnd(ScaleEndDetails details) async {
    mainEditorCallbacks?.handleScaleEnd(details);
    layerInteractionManager.activeInteractionLayer = null;

    /// Check if layers should be removed.
    if (layerInteractionManager.hoverRemoveBtn) {
      for (Layer layer in layerInteractionManager.selectedLayersScaleStart) {
        activeLayers.remove(layer);
        mainEditorCallbacks?.handleRemoveLayer(layer);
      }
      layerInteractionManager.clearSelectedLayers();
    }

    if (!hasSelectedLayers) {
      if (!_layerDragSelectionService.isActive) {
        interactiveViewer.currentState?.onScaleEnd(details);
      }

      /// On mobile when layers are not selectable we check if a layer was
      /// transformed.
      if (!isDesktop &&
          layerInteractionManager.layerWasTransformed &&
          layerInteraction.selectable != LayerInteractionSelectable.enabled) {
        _takeScreenshot(replaceLastScreenshot: true);
      }
    } else {
      /// At this point, we only create a screenshot since the new history
      /// entry was already added in [_onScaleStart].
      _takeScreenshot(replaceLastScreenshot: true);
      if (!layerInteraction.keepSelectionOnInteraction) {
        layerInteractionManager.clearSelectedLayers();
      }
    }

    isLayerBeingTransformed = false;
    _checkInteractiveViewer();
    _controllers.uiLayerCtrl.add(null);
    layerInteractionManager.onScaleEnd();
    _layerDragSelectionService.endDragging();
    setState(() {});
  }

  /// Handles tap events on a text layer.
  ///
  /// This method opens a text editor for the specified text layer and updates
  /// the layer's properties
  /// based on the user's input.
  ///
  /// [layerData] - The text layer data to be edited.
  void _onTextLayerTap(TextLayer layerData) async {
    TextLayer? updatedLayer = await openPage(
      TextEditor(
        key: textEditor,
        layer: _layerCopyManager.copyLayer(layerData) as TextLayer,
        heroTag: layerData.id,
        configs: configs,
        theme: _theme,
        callbacks: callbacks,
        scaleFactor: textEditorConfigs.enableMainEditorZoomFactor
            ? interactiveViewer.currentState?.scaleFactor ?? 1.0
            : 1.0,
      ),

      /// Small Duration is important for a smooth hero animation
      duration: const Duration(milliseconds: 250),
    );

    if (!mounted || updatedLayer == null) return;

    updatedLayer
      ..id = layerData.id
      ..key = layerData.key
      ..keyInternalSize = layerData.keyInternalSize
      ..flipX = layerData.flipX
      ..flipY = layerData.flipY
      ..offset = layerData.offset
      ..scale = layerData.scale
      ..rotation = layerData.rotation
      ..boxConstraints = layerData.boxConstraints
      ..groupId = layerData.groupId
      ..interaction = layerData.interaction
      ..meta = layerData.meta;

    if (updatedLayer.text.isEmpty) {
      removeLayer(layerData);
      return;
    }

    int i = activeLayers.indexWhere((element) => element.id == layerData.id);
    replaceLayer(index: i, layer: updatedLayer);
  }

  void _editPaintLayer(PaintLayer layer) async {
    if (layer.isPaintLayer && layer.item.isCensorArea) return;

    PaintLayer? result = await showModalBottomSheet<PaintLayer>(
      context: context,
      backgroundColor: paintEditorConfigs.style.editSheetBackgroundColor,
      showDragHandle: paintEditorConfigs.style.editSheetShowDragHandle,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) =>
          paintEditorConfigs.widgets.editBottomSheet?.call(layer) ??
          SafeArea(
            child: PaintEditorLayerEditor(
              layer: _layerCopyManager.duplicateLayer(layer,
                  offset: Offset.zero) as PaintLayer,
              configs: configs,
            ),
          ),
    );

    if (result == null) return;

    replaceLayer(index: getLayerStackIndex(layer), layer: result);
  }

  /// Initializes the key event listener by adding a handler to the keyboard
  /// service.
  void initKeyEventListener() {
    ServicesBinding.instance.keyboard.addHandler(_onKeyEvent);
  }

  /// Removes the key event listener by removing the handler from the keyboard
  /// service.
  void removeKeyEventListener() {
    ServicesBinding.instance.keyboard.removeHandler(_onKeyEvent);
  }

  void _selectLayerAfterHeroIsDone(String id) async {
    if (layerInteractionManager.layersAreSelectable(configs) &&
        layerInteraction.initialSelected) {
      if (isSubEditorOpen) await _pageOpenCompleter.future;
      layerInteractionManager.addSelectedLayer(id);
      _checkInteractiveViewer();
      _controllers.uiLayerCtrl.add(null);
    }
  }

  /// Open a new page on top of the current page.
  ///
  /// This method navigates to a new page using a fade transition animation.
  Future<T?> openPage<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    layerInteractionManager.clearSelectedLayers();
    _checkInteractiveViewer();
    isSubEditorOpen = true;

    setState(() {});

    SubEditor editorName = SubEditor.unknown;

    if (T is List<PaintLayer> || page is PaintEditor) {
      editorName = SubEditor.paint;
    } else if (T is TextLayer || page is TextEditor) {
      editorName = SubEditor.text;
    } else if (T is TransformConfigs || page is CropRotateEditor) {
      editorName = SubEditor.cropRotate;
    } else if (T is TuneAdjustmentMatrix || page is TuneEditor) {
      editorName = SubEditor.tune;
    } else if (T is FilterMatrix || page is FilterEditor) {
      editorName = SubEditor.filter;
    } else if (T is double || page is BlurEditor) {
      editorName = SubEditor.blur;
    } else if (page is EmojiEditor) {
      editorName = SubEditor.emoji;
    }

    mainEditorCallbacks?.handleOpenSubEditor(editorName);
    _pageOpenCompleter = Completer();
    return Navigator.push<T?>(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: mainEditorConfigs.style.subEditorPage.barrierColor,
        barrierDismissible:
            mainEditorConfigs.style.subEditorPage.barrierDismissible,
        transitionDuration: duration,
        reverseTransitionDuration: duration,
        transitionsBuilder:
            mainEditorConfigs.style.subEditorPage.transitionsBuilder ??
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
        pageBuilder: (context, animation, secondaryAnimation) {
          void animationStatusListener(AnimationStatus status) {
            switch (status) {
              case AnimationStatus.completed:
                if (cropRotateEditor.currentState != null) {
                  cropRotateEditor.currentState!.hideFakeHero();
                }
                break;
              case AnimationStatus.dismissed:
                setState(() {
                  isSubEditorOpen = false;
                  isSubEditorClosing = false;
                  if (!_pageOpenCompleter.isCompleted) {
                    _pageOpenCompleter.complete(true);
                  }

                  if (stateManager.heroScreenshotRequired) {
                    stateManager.heroScreenshotRequired = false;
                    _takeScreenshot();
                  }
                });

                animation.removeStatusListener(animationStatusListener);
                mainEditorCallbacks?.handleEndCloseSubEditor(editorName);
                break;
              case AnimationStatus.reverse:
                isSubEditorClosing = true;
                mainEditorCallbacks?.handleStartCloseSubEditor(editorName);

                break;
              case AnimationStatus.forward:
                break;
            }
          }

          animation.addStatusListener(animationStatusListener);
          if (mainEditorConfigs.style.subEditorPage.requireReposition) {
            return SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: mainEditorConfigs.style.subEditorPage.positionTop,
                    left: mainEditorConfigs.style.subEditorPage.positionLeft,
                    right: mainEditorConfigs.style.subEditorPage.positionRight,
                    bottom:
                        mainEditorConfigs.style.subEditorPage.positionBottom,
                    child: Center(
                      child: Container(
                        width: mainEditorConfigs
                                .style.subEditorPage.enforceSizeFromMainEditor
                            ? sizesManager.editorSize.width
                            : null,
                        height: mainEditorConfigs
                                .style.subEditorPage.enforceSizeFromMainEditor
                            ? sizesManager.editorSize.height
                            : null,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: mainEditorConfigs
                              .style.subEditorPage.borderRadius,
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

  /// Opens the paint editor.
  ///
  /// This method opens the paint editor and allows the user to draw on the
  /// current image.
  /// After closing the paint editor, any changes made are applied to the
  /// image's layers.
  void openPaintEditor() async {
    var paintCallbacks =
        callbacks.paintEditorCallbacks ?? const PaintEditorCallbacks();
    var overridenPaintCallbacks = paintCallbacks.copyWith(
      onEditorZoomMatrix4Change: (value) {
        callbacks.paintEditorCallbacks?.onEditorZoomMatrix4Change?.call(value);
        if (paintEditorConfigs.enableShareZoomMatrix) {
          interactiveViewer.currentState?.transformMatrix4 = value;
        }
      },
    );

    PaintEditorResponse? result = await openPage<PaintEditorResponse>(
      PaintEditor.autoSource(
        key: paintEditor,
        editorImage: editorImage,
        videoController: widget.videoController,
        initConfigs: PaintEditorInitConfigs(
          configs: configs,
          callbacks: callbacks.copyWith(
            paintEditorCallbacks: overridenPaintCallbacks,
          ),
          layers: _layerCopyManager.duplicateLayerList(
            activeLayers,
            offset: Offset.zero,
            enableCopyId: true,
          ),
          theme: _theme,
          mainImageSize: sizesManager.decodedImageSize,
          mainBodySize: sizesManager.bodySize,
          transformConfigs: stateManager.transformConfigs,
          appliedBlurFactor: stateManager.activeBlur,
          appliedFilters: stateManager.activeFilters,
          appliedTuneAdjustments: stateManager.activeTuneAdjustments,
          initialZoomMatrix: interactiveViewer.currentState?.transformMatrix4,
        ),
      ),
      duration: const Duration(milliseconds: 150),
    );

    if (result == null) return;

    String lastLayerId = '';
    for (var i = 0; i < result.layers.length; i++) {
      final layer = result.layers[i];
      final oldIndex = activeLayers.indexWhere((el) => el.id == layer.id);

      final duplicatedLayer = _layerCopyManager.duplicateLayer(
        layer,
        offset: Offset.zero,
      );
      lastLayerId = duplicatedLayer.id;
      addLayer(
        duplicatedLayer,
        removeLayerIndex: oldIndex,
        blockSelectLayer: true,
        blockCaptureScreenshot: true,
        autoCorrectZoomOffset: false,
        autoCorrectZoomScale: false,
      );
    }
    for (Layer layer in result.removedLayers) {
      removeLayer(layer, blockCaptureScreenshot: true);
    }

    if (lastLayerId.isNotEmpty) {
      _selectLayerAfterHeroIsDone(lastLayerId);
    }

    _takeScreenshot(replaceLastScreenshot: true);
    setState(() {});
    mainEditorCallbacks?.handleUpdateUI();
  }

  /// Opens the text editor.
  ///
  /// This method opens the text editor, allowing the user to add or edit text
  /// layers on the image.
  void openTextEditor({
    /// Small Duration is important for a smooth hero animation
    Duration duration = const Duration(milliseconds: 150),
  }) async {
    TextLayer? layer = await openPage(
      TextEditor(
        key: textEditor,
        configs: configs,
        theme: _theme,
        callbacks: callbacks,
        scaleFactor: textEditorConfigs.enableMainEditorZoomFactor
            ? interactiveViewer.currentState?.scaleFactor ?? 1.0
            : 1.0,
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
  /// This method opens the crop editor, allowing the user to crop and rotate
  /// the image.
  void openCropRotateEditor() async {
    if (!_isInitialized) await _decodeImageCompleter.future;

    await openPage<TransformConfigs?>(
      CropRotateEditor.autoSource(
        key: cropRotateEditor,
        editorImage: editorImage,
        videoController: widget.videoController,
        initConfigs: CropRotateEditorInitConfigs(
          configs: configs,
          callbacks: callbacks,
          theme: _theme,
          layers: _layerCopyManager.copyLayerList(activeLayers),
          transformConfigs: stateManager.transformConfigs,
          mainImageSize: sizesManager.decodedImageSize,
          mainBodySize: sizesManager.bodySize,
          enableFakeHero: true,
          appliedBlurFactor: stateManager.activeBlur,
          appliedFilters: stateManager.activeFilters,
          appliedTuneAdjustments: stateManager.activeTuneAdjustments,
          onDone: (transformConfigs, fitToScreenFactor, imageInfos) async {
            List<Layer> updatedLayers = LayerTransformGenerator(
              layers: stateManager.activeLayers,
              activeTransformConfigs: stateManager.transformConfigs,
              newTransformConfigs: transformConfigs,
              layerDrawAreaSize: sizesManager.bodySize,
              undoChanges: false,
              fitToScreenFactor: fitToScreenFactor,
            ).updatedLayers;

            _imageInfos = null;
            unawaited(decodeImage(transformConfigs));
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

  /// Opens the tune editor.
  ///
  /// This method opens the Tune Editor page, allowing the user to make tune
  /// adjustments (such as brightness, contrast, etc.) to the current image.
  ///
  /// If tune adjustments are made, they are added to the editor's history
  /// and the UI is updated accordingly. If the operation is canceled or no
  /// adjustments are made, the current state remains unchanged.
  void openTuneEditor({bool enableHero = true}) async {
    if (!mounted) return;
    List<TuneAdjustmentMatrix>? tuneAdjustments = await openPage(
      HeroMode(
        enabled: enableHero,
        child: TuneEditor.autoSource(
          key: tuneEditor,
          editorImage: editorImage,
          videoController: widget.videoController,
          initConfigs: TuneEditorInitConfigs(
            theme: _theme,
            configs: configs,
            callbacks: callbacks,
            transformConfigs: stateManager.transformConfigs,
            layers: _layerCopyManager.copyLayerList(activeLayers),
            mainImageSize: sizesManager.decodedImageSize,
            mainBodySize: sizesManager.bodySize,
            convertToUint8List: false,
            appliedBlurFactor: stateManager.activeBlur,
            appliedFilters: stateManager.activeFilters,
            appliedTuneAdjustments: stateManager.activeTuneAdjustments,
          ),
        ),
      ),
    );

    if (tuneAdjustments == null) return;

    addHistory(tuneAdjustments: tuneAdjustments, heroScreenshotRequired: true);

    setState(() {});
    mainEditorCallbacks?.handleUpdateUI();
  }

  /// Opens the filter editor.
  ///
  /// This method allows the user to apply filters to the current image and
  /// replaces the image
  /// with the filtered version if a filter is applied.
  ///
  /// The filter editor is opened as a page, and the resulting filtered image
  /// is received as a
  /// `Uint8List`. If no filter is applied or the operation is canceled, the
  /// original image is retained.
  void openFilterEditor() async {
    if (!mounted) return;
    FilterMatrix? filters = await openPage(
      FilterEditor.autoSource(
        key: filterEditor,
        editorImage: editorImage,
        videoController: widget.videoController,
        initConfigs: FilterEditorInitConfigs(
          theme: _theme,
          configs: configs,
          callbacks: callbacks,
          transformConfigs: stateManager.transformConfigs,
          layers: _layerCopyManager.copyLayerList(activeLayers),
          mainImageSize: sizesManager.decodedImageSize,
          mainBodySize: sizesManager.bodySize,
          convertToUint8List: false,
          appliedBlurFactor: stateManager.activeBlur,
          appliedFilters: stateManager.activeFilters,
          appliedTuneAdjustments: stateManager.activeTuneAdjustments,
        ),
      ),
    );

    if (filters == null) return;

    addHistory(filters: filters, heroScreenshotRequired: true);

    setState(() {});
    mainEditorCallbacks?.handleUpdateUI();
  }

  /// Opens the blur editor as a modal bottom sheet.
  void openBlurEditor() async {
    if (!mounted) return;
    double? blur = await openPage(
      BlurEditor.autoSource(
        key: blurEditor,
        editorImage: editorImage,
        videoController: widget.videoController,
        initConfigs: BlurEditorInitConfigs(
          theme: _theme,
          mainImageSize: sizesManager.decodedImageSize,
          mainBodySize: sizesManager.bodySize,
          layers: _layerCopyManager.copyLayerList(activeLayers),
          configs: configs,
          callbacks: callbacks,
          transformConfigs: stateManager.transformConfigs,
          convertToUint8List: false,
          appliedBlurFactor: stateManager.activeBlur,
          appliedFilters: stateManager.activeFilters,
          appliedTuneAdjustments: stateManager.activeTuneAdjustments,
        ),
      ),
    );

    if (blur == null) return;

    addHistory(blur: blur, heroScreenshotRequired: true);

    setState(() {});
    mainEditorCallbacks?.handleUpdateUI();
  }

  /// Opens the emoji editor.
  ///
  /// This method opens the emoji editor as a modal bottom sheet, allowing the
  /// user to add emoji
  /// layers to the current image. The selected emoji layer's properties, such
  /// as scale and offset,
  /// are adjusted before adding it to the image's layers.
  ///
  /// Keyboard event handlers are temporarily removed while the emoji editor is
  /// active and restored
  /// after its closure.
  void openEmojiEditor() async {
    setState(() => layerInteractionManager.clearSelectedLayers());
    _checkInteractiveViewer();
    ServicesBinding.instance.keyboard.removeHandler(_onKeyEvent);
    final effectiveBoxConstraints = emojiEditorConfigs
        .style.editorBoxConstraintsBuilder
        ?.call(context, configs);

    DraggableSheetStyle sheetTheme =
        emojiEditorConfigs.style.themeDraggableSheet;
    bool useDraggableSheet = sheetTheme.maxChildSize != sheetTheme.minChildSize;
    EmojiLayer? layer = await showModalBottomSheet(
      context: context,
      backgroundColor: emojiEditorConfigs.style.backgroundColor,
      constraints: effectiveBoxConstraints,
      showDragHandle: emojiEditorConfigs.style.showDragHandle,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) => SafeArea(
        child: !useDraggableSheet
            ? ConstrainedBox(
                constraints: effectiveBoxConstraints ??
                    BoxConstraints(
                      maxHeight: 300 + MediaQuery.viewInsetsOf(context).bottom,
                    ),
                child: EmojiEditor(configs: configs),
              )
            : DraggableScrollableSheet(
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
                },
              ),
      ),
    );
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
    final effectiveBoxConstraints = stickerEditorConfigs
        .style.editorBoxConstraintsBuilder
        ?.call(context, configs);
    var sheetTheme = stickerEditorConfigs.style.draggableSheetStyle;
    WidgetLayer? layer = await showModalBottomSheet(
      context: context,
      backgroundColor: stickerEditorConfigs.style.bottomSheetBackgroundColor,
      constraints: effectiveBoxConstraints,
      showDragHandle: stickerEditorConfigs.style.showDragHandle,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => SafeArea(
        child: DraggableScrollableSheet(
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
        ),
      ),
    );
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
  void moveLayerListPosition({required int oldIndex, required int newIndex}) {
    if (oldIndex == newIndex || oldIndex < 0 || newIndex < 0) return;

    final layers = _layerCopyManager.copyLayerList(activeLayers);

    if (oldIndex < layers.length && newIndex <= layers.length) {
      final item = layers.removeAt(oldIndex);

      // Insert directly at newIndex, no adjustment needed
      layers.insert(newIndex, item);

      addHistory(layers: layers);
      setState(() {});
    }
  }

  /// Moves the given layer one step forward in the stack.
  /// Does nothing if the layer is already at the top.
  void moveLayerForward(Layer layer) {
    int oldIndex = getLayerStackIndex(layer);
    if (oldIndex >= activeLayers.length - 1) return;
    moveLayerListPosition(oldIndex: oldIndex, newIndex: oldIndex + 1);
  }

  /// Moves the given layer one step backward in the stack.
  /// Does nothing if the layer is already at the bottom.
  void moveLayerBackward(Layer layer) {
    int oldIndex = getLayerStackIndex(layer);
    if (oldIndex <= 0) return;
    moveLayerListPosition(oldIndex: oldIndex, newIndex: oldIndex - 1);
  }

  /// Moves the given layer to the top of the stack.
  /// Does nothing if the layer is already at the top.
  void moveLayerToFront(Layer layer) {
    int oldIndex = getLayerStackIndex(layer);
    if (oldIndex == -1 || oldIndex == activeLayers.length - 1) return;
    moveLayerListPosition(
      oldIndex: oldIndex,
      newIndex: activeLayers.length - 1,
    );
  }

  /// Moves the given layer to the bottom of the stack.
  /// Does nothing if the layer is already at the bottom.
  void moveLayerToBack(Layer layer) {
    int oldIndex = getLayerStackIndex(layer);
    if (oldIndex <= 0) return;
    moveLayerListPosition(oldIndex: oldIndex, newIndex: 0);
  }

  /// Returns the index of the given layer in the active layer stack.
  /// Returns -1 if the layer is not found.
  int getLayerStackIndex(Layer layer) {
    return activeLayers.indexWhere((item) => item.id == layer.id);
  }

  /// Undo the last editing action.
  ///
  /// This function allows the user to undo the most recent editing action
  /// performed on the image.
  /// It decreases the edit position, and the image is decoded to reflect
  /// the previous state.
  void undoAction() {
    GestureManager.instance.stopPropagation();
    if (stateManager.canUndo) {
      setState(() {
        layerInteractionManager.clearSelectedLayers();
        _checkInteractiveViewer();
        stateManager.undo();
        decodeImage();
      });
      mainEditorCallbacks?.handleUndo();
    }
  }

  /// Redo the previously undone editing action.
  ///
  /// This function allows the user to redo an editing action that was
  /// previously undone using the
  /// `undoAction` function. It increases the edit position, and the image is
  /// decoded to reflect
  /// the next state.
  void redoAction() {
    if (stateManager.canRedo) {
      setState(() {
        layerInteractionManager.clearSelectedLayers();
        _checkInteractiveViewer();
        stateManager.redo();
        decodeImage();
      });
      mainEditorCallbacks?.handleRedo();
    }
  }

  /// Takes a screenshot of the current editor state.
  ///
  /// This method is intended to be used for capturing the current state of the
  /// editor and saving it as an image.
  ///
  /// - If a subeditor is currently open, the method waits until it is fully
  ///   loaded.
  /// - The screenshot is taken in a post-frame callback to ensure the UI is
  ///   fully rendered.
  void _takeScreenshot({bool replaceLastScreenshot = false}) async {
    // Wait for the editor to be fully open, if it is currently opening
    if (isSubEditorOpen) await _pageOpenCompleter.future;

    if (replaceLastScreenshot) {
      stateManager.screenshots.removeLast();
    }

    // Capture the screenshot in a post-frame callback to ensure the UI is fully
    // rendered
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_imageInfos == null && mounted) await decodeImage();

      if (!mounted) return;

      await _controllers.screenshot.capture(
        imageInfos: _imageInfos!,
        screenshots: stateManager.screenshots,
      );
    });
  }

  /// Complete the editing process and return the edited image.
  ///
  /// This function is called when the user is done editing the image. If no
  /// changes have been made or if the image has no additional layers, it
  /// cancels the editing process and closes the editor. Otherwise, it captures
  /// the current state of the image, including any applied changes or layers,
  /// and returns it as a byte array.
  ///
  /// Before returning the edited image, a loading dialog is displayed to
  /// indicate that the operation is in progress.
  void doneEditing() async {
    if (_isProcessingFinalImage) return;
    if (!stateManager.canUndo && activeLayers.isEmpty) {
      if (!imageGenerationConfigs.allowEmptyEditingCompletion) {
        return closeEditor();
      }
    }
    callbacks.onImageEditingStarted?.call();

    /// Hide every unnecessary element that Screenshot Controller will capture
    /// a correct image.
    setState(() {
      _isProcessingFinalImage = true;
      layerInteractionManager.clearSelectedLayers();
      _checkInteractiveViewer();
    });

    /// Ensure hero animations finished
    if (isSubEditorOpen) await _pageOpenCompleter.future;

    /// For the case the user add initial transformConfigs but there are no
    /// changes we need to ensure the editor will generate the image.
    if (mainEditorConfigs.transformSetup != null && !stateManager.canUndo) {
      addHistory();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      LoadingDialog.instance.show(
        context,
        theme: _theme,
        configs: configs,
        message: i18n.doneLoadingMsg,
      );

      if (callbacks.onThumbnailGenerated != null) {
        if (_imageInfos == null) await decodeImage();

        final results = await Future.wait([
          captureEditorImage(),
          _controllers.screenshot.getRawRenderedImage(
            imageInfos: _imageInfos!,
            useThumbnailSize: false,
          ),
        ]);

        await callbacks.onThumbnailGenerated!(
          results[0] as Uint8List,
          results[1] as ui.Image,
        );
      } else {
        Uint8List? bytes = await captureEditorImage();
        await onImageEditingComplete?.call(bytes);

        final transform = stateManager.transformConfigs;
        final isTransformed = transform.isNotEmpty;

        Size originalImageSize = _imageInfos!.rawSize;
        Size outputSize = transform.getCropSize(originalImageSize);
        Offset outputOffset = transform.getCropStartOffset(originalImageSize);

        await onCompleteWithParameters?.call(
          CompleteParameters(
            blur: stateManager.activeBlur,
            matrixFilterList: stateManager.activeFilters,
            matrixTuneAdjustmentsList: stateManager.activeTuneAdjustments
                .map((item) => item.matrix)
                .toList(),
            startTime: widget.videoController?.startTime,
            endTime: widget.videoController?.endTime,
            cropWidth: isTransformed ? outputSize.width.round() : null,
            cropHeight: isTransformed ? outputSize.height.round() : null,
            cropX: isTransformed ? outputOffset.dx.round() : null,
            cropY: isTransformed ? outputOffset.dy.round() : null,
            flipX: transform.is90DegRotated ? transform.flipY : transform.flipX,
            flipY: transform.is90DegRotated ? transform.flipX : transform.flipY,
            rotateTurns: transform.angleToTurns(),
            image: bytes,
            isTransformed: isTransformed,
            layers: activeLayers,
          ),
        );
      }

      LoadingDialog.instance.hide();

      onCloseEditor?.call(EditorMode.main);

      /// Allow users to continue editing if they didn't close the editor.
      setState(() => _isProcessingFinalImage = false);
    });
  }

  /// Captures the final editor image.
  ///
  /// This method generates the final image of the editor content, taking
  /// into account the pixel ratio for high-resolution images. If
  /// `generateOnlyImageBounds` is set in `imageGenerationConfigs`, it uses the
  /// base pixel ratio; otherwise, it uses the maximum of the base pixel ratio
  /// and the device's pixel ratio.
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

    bool hasChanges = stateManager.canUndo;
    bool useOriginalImage = !_isVideoEditor &&
        !hasChanges &&
        imageGenerationConfigs.enableUseOriginalBytes;

    if (!hasChanges && !imageGenerationConfigs.enableUseOriginalBytes) {
      addHistory();
    }

    return await _controllers.screenshot.captureFinalScreenshot(
          imageInfos: _imageInfos!,
          backgroundScreenshot:
              useOriginalImage ? null : stateManager.activeScreenshot,
          originalImageBytes: useOriginalImage
              ? await editorImage!.safeByteArray(context)
              : null,
        ) ??
        Uint8List.fromList([]);
  }

  /// Closes all active sub-editors within the main editor, including paint,
  /// text, crop/rotate, filter, tune, and emoji editors.
  /// This ensures that any open sub-editor is properly closed and the main
  /// editor returns to its default state.
  void closeSubEditor() {
    paintEditor.currentState?.close();
    textEditor.currentState?.close();
    cropRotateEditor.currentState?.close();
    filterEditor.currentState?.close();
    tuneEditor.currentState?.close();
    emojiEditor.currentState?.close();
  }

  /// Close the image editor.
  ///
  /// This function allows the user to close the image editor without saving
  /// any changes or edits.
  /// It navigates back to the previous screen or closes the modal editor.
  void closeEditor() {
    if (!stateManager.canUndo) {
      if (onCloseEditor == null) {
        Navigator.pop(context);
      } else {
        onCloseEditor!.call(EditorMode.main);
      }
    } else {
      closeWarning();
    }
  }

  /// Displays a warning dialog before closing the image editor.
  void closeWarning() async {
    if (isPopScopeDisabled) {
      Navigator.pop(context);
      return;
    }
    _isDialogOpen = true;

    bool close = false;

    if (!mounted) return;

    if (mainEditorConfigs.widgets.closeWarningDialog != null) {
      close = await mainEditorConfigs.widgets.closeWarningDialog!(this);
    } else {
      await showAdaptiveDialog(
        context: context,
        builder: (BuildContext context) => Theme(
          data: _theme,
          child: AdaptiveDialog(
            designMode: designMode,
            brightness: _theme.brightness,
            style: configs.dialogConfigs.style.adaptiveDialog,
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
        onCloseEditor!.call(EditorMode.main);
      }
    }

    _isDialogOpen = false;
  }

  /// Imports state history and performs necessary recalculations.
  ///
  /// If [ImportStateHistory.configs.recalculateSizeAndPosition] is `true`, it
  /// recalculates the position and size of layers.
  /// It adjusts the scale and offset of each layer based on the image size and
  /// the editor's dimensions.
  ///
  /// If [ImportStateHistory.configs.mergeMode] is
  /// [ImportEditorMergeMode.replace], it replaces the current state history
  /// with the imported one.
  /// Otherwise, it merges the imported state history with the current one
  /// based on the merge mode.
  ///
  /// After importing, it updates the UI by calling [setState()] and the
  /// optional [onUpdateUI] callback.
  Future<void> importStateHistory(ImportStateHistory import) async {
    mainEditorCallbacks?.onImportHistoryStart?.call(this, import);

    await _stateHistoryService.importStateHistory(
      import,
      context,
      () => setState(() {}),
    );
    await decodeImage();

    mainEditorCallbacks?.onImportHistoryEnd?.call(this, import);
  }

  /// Exports the current state history.
  ///
  /// `configs` specifies the export configurations, such as whether to include
  /// filters or layers.
  ///
  /// Returns an [ExportStateHistory] object containing the exported state
  /// history, image state history, image size, edit position, and export
  /// configurations.
  Future<ExportStateHistory> exportStateHistory({
    ExportEditorConfigs configs = const ExportEditorConfigs(),
  }) async {
    if (_imageInfos == null) await decodeImage();
    if (_imageInfos == null) throw ArgumentError('Failed to decode the image');
    if (!mounted) throw ArgumentError('Context unmounted');

    return _stateHistoryService.exportStateHistory(
      imageInfos: _imageInfos!,
      configs: configs,
      context: context,
    );
  }

  /// Locks all layers in the editor.
  ///
  /// If [onlyCurrentHistory] is set to `true`, only the layers in the current
  /// history state will be locked.
  ///
  /// Parameters:
  /// - [onlyCurrentHistory]: A boolean value indicating whether to lock only
  ///   the layers in the current history state. Defaults to `false`.
  ///
  /// See also:
  /// - [unlockAllLayers] to unlock all layers.
  void lockAllLayers({bool onlyCurrentHistory = false}) {
    stateManager.updateLayerInteraction(
      enableInteraction: false,
      onlyCurrentHistory: onlyCurrentHistory,
    );
    clearLayerSelection();
  }

  /// Unlocks all layers in the editor.
  ///
  /// If [onlyCurrentHistory] is set to `true`, only the layers in the current
  /// history state will be unlocked.
  ///
  /// Parameters:
  /// - [onlyCurrentHistory]: A boolean value indicating whether to unlock only
  ///   the layers in the current history state. Defaults to `false`.
  ///
  /// See also:
  /// - [lockAllLayers] to lock all layers.
  void unlockAllLayers({bool onlyCurrentHistory = false}) {
    stateManager.updateLayerInteraction(
      enableInteraction: true,
      onlyCurrentHistory: onlyCurrentHistory,
    );
  }

  /// Clears the currently selected layer by:
  /// - Clearing the selected layer ID in the [layerInteractionManager]
  /// - Notifying listeners via [_controllers.uiLayerCtrl]
  void clearLayerSelection() {
    layerInteractionManager.clearSelectedLayers();
    _controllers.uiLayerCtrl.add(null);
  }

  /// Selects a layer by its index in [activeLayers].
  ///
  /// If the index is out of bounds, the selection is cleared and `null` is
  /// returned.
  /// Otherwise, the corresponding layer is marked as selected and listeners
  /// are notified.
  ///
  /// Returns the selected [Layer] or `null` if the index is invalid.
  Layer? selectLayerByIndex(int index, {bool enableMultiSelect = false}) {
    if (index < 0 || index >= activeLayers.length) {
      clearLayerSelection();
      return null;
    }

    var layer = activeLayers[index];

    return selectLayerById(layer.id, enableMultiSelect: enableMultiSelect);
  }

  /// Selects a layer by its unique [id].
  ///
  /// Internally uses [selectLayerByIndex] after finding the layer's index.
  ///
  /// Returns the selected [Layer] or `null` if the ID does not match any
  /// active layer.
  Layer? selectLayerById(String id, {bool enableMultiSelect = false}) {
    int index = activeLayers.indexWhere((layer) => layer.id == id);
    if (index == -1) return null;

    Layer? layer = activeLayers[index];

    // Check if the layer allows selection
    if (!layer.interaction.enableSelection) return null;

    if (!enableMultiSelect) layerInteractionManager.clearSelectedLayers();

    layerInteractionManager.addSelectedLayer(id);
    _controllers.uiLayerCtrl.add(null);
    return layer;
  }

  /// Selects all available layers.
  void selectAllLayers() {
    layerInteractionManager.setSelectedLayers(
      activeLayers
          .where((layer) => layer.interaction.enableSelection)
          .map((layer) => layer.id),
    );
    _controllers.uiLayerCtrl.add(null);
  }

  /// Deselects all currently selected layers.
  void unselectAllLayers() {
    layerInteractionManager.clearSelectedLayers();
    _controllers.uiLayerCtrl.add(null);
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
      child: ExtendedPopScope(
        canPop: isPopScopeDisabled ||
            !stateManager.canUndo ||
            _isProcessingFinalImage,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop &&
              !isPopScopeDisabled &&
              stateManager.canUndo &&
              !_isProcessingFinalImage) {
            closeWarning();
          }
          mainEditorCallbacks?.onPopInvoked?.call(didPop, result);
        },
        child: ImageInfosProvider(
          infos: _imageInfos,
          imageFitToWidth:
              _imageInfos?.renderedSize.width == sizesManager.bodySize.width,
          child: ScreenResizeDetector(
            ignoreSafeArea: false,
            onResizeUpdate: (event) {
              sizesManager
                ..recalculateLayerPosition(
                  history: stateManager.stateHistory,
                  resizeEvent: ResizeEvent(
                    oldContentSize: Size(
                      event.oldContentSize.width,
                      event.oldContentSize.height -
                          sizesManager.allToolbarHeight,
                    ),
                    newContentSize: Size(
                      event.newContentSize.width,
                      event.newContentSize.height -
                          sizesManager.allToolbarHeight,
                    ),
                  ),
                )
                ..lastScreenSize = event.newContentSize;
            },
            onResizeEnd: (event) async {
              await decodeImage();
            },
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: mainEditorConfigs.style.uiOverlayStyle,
              child: Theme(
                data: _theme,
                child: SafeArea(
                  top: mainEditorConfigs.safeArea.top,
                  bottom: mainEditorConfigs.safeArea.bottom,
                  left: mainEditorConfigs.safeArea.left,
                  right: mainEditorConfigs.safeArea.right,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      sizesManager.editorSize = constraints.biggest;
                      return Scaffold(
                        backgroundColor: mainEditorConfigs.style.background,
                        resizeToAvoidBottomInset: false,
                        appBar: _buildAppBar(),
                        body: _buildBody(),
                        bottomNavigationBar: _buildBottomNavBar(),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    if (mainEditorConfigs.widgets.appBar != null) {
      return mainEditorConfigs.widgets.appBar!.call(
        this,
        _rebuildController.stream,
      );
    }

    return hasSelectedLayers &&
            configs.layerInteraction.hideToolbarOnInteraction
        ? null
        : MainEditorAppBar(
            i18n: i18n,
            configs: configs,
            closeEditor: closeEditor,
            undoAction: undoAction,
            redoAction: redoAction,
            doneEditing: doneEditing,
            isInitialized: _isInitialized,
            stateManager: stateManager,
          );
  }

  Widget _buildBody() {
    return LayoutBuilder(builder: (context, constraints) {
      sizesManager.bodySize = constraints.biggest;
      return !_isVideoPlayerReady
          ? _buildSetupSpinner()
          : Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (details) {
                _lastDownEvent = details;
                _tapDownTimestamp = DateTime.now();
                _mouseService.onPointerDown(details);
                if (layerInteractionManager.selectedLayerId.isNotEmpty ||
                    GestureManager.instance.isBlocked) {
                  return;
                }
                bool isDoubleTap = detectDoubleTap(details);
                if (!isDoubleTap) return;

                handleDoubleTap(context, details, mainEditorConfigs);
                mainEditorCallbacks?.onDoubleTap?.call();
              },
              onPointerUp: (event) {
                _mouseService.onPointerUp(event);
                onPointerUp(event);

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final offsetDistance =
                      (event.position - _lastDownEvent!.position).distance;
                  final timeElapsed = DateTime.now()
                      .difference(_tapDownTimestamp)
                      .inMilliseconds;

                  // Ignore if pointer moved too much (exceeds tap slop)
                  if (offsetDistance >= tapSlop) return;

                  // Ignore if tap took too long (not a quick tap)
                  if (timeElapsed > tapTimeElapsed) return;

                  if (!configs.videoEditor.enablePlayButton) {
                    widget.videoController?.togglePlayState();
                  }
                  mainEditorCallbacks?.onTap?.call();
                });
              },
              onPointerSignal: isDesktop && hasSelectedLayers
                  ? (event) {
                      final hasMultiSelection = selectedLayers.length > 1;

                      final zoomEnabled = mainEditorConfigs.enableZoom;
                      final zoomGestureActive = interactiveViewer
                              .currentState?.isInteractionEnabled ==
                          true;

                      if ((hasMultiSelection && zoomEnabled) ||
                          (zoomEnabled && zoomGestureActive)) {
                        return;
                      }

                      /// Otherwise, handle scroll as a layer scaling
                      /// interaction.
                      _desktopInteractionManager.mouseScroll(event,
                          selectedLayers: selectedLayers,
                          interactiveViewer: interactiveViewer.currentState);
                    }
                  : null,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  /// That function is required so that multiselect works
                  /// correctly, even when it’s empty.
                },
                onLongPress: mainEditorCallbacks?.onLongPress,
                onScaleStart: _onScaleStart,
                onScaleUpdate: _onScaleUpdate,
                onScaleEnd: _onScaleEnd,
                child: mainEditorConfigs.widgets.wrapBody?.call(
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
    return MainEditorInteractiveContent(
      buildImage: _buildImage,
      buildVideo: _buildVideo,
      buildLayers: _buildLayers,
      buildHelperLines: _buildHelperLines,
      buildRemoveArea: _buildRemoveArea,
      callbacks: callbacks,
      sizesManager: sizesManager,
      configs: configs,
      layerInteractionManager: layerInteractionManager,
      controllers: _controllers,
      processFinalImage: _isProcessingFinalImage,
      rebuildController: _rebuildController,
      stateManager: stateManager,
      interactiveViewerKey: interactiveViewer,
      state: this,
      videoController: widget.videoController,
      isVideoEditor: _isVideoEditor,
      layerDragSelectionService: _layerDragSelectionService,
    );
  }

  Widget? _buildBottomNavBar() {
    if (mainEditorConfigs.widgets.bottomBar != null) {
      return mainEditorConfigs.widgets.bottomBar!.call(
        this,
        _rebuildController.stream,
        _bottomBarKey,
      );
    }

    return hasSelectedLayers &&
            configs.layerInteraction.hideToolbarOnInteraction
        ? null
        : MainEditorBottombar(
            controllers: _controllers,
            configs: configs,
            sizesManager: sizesManager,
            bottomBarKey: _bottomBarKey,
            theme: _theme,
            openPaintEditor: openPaintEditor,
            openTextEditor: openTextEditor,
            openCropRotateEditor: openCropRotateEditor,
            openTuneEditor: openTuneEditor,
            openFilterEditor: openFilterEditor,
            openBlurEditor: openBlurEditor,
            openEmojiEditor: openEmojiEditor,
            openStickerEditor: openStickerEditor,
          );
  }

  Widget _buildLayers() {
    return MainEditorLayers(
      controllers: _controllers,
      layerInteractionManager: layerInteractionManager,
      configs: configs,
      callbacks: callbacks,
      sizesManager: sizesManager,
      activeLayers: activeLayers,
      isSubEditorOpen: isSubEditorOpen,
      onCheckInteractiveViewer: _checkInteractiveViewer,
      onTextLayerTap: _onTextLayerTap,
      onEditPaintLayer: _editPaintLayer,
      state: this,
      dragSelectionService: _layerDragSelectionService,
      mouseService: _mouseService,
      onContextMenuToggled: (isOpen) {
        _isContextMenuOpen = isOpen;
      },
      onDuplicateLayer: (layer) {
        var duplication = _layerCopyManager.duplicateLayer(layer);
        addLayer(
          duplication,
          autoCorrectZoomOffset: false,
          autoCorrectZoomScale: false,
        );
      },
    );
  }

  Widget _buildHelperLines() {
    return MainEditorHelperLines(
      sizesManager: sizesManager,
      layerInteractionManager: layerInteractionManager,
      controllers: _controllers,
      interactiveViewer: interactiveViewer,
      helperLines: helperLines,
      configs: configs,
    );
  }

  Widget _buildRemoveArea() {
    return MainEditorRemoveLayerArea(
      layerInteraction: layerInteraction,
      layerInteractionManager: layerInteractionManager,
      mainEditorConfigs: mainEditorConfigs,
      state: this,
      controllers: _controllers,
      removeAreaKey: _removeAreaKey,
      isLayerBeingTransformed: isLayerBeingTransformed,
    );
  }

  Widget _buildSetupSpinner() {
    return Center(
      child: SizedBox(
        width: 48,
        height: 48,
        child: FittedBox(
          child: PlatformCircularProgressIndicator(configs: configs),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return MainEditorBackgroundImage(
      backgroundImageColorFilterKey:
          _isVideoEditor ? GlobalKey() : _backgroundImageColorFilterKey,
      heroTag: _isVideoEditor ? 'image-${configs.heroTag}' : configs.heroTag,
      configs: configs,
      editorImage: editorImage!,
      isInitialized: _isInitialized ||
          stateHistoryConfigs.initStateHistory != null ||
          _stateHistoryService.isImportInProgress,
      sizesManager: sizesManager,
      stateManager: stateManager,
    );
  }

  Widget _buildVideo() {
    return MainEditorBackgroundVideo(
      backgroundImageColorFilterKey: _backgroundImageColorFilterKey,
      configs: configs,
      isInitialized: _isInitialized,
      sizesManager: sizesManager,
      stateManager: stateManager,
      videoPlayer: widget.videoController!.videoPlayer,
    );
  }
}
