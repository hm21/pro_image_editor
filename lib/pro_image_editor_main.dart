import 'dart:async';
import 'dart:math';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pro_image_editor/models/import_export/utils/export_import_enum.dart';
import 'package:pro_image_editor/modules/sticker_editor.dart';
import 'package:screenshot/screenshot.dart';
import 'package:vibration/vibration.dart';

import 'models/history/state_history.dart';
import 'models/history/last_position.dart';
import 'models/crop_rotate_editor_response.dart';
import 'models/editor_image.dart';
import 'models/filter_state_history.dart';
import 'models/import_export/export_state_history.dart';
import 'models/import_export/export_state_history_configs.dart';
import 'models/import_export/import_state_history.dart';
import 'models/layer.dart';
import 'modules/crop_rotate_editor/crop_rotate_editor.dart';
import 'modules/emoji_editor.dart';
import 'modules/filter_editor/filter_editor.dart';
import 'modules/filter_editor/widgets/image_with_multiple_filters.dart';
import 'modules/paint_editor/paint_editor.dart';
import 'modules/text_editor.dart';
import 'utils/debounce.dart';
import 'models/editor_configs/pro_image_editor_configs.dart';
import 'widgets/adaptive_dialog.dart';
import 'widgets/flat_icon_text_button.dart';
import 'widgets/layer_widget.dart';
import 'widgets/loading_dialog.dart';
import 'widgets/pro_image_editor_desktop_mode.dart';

typedef ImageEditingCompleteCallback = Future<void> Function(Uint8List bytes);

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
class ProImageEditor extends StatefulWidget {
  /// Image data as a `Uint8List` from memory.
  final Uint8List? byteArray;

  /// Path to the image asset.
  final String? assetPath;

  /// URL of the image to be loaded from the network.
  final String? networkUrl;

  /// File object representing the image file.
  final File? file;

  /// A callback function that will be called when the editing is done,
  /// and it returns the edited image as a Uint8List.
  ///
  /// The edited image is provided as a Uint8List to the [onImageEditingComplete] function
  /// when the editing is completed.
  final ImageEditingCompleteCallback onImageEditingComplete;

  /// A callback function that will be called before the image editor will close.
  final Function? onCloseEditor;

  /// A callback function that can be used to update the UI from custom widgets.
  final Function? onUpdateUI;

