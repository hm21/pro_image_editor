// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:pro_image_editor/models/transform_helper.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import '../../mixins/converted_configs.dart';
import '../../mixins/standalone_editor.dart';
import '../../models/crop_rotate_editor/transform_factors.dart';
import '../../models/editor_image.dart';
import '../../models/history/filter_state_history.dart';
import '../../models/isolate_models/isolate_capture_model.dart';
import '../../utils/content_recorder.dart/content_recorder.dart';
import '../../utils/content_recorder.dart/content_recorder_controller.dart';
import '../../utils/decode_image.dart';
import '../../widgets/layer_stack.dart';
import '../../widgets/loading_dialog.dart';
import '../../widgets/transform/transformed_content_generator.dart';
import 'widgets/filter_editor_item_list.dart';
import 'widgets/image_with_filters.dart';

/// The `FilterEditor` widget allows users to editing images with painting tools.
///
/// You can create a `FilterEditor` using one of the factory methods provided:
/// - `FilterEditor.file`: Loads an image from a file.
/// - `FilterEditor.asset`: Loads an image from an asset.
/// - `FilterEditor.network`: Loads an image from a network URL.
/// - `FilterEditor.memory`: Loads an image from memory as a `Uint8List`.
/// - `FilterEditor.autoSource`: Automatically selects the source based on provided parameters.
class FilterEditor extends StatefulWidget
    with StandaloneEditor<FilterEditorInitConfigs> {
  @override
  final FilterEditorInitConfigs initConfigs;
  @override
  final EditorImage editorImage;

  /// Constructs a `FilterEditor` widget.
  ///
  /// The [key] parameter is used to provide a key for the widget.
  /// The [editorImage] parameter specifies the image to be edited.
  /// The [initConfigs] parameter specifies the initialization configurations for the editor.
  const FilterEditor._({
    super.key,
    required this.editorImage,
    required this.initConfigs,
  });

  /// Constructs a `FilterEditor` widget with image data loaded from memory.
  factory FilterEditor.memory(
    Uint8List byteArray, {
    Key? key,
    required FilterEditorInitConfigs initConfigs,
  }) {
    return FilterEditor._(
      key: key,
      editorImage: EditorImage(byteArray: byteArray),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `FilterEditor` widget with an image loaded from a file.
  factory FilterEditor.file(
    File file, {
    Key? key,
    required FilterEditorInitConfigs initConfigs,
  }) {
    return FilterEditor._(
      key: key,
      editorImage: EditorImage(file: file),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `FilterEditor` widget with an image loaded from an asset.
  factory FilterEditor.asset(
    String assetPath, {
    Key? key,
    required FilterEditorInitConfigs initConfigs,
  }) {
    return FilterEditor._(
      key: key,
      editorImage: EditorImage(assetPath: assetPath),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `FilterEditor` widget with an image loaded from a network URL.
  factory FilterEditor.network(
    String networkUrl, {
    Key? key,
    required FilterEditorInitConfigs initConfigs,
  }) {
    return FilterEditor._(
      key: key,
      editorImage: EditorImage(networkUrl: networkUrl),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `FilterEditor` widget with an image loaded automatically based on the provided source.
  ///
  /// Either [byteArray], [file], [networkUrl], or [assetPath] must be provided.
  factory FilterEditor.autoSource({
    Key? key,
    required FilterEditorInitConfigs initConfigs,
    Uint8List? byteArray,
    File? file,
    String? assetPath,
    String? networkUrl,
  }) {
    if (byteArray != null) {
      return FilterEditor.memory(
        byteArray,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (file != null) {
      return FilterEditor.file(
        file,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (networkUrl != null) {
      return FilterEditor.network(
        networkUrl,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (assetPath != null) {
      return FilterEditor.asset(
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
  createState() => FilterEditorState();
}

/// The state class for the `FilterEditor` widget.
class FilterEditorState extends State<FilterEditor>
    with
        ImageEditorConvertedConfigs,
        StandaloneEditorState<FilterEditor, FilterEditorInitConfigs> {
  /// Manages the capturing a screenshot of the image.
  ContentRecorderController screenshotCtrl = ContentRecorderController();

  /// Update the image with the applied filter and the slider value.
  late final StreamController _uiFilterStream;

  /// The selected filter.
  ColorFilterGenerator selectedFilter = PresetFilters.none;

  /// Represents the dimensions of the body.
  Size _bodySize = Size.zero;

  /// The opacity of the selected filter.
  double filterOpacity = 1;

  /// Indicates it create a screenshot or not.
  bool _createScreenshot = false;

  /// The position in the history of screenshots. This is used to track the
  /// current position in the list of screenshots.
  int _historyPosition = 0;

  /// The pixel ratio of the image.
  double? _pixelRatio;

  /// A list of captured screenshots. Each element in the list represents the
  /// state of a screenshot captured by the isolate.
  final List<IsolateCaptureState> _screenshots = [];

  @override
  void initState() {
    _uiFilterStream = StreamController.broadcast();
    super.initState();
  }

  @override
  void dispose() {
    _uiFilterStream.close();
    screenshotCtrl.destroy();
    super.dispose();
  }

  /// Closes the editor without applying changes.
  void close() {
    if (initConfigs.onCloseEditor == null) {
      Navigator.pop(context);
    } else {
      initConfigs.onCloseEditor!.call();
    }
  }

  /// Handles the "Done" action, either by applying changes or closing the editor.
  void done() async {
    if (_createScreenshot) return;
    initConfigs.onImageEditingStarted?.call();

    if (widget.initConfigs.convertToUint8List) {
      _createScreenshot = true;
      LoadingDialog loading = LoadingDialog()
        ..show(
          context,
          configs: configs,
          theme: theme,
          message: i18n.filterEditor.applyFilterDialogMsg,
        );
      if (_pixelRatio == null) await _setPixelRatio();
      Uint8List? bytes = await screenshotCtrl.getFinalScreenshot(
        pixelRatio: _pixelRatio,
        configs: configs,
        backgroundScreenshot:
            _historyPosition > 0 ? _screenshots[_historyPosition - 1] : null,
        originalImageBytes: _historyPosition > 0
            ? null
            : await widget.editorImage.safeByteArray,
      );

      _createScreenshot = false;
      if (mounted) {
        loading.hide(context);

        await initConfigs.onImageEditingComplete
            ?.call(bytes ?? Uint8List.fromList([]));

        initConfigs.onCloseEditor?.call();
      }
    } else {
      FilterStateHistory filter = FilterStateHistory(
        filter: selectedFilter,
        opacity: filterOpacity,
      );
      Navigator.pop(context, filter);
    }
  }

  Future<void> _setPixelRatio() async {
    _pixelRatio ??= (await decodeImageInfos(
      bytes: await widget.editorImage.safeByteArray,
      screenSize: _bodySize,
    ))
        .pixelRatio;
  }

  /// Takes a screenshot of the current editor state.
  void _takeScreenshot() async {
    if (!widget.initConfigs.convertToUint8List) return;

    await _setPixelRatio();
    // Capture the screenshot in a post-frame callback to ensure the UI is fully rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _historyPosition++;
      screenshotCtrl.isolateCaptureImage(
        configs: configs,
        pixelRatio: _pixelRatio,
        screenshots: _screenshots,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme.copyWith(
          tooltipTheme: theme.tooltipTheme.copyWith(preferBelow: true)),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: imageEditorTheme.uiOverlayStyle,
        child: Scaffold(
          backgroundColor: imageEditorTheme.filterEditor.background,
          appBar: _buildAppBar(),
          body: _buildBody(),
          bottomNavigationBar: _buildBottomNavBar(),
        ),
      ),
    );
  }

  /// Builds the app bar for the filter editor.
  PreferredSizeWidget _buildAppBar() {
    return customWidgets.appBarFilterEditor ??
        AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: imageEditorTheme.filterEditor.appBarBackgroundColor,
          foregroundColor: imageEditorTheme.filterEditor.appBarForegroundColor,
          actions: [
            IconButton(
              tooltip: i18n.filterEditor.back,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: Icon(icons.backButton),
              onPressed: close,
            ),
            const Spacer(),
            IconButton(
              tooltip: i18n.filterEditor.done,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: Icon(icons.applyChanges),
              iconSize: 28,
              onPressed: done,
            ),
          ],
        );
  }

  /// Builds the main content area of the editor.
  Widget _buildBody() {
    return LayoutBuilder(builder: (context, constraints) {
      _bodySize = constraints.biggest;
      return ContentRecorder(
        controller: screenshotCtrl,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            Hero(
              tag: heroTag,
              createRectTween: (begin, end) =>
                  RectTween(begin: begin, end: end),
              child: TransformedContentGenerator(
                configs: configs,
                transformConfigs: transformConfigs ?? TransformConfigs.empty(),
                child: StreamBuilder(
                    stream: _uiFilterStream.stream,
                    builder: (context, snapshot) {
                      return ImageWithFilters(
                        width: getMinimumSize(mainImageSize, _bodySize).width,
                        height: getMinimumSize(mainImageSize, _bodySize).height,
                        designMode: designMode,
                        image: editorImage,
                        filters: [
                          ...appliedFilters,
                          FilterStateHistory(
                            filter: selectedFilter,
                            opacity: filterOpacity,
                          ),
                        ],
                        blurFactor: appliedBlurFactor,
                      );
                    }),
              ),
            ),
            if (filterEditorConfigs.showLayers && layers != null)
              LayerStack(
                transformHelper: TransformHelper(
                  mainBodySize: getMinimumSize(mainBodySize, _bodySize),
                  mainImageSize: getMinimumSize(mainImageSize, _bodySize),
                  editorBodySize: _bodySize,
                  transformConfigs: transformConfigs,
                ),
                configs: configs,
                layers: layers!,
                clipBehavior: Clip.none,
              ),
          ],
        ),
      );
    });
  }

  /// Builds the bottom navigation bar with filter options.
  Widget _buildBottomNavBar() {
    return SafeArea(
      child: Container(
        color: imageEditorTheme.filterEditor.background,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: StreamBuilder(
                  stream: _uiFilterStream.stream,
                  builder: (context, snapshot) {
                    return SizedBox(
                      height: 40,
                      child: selectedFilter == PresetFilters.none
                          ? null
                          : Slider(
                              min: 0,
                              max: 1,
                              divisions: 100,
                              value: filterOpacity,
                              onChanged: (value) {
                                filterOpacity = value;
                                _uiFilterStream.add(null);
                                onUpdateUI?.call();
                              },
                              onChangeEnd: (value) {
                                _takeScreenshot();
                              },
                            ),
                    );
                  }),
            ),
            FilterEditorItemList(
              mainBodySize: getMinimumSize(mainBodySize, _bodySize),
              mainImageSize: getMinimumSize(mainImageSize, _bodySize),
              byteArray: editorImage.byteArray,
              file: editorImage.file,
              assetPath: editorImage.assetPath,
              networkUrl: editorImage.networkUrl,
              activeFilters: appliedFilters,
              blurFactor: appliedBlurFactor,
              configs: configs,
              transformConfigs: transformConfigs,
              selectedFilter: selectedFilter,
              onSelectFilter: (filter) {
                selectedFilter = filter;
                _uiFilterStream.add(null);
                onUpdateUI?.call();
                _takeScreenshot();
              },
            ),
          ],
        ),
      ),
    );
  }
}