  /// Configuration options for the image editor.
  final ProImageEditorConfigs configs;

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
  /// The `onImageEditingComplete` parameter is a callback function that will be called when the editing is done,
  /// and it returns the edited image as a Uint8List.
  ///
  /// The `onCloseEditor` parameter is a callback function that gets invoked when the editor is closed.
  /// You can use this callback if you want to close the editor with your own parameters or if you want
  /// to prevent Navigator.pop(context) from being automatically triggered.
  ///
  /// The `onUpdateUI` parameter is a callback function that can be used to update the UI from custom widgets.
  const ProImageEditor._({
    super.key,
    required this.onImageEditingComplete,
    this.onCloseEditor,
    this.onUpdateUI,
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

  /// Creates a `ProImageEditor` widget for editing an image from memory.
  ///
  /// The `byteArray` parameter should contain the image data as a `Uint8List`.
  ///
  /// The `configs` parameter allows you to customize the image editing experience by providing
  /// various configuration options. If not specified, default settings will be used.
  ///
  /// The `onImageEditingComplete` parameter is a callback function that will be called when the editing is done,
  /// and it returns the edited image as a Uint8List.
  ///
  /// The `onCloseEditor` parameter is a callback function that gets invoked when the editor is closed.
  /// You can use this callback if you want to close the editor with your own parameters or if you want
  /// to prevent Navigator.pop(context) from being automatically triggered.
  ///
  /// The `onUpdateUI` parameter is a callback function that can be used to update the UI from custom widgets.
  factory ProImageEditor.memory(
    Uint8List byteArray, {
    Key? key,
    required ImageEditingCompleteCallback onImageEditingComplete,
    Function? onUpdateUI,
    Function? onCloseEditor,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
  }) {
    return ProImageEditor._(
      key: key,
      byteArray: byteArray,
      configs: configs,
      onImageEditingComplete: onImageEditingComplete,
      onCloseEditor: onCloseEditor,
      onUpdateUI: onUpdateUI,
    );
  }

  /// Creates a `ProImageEditor` widget for editing an image from a file.
  ///
  /// The `file` parameter should point to the image file.
  ///
  /// The `configs` parameter allows you to customize the image editing experience by providing
  /// various configuration options. If not specified, default settings will be used.
  ///
  /// The `onImageEditingComplete` parameter is a callback function that will be called when the editing is done,
  /// and it returns the edited image as a Uint8List.
  ///
  /// The `onCloseEditor` parameter is a callback function that gets invoked when the editor is closed.
  /// You can use this callback if you want to close the editor with your own parameters or if you want
  /// to prevent Navigator.pop(context) from being automatically triggered.
  ///
  /// The `onUpdateUI` parameter is a callback function that can be used to update the UI from custom widgets.
  factory ProImageEditor.file(
    File file, {
    Key? key,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    required ImageEditingCompleteCallback onImageEditingComplete,
    Function? onUpdateUI,
    Function? onCloseEditor,
  }) {
    return ProImageEditor._(
      key: key,
      file: file,
      configs: configs,
      onImageEditingComplete: onImageEditingComplete,
      onCloseEditor: onCloseEditor,
      onUpdateUI: onUpdateUI,
    );
  }

  /// Creates a `ProImageEditor` widget for editing an image from an asset.
  ///
  /// The `assetPath` parameter should specify the path to the image asset.
  ///
  /// The `configs` parameter allows you to customize the image editing experience by providing
  /// various configuration options. If not specified, default settings will be used.
  ///
  /// The `onImageEditingComplete` parameter is a callback function that will be called when the editing is done,
  /// and it returns the edited image as a Uint8List.
  ///
  /// The `onCloseEditor` parameter is a callback function that gets invoked when the editor is closed.
  /// You can use this callback if you want to close the editor with your own parameters or if you want
  /// to prevent Navigator.pop(context) from being automatically triggered.
  ///
  /// The `onUpdateUI` parameter is a callback function that can be used to update the UI from custom widgets.
  factory ProImageEditor.asset(
    String assetPath, {
    Key? key,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    required ImageEditingCompleteCallback onImageEditingComplete,
    Function? onUpdateUI,
    Function? onCloseEditor,
  }) {
    return ProImageEditor._(
      key: key,
      assetPath: assetPath,
      configs: configs,
      onImageEditingComplete: onImageEditingComplete,
      onCloseEditor: onCloseEditor,
      onUpdateUI: onUpdateUI,
    );
  }

  /// Creates a `ProImageEditor` widget for editing an image from a network URL.
  ///
  /// The `networkUrl` parameter should specify the URL of the image to be loaded.
  ///
  /// The `configs` parameter allows you to customize the image editing experience by providing
  /// various configuration options. If not specified, default settings will be used.
  ///
  /// The `onImageEditingComplete` parameter is a callback function that will be called when the editing is done,
  /// and it returns the edited image as a Uint8List.
  ///
  /// The `onCloseEditor` parameter is a callback function that gets invoked when the editor is closed.
  /// You can use this callback if you want to close the editor with your own parameters or if you want
  /// to prevent Navigator.pop(context) from being automatically triggered.
  ///
  /// The `onUpdateUI` parameter is a callback function that can be used to update the UI from custom widgets.
  factory ProImageEditor.network(
    String networkUrl, {
    Key? key,
    ProImageEditorConfigs configs = const ProImageEditorConfigs(),
    required ImageEditingCompleteCallback onImageEditingComplete,
    Function? onUpdateUI,
    Function? onCloseEditor,
  }) {
    return ProImageEditor._(
      key: key,
      networkUrl: networkUrl,
      configs: configs,
      onImageEditingComplete: onImageEditingComplete,
      onCloseEditor: onCloseEditor,
      onUpdateUI: onUpdateUI,
    );
  }

  @override
  State<ProImageEditor> createState() => ProImageEditorState();
}

class ProImageEditorState extends State<ProImageEditor> {
  /// A GlobalKey for the Painting Editor, used to access and control the state of the painting editor.
  final paintingEditor = GlobalKey<PaintingEditorState>();

  /// A GlobalKey for the Text Editor, used to access and control the state of the text editor.
  final textEditor = GlobalKey<TextEditorState>();

  /// A GlobalKey for the Crop and Rotate Editor, used to access and control the state of the crop and rotate editor.
  final cropRotateEditor = GlobalKey<CropRotateEditorState>();

  /// A GlobalKey for the Filter Editor, used to access and control the state of the filter editor.
  final filterEditor = GlobalKey<FilterEditorState>();

  /// A GlobalKey for the Emoji Editor, used to access and control the state of the emoji editor.
  final emojiEditor = GlobalKey<EmojiEditorState>();

  /// Stream controller for tracking mouse movement within the editor.
  late StreamController<bool> _mouseMoveStream;

  /// Scroll controller for the bottom bar in the editor interface.
  late ScrollController _bottomBarScrollCtrl;

  /// Controller for capturing screenshots of the editor content.
  late ScreenshotController _screenshotCtrl;

  /// List to track changes made to the image during editing.
  List<EditorImage> _imgStateHistory = [];

  /// List to store the history of image editor changes.
  List<EditorStateHistory> _stateHistory = [];

  /// The current theme used by the image editor.
  late ThemeData _theme;

  /// Debounce for scaling actions in the editor.
  late Debounce _scaleDebounce;

  /// Debounce for handling changes in screen size.
  late Debounce _screenSizeDebouncer;

  /// Stores the last recorded screen size.
  Size _lastScreenSize = const Size(0, 0);

  /// Getter for the screen size of the device.
  Size get _screen => MediaQuery.of(context).size;

  /// Getter for the active layer currently being edited.
  Layer get _activeLayer => _layers[_selectedLayer];

  /// Temporary layer used during editing.
  Layer? _tempLayer;

  /// Position in the edit history.
  int _editPosition = 0;

  /// Index of the selected layer.
  int _selectedLayer = -1;

  /// Flag indicating if the editor has been initialized.
  bool _inited = false;

  /// Flag indicating if the crop tool is active.
  bool _activeCrop = false;

  /// Flag indicating if the scaling tool is active.
  bool _activeScale = false;

  /// Flag indicating if the remove button is hovered.
  bool hoverRemoveBtn = false;

  /// Flag indicating if the image needs decoding.
  bool _imageNeedDecode = true;

  /// Flag indicating if vertical helper lines should be displayed.
  bool _showVerticalHelperLine = false;

  /// Flag indicating if horizontal helper lines should be displayed.
  bool _showHorizontalHelperLine = false;

  /// Flag indicating if rotation helper lines should be displayed.
  bool _showRotationHelperLine = false;

  /// Flag indicating if the device can vibrate.
  bool _deviceCanVibrate = false;

  /// Flag indicating if the device can perform custom vibration.
  bool _deviceCanCustomVibrate = false;

  /// Flag indicating if rotation helper lines have started.
  bool _rotationStartedHelper = false;

  /// Flag indicating if helper lines should be displayed.
  bool _showHelperLines = false;

  /// Controls high-performance scaling for free-style drawing.
  /// When `true`, enables optimized scaling for improved performance.
  bool _freeStyleHighPerformanceScaling = false;

  /// Controls high-performance moving for free-style drawing.
  /// When `true`, enables optimized moving for improved performance.
  bool _freeStyleHighPerformanceMoving = false;

  /// Enables or disables hit detection.
  /// When `true`, allows detecting user interactions with the painted layer.
  bool _enabledHitDetection = true;

  /// Flag to track if editing is completed.
  bool _doneEditing = false;

  /// The pixel ratio of the device's screen.
  double _pixelRatio = 1;

  /// Y-coordinate of the rotation helper line.
  double _rotationHelperLineY = 0;

  /// X-coordinate of the rotation helper line.
  double _rotationHelperLineX = 0;

  /// Rotation angle of the rotation helper line.
  double _rotationHelperLineDeg = 0;

  /// The base scale factor for the editor.
  double _baseScaleFactor = 1.0;

  /// The base angle factor for the editor.
  double _baseAngleFactor = 0;

  /// X-coordinate where snapping started.
  double _snapStartPosX = 0;

  /// Y-coordinate where snapping started.
  double _snapStartPosY = 0;

  /// Initial rotation angle when snapping started.
  double _snapStartRotation = 0;

  /// Last recorded rotation angle during snapping.
  double _snapLastRotation = 0;

  /// Span for detecting hits on layers.
  final double _hitSpan = 10;

  /// Width of the image being edited.
  double _imageWidth = 0;

  /// Height of the image being edited.
  double _imageHeight = 0;

  /// Getter for the screen inner height, excluding top and bottom padding.
  double get _screenInnerHeight =>
      _screen.height -
      _screenPadding.top -
      _screenPadding.bottom -
      kToolbarHeight * 2;

  /// Getter for the X-coordinate of the middle of the screen.
  double get _screenMiddleX =>
      _screen.width / 2 - (_screenPadding.left + _screenPadding.right) / 2;

  /// Getter for the Y-coordinate of the middle of the screen.
  double get _screenMiddleY =>
      _screen.height / 2 - (_screenPadding.top + _screenPadding.bottom) / 2;

  /// Last recorded X-axis position for layers.
  LayerLastPosition _lastPositionX = LayerLastPosition.center;

  /// Last recorded Y-axis position for layers.
  LayerLastPosition _lastPositionY = LayerLastPosition.center;

  /// Getter for the screen padding, accounting for safe area insets.
  EdgeInsets get _screenPadding => MediaQuery.of(context).padding;

  /// Whether an editor is currently open.
  bool _openEditor = false;

  /// Whether a dialog is currently open.
  bool _openDialog = false;

  /// Indicates whether the browser's context menu was enabled before any changes.
  bool _browserContextMenuBeforeEnabled = false;

  /// Store the last device Orientation
  int _deviceOrientation = 0;

  @override
  void initState() {
    super.initState();
    _mouseMoveStream = StreamController.broadcast();
    _screenshotCtrl = ScreenshotController();
    _scaleDebounce = Debounce(const Duration(milliseconds: 100));
    _screenSizeDebouncer = Debounce(const Duration(milliseconds: 200));

    _bottomBarScrollCtrl = ScrollController();

    _imgStateHistory.add(EditorImage(
      assetPath: widget.assetPath,
      byteArray: widget.byteArray,
      file: widget.file,
      networkUrl: widget.networkUrl,
    ));

    _stateHistory
        .add(EditorStateHistory(bytesRefIndex: 0, layers: [], filters: []));

    Vibration.hasVibrator().then((value) => _deviceCanVibrate = value ?? false);
    Vibration.hasCustomVibrationsSupport()
        .then((value) => _deviceCanCustomVibrate = value ?? false);

    ServicesBinding.instance.keyboard.addHandler(_onKey);
    if (kIsWeb) {
      _browserContextMenuBeforeEnabled = BrowserContextMenu.enabled;
      BrowserContextMenu.disableContextMenu();
    }
  }

  @override
  void dispose() {
    _mouseMoveStream.close();
    _bottomBarScrollCtrl.dispose();
    _scaleDebounce.dispose();
    _screenSizeDebouncer.dispose();
    SystemChrome.setSystemUIOverlayStyle(_theme.brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark);
    SystemChrome.restoreSystemUIOverlays();
    ServicesBinding.instance.keyboard.removeHandler(_onKey);
    if (kIsWeb && _browserContextMenuBeforeEnabled) {
      BrowserContextMenu.enableContextMenu();
    }
    super.dispose();
  }

  /// Handles keyboard events.
  ///
  /// This method responds to key events and performs actions based on the pressed keys.
  /// If the 'Escape' key is pressed and the widget is still mounted, it triggers the navigator to pop the current context.
  bool _onKey(KeyEvent event) {
    final key = event.logicalKey.keyLabel;

    if (mounted && event is KeyDownEvent) {
      switch (key) {
        case 'Escape':
          if (!_activeCrop && !_openDialog) {
            if (_openEditor) {
              Navigator.pop(context);
            } else {
              closeEditor();
            }
          }
          break;

        case 'Subtract':
        case 'Numpad Subtract':
        case 'Page Down':
        case 'Arrow Down':
          _keyboardZoom(true);
          break;
        case 'Add':
        case 'Numpad Add':
        case 'Page Up':
        case 'Arrow Up':
          _keyboardZoom(false);
          break;
        case 'Arrow Left':
          _keyboardRotate(true);
          break;
        case 'Arrow Right':
          _keyboardRotate(false);
          break;
      }
    }

    return false;
  }

  /// Get the list of layers from the current image editor changes.
  List<Layer> get _layers => _stateHistory[_editPosition].layers;

  /// Get the list of filters from the current image editor changes.
  List<FilterStateHistory> get _filters => _stateHistory[_editPosition].filters;

  /// Get the current image being edited from the change list.
  EditorImage get _image =>
      _imgStateHistory[_stateHistory[_editPosition].bytesRefIndex];

  /// Clean forward changes in the history.
  ///
  /// This method removes any changes made after the current edit position in the history.
  void _cleanForwardChanges() {
    if (_stateHistory.length > 1) {
      while (_editPosition < _stateHistory.length - 1) {
        _stateHistory.removeLast();
        if (_imgStateHistory.length - 1 > _stateHistory.last.bytesRefIndex) {
          _imgStateHistory.removeLast();
        }
      }
    }
    _editPosition = _stateHistory.length - 1;
  }

  /// Add a cropped image to the editor.
  ///
  /// This method adds a cropped image to the editor and updates the editing state.
  void _addCroppedImg(List<Layer> layers, EditorImage image) {
    _cleanForwardChanges();
    _imgStateHistory.add(image);
    _stateHistory.add(
      EditorStateHistory(
        bytesRefIndex: _imgStateHistory.length - 1,
        layers: layers,
        filters: _filters,
      ),
    );
    _editPosition = _stateHistory.length - 1;
  }

  /// Add a new layer to the image editor.
  ///
  /// This method adds a new layer to the image editor and updates the editing state.
  void addLayer(Layer layer, {int removeLayerIndex = -1, EditorImage? image}) {
    _cleanForwardChanges();
    if (image != null) _imgStateHistory.add(image);

    _stateHistory.add(
      EditorStateHistory(
        bytesRefIndex: _imgStateHistory.length - 1,
        layers: List<Layer>.from(
            _stateHistory.last.layers.map((e) => _copyLayer(e)))
          ..add(layer),
        filters: _filters,
      ),
    );
    _editPosition++;
    if (removeLayerIndex >= 0) {
      _layers.removeAt(removeLayerIndex);
    }
  }

  /// Update the temporary layer in the editor.
  ///
  /// This method updates the temporary layer in the editor and updates the editing state.
  void _updateTempLayer() {
    _cleanForwardChanges();
    _stateHistory.add(
      EditorStateHistory(
        bytesRefIndex: _imgStateHistory.length - 1,
        layers: List.from(_stateHistory.last.layers.map((e) => _copyLayer(e))),
        filters: _filters,
      ),
    );
    var oldIndex =
        _layers.indexWhere((element) => element.id == _tempLayer!.id);
    if (oldIndex >= 0) {
      _stateHistory[_editPosition].layers[oldIndex] = _copyLayer(_tempLayer!);
    }
    _editPosition++;
    _tempLayer = null;
  }

  /// Remove a layer from the editor.
  ///
  /// This method removes a layer from the editor and updates the editing state.
  void _removeLayer(int layerPos, {Layer? layer}) {
    _cleanForwardChanges();
    var layers = List<Layer>.from(_layers.map((e) => _copyLayer(e)));
    layers.removeAt(layerPos);
    _stateHistory.add(
      EditorStateHistory(
        bytesRefIndex: _imgStateHistory.length - 1,
        layers: layers,
        filters: _filters,
      ),
    );
    var oldIndex = _layers
        .indexWhere((element) => element.id == (layer?.id ?? _tempLayer!.id));
    if (oldIndex >= 0) {
      _stateHistory[_editPosition].layers[oldIndex] =
          _copyLayer(layer ?? _tempLayer!);
    }
    _editPosition++;
  }

  /// Open a new page on top of the current page.
  ///
  /// This method navigates to a new page using a fade transition animation.
  Future<T?> _openPage<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.push<T?>(
      context,
      PageRouteBuilder(
        opaque: false,
        transitionDuration: duration,
        reverseTransitionDuration: duration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        pageBuilder: (context, animation, secondaryAnimation) => page,
      ),
    );
  }

  /// Decode the image being edited.
  ///
  /// This method decodes the image if it hasn't been decoded yet and updates its properties.
  void _decodeImage() async {
    bool shouldImportStateHistory =
        _imageNeedDecode && widget.configs.initStateHistory != null;
    _imageNeedDecode = false;
    var decodedImage = await decodeImageFromList(await _image.safeByteArray);

    if (!mounted) return;
    var w = decodedImage.width;
    var h = decodedImage.height;

    var widthRatio = w.toDouble() / _screen.width;
    var heightRatio = h.toDouble() / _screenInnerHeight;
    _pixelRatio = max(heightRatio, widthRatio);

    _imageWidth = w / _pixelRatio;
    _imageHeight = h / _pixelRatio;
    _inited = true;

    if (shouldImportStateHistory) {
      importStateHistory(widget.configs.initStateHistory!);
    }

    setState(() {});
    widget.onUpdateUI?.call();
  }

  /// Copy a layer to create a new instance of the same type.
  ///
  /// This method takes a layer and creates a new instance of the same type.
  Layer _copyLayer(Layer layer) {
    if (layer is TextLayerData) {
      return _createCopyTextLayer(layer);
    } else if (layer is EmojiLayerData) {
      return _createCopyEmojiLayer(layer);
    } else if (layer is PaintingLayerData) {
      return _createCopyPaintingLayer(layer);
    } else if (layer is StickerLayerData) {
      return _createCopyStickerLayer(layer);
    } else {
      return layer;
    }
  }

  /// Create a copy of a TextLayerData instance.
  TextLayerData _createCopyTextLayer(TextLayerData layer) {
    return TextLayerData(
      id: layer.id,
      text: layer.text,
      align: layer.align,
      background: Color(layer.background.value),
      color: Color(layer.color.value),
      colorMode: layer.colorMode,
      colorPickerPosition: layer.colorPickerPosition,
      offset: Offset(layer.offset.dx, layer.offset.dy),
      rotation: layer.rotation,
      scale: layer.scale,
      flipX: layer.flipX,
      flipY: layer.flipY,
    );
  }

  /// Create a copy of an EmojiLayerData instance.
  EmojiLayerData _createCopyEmojiLayer(EmojiLayerData layer) {
    return EmojiLayerData(
      id: layer.id,
      emoji: layer.emoji,
      offset: Offset(layer.offset.dx, layer.offset.dy),
      rotation: layer.rotation,
      scale: layer.scale,
      flipX: layer.flipX,
      flipY: layer.flipY,
    );
  }

  /// Create a copy of an EmojiLayerData instance.
  StickerLayerData _createCopyStickerLayer(StickerLayerData layer) {
    return StickerLayerData(
      id: layer.id,
      sticker: layer.sticker,
      offset: Offset(layer.offset.dx, layer.offset.dy),
      rotation: layer.rotation,
      scale: layer.scale,
      flipX: layer.flipX,
      flipY: layer.flipY,
    );
  }

  /// Create a copy of a PaintingLayerData instance.
  PaintingLayerData _createCopyPaintingLayer(PaintingLayerData layer) {
    return PaintingLayerData(
      id: layer.id,
      offset: Offset(layer.offset.dx, layer.offset.dy),
      rotation: layer.rotation,
      scale: layer.scale,
      flipX: layer.flipX,
      flipY: layer.flipY,
      item: layer.item.copy(),
      rawSize: layer.rawSize,
    );
  }

  /// Set the temporary layer to a copy of the provided layer.
  void _setTempLayer(Layer layer) {
    _tempLayer = _copyLayer(layer);
  }

  /// Vibrates the device briefly if enabled and supported.
  ///
  /// This function checks if helper lines hit vibration is enabled in the widget's
  /// configurations (`widget.configs.helperLines.hitVibration`) and whether the
  /// device supports vibration. If both conditions are met, it triggers a brief
  /// vibration on the device.
  ///
  /// If the device supports custom vibrations, it uses the `Vibration.vibrate`
  /// method with a duration of 3 milliseconds to produce the vibration.
  ///
  /// On older Android devices, it initiates vibration using `Vibration.vibrate`,
  /// and then, after 3 milliseconds, cancels the vibration using `Vibration.cancel`.
  ///
  /// This function is used to provide haptic feedback when helper lines are interacted
  /// with, enhancing the user experience.
  void _lineHitVibrate() {
    if (widget.configs.helperLines.hitVibration && _deviceCanVibrate) {
      if (_deviceCanCustomVibrate) {
        Vibration.vibrate(duration: 3);
      } else if (Platform.isAndroid) {
        // On old android devices we can stop the vibration after 3 milliseconds
        // iOS: only works for custom haptic vibrations using CHHapticEngine.
        // This will set `_deviceCanCustomVibrate` anyway to true so it's impossible to fake it.
        Vibration.vibrate();
        Future.delayed(const Duration(milliseconds: 3)).whenComplete(() {
          Vibration.cancel();
        });
      }
    }
  }

  /// Handle the start of a scaling operation.
  ///
  /// This method is called when a scaling operation begins and initializes the necessary variables.
  void _onScaleStart(ScaleStartDetails details) {
    if (_selectedLayer < 0) return;
    _snapStartPosX = details.focalPoint.dx;
    _snapStartPosY = details.focalPoint.dy;
    var layer = _layers[_selectedLayer];
    _setTempLayer(layer);
    _baseScaleFactor = layer.scale;
    _baseAngleFactor = layer.rotation;
    _snapStartRotation = layer.rotation * 180 / pi;
    _snapLastRotation = _snapStartRotation;
    _rotationStartedHelper = false;
    _showHelperLines = true;

    double posX = layer.offset.dx + screenPaddingHelper.left;
    double posY = layer.offset.dy + screenPaddingHelper.top;

    _lastPositionY = posY <= _screenMiddleY - _hitSpan
        ? LayerLastPosition.top
        : posY >= _screenMiddleY + _hitSpan
            ? LayerLastPosition.bottom
            : LayerLastPosition.center;

    _lastPositionX = posX <= _screenMiddleX - _hitSpan
        ? LayerLastPosition.left
        : posX >= _screenMiddleX + _hitSpan
            ? LayerLastPosition.right
            : LayerLastPosition.center;
  }

  /// Handle updates during scaling.
  ///
  /// This method is called during a scaling operation and updates the selected layer's position and properties.
  void _onScaleUpdate(ScaleUpdateDetails detail) {
    if (_selectedLayer < 0) return;

    _enabledHitDetection = false;
    if (detail.pointerCount == 1) {
      if (_activeScale) return;
      _freeStyleHighPerformanceMoving =
          widget.configs.paintEditorConfigs.freeStyleHighPerformanceMoving ??
              isWebMobile;
      _activeLayer.offset = Offset(
        _activeLayer.offset.dx + detail.focalPointDelta.dx,
        _activeLayer.offset.dy + detail.focalPointDelta.dy,
      );

      hoverRemoveBtn = detail.focalPoint.dx <= kToolbarHeight &&
          detail.focalPoint.dy <=
              kToolbarHeight + MediaQuery.of(context).viewPadding.top;

      bool vibarate = false;
      double posX = _activeLayer.offset.dx + screenPaddingHelper.left;
      double posY = _activeLayer.offset.dy + screenPaddingHelper.top;

      bool hitAreaX = detail.focalPoint.dx >= _snapStartPosX - _hitSpan &&
          detail.focalPoint.dx <= _snapStartPosX + _hitSpan;
      bool hitAreaY = detail.focalPoint.dy >= _snapStartPosY - _hitSpan &&
          detail.focalPoint.dy <= _snapStartPosY + _hitSpan;

      bool helperGoNearLineLeft =
          posX >= _screenMiddleX && _lastPositionX == LayerLastPosition.left;
      bool helperGoNearLineRight =
          posX <= _screenMiddleX && _lastPositionX == LayerLastPosition.right;
      bool helperGoNearLineTop =
          posY >= _screenMiddleY && _lastPositionY == LayerLastPosition.top;
      bool helperGoNearLineBottom =
          posY <= _screenMiddleY && _lastPositionY == LayerLastPosition.bottom;

      /// Calc vertical helper line
      if ((!_showVerticalHelperLine &&
              (helperGoNearLineLeft || helperGoNearLineRight)) ||
          (_showVerticalHelperLine && hitAreaX)) {
        if (!_showVerticalHelperLine) {
          vibarate = true;
          _snapStartPosX = detail.focalPoint.dx;
        }
        _showVerticalHelperLine = true;
        _activeLayer.offset = Offset(
            _screenMiddleX - screenPaddingHelper.left, _activeLayer.offset.dy);
        _lastPositionX = LayerLastPosition.center;
      } else {
        _showVerticalHelperLine = false;
        _lastPositionX = posX <= _screenMiddleX
            ? LayerLastPosition.left
            : LayerLastPosition.right;
      }

      /// Calc horizontal helper line
      if ((!_showHorizontalHelperLine &&
              (helperGoNearLineTop || helperGoNearLineBottom)) ||
          (_showHorizontalHelperLine && hitAreaY)) {
        if (!_showHorizontalHelperLine) {
          vibarate = true;
          _snapStartPosY = detail.focalPoint.dy;
        }
        _showHorizontalHelperLine = true;
        _activeLayer.offset = Offset(
            _activeLayer.offset.dx, _screenMiddleY - screenPaddingHelper.top);
        _lastPositionY = LayerLastPosition.center;
      } else {
        _showHorizontalHelperLine = false;
        _lastPositionY = posY <= _screenMiddleY
            ? LayerLastPosition.top
            : LayerLastPosition.bottom;
      }

      if (vibarate) {
        _lineHitVibrate();
      }
    } else if (detail.pointerCount == 2) {
      _freeStyleHighPerformanceScaling =
          widget.configs.paintEditorConfigs.freeStyleHighPerformanceScaling ??
              !isDesktop;
      _activeScale = true;

      _activeLayer.scale = _baseScaleFactor * detail.scale;
      _activeLayer.rotation = _baseAngleFactor + detail.rotation;

      var hitSpanX = _hitSpan / 2;
      var deg = _activeLayer.rotation * 180 / pi;
      var degChange = detail.rotation * 180 / pi;
      var degHit = (_snapStartRotation + degChange) % 45;
      var hitAreaBelow = degHit <= hitSpanX;
      var hitAreaAfter = degHit >= 45 - hitSpanX;
      var hitArea = hitAreaBelow || hitAreaAfter;

      if ((!_showRotationHelperLine &&
              ((degHit > 0 && degHit <= hitSpanX && _snapLastRotation < deg) ||
                  (degHit < 45 &&
                      degHit >= 45 - hitSpanX &&
                      _snapLastRotation > deg))) ||
          (_showRotationHelperLine && hitArea)) {
        if (_rotationStartedHelper) {
          _activeLayer.rotation =
              (deg - (degHit > 45 - hitSpanX ? degHit - 45 : degHit)) /
                  180 *
                  pi;
          _rotationHelperLineDeg = _activeLayer.rotation;

          double posY = _activeLayer.offset.dy + screenPaddingHelper.top;
          double posX = _activeLayer.offset.dx + screenPaddingHelper.left;

          _rotationHelperLineX = posX;
          _rotationHelperLineY = posY;
          if (!_showRotationHelperLine) {
            _lineHitVibrate();
          }
          _showRotationHelperLine = true;
        }
        _snapLastRotation = deg;
      } else {
        _showRotationHelperLine = false;
        _rotationStartedHelper = true;
      }

      _scaleDebounce(() => _activeScale = false);
    }
    setState(() {});
    widget.onUpdateUI?.call();
  }

  /// Handle the end of a scaling operation.
  ///
  /// This method is called when a scaling operation ends and resets helper lines and flags.
  void _onScaleEnd(ScaleEndDetails detail) {
    if (!hoverRemoveBtn && _tempLayer != null) _updateTempLayer();

    _enabledHitDetection = true;
    _freeStyleHighPerformanceScaling = false;
    _freeStyleHighPerformanceMoving = false;
    _showHorizontalHelperLine = false;
    _showVerticalHelperLine = false;
    _showRotationHelperLine = false;
    _showHelperLines = false;
    hoverRemoveBtn = false;
    setState(() {});
    widget.onUpdateUI?.call();
  }

  /// Rotate a layer.
  ///
  /// This method rotates a layer based on various factors, including flip and angle.
  void _rotateLayer({
    required Layer layer,
    required bool beforeIsFlipX,
    required double newImgW,
    required double newImgH,
    required double rotationScale,
    required double rotationRadian,
    required double rotationAngle,
  }) {
    if (beforeIsFlipX) {
      layer.rotation -= rotationRadian;
    } else {
      layer.rotation += rotationRadian;
    }

    if (rotationAngle == 90) {
      layer.scale /= rotationScale;
      layer.offset = Offset(
        newImgW - layer.offset.dy / rotationScale,
        layer.offset.dx / rotationScale,
      );
    } else if (rotationAngle == 180) {
      layer.offset = Offset(
        newImgW - layer.offset.dx,
        newImgH - layer.offset.dy,
      );
    } else if (rotationAngle == 270) {
      layer.scale /= rotationScale;
      layer.offset = Offset(
        layer.offset.dy / rotationScale,
        newImgH - layer.offset.dx / rotationScale,
      );
    }
  }

  /// Flip a layer horizontally or vertically.
  ///
  /// This method flips a layer either horizontally or vertically based on the specified parameters.
  void _flipLayer({
    required Layer layer,
    required bool flipX,
    required bool flipY,
    required bool isHalfPi,
  }) {
    if (flipY) {
      if (isHalfPi) {
        layer.flipY = !layer.flipY;
      } else {
        layer.flipX = !layer.flipX;
      }
      layer.offset = Offset(
        _imageWidth - layer.offset.dx,
        layer.offset.dy,
      );
    }
    if (flipX) {
      layer.flipX = !layer.flipX;
      layer.offset = Offset(
        layer.offset.dx,
        _imageHeight - layer.offset.dy,
      );
    }
  }

  /// Handles zooming of a layer.
  ///
  /// This method calculates the zooming of a layer based on the specified parameters.
  /// It checks if the layer should be zoomed and performs the necessary transformations.
  ///
  /// Returns `true` if the layer was zoomed, otherwise `false`.
  bool _zoomedLayer({
    required Layer layer,
    required double scale,
    required double scaleX,
    required double oldFullH,
    required double oldFullW,
    required Rect cropRect,
    required bool isHalfPi,
  }) {
    var paddingTop = cropRect.top / _pixelRatio;
    var paddingLeft = cropRect.left / _pixelRatio;
    var paddingRight = oldFullW - cropRect.right;
    var paddingBottom = oldFullH - cropRect.bottom;

    // important to check with < 1 and >-1 cuz crop-editor has rounding bugs
    if (paddingTop > 0.1 ||
        paddingTop < -0.1 ||
        paddingLeft > 0.1 ||
        paddingLeft < -0.1 ||
        paddingRight > 0.1 ||
        paddingRight < -0.1 ||
        paddingBottom > 0.1 ||
        paddingBottom < -0.1) {
      var initialIconX = (layer.offset.dx - paddingLeft) * scaleX;
      var initialIconY = (layer.offset.dy - paddingTop) * scaleX;
      layer.offset = Offset(
        initialIconX,
        initialIconY,
      );

      layer.scale *= scale;
      return true;
    }
    return false;
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
        i18n: widget.configs.i18n,
        icons: widget.configs.icons,
        imageEditorTheme: widget.configs.imageEditorTheme,
        customWidgets: widget.configs.customWidgets,
        configs: widget.configs.textEditorConfigs,
        designMode: widget.configs.designMode,
        theme: _theme,
        onUpdateUI: widget.onUpdateUI,
      ),
      duration: const Duration(milliseconds: 50),
    );

    if (layer == null || !mounted) return;

    int i = _layers.indexWhere((element) => element.id == layerData.id);
    if (i >= 0) {
      _setTempLayer(layerData);
      TextLayerData textLayer = _layers[i] as TextLayerData;
      textLayer
        ..text = layer.text
        ..background = layer.background
        ..color = layer.color
        ..colorMode = layer.colorMode
        ..colorPickerPosition = layer.colorPickerPosition
        ..align = layer.align
        ..id = layerData.id
        ..flipX = layerData.flipX
        ..flipY = layerData.flipY
        ..offset = layerData.offset
        ..scale = layerData.scale
        ..rotation = layerData.rotation;

      _updateTempLayer();
    }

    setState(() {});
    widget.onUpdateUI?.call();
  }

  /// Opens the painting editor.
  ///
  /// This method opens the painting editor and allows the user to draw on the current image.
  /// After closing the painting editor, any changes made are applied to the image's layers.
  void openPaintingEditor() async {
    _openEditor = true;
    await _openPage<List<PaintingLayerData>>(
      PaintingEditor.autoSource(
        key: paintingEditor,
        file: _image.file,
        byteArray: _image.byteArray,
        assetPath: _image.assetPath,
        networkUrl: _image.networkUrl,
        icons: widget.configs.icons,
        layers: _layers,
        theme: _theme,
        i18n: widget.configs.i18n,
        imageSize: Size(_imageWidth, _imageHeight),
        imageEditorTheme: widget.configs.imageEditorTheme,
        customWidgets: widget.configs.customWidgets,
        layerFontSize: widget.configs.textEditorConfigs.initFontSize,
        configs: widget.configs.paintEditorConfigs,
        stickerInitWidth: widget.configs.stickerEditorConfigs?.initWidth ?? 100,
        paddingHelper: EdgeInsets.only(
          top: (_screen.height -
                      _screenPadding.top -
                      _screenPadding.bottom -
                      _imageHeight) /
                  2 -
              kToolbarHeight,
          left: (_screen.width -
                  _screenPadding.left -
                  _screenPadding.right -
                  _imageWidth) /
              2,
        ),
        designMode: widget.configs.designMode,
        emojiTextStyle: widget.configs.emojiEditorConfigs.textStyle,
        onUpdateUI: widget.onUpdateUI,
        filters: _filters,
      ),
      duration: const Duration(milliseconds: 150),
    ).then((List<PaintingLayerData>? paintingLayers) {
      if (paintingLayers != null && paintingLayers.isNotEmpty) {
        for (var layer in paintingLayers) {
          addLayer(layer);
        }

        setState(() {});
        widget.onUpdateUI?.call();
      }
    });
    _openEditor = false;
  }

  /// Opens the text editor.
  ///
  /// This method opens the text editor, allowing the user to add or edit text layers on the image.
  void openTextEditor() async {
    _openEditor = true;
    TextLayerData? layer = await _openPage(
      TextEditor(
        key: textEditor,
        i18n: widget.configs.i18n,
        icons: widget.configs.icons,
        imageEditorTheme: widget.configs.imageEditorTheme,
        customWidgets: widget.configs.customWidgets,
        configs: widget.configs.textEditorConfigs,
        designMode: widget.configs.designMode,
        theme: _theme,
        onUpdateUI: widget.onUpdateUI,
      ),
      duration: const Duration(milliseconds: 50),
    );
    _openEditor = false;

    if (layer == null || !mounted) return;
    layer.offset = Offset(
      _imageWidth / 2,
      _imageHeight / 2,
    );

    addLayer(layer);

    setState(() {});
    widget.onUpdateUI?.call();
  }

  /// Opens the crop editor.
  ///
  /// This method opens the crop editor, allowing the user to crop and rotate the image.
  void openCropEditor() async {
    if (_activeCrop) return;
    EditorImage img = EditorImage(
      assetPath: _image.assetPath,
      byteArray: _image.byteArray,
      file: _image.file,
      networkUrl: _image.networkUrl,
    );
    Uint8List? bytesWithLayers;
    if (_layers.isNotEmpty || _filters.isNotEmpty) {
      _activeCrop = true;
      LoadingDialog loading = LoadingDialog()
        ..show(
          context,
          theme: _theme,
          imageEditorTheme: widget.configs.imageEditorTheme,
          designMode: widget.configs.designMode,
          i18n: widget.configs.i18n,
          message: widget.configs.i18n.cropRotateEditor.prepareImageDialogMsg,
        );
      bytesWithLayers = await _screenshotCtrl.capture(
        pixelRatio: _pixelRatio,
      );
      if (mounted) await loading.hide(context);
    }
    _activeCrop = false;
    if (!mounted) return;

    _openEditor = true;

    _openPage<CropRotateEditorRes?>(
      CropRotateEditor.autoSource(
        key: cropRotateEditor,
        file: img.file,
        onUpdateUI: widget.onUpdateUI,
        byteArray: img.byteArray,
        assetPath: img.assetPath,
        networkUrl: img.networkUrl,
        bytesWithLayers: bytesWithLayers,
        i18n: widget.configs.i18n,
        icons: widget.configs.icons,
        theme: _theme,
        imageSize: Size(_imageWidth, _imageHeight),
        heroTag: widget.configs.heroTag,
        designMode: widget.configs.designMode,
        imageEditorTheme: widget.configs.imageEditorTheme,
        customWidgets: widget.configs.customWidgets,
        configs: widget.configs.cropRotateEditorConfigs,
      ),
    ).then((response) async {
      _openEditor = false;
      if (response != null) {
        CropRotateEditorResponse res = response.result;
        if (res.bytes != null) {
          var decodedImage = response.image;
          if (!mounted) return;
          var w = decodedImage.width;
          var h = decodedImage.height;

          var widthRatio = w.toDouble() / _screen.width;
          var heightRatio = h.toDouble() / _screenInnerHeight;
          var newPixelRatio = max(heightRatio, widthRatio);

          var newImgW = w / newPixelRatio;
          var newImgH = h / newPixelRatio;
          var scale = (_imageWidth * _pixelRatio) / w;
          var oldFullW = _imageWidth * _pixelRatio;
          var oldFullH = _imageHeight * _pixelRatio;

          var rotationScale = _imageWidth / newImgH;

          double fitFactor = 1;

          bool oldFitWidth = _imageWidth >= _screen.width - 0.1 &&
              _imageWidth <= _screen.width + 0.1;
          bool newFitWidth =
              newImgW >= _screen.width - 0.1 && newImgW <= _screen.width + 0.1;
          var scaleX = newFitWidth ? oldFullW / w : oldFullH / h;

          if (oldFitWidth != newFitWidth) {
            if (newFitWidth) {
              fitFactor = _imageWidth / newImgW;
            } else {
              fitFactor = _imageHeight / newImgH;
            }
          }

          List<Layer> updatedLayers = [];
          for (var el in _layers) {
            var layer = _copyLayer(el);
            var beforeIsFlipX = layer.flipX;
            switch (res.rotationAngle) {
              case 0:
              case 180:
                layer.offset = Offset(
                  layer.offset.dx / fitFactor,
                  layer.offset.dy / fitFactor,
                );
                break;
              case 180:
                layer.offset = Offset(
                  layer.offset.dx / fitFactor,
                  layer.offset.dy / fitFactor,
                );
                break;
              default:
            }
            bool zoomed = _zoomedLayer(
              layer: layer,
              scale: scale,
              scaleX: scaleX,
              oldFullH: oldFullH,
              oldFullW: oldFullW,
              cropRect: res.cropRect,
              isHalfPi: res.isHalfPi,
            );
            _flipLayer(
              layer: layer,
              flipX: res.flipX,
              flipY: res.flipY,
              isHalfPi: res.isHalfPi,
            );
            _rotateLayer(
              layer: layer,
              beforeIsFlipX: beforeIsFlipX,
              newImgW: newImgW,
              newImgH: newImgH,
              rotationAngle: res.rotationAngle,
              rotationRadian: res.rotationRadian,
              rotationScale: zoomed ? 1 : rotationScale,
            );

            updatedLayers.add(layer);
          }

          _addCroppedImg(updatedLayers, EditorImage(byteArray: res.bytes));
          _pixelRatio = max(heightRatio, widthRatio);
          _imageWidth = w / _pixelRatio;
          _imageHeight = h / _pixelRatio;
          setState(() {});
          widget.onUpdateUI?.call();
        }
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
    _openEditor = true;
    FilterStateHistory? filterAppliedImage = await _openPage(
      FilterEditor.autoSource(
        key: filterEditor,
        file: _image.file,
        byteArray: _image.byteArray,
        assetPath: _image.assetPath,
        networkUrl: _image.networkUrl,
        theme: _theme,
        i18n: widget.configs.i18n,
        icons: widget.configs.icons,
        heroTag: widget.configs.heroTag,
        designMode: widget.configs.designMode,
        imageEditorTheme: widget.configs.imageEditorTheme,
        customWidgets: widget.configs.customWidgets,
        configs: widget.configs.filterEditorConfigs,
        onUpdateUI: widget.onUpdateUI,
        activeFilters: _filters,
        convertToUint8List: false,
      ),
    );
    _openEditor = false;

    if (filterAppliedImage == null) return;

    _cleanForwardChanges();

    _stateHistory.add(
      EditorStateHistory(
        bytesRefIndex: _imgStateHistory.length - 1,
        layers: _layers,
        filters: [
          filterAppliedImage,
          ..._filters,
        ],
      ),
    );
    _editPosition++;

    setState(() {});
    widget.onUpdateUI?.call();
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
    ServicesBinding.instance.keyboard.removeHandler(_onKey);
    EmojiLayerData? layer = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (BuildContext context) => EmojiEditor(
        i18n: widget.configs.i18n,
        imageEditorTheme: widget.configs.imageEditorTheme,
        designMode: widget.configs.designMode,
        configs: widget.configs.emojiEditorConfigs,
      ),
    );
    ServicesBinding.instance.keyboard.addHandler(_onKey);
    if (layer == null || !mounted) return;
    layer.scale = widget.configs.emojiEditorConfigs.initScale;
    layer.offset = Offset(
      _imageWidth / 2,
      _imageHeight / 2,
    );

    addLayer(layer);

    setState(() {});
    widget.onUpdateUI?.call();
  }

  /// Opens the sticker editor as a modal bottom sheet.
  void openStickerEditor() async {
    ServicesBinding.instance.keyboard.removeHandler(_onKey);
    StickerLayerData? layer = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (BuildContext context) => StickerEditor(
        i18n: widget.configs.i18n,
        imageEditorTheme: widget.configs.imageEditorTheme,
        designMode: widget.configs.designMode,
        configs: widget.configs.stickerEditorConfigs!,
      ),
    );
    ServicesBinding.instance.keyboard.addHandler(_onKey);
    if (layer == null || !mounted) return;
    layer.offset = Offset(
      _imageWidth / 2,
      _imageHeight / 2,
    );

    addLayer(layer);

    setState(() {});
    widget.onUpdateUI?.call();
  }

  /// Undo the last editing action.
  ///
  /// This function allows the user to undo the most recent editing action performed on the image.
  /// It decreases the edit position, and the image is decoded to reflect the previous state.
  void undoAction() {
    if (_editPosition > 0) {
      setState(() {
        _editPosition--;
        _decodeImage();
      });
      widget.onUpdateUI?.call();
    }
  }

  /// Redo the previously undone editing action.
  ///
  /// This function allows the user to redo an editing action that was previously undone using the
  /// `undoAction` function. It increases the edit position, and the image is decoded to reflect
  /// the next state.
  void redoAction() {
    if (_editPosition < _stateHistory.length - 1) {
      setState(() {
        _editPosition++;
        _decodeImage();
      });
      widget.onUpdateUI?.call();
    }
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
    if (_editPosition <= 0 && _layers.isEmpty) {
      return closeEditor();
    }
    _doneEditing = true;
    LoadingDialog loading = LoadingDialog()
      ..show(
        context,
        i18n: widget.configs.i18n,
        theme: _theme,
        designMode: widget.configs.designMode,
        message: widget.configs.i18n.doneLoadingMsg,
        imageEditorTheme: widget.configs.imageEditorTheme,
      );

    var bytes = await _screenshotCtrl.capture(pixelRatio: _pixelRatio);

    if (bytes != null) {
      await widget.onImageEditingComplete(bytes);
    }

    if (mounted) loading.hide(context);

    widget.onCloseEditor?.call();
  }

  /// Close the image editor.
  ///
  /// This function allows the user to close the image editor without saving any changes or edits.
  /// It navigates back to the previous screen or closes the modal editor.
  void closeEditor() {
    if (_editPosition <= 0) {
      if (widget.onCloseEditor == null) {
        Navigator.pop(context);
      } else {
        widget.onCloseEditor!.call();
      }
    } else {
      closeWarning();
    }
  }

  /// Displays a warning dialog before closing the image editor.
  void closeWarning() async {
    _openDialog = true;
    await showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) => AdaptiveDialog(
        designMode: widget.configs.designMode,
        brightness: _theme.brightness,
        title: Text(widget.configs.i18n.various.closeEditorWarningTitle),
        content: Text(widget.configs.i18n.various.closeEditorWarningMessage),
        actions: <AdaptiveDialogAction>[
          AdaptiveDialogAction(
            designMode: widget.configs.designMode,
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child:
                Text(widget.configs.i18n.various.closeEditorWarningCancelBtn),
          ),
          AdaptiveDialogAction(
            designMode: widget.configs.designMode,
            onPressed: () {
              _editPosition = 0;
              Navigator.pop(context, 'OK');
              if (widget.onCloseEditor == null) {
                Navigator.pop(context);
              } else {
                widget.onCloseEditor!.call();
              }
            },
            child:
                Text(widget.configs.i18n.various.closeEditorWarningConfirmBtn),
          ),
        ],
      ),
    );
    _openDialog = false;
  }

  /// Handles Keyboard zoom event
  void _keyboardRotate(bool left) {
    if (left) {
      _activeLayer.rotation -= 0.087266;
    } else {
      _activeLayer.rotation += 0.087266;
    }
    setState(() {});
    widget.onUpdateUI?.call();
  }

  /// Handles Keyboard zoom event
  void _keyboardZoom(bool zoomIn) {
    double factor = _activeLayer is PaintingLayerData
        ? 0.1
        : _activeLayer is TextLayerData
            ? 0.15
            : widget.configs.textEditorConfigs.initFontSize / 50;
    if (zoomIn) {
      _activeLayer.scale -= factor;
      _activeLayer.scale = max(0.1, _activeLayer.scale);
    } else {
      _activeLayer.scale += factor;
    }
    setState(() {});
    widget.onUpdateUI?.call();
  }

  /// Handles mouse scroll events.
  void _mouseScroll(PointerSignalEvent event) {
    bool shiftDown = RawKeyboard.instance.keysPressed
            .contains(LogicalKeyboardKey.shiftLeft) ||
        RawKeyboard.instance.keysPressed
            .contains(LogicalKeyboardKey.shiftRight);

    if (event is PointerScrollEvent && _selectedLayer >= 0) {
      if (shiftDown) {
        if (event.scrollDelta.dy > 0) {
          _activeLayer.rotation -= 0.087266;
        } else if (event.scrollDelta.dy < 0) {
          _activeLayer.rotation += 0.087266;
        }
      } else {
        double factor = _activeLayer is PaintingLayerData
            ? 0.1
            : _activeLayer is TextLayerData
                ? 0.15
                : widget.configs.textEditorConfigs.initFontSize / 50;
        if (event.scrollDelta.dy > 0) {
          _activeLayer.scale -= factor;
          _activeLayer.scale = max(0.1, _activeLayer.scale);
        } else if (event.scrollDelta.dy < 0) {
          _activeLayer.scale += factor;
        }
      }
      setState(() {});
      widget.onUpdateUI?.call();
    }
  }

  /// Get the screen padding values.
  EdgeInsets get screenPaddingHelper => EdgeInsets.only(
        top: (_screen.height -
                _screenPadding.top -
                _screenPadding.bottom -
                _imageHeight) /
            2,
        left: (_screen.width -
                _screenPadding.left -
                _screenPadding.right -
                _imageWidth) /
            2,
      );

  /// Determines whether undo actions can be performed on the current state.
  bool get canUndo => _editPosition > 0;

  /// Determines whether redo actions can be performed on the current state.
  bool get canRedo => _editPosition < _stateHistory.length - 1;

  void importStateHistory(ImportStateHistory import) {
    /// Recalculate position and size
    if (import.configs.recalculateSizeAndPosition) {
      var imgSize = import.imgSize;
      for (var el in import.stateHistory) {
        for (var layer in el.layers) {
          // Calculate scaling factors for width and height
          double scaleWidth = _imageWidth / imgSize.width;
          double scaleHeight = _imageHeight / imgSize.height;

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
      _editPosition = import.editorPosition + 1;
      if (import.imgStateHistory.isNotEmpty) {
        _imgStateHistory = import.imgStateHistory;
      }
      _stateHistory = [
        EditorStateHistory(bytesRefIndex: 0, filters: [], layers: []),
        ...import.stateHistory
      ];
    } else {
      for (var el in import.stateHistory) {
        if (import.configs.mergeMode == ImportEditorMergeMode.merge) {
          el.layers.insertAll(0, _stateHistory.last.layers);
          el.filters.insertAll(0, _stateHistory.last.filters);
        }
      }

      _stateHistory.addAll(import.stateHistory);
      _imgStateHistory.addAll(import.imgStateHistory);
      _editPosition = _stateHistory.length - 1;
    }

    setState(() {});
    widget.onUpdateUI?.call();
  }

  ExportStateHistory exportStateHistory(
      {ExportEditorConfigs configs = const ExportEditorConfigs()}) {
    return ExportStateHistory(
      _stateHistory,
      _imgStateHistory,
      Size(_imageWidth, _imageHeight),
      _editPosition,
      configs: configs,
    );
  }

  @override
  Widget build(BuildContext context) {
    _theme = widget.configs.theme ??
        ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue.shade800,
            brightness: Brightness.dark,
          ),
        );
    if (_imageNeedDecode) _decodeImage();
    return OrientationBuilder(builder: (context, orientation) {
      if (_deviceOrientation != orientation.index) {
        _deviceOrientation = orientation.index;
      }
      return PopScope(
        canPop: _editPosition <= 0 || _doneEditing,
        onPopInvoked: (didPop) {
          if (_editPosition > 0 && !_doneEditing) {
            closeWarning();
          }
        },
        child: LayoutBuilder(builder: (context, constraints) {
          // Check if screensize changed to recalculate image size
          if (_lastScreenSize.width != constraints.maxWidth ||
              _lastScreenSize.height != constraints.maxHeight) {
            _screenSizeDebouncer(() {
              _decodeImage();
            });
            _lastScreenSize = Size(
              constraints.maxWidth,
              constraints.maxHeight,
            );
          }

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: widget.configs.imageEditorTheme.uiOverlayStyle,
            child: Theme(
              data: _theme,
              child: SafeArea(
                child: Scaffold(
                  backgroundColor: widget.configs.imageEditorTheme.background,
                  resizeToAvoidBottomInset: false,
                  appBar: _buildAppBar(),
                  body: _buildBody(),
                  bottomNavigationBar: _buildBottomNavBar(),
                ),
              ),
            ),
          );
        }),
      );
    });
  }

  PreferredSizeWidget? _buildAppBar() {
    return _selectedLayer >= 0
        ? null
        : widget.configs.customWidgets.appBar ??
            AppBar(
              automaticallyImplyLeading: false,
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
              actions: [
                IconButton(
                  tooltip: widget.configs.i18n.cancel,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  icon: Icon(widget.configs.icons.closeEditor),
                  onPressed: closeEditor,
                ),
                const Spacer(),
                IconButton(
                  key: const ValueKey('TextEditorMainUndoButton'),
                  tooltip: widget.configs.i18n.undo,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  icon: Icon(
                    widget.configs.icons.undoAction,
                    color: _editPosition > 0
                        ? Colors.white
                        : Colors.white.withAlpha(80),
                  ),
                  onPressed: undoAction,
                ),
                IconButton(
                  key: const ValueKey('TextEditorMainRedoButton'),
                  tooltip: widget.configs.i18n.redo,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  icon: Icon(
                    widget.configs.icons.redoAction,
                    color: _editPosition < _stateHistory.length - 1
                        ? Colors.white
                        : Colors.white.withAlpha(80),
                  ),
                  onPressed: redoAction,
                ),
                IconButton(
                  tooltip: widget.configs.i18n.done,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  icon: Icon(widget.configs.icons.doneIcon),
                  iconSize: 28,
                  onPressed: doneEditing,
                ),
              ],
            );
  }

  Widget _buildBody() {
    var editorImage = _buildImageWithFilter();

    return Listener(
      onPointerSignal: isDesktop ? _mouseScroll : null,
      child: GestureDetector(
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        onScaleEnd: _onScaleEnd,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Hero(
              tag: !_inited ? '--' : widget.configs.heroTag,
              createRectTween: (begin, end) =>
                  RectTween(begin: begin, end: end),
              child: Center(
                child: SizedBox(
                  height: _imageHeight,
                  width: _imageWidth,
                  child: StreamBuilder<bool>(
                      stream: _mouseMoveStream.stream,
                      initialData: false,
                      builder: (context, snapshot) {
                        return MouseRegion(
                          hitTestBehavior: HitTestBehavior.translucent,
                          cursor: snapshot.data != true
                              ? SystemMouseCursors.basic
                              : widget
                                  .configs.imageEditorTheme.layerHoverCursor,
                          onHover: isDesktop
                              ? (event) {
                                  var hasHit = _layers.indexWhere((element) =>
                                          element is PaintingLayerData &&
                                          element.item.hit) >=
                                      0;
                                  if (hasHit != snapshot.data) {
                                    _mouseMoveStream.add(hasHit);
                                  }
                                }
                              : null,
                          child: Screenshot(
                            controller: _screenshotCtrl,
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                Offstage(
                                  offstage: !_inited,
                                  child: editorImage,
                                ),
                                if (_selectedLayer < 0) _buildLayers(),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ),
            // show same image solong decoding that screenshot is ready
            if (!_inited) editorImage,
            if (_selectedLayer >= 0) _buildLayers(),
            _buildHelperLines(),
            if (_selectedLayer >= 0) _buildRemoveIcon(),
          ],
        ),
      ),
    );
  }

  Widget? _buildBottomNavBar() {
    var bottomTextStyle = const TextStyle(fontSize: 10.0, color: Colors.white);
    double bottomIconSize = 22.0;

    return _selectedLayer >= 0
        ? null
        : widget.configs.customWidgets.bottomNavigationBar ??
            Theme(
              data: _theme,
              child: Scrollbar(
                controller: _bottomBarScrollCtrl,
                scrollbarOrientation: ScrollbarOrientation.top,
                thickness: isDesktop ? null : 0,
                child: BottomAppBar(
                  height: kBottomNavigationBarHeight,
                  color: Colors.black,
                  padding: EdgeInsets.zero,
                  child: Center(
                    child: SingleChildScrollView(
                      controller: _bottomBarScrollCtrl,
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: min(_screen.width, 500),
                          maxWidth: 500,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              if (widget.configs.paintEditorConfigs.enabled)
                                FlatIconTextButton(
                                  key: const ValueKey(
                                      'open-painting-editor-btn'),
                                  label: Text(
                                      widget.configs.i18n.paintEditor
                                          .bottomNavigationBarText,
                                      style: bottomTextStyle),
                                  icon: Icon(
                                    widget.configs.icons.paintingEditor
                                        .bottomNavBar,
                                    size: bottomIconSize,
                                    color: Colors.white,
                                  ),
                                  onPressed: openPaintingEditor,
                                ),
                              if (widget.configs.textEditorConfigs.enabled)
                                FlatIconTextButton(
                                  key: const ValueKey('open-text-editor-btn'),
                                  label: Text(
                                      widget.configs.i18n.textEditor
                                          .bottomNavigationBarText,
                                      style: bottomTextStyle),
                                  icon: Icon(
                                    widget
                                        .configs.icons.textEditor.bottomNavBar,
                                    size: bottomIconSize,
                                    color: Colors.white,
                                  ),
                                  onPressed: openTextEditor,
                                ),
                              if (widget
                                  .configs.cropRotateEditorConfigs.enabled)
                                FlatIconTextButton(
                                  key: const ValueKey(
                                      'open-crop-rotate-editor-btn'),
                                  label: Text(
                                      widget.configs.i18n.cropRotateEditor
                                          .bottomNavigationBarText,
                                      style: bottomTextStyle),
                                  icon: Icon(
                                    widget.configs.icons.cropRotateEditor
                                        .bottomNavBar,
                                    size: bottomIconSize,
                                    color: Colors.white,
                                  ),
                                  onPressed: openCropEditor,
                                ),
                              if (widget.configs.filterEditorConfigs.enabled)
                                FlatIconTextButton(
                                  key: const ValueKey('open-filter-editor-btn'),
                                  label: Text(
                                      widget.configs.i18n.filterEditor
                                          .bottomNavigationBarText,
                                      style: bottomTextStyle),
                                  icon: Icon(
                                    widget.configs.icons.filterEditor
                                        .bottomNavBar,
                                    size: bottomIconSize,
                                    color: Colors.white,
                                  ),
                                  onPressed: openFilterEditor,
                                ),
                              if (widget.configs.emojiEditorConfigs.enabled)
                                FlatIconTextButton(
                                  key: const ValueKey('open-emoji-editor-btn'),
                                  label: Text(
                                      widget.configs.i18n.emojiEditor
                                          .bottomNavigationBarText,
                                      style: bottomTextStyle),
                                  icon: Icon(
                                    widget
                                        .configs.icons.emojiEditor.bottomNavBar,
                                    size: bottomIconSize,
                                    color: Colors.white,
                                  ),
                                  onPressed: openEmojiEditor,
                                ),
                              if (widget
                                      .configs.stickerEditorConfigs?.enabled ==
                                  true)
                                FlatIconTextButton(
                                  key:
                                      const ValueKey('open-sticker-editor-btn'),
                                  label: Text(
                                      widget.configs.i18n.stickerEditor
                                          .bottomNavigationBarText,
                                      style: bottomTextStyle),
                                  icon: Icon(
                                    widget.configs.icons.stickerEditor
                                        .bottomNavBar,
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
  }

  Widget _buildLayers() {
    int loopHelper = 0;
    return Stack(
      children: _layers.map((layerItem) {
        var i = loopHelper;
        loopHelper++;

        return LayerWidget(
          key: ValueKey('${layerItem.id}-$i'),
          layerHoverCursor: widget.configs.imageEditorTheme.layerHoverCursor,
          padding: _selectedLayer < 0 ? EdgeInsets.zero : screenPaddingHelper,
          layerData: layerItem,
          textFontSize: widget.configs.textEditorConfigs.initFontSize,
          emojiTextStyle: widget.configs.emojiEditorConfigs.textStyle,
          enabledHitDetection: _enabledHitDetection,
          freeStyleHighPerformanceScaling: _freeStyleHighPerformanceScaling,
          freeStyleHighPerformanceMoving: _freeStyleHighPerformanceMoving,
          designMode: widget.configs.designMode,
          stickerInitWidth:
              widget.configs.stickerEditorConfigs?.initWidth ?? 100,
          onTap: (layer) async {
            if (layer is TextLayerData) {
              _onTextLayerTap(layer);
            }
          },
          onTapUp: () {
            setState(() {
              if (hoverRemoveBtn) _removeLayer(_selectedLayer);
              _selectedLayer = -1;
            });
            widget.onUpdateUI?.call();
          },
          onTapDown: () {
            _selectedLayer = i;
          },
          onRemoveTap: () {
            setState(() {
              _removeLayer(
                  _layers.indexWhere((element) => element.id == layerItem.id),
                  layer: layerItem);
            });
            widget.onUpdateUI?.call();
          },
          i18n: widget.configs.i18n,
        );
      }).toList(),
    );
  }

  Widget _buildHelperLines() {
    double screenH = _screen.height;
    double screenW = _screen.width;
    double lineH = 1.25;
    int duration = 100;
    if (!_showHelperLines) return const SizedBox.shrink();
    return Stack(
      children: [
        if (widget.configs.helperLines.showVerticalLine)
          Align(
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: Duration(milliseconds: duration),
              width: _showVerticalHelperLine ? lineH : 0,
              height: screenH,
              color: widget.configs.imageEditorTheme.helperLine.verticalColor,
            ),
          ),
        if (widget.configs.helperLines.showHorizontalLine)
          Align(
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: Duration(milliseconds: duration),
              width: screenW,
              height: _showHorizontalHelperLine ? lineH : 0,
              color: widget.configs.imageEditorTheme.helperLine.horizontalColor,
            ),
          ),
        if (widget.configs.helperLines.showRotateLine)
          Positioned(
            left: _rotationHelperLineX,
            top: _rotationHelperLineY,
            child: FractionalTranslation(
              translation: const Offset(-0.5, -0.5),
              child: Transform.rotate(
                angle: _rotationHelperLineDeg,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: duration),
                  width: _showRotationHelperLine ? lineH : 0,
                  height: screenH * 2,
                  color: widget.configs.imageEditorTheme.helperLine.rotateColor,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRemoveIcon() {
    return widget.configs.customWidgets.removeLayer ??
        Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
            bottom: false,
            child: Container(
              height: kToolbarHeight,
              width: kToolbarHeight,
              decoration: BoxDecoration(
                color: hoverRemoveBtn ? Colors.red : Colors.grey.shade800,
                borderRadius:
                    const BorderRadius.only(bottomRight: Radius.circular(20)),
              ),
              child: Center(
                child: Icon(
                  widget.configs.icons.removeElementZone,
                  size: 28,
                ),
              ),
            ),
          ),
        );
  }

  Widget _buildImageWithFilter() {
    return ImageWithMultipleFilters(
      width: _imageWidth,
      height: _imageHeight,
      designMode: widget.configs.designMode,
      image: _image,
      filters: _filters,
    );
  }
}
